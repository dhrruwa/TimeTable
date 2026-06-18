import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

import '../models/period_models.dart';

/// Encodes/decodes an entire [Timetable] into a self-contained share URL — the
/// link itself carries ALL the data (gzip + base64url in the URL fragment), so
/// sharing works with no server and fully offline.
///
/// The payload uses a COMPACT representation (v2): subjects are referenced by
/// index and the random per-row UUIDs are dropped (regenerated on import). UUIDs
/// don't compress, so keeping them made large/imported timetables overflow a QR
/// code's capacity. The compact form is ~3–4× smaller and fits in a QR again.
///
/// Link shape: `https://<host>/t#d=<payload>`  (also accepts the custom scheme
/// `classtimetable://import#d=<payload>`). The payload lives in the URL
/// fragment so static hosts / chat apps never strip or log it.
class ShareCodec {
  ShareCodec._();

  static const _uuid = Uuid();

  /// Public landing host (a free GitHub Pages site can serve the store-redirect
  /// page). The app also registers this host for deep links.
  static const webHost = 'https://dhrruwa.github.io/TimeTable';
  static const scheme = 'classtimetable';

  /// Builds a shareable https link containing the whole timetable.
  static String encode(Timetable timetable) {
    final json = utf8.encode(jsonEncode(_toCompact(timetable)));
    final gz = GZipCodec(level: 9).encode(json);
    final payload = base64Url.encode(gz).replaceAll('=', '');
    return '$webHost/t#d=$payload';
  }

  /// Tries to extract a [Timetable] from any shared string (full URL, custom
  /// scheme, or a bare payload). Returns null if it isn't a timetable link.
  /// Accepts both the compact (v2) and the legacy full-JSON payloads.
  static Timetable? tryDecode(String input) {
    try {
      final payload = _extractPayload(input.trim());
      if (payload == null || payload.isEmpty) return null;
      final normalized = _restorePadding(payload);
      final gz = base64Url.decode(normalized);
      final json = utf8.decode(GZipCodec().decode(gz));
      final obj = jsonDecode(json);
      if (obj is Map && obj['v'] == 2) {
        return _fromCompact(obj.cast<String, dynamic>());
      }
      // Legacy links: the full Timetable JSON.
      return Timetable.fromJson((obj as Map).cast<String, dynamic>());
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

  // ─── compact (v2) representation ──────────────────────────────────────────

  static Map<String, dynamic> _toCompact(Timetable t) {
    final subjectIndex = <String, int>{};
    final subjects = <List<dynamic>>[];
    for (final s in t.subjects) {
      subjectIndex[s.id] = subjects.length;
      subjects.add([s.name, s.color]);
    }
    final week = <String, List<dynamic>>{};
    t.week.forEach((day, periods) {
      week['$day'] = [
        for (final p in periods)
          [
            subjectIndex[p.subjectId] ?? -1,
            p.room ?? '',
            p.teacher ?? '',
            p.isLab ? 1 : 0,
          ]
      ];
    });
    final m = t.meta;
    final c = t.config;
    return {
      'v': 2,
      'm': [
        m.university,
        m.branch,
        m.semester,
        m.section,
        m.creatorName ?? '',
        m.creatorId ?? '',
        m.verified ? 1 : 0,
        m.updatedAtMs,
      ],
      'c': [
        c.dayStartMin,
        c.classMins,
        c.labMins,
        c.teaAfter,
        c.teaMins,
        c.lunchAfter,
        c.lunchMins,
      ],
      's': subjects,
      'w': week,
    };
  }

  static Timetable _fromCompact(Map<String, dynamic> j) {
    final rawSubs = (j['s'] as List?) ?? const [];
    final subjects = <Subject>[];
    final idByIndex = <int, String>{};
    for (var i = 0; i < rawSubs.length; i++) {
      final l = rawSubs[i] as List;
      final id = _uuid.v4();
      idByIndex[i] = id;
      subjects.add(Subject(
        id: id,
        name: l[0] as String,
        color: (l[1] as num).toInt(),
      ));
    }

    final week = <int, List<Period>>{};
    (j['w'] as Map?)?.forEach((day, periods) {
      week[int.parse(day.toString())] = [
        for (final e in (periods as List))
          Period(
            id: _uuid.v4(),
            subjectId: idByIndex[(e[0] as num).toInt()] ?? '',
            room: _nz(e[1]),
            teacher: _nz(e[2]),
            isLab: (e[3] as num).toInt() == 1,
          )
      ];
    });

    final m = (j['m'] as List?) ?? const [];
    final meta = m.length >= 8
        ? TimetableMeta(
            university: m[0] as String,
            branch: m[1] as String,
            semester: m[2] as String,
            section: m[3] as String,
            creatorName: _nz(m[4]),
            creatorId: _nz(m[5]),
            verified: (m[6] as num).toInt() == 1,
            updatedAtMs: (m[7] as num).toInt(),
          )
        : const TimetableMeta();

    final c = (j['c'] as List?) ?? const [];
    final config = c.length >= 7
        ? TimetableConfig(
            dayStartMin: (c[0] as num).toInt(),
            classMins: (c[1] as num).toInt(),
            labMins: (c[2] as num).toInt(),
            teaAfter: (c[3] as num).toInt(),
            teaMins: (c[4] as num).toInt(),
            lunchAfter: (c[5] as num).toInt(),
            lunchMins: (c[6] as num).toInt(),
          )
        : const TimetableConfig();

    return Timetable(
      subjects: subjects,
      week: week,
      config: config,
      meta: meta,
    );
  }

  static String? _nz(dynamic v) {
    final s = (v ?? '').toString();
    return s.isEmpty ? null : s;
  }

  // ─── payload helpers ──────────────────────────────────────────────────────

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
