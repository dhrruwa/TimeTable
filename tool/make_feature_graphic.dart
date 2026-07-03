// Generates the Play Store feature graphic (1024x500) into store_assets/.
// Run: dart run tool/make_feature_graphic.dart
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  const w = 1024, h = 500;
  final canvas = img.Image(width: w, height: h);

  // Vertical brand gradient: indigo -> near-black.
  const top = [0x2A, 0x2E, 0x5A];
  const bot = [0x0B, 0x0D, 0x18];
  for (var y = 0; y < h; y++) {
    final t = y / h;
    final r = (top[0] + (bot[0] - top[0]) * t).round();
    final g = (top[1] + (bot[1] - top[1]) * t).round();
    final b = (top[2] + (bot[2] - top[2]) * t).round();
    for (var x = 0; x < w; x++) {
      canvas.setPixelRgb(x, y, r, g, b);
    }
  }

  // Soft accent glow (indigo) behind the icon.
  final glow = img.ColorRgb8(0x59, 0x65, 0xC8);
  img.fillCircle(canvas, x: 230, y: h ~/ 2, radius: 210, color: glow, antialias: true);

  // App icon, rounded already, at left.
  final icon = img.decodeImage(File('store_assets/play_icon_512.png').readAsBytesSync())!;
  final iconR = img.copyResize(icon, width: 300, height: 300);
  img.compositeImage(canvas, iconR, dstX: 80, dstY: (h - 300) ~/ 2);

  // Text block on the right.
  final white = img.ColorRgb8(255, 255, 255);
  final sub = img.ColorRgb8(200, 205, 235);
  final dim = img.ColorRgb8(160, 165, 195);
  img.drawString(canvas, 'ClassSync', font: img.arial48, x: 450, y: 155, color: white);
  img.drawString(canvas, 'Timetable  -  Attendance  -  Widgets',
      font: img.arial24, x: 452, y: 225, color: sub);
  img.drawString(canvas, '10 themed wallpaper packs.  No ads.  No account.',
      font: img.arial24, x: 452, y: 262, color: dim);

  File('store_assets/play_feature_graphic.png')
      .writeAsBytesSync(img.encodePng(canvas));
  stdout.writeln('wrote store_assets/play_feature_graphic.png (1024x500)');
}
