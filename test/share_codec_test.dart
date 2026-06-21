import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/data/sample_week.dart';
import 'package:timetable/logic/share_codec.dart';
import 'package:timetable/models/period_models.dart';

/// An ID-independent fingerprint of a timetable. The compact share format
/// intentionally drops the random per-row UUIDs and regenerates them on decode
/// (they don't compress, so keeping them overflowed QR codes — see ShareCodec).
/// So a faithful round-trip preserves everything *except* the ids; we compare
/// subjects by name+color and periods by their resolved subject + details.
String _fingerprint(Timetable t) {
  String subjectName(String id) =>
      t.subjects.firstWhere((s) => s.id == id).name;
  return jsonEncode({
    'subjects': [
      for (final s in t.subjects) [s.name, s.color],
    ],
    'config': t.config.toJson(),
    'meta': t.meta.toJson(),
    'week': {
      for (final day in t.week.keys.toList()..sort())
        '$day': [
          for (final p in t.week[day]!)
            [subjectName(p.subjectId), p.room, p.teacher, p.isLab],
        ],
    },
  });
}

void main() {
  test('encode -> link -> decode round-trips the full timetable', () {
    final original = buildSampleTimetable().copyWith(
      meta: const TimetableMeta(
        university: 'REVA University',
        branch: 'CSE',
        semester: '4',
        section: 'A',
        creatorName: 'Aditya',
        verified: true,
      ),
    );

    final link = ShareCodec.encode(original);
    // It's a real URL carrying the data in the fragment.
    expect(link.startsWith('https://'), isTrue);
    expect(link.contains('#d='), isTrue);
    expect(ShareCodec.looksLikeShareLink(link), isTrue);

    final decoded = ShareCodec.tryDecode(link);
    expect(decoded, isNotNull);

    // Everything survives the trip.
    expect(decoded!.meta.university, 'REVA University');
    expect(decoded.meta.branch, 'CSE');
    expect(decoded.meta.semester, '4');
    expect(decoded.meta.section, 'A');
    expect(decoded.meta.creatorName, 'Aditya');
    expect(decoded.meta.verified, isTrue);
    expect(decoded.subjects.length, original.subjects.length);
    expect(decoded.week.length, original.week.length);
    // Everything survives except the deliberately-regenerated ids.
    expect(_fingerprint(decoded), _fingerprint(original));

    // Print the link + size so we can eyeball it.
    // ignore: avoid_print
    print('LINK (${link.length} chars):\n$link');
  });

  test('decode tolerates the custom scheme + extra chat text', () {
    final link = ShareCodec.encode(buildSampleTimetable());
    final payload = link.split('#d=')[1];

    final scheme = 'classtimetable://import#d=$payload';
    expect(ShareCodec.tryDecode(scheme), isNotNull);

    final withText = 'Join our class! $link  see you there';
    expect(ShareCodec.tryDecode(withText.split(' ').firstWhere((w) => w.contains('#d='))), isNotNull);
  });

  test('non-timetable strings decode to null', () {
    expect(ShareCodec.tryDecode('https://google.com'), isNull);
    expect(ShareCodec.tryDecode('hello world'), isNull);
  });
}
