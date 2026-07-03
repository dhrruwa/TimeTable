import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/period_models.dart';
import 'community_repository.dart';

/// Real, shared community backend backed by Supabase (PostgREST + RPC).
///
/// Unlike [IsarCommunityRepository] (a local, per-device mock), this stores
/// published timetables in a single Postgres table every install can read, so
/// discovery/search/join work across different users and devices.
///
/// - Reads (`findMatch`, `search`) hit PostgREST directly and fail *soft*:
///   any network/HTTP error returns null/empty so the UI just shows
///   "no timetable found" instead of crashing when offline.
/// - Writes (`publish`, `join`) go through SECURITY DEFINER RPCs so clients
///   never need direct INSERT/UPDATE rights on the table (RLS = read-only),
///   and `publish` protects a class's row from being overwritten by anyone
///   other than its original creator.
class SupabaseCommunityRepository implements CommunityRepository {
  final http.Client _client;
  final String baseUrl;
  final String anonKey;

  SupabaseCommunityRepository({
    required this.baseUrl,
    required this.anonKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  static const _table = 'community_timetables';
  static const _timeout = Duration(seconds: 20);

  Map<String, String> get _headers => {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
      };

  String get _restBase => '$baseUrl/rest/v1';
  String get _rpcBase => '$baseUrl/rest/v1/rpc';

  CommunityEntry _fromRow(Map<String, dynamic> row) => CommunityEntry(
        timetable: Timetable.fromJsonString(row['json'] as String),
        userCount: (row['user_count'] as num?)?.toInt() ?? 1,
      );

  @override
  Future<CommunityEntry?> findMatch(TimetableMeta meta) async {
    if (!meta.isComplete) return null;
    try {
      final uri = Uri.parse(
        '$_restBase/$_table'
        '?match_key=eq.${Uri.encodeQueryComponent(meta.matchKey)}'
        '&select=json,user_count&limit=1',
      );
      final res = await _client.get(uri, headers: _headers).timeout(_timeout);
      if (res.statusCode != 200) return null;
      final list = jsonDecode(res.body) as List;
      if (list.isEmpty) return null;
      return _fromRow((list.first as Map).cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CommunityEntry>> search({
    String? university,
    String? branch,
    String? semester,
    String? section,
  }) async {
    try {
      final params = <String>[
        'select=json,user_count',
        'order=user_count.desc',
        'limit=50',
      ];
      void ilike(String col, String? v) {
        final q = v?.trim() ?? '';
        if (q.isEmpty) return;
        params.add('$col=ilike.${Uri.encodeQueryComponent('*$q*')}');
      }

      ilike('university', university);
      ilike('branch', branch);
      ilike('semester', semester);
      ilike('section', section);

      final uri = Uri.parse('$_restBase/$_table?${params.join('&')}');
      final res = await _client.get(uri, headers: _headers).timeout(_timeout);
      if (res.statusCode != 200) return const [];
      final list = jsonDecode(res.body) as List;
      return [
        for (final e in list) _fromRow((e as Map).cast<String, dynamic>()),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<CommunityEntry> publish(Timetable timetable) async {
    final m = timetable.meta;
    final row = await _rpc('publish_timetable', {
      'p_match_key': m.matchKey,
      'p_university': m.university,
      'p_branch': m.branch,
      'p_semester': m.semester,
      'p_section': m.section,
      'p_creator_name': m.creatorName,
      'p_creator_id': m.creatorId,
      'p_verified': m.verified,
      'p_updated_at_ms': m.updatedAtMs,
      'p_json': timetable.toJsonString(),
    });
    if (row == null) {
      throw const CommunityException(
        "Couldn't publish to the community. Check your connection and try again.",
      );
    }
    return _fromRow(row);
  }

  @override
  Future<CommunityEntry?> join(String matchKey) async {
    final row = await _rpc('join_timetable', {'p_match_key': matchKey});
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> suggestChange(String matchKey, String note) async {
    // Best-effort; ignored if the backend has no reports table yet.
    await _rpc('report_timetable', {
      'p_match_key': matchKey,
      'p_kind': 'suggestion',
      'p_note': note,
    });
  }

  @override
  Future<void> report(String matchKey, String reason) async {
    await _rpc('report_timetable', {
      'p_match_key': matchKey,
      'p_kind': 'report',
      'p_note': reason,
    });
  }

  /// POSTs to a Postgres function. Returns the single result row as a map, or
  /// null on any failure (non-200 / network / shape mismatch).
  Future<Map<String, dynamic>?> _rpc(
      String fn, Map<String, dynamic> args) async {
    try {
      final res = await _client
          .post(Uri.parse('$_rpcBase/$fn'),
              headers: _headers, body: jsonEncode(args))
          .timeout(_timeout);
      if (res.statusCode != 200 || res.body.isEmpty) return null;
      final decoded = jsonDecode(res.body);
      final obj = decoded is List
          ? (decoded.isEmpty ? null : decoded.first)
          : decoded;
      if (obj is Map) return obj.cast<String, dynamic>();
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}

/// A community failure with a message safe to show to the user.
class CommunityException implements Exception {
  final String message;
  const CommunityException(this.message);
  @override
  String toString() => message;
}
