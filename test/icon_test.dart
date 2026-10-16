// Renders the app icon from the in-code Tiko art.
// Run: flutter test test/icon_test.dart --dart-define=ICONS=true
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_explorers/core/widgets/tiko.dart';

const run = bool.fromEnvironment('ICONS');

Future<void> render(String path, Color? bg, double owlShare) async {
  const s = 1024.0;
  final rec = ui.PictureRecorder();
  final c = Canvas(rec);
  if (bg != null) c.drawRect(const Rect.fromLTWH(0, 0, s, s), Paint()..color = bg);
  if (bg != null) {
    c.drawCircle(const Offset(150, 860), 330, Paint()..color = const Color(0xFFFFC94D));
    c.drawCircle(const Offset(900, 170), 240, Paint()..color = const Color(0xFFFFC94D));
  }
  final o = s * owlShare;
  c.save();
  c.translate((s - o) / 2, (s - o * 124 / 120) / 2 + o * .02);
  TikoPainter().paint(c, Size(o, o * 124 / 120));
  c.restore();
  final img = await rec.endRecording().toImage(s.toInt(), s.toInt());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(data!.buffer.asUint8List());
}

void main() {
  test('render icons', skip: !run, () async {
    await render('assets/icon/icon.png', const Color(0xFFFFB703), .74);
    await render('assets/icon/icon_foreground.png', null, .5);
  });
}
