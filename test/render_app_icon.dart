import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Renders the app logo (timetable-grid mark) to PNG masters for
// flutter_launcher_icons. Run: flutter test test/render_app_icon.dart

const _size = 1024.0;
const _indigoTop = Color(0xFF6A76E4);
const _indigoBottom = Color(0xFF454FB4);
const _amber = Color(0xFFE9B24A);

// Timetable grid: white rounded card, tinted frozen first column, one amber
// "current class" cell, thin grid lines. [scale] insets the mark for the
// Android adaptive safe zone.
void _drawMark(Canvas c, {required double scale}) {
  c.save();
  c.translate(_size / 2, _size / 2);
  c.scale(scale);
  c.translate(-_size / 2, -_size / 2);

  const l = 212.0, t = 212.0, w = 600.0, h = 600.0;
  final card = RRect.fromRectAndRadius(
      const Rect.fromLTWH(l, t, w, h), const Radius.circular(72));

  // soft shadow
  c.drawRRect(
    card.shift(const Offset(0, 14)),
    Paint()
      ..color = const Color(0x2A101340)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
  );

  c.save();
  c.clipRRect(card);
  c.drawRRect(card, Paint()..color = Colors.white);
  // frozen first column
  c.drawRect(
      Rect.fromLTWH(l, t, w / 4, h), Paint()..color = const Color(0xFFEDEFFA));
  // highlighted "current" cell (col 3, row 2)
  c.drawRect(Rect.fromLTWH(l + w / 4 * 2, t + h / 4 * 1, w / 4, h / 4),
      Paint()..color = _amber);
  // grid lines
  final line = Paint()
    ..color = const Color(0xFFC9CEE6)
    ..strokeWidth = 9;
  for (var i = 1; i < 4; i++) {
    c.drawLine(Offset(l + w / 4 * i, t), Offset(l + w / 4 * i, t + h), line);
    c.drawLine(Offset(l, t + h / 4 * i), Offset(l + w, t + h / 4 * i), line);
  }
  c.restore();
  c.restore();
}

Future<void> _render(String path, {required bool background}) async {
  final rec = ui.PictureRecorder();
  final c = Canvas(rec);
  if (background) {
    c.drawRect(
      const Rect.fromLTWH(0, 0, _size, _size),
      Paint()
        ..shader = ui.Gradient.linear(const Offset(0, 0), const Offset(0, _size),
            [_indigoTop, _indigoBottom]),
    );
  }
  _drawMark(c, scale: background ? 1.0 : 0.86);
  final img = await rec.endRecording().toImage(_size.toInt(), _size.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  await File(path).writeAsBytes(bytes!.buffer.asUint8List());
}

void main() {
  test('render app icon masters', () async {
    await _render('assets/icon/app_icon.png', background: true);
    await _render('assets/icon/app_icon_foreground.png', background: false);
    expect(File('assets/icon/app_icon.png').existsSync(), isTrue);
  });
}
