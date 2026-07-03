import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Renders the app logo to PNG masters for flutter_launcher_icons.
// Run: flutter test test/render_app_icon.dart
//
// Design: an "agenda / class schedule" mark — three white pill rows (classes),
// each tagged with a subject-colour dot, on the app's indigo gradient. Reads
// clearly down to launcher size.

const _size = 1024.0;

// App palette.
const _indigoTop = Color(0xFF6A76E4);
const _indigoBottom = Color(0xFF454FB4);
const _teal = Color(0xFF3FB6A2);
const _amber = Color(0xFFE9B24A);
const _rose = Color(0xFFE0748C);

void _drawMark(Canvas canvas, {required double scale}) {
  canvas.save();
  // Scale about the centre (foreground icons need a safe-zone inset).
  canvas.translate(_size / 2, _size / 2);
  canvas.scale(scale);
  canvas.translate(-_size / 2, -_size / 2);

  const barW = 486.0;
  const barH = 150.0;
  const gap = 70.0;
  const barX = 336.0;
  const dotCx = 268.0;
  const dotR = 40.0;

  const totalH = barH * 3 + gap * 2; // 590
  const startY = (_size - totalH) / 2; // 217

  final rows = [
    (_teal, false),
    (_amber, true), // highlighted "current" class
    (_rose, false),
  ];

  for (var i = 0; i < rows.length; i++) {
    final top = startY + i * (barH + gap);
    final cy = top + barH / 2;
    final (dotColor, highlighted) = rows[i];

    // Soft drop shadow for depth.
    final shadow = Paint()
      ..color = const Color(0x33101340)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, top + 10, barW, barH), const Radius.circular(75)),
      shadow,
    );

    // The pill (class row).
    final bar = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, top, barW, barH), const Radius.circular(75)),
      bar,
    );

    // A shorter accent underline on the highlighted row to hint "in progress".
    if (highlighted) {
      final underline = Paint()..color = _indigoBottom.withValues(alpha: 0.16);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(barX + 150, cy + 18, 210, 26),
            const Radius.circular(13)),
        underline,
      );
      final topline = Paint()..color = _amber.withValues(alpha: 0.9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(barX + 150, cy - 44, 150, 26),
            const Radius.circular(13)),
        topline,
      );
    } else {
      final line = Paint()..color = _indigoBottom.withValues(alpha: 0.14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(barX + 150, cy - 13, 240, 26),
            const Radius.circular(13)),
        line,
      );
    }

    // Subject-colour dot.
    canvas.drawCircle(Offset(dotCx, cy), dotR, Paint()..color = dotColor);
  }

  canvas.restore();
}

Future<void> _render(String path, {required bool background}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final rect = const Rect.fromLTWH(0, 0, _size, _size);

  if (background) {
    final bg = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(0, _size),
        [_indigoTop, _indigoBottom],
      );
    canvas.drawRect(rect, bg);
  }

  _drawMark(canvas, scale: background ? 1.0 : 0.72);

  final picture = recorder.endRecording();
  final image = await picture.toImage(_size.toInt(), _size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(path).writeAsBytes(bytes!.buffer.asUint8List());
}

void main() {
  test('render app icon masters', () async {
    // Full-bleed master (iOS + legacy Android): indigo bg + mark.
    await _render('assets/icon/app_icon.png', background: true);
    // Transparent foreground (Android adaptive): mark only, safe-zone inset.
    await _render('assets/icon/app_icon_foreground.png', background: false);
    expect(File('assets/icon/app_icon.png').existsSync(), isTrue);
    expect(File('assets/icon/app_icon_foreground.png').existsSync(), isTrue);
  });
}
