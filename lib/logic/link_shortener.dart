import 'dart:async';

import 'package:http/http.dart' as http;

/// Turns the (long, self-contained) timetable share URL into a short link for
/// messaging, and resolves a short link back to the full URL when one is pasted
/// to import. Both operations fail *soft* — sharing/importing always still work
/// with the original long link if the network/service is unavailable.
class LinkShortener {
  LinkShortener._();

  static const _timeout = Duration(seconds: 8);

  /// Returns a shortened URL, or [longUrl] unchanged on any failure.
  static Future<String> shorten(String longUrl) async {
    try {
      final uri = Uri.parse(
          'https://tinyurl.com/api-create.php?url=${Uri.encodeComponent(longUrl)}');
      final res = await http.get(uri).timeout(_timeout);
      final body = res.body.trim();
      if (res.statusCode == 200 &&
          body.startsWith('https://') &&
          body.length < longUrl.length) {
        return body;
      }
    } catch (_) {/* fall through */}
    return longUrl;
  }

  /// Follows a short link's redirect and returns the full target URL (which
  /// carries the timetable in its `#d=` fragment), or null on failure.
  static Future<String?> resolve(String shortUrl) async {
    try {
      final req = http.Request('GET', Uri.parse(shortUrl))
        ..followRedirects = false;
      final res = await http.Client().send(req).timeout(_timeout);
      final location = res.headers['location'];
      if (location != null && location.contains('#d=')) return location;
    } catch (_) {/* fall through */}
    return null;
  }
}
