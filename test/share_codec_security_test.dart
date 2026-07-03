import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/logic/share_codec.dart';
import 'package:timetable/models/period_models.dart';

void main() {
  test('normal share link still round-trips after hardening', () {
    const t = Timetable(
      subjects: [Subject(id: 'a', name: 'Math', color: 0xFF5965C8)],
      week: {
        1: [Period(id: '1', subjectId: 'a', room: 'R1', teacher: 'Rao')]
      },
      meta: TimetableMeta(
          university: 'REVA', branch: 'CSE', semester: '4', section: 'A'),
    );
    final link = ShareCodec.encode(t);
    final decoded = ShareCodec.tryDecode(link);
    expect(decoded?.subjects.single.name, 'Math');
  });

  test('decompression bomb is rejected without crashing', () {
    // ~5 MB of highly compressible data → a tiny gzip payload that would inflate
    // far past the decoder cap. Must return null (not OOM).
    final huge = utf8.encode('A' * (5 * 1024 * 1024));
    final gz = gzip.encode(huge);
    expect(gz.length, lessThan(64 * 1024)); // small compressed
    final bombLink =
        'https://dhrruwa.github.io/TimeTable/t#d=${base64Url.encode(gz).replaceAll('=', '')}';

    final decoded = ShareCodec.tryDecode(bombLink);
    expect(decoded, isNull); // safely refused
  });

  test('oversize encoded payload is rejected before decoding', () {
    final bombLink = 'https://dhrruwa.github.io/TimeTable/t#d=${'A' * (128 * 1024)}';
    expect(ShareCodec.tryDecode(bombLink), isNull);
  });
}
