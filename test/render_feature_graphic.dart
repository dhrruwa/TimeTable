import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// flutter test uses the block-glyph "Ahem" font by default, so real text must
// be loaded explicitly or it renders as solid boxes.
Future<ByteData> _fontData(String path) async {
  final bytes = await File(path).readAsBytes();
  return ByteData.view(Uint8List.fromList(bytes).buffer);
}

// Renders the Play Store feature graphic (1024x500).
// Run: flutter test test/render_feature_graphic.dart -> play/feature_graphic.png

const _w = 1024.0, _h = 500.0;
const _indigoTop = Color(0xFF6A76E4);
const _indigoBottom = Color(0xFF454FB4);
const _amber = Color(0xFFE9B24A);

void _grid(Canvas c, Offset center, double size) {
  final l = center.dx - size / 2, t = center.dy - size / 2;
  final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(l, t, size, size), Radius.circular(size * 0.12));
  c.drawRRect(card.shift(const Offset(0, 6)),
      Paint()
        ..color = const Color(0x33101340)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16));
  c.save();
  c.clipRRect(card);
  c.drawRRect(card, Paint()..color = Colors.white);
  c.drawRect(Rect.fromLTWH(l, t, size / 4, size),
      Paint()..color = const Color(0xFFEDEFFA));
  c.drawRect(Rect.fromLTWH(l + size / 4 * 2, t + size / 4, size / 4, size / 4),
      Paint()..color = _amber);
  final line = Paint()
    ..color = const Color(0xFFC9CEE6)
    ..strokeWidth = size * 0.014;
  for (var i = 1; i < 4; i++) {
    c.drawLine(Offset(l + size / 4 * i, t), Offset(l + size / 4 * i, t + size), line);
    c.drawLine(Offset(l, t + size / 4 * i), Offset(l + size, t + size / 4 * i), line);
  }
  c.restore();
}

void _text(Canvas c, String s, Offset at, double size, FontWeight w, Color col) {
  final tp = TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(
          color: col,
          fontSize: size,
          fontWeight: w,
          letterSpacing: -0.5,
          fontFamily: 'Brand'),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, at);
}

void main() {
  test('render feature graphic', () async {
    final loader = FontLoader('Brand')
      ..addFont(_fontData('/System/Library/Fonts/SFNS.ttf'));
    await loader.load();

    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    c.drawRect(
      const Rect.fromLTWH(0, 0, _w, _h),
      Paint()
        ..shader = ui.Gradient.linear(
            const Offset(0, 0), const Offset(_w, _h), [_indigoTop, _indigoBottom]),
    );
    _grid(c, const Offset(230, 250), 300);
    _text(c, 'Timetable', const Offset(430, 150), 92, FontWeight.w800, Colors.white);
    _text(c, 'Your whole class, one timetable.', const Offset(434, 268), 34,
        FontWeight.w500, Colors.white.withValues(alpha: 0.92));
    _text(c, 'Live widget · AI import · share by QR', const Offset(434, 322),
        26, FontWeight.w500, Colors.white.withValues(alpha: 0.75));

    final img = await rec.endRecording().toImage(_w.toInt(), _h.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory('play').createSync(recursive: true);
    await File('play/feature_graphic.png').writeAsBytes(bytes!.buffer.asUint8List());
    expect(File('play/feature_graphic.png').existsSync(), isTrue);
  });
}
