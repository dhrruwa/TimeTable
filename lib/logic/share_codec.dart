import 'dart:convert';
import 'dart:io';

import '../models/period_models.dart';

/// Encodes/decodes an entire [Timetable] into a self-contained share URL — the
/// link itself carries ALL the data (gzip + base64url in the URL fragment), so
/// sharing works with no server and fully offline.
///
/// Link shape: `https://<host>/t#d=<payload>`  (also accepts the custom scheme
/// `classtimetable://import#d=<payload>`). The payload lives in the URL
/// fragment so static hosts / chat apps never strip or log it.
class ShareCodec {
  ShareCodec._();

  /// Public landing host (a free GitHub Pages site can serve the store-redirect
  /// page). The app also registers this host for deep links.
  static const webHost = 'https://dhrruwa.github.io/TimeTable';
  static const scheme = 'classtimetable';

  /// Builds a shareable https link containing the whole timetable.
  static String encode(Timetable timetable) {
    final json = utf8.encode(timetable.toJsonString());
    final gz = GZipCodec(level: 9).encode(json);
    final payload = base64Url.encode(gz).replaceAll('=', '');
    return '$webHost/t#d=$payload';
  }

  /// Tries to extract a [Timetable] from any shared string (full URL, custom
  /// scheme, or a bare payload). Returns null if it isn't a timetable link.
  static Timetable? tryDecode(String input) {
    try {
      final payload = _extractPayload(input.trim());
      if (payload == null || payload.isEmpty) return null;
      final normalized = _restorePadding(payload);
      final gz = base64Url.decode(normalized);
      final json = utf8.decode(GZipCodec().decode(gz));
      return Timetable.fromJsonString(json);
    } catch (_) {
      return null;
    }
  }

  /// True if the string looks like one of our share links.
  static bool looksLikeShareLink(String input) {
    final s = input.trim();
    return s.contains('#d=') &&
        (s.startsWith(webHost) ||
            s.startsWith('$scheme://') ||
            s.contains('/t#d='));
  }

  static String? _extractPayload(String input) {
    // Prefer the fragment after `#d=`.
    final idx = input.indexOf('#d=');
    if (idx >= 0) return input.substring(idx + 3);
    // Or a query `?d=` / `&d=`.
    final uri = Uri.tryParse(input);
    if (uri != null && uri.queryParameters['d'] != null) {
      return uri.queryParameters['d'];
    }
    // Or treat the whole thing as the payload.
    if (!input.contains('://') && !input.contains(' ')) return input;
    return null;
  }

  static String _restorePadding(String s) {
    final mod = s.length % 4;
    if (mod == 0) return s;
    return s + ('=' * (4 - mod));
  }
}
