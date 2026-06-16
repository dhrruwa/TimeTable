import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Calls the Supabase Edge Function (`extract-timetable`) which proxies Google
/// Gemini. The Gemini API key lives ONLY in the function's secret env — never in
/// this app. The anon key below is the project's PUBLIC key and is safe to ship.
///
/// Configure both values at build time, e.g.:
///   flutter run --dart-define=SUPABASE_URL=https://ocfdldqamonkndutuevd.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
class TimetableImportService {
  final http.Client _client;
  final String functionUrl;
  final String anonKey;

  TimetableImportService({
    http.Client? client,
    String? functionUrl,
    String? anonKey,
  })  : _client = client ?? http.Client(),
        functionUrl = functionUrl ?? _defaultFunctionUrl,
        anonKey = anonKey ?? _defaultAnonKey;

  static const _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ocfdldqamonkndutuevd.supabase.co',
  );
  static const _defaultAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const _defaultFunctionUrl =
      '$_supabaseUrl/functions/v1/extract-timetable';

  /// Sends the file bytes to the Edge Function and returns the parsed timetable
  /// JSON map. Throws an [ImportException] with a user-facing [ImportException.message]
  /// on any failure.
  Future<Map<String, dynamic>> extract({
    required List<int> bytes,
    required String mime,
  }) async {
    if (anonKey.isEmpty) {
      throw const ImportException(
        'Import isn’t configured. Missing SUPABASE_ANON_KEY.',
      );
    }

    final body = jsonEncode({'mime': mime, 'data': base64Encode(bytes)});

    http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse(functionUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $anonKey',
              'apikey': anonKey,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 120));
    } on TimeoutException {
      throw const ImportException(
        'The server took too long to respond. Try a clearer, tighter photo of '
        'just the timetable grid, then try again.',
      );
    } catch (_) {
      throw const ImportException(
        'Couldn’t reach the server. Check your connection and try again.',
      );
    }

    if (res.statusCode == 200) {
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
        throw const ImportException('Unexpected response from the server.');
      } on FormatException {
        throw const ImportException('Unexpected response from the server.');
      }
    }

    // Non-200: the function returns {error, message} — surface message if present.
    String? message;
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map && decoded['message'] is String) {
        message = decoded['message'] as String;
      }
    } catch (_) {/* fall through to status-based message */}

    throw ImportException(message ?? _messageForStatus(res.statusCode));
  }

  String _messageForStatus(int status) {
    switch (status) {
      case 429:
        return 'Too many requests right now. Try again in a minute.';
      case 413:
        return 'That file is too large. Try a smaller image or PDF.';
      case 415:
        return 'Unsupported file. Use a JPG, PNG, or PDF.';
      case 422:
        return 'Couldn’t read a timetable in that file. Try a clearer photo.';
      default:
        return 'Something went wrong (error $status). Please try again.';
    }
  }

  void dispose() => _client.close();
}

/// A failure with a message safe to show directly to the user.
class ImportException implements Exception {
  final String message;
  const ImportException(this.message);

  @override
  String toString() => message;
}
