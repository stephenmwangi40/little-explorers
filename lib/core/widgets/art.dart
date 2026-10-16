import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// All illustrations are original and drawn in code (no image assets).
/// Each painter works in the SVG viewBox units of the prototype and is
/// scaled to the widget size.
abstract class ViewBoxPainter extends CustomPainter {
  final double vw, vh;
  ViewBoxPainter(this.vw, this.vh);

  void draw(Canvas c);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final s = math.min(size.width / vw, size.height / vh);
    canvas.translate((size.width - vw * s) / 2, (size.height - vh * s) / 2);
    canvas.scale(s);
    draw(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Paint fill(Color c) => Paint()..color = c;
Paint stroke(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

void oval(Canvas c, double cx, double cy, double rx, double ry, Paint p) =>
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), p);

void rotated(Canvas c, double deg, double cx, double cy, void Function() f) {
  c.save();
  c.translate(cx, cy);
  c.rotate(deg * math.pi / 180);
  c.translate(-cx, -cy);
  f();
  c.restore();
}

// ---------------------------------------------------------------- explorer

class ExplorerPainter extends ViewBoxPainter {
  final Color color;
  final String hat;
  ExplorerPainter(this.color, this.hat) : super(100, 110);

  @override
  void draw(Canvas c) {
    oval(c, 50, 104, 26, 4, fill(const Color(0x261F2A44)));
    c.drawRRect(RRect.fromLTRBR(24, 62, 76, 102, const Radius.circular(20)), fill(color));
    c.drawCircle(const Offset(50, 48), 26, fill(const Color(0xFFF6C9A0)));
    c.drawCircle(const Offset(41, 48), 4, fill(C.ink));
    c.drawCircle(const Offset(59, 48), 4, fill(C.ink));
    c.drawPath(Path()..moveTo(42, 58)..quadraticBezierTo(50, 65, 58, 58), stroke(C.ink, 3));
    c.drawCircle(const Offset(34, 56), 4, fill(const Color(0xFFFF8FAB)));
    c.drawCircle(const Offset(66, 56), 4, fill(const Color(0xFFFF8FAB)));
    switch (hat) {
      case 'cap':
        c.drawArc(Rect.fromCenter(center: const Offset(50, 40), width: 48, height: 44), math.pi, math.pi, true, fill(C.ink));
        c.drawRRect(RRect.fromLTRBR(60, 36, 84, 42, const Radius.circular(3)), fill(C.ink));
      case 'flower':
        final p = fill(const Color(0xFFFF8FAB));
        for (final o in const [Offset(70, 26), Offset(80, 30), Offset(74, 38), Offset(64, 35)]) {
          c.drawCircle(o, 7, p);
        }
        c.drawCircle(const Offset(72, 32), 5, fill(C.gold));
      case 'crown':
        c.drawPath(
            Path()
              ..moveTo(32, 34)
              ..lineTo(38, 18)
              ..lineTo(50, 28)
              ..lineTo(60, 14)
              ..lineTo(70, 28)
              ..lineTo(82, 18)
              ..lineTo(88, 34)
              ..close(),
            fill(C.gold));
      case 'helmet':
        c.drawArc(Rect.fromCircle(center: const Offset(50, 44), radius: 26), math.pi, math.pi, true, fill(C.blue));
        c.drawRRect(RRect.fromLTRBR(44, 20, 56, 28, const Radius.circular(3)), fill(Colors.white));
    }
  }
}

class Explorer extends StatelessWidget {
  final double size;
  final Color color;
  final String hat;
  const Explorer({super.key, required this.size, this.color = C.coral, this.hat = 'cap'});

  @override
  Widget build(BuildContext context) => SizedBox(
      width: size, height: size * 1.1, child: CustomPaint(painter: ExplorerPainter(color, hat)));
}

// ---------------------------------------------------------------- turtle

class TurtlePainter extends ViewBoxPainter {
  TurtlePainter() : super(120, 80);
  @override
  void draw(Canvas c) {
    const leg = Color(0xFFA7E07A);
    oval(c, 60, 74, 40, 4, fill(const Color(0x261F2A44)));
    oval(c, 28, 64, 9, 7, fill(leg));
    oval(c, 86, 64, 9, 7, fill(leg));
    c.drawCircle(const Offset(102, 40), 15, fill(leg));
    c.drawCircle(const Offset(107, 36), 3.5, fill(C.ink));
    c.drawPath(Path()..moveTo(100, 46)..quadraticBezierTo(105, 49, 109, 46), stroke(C.ink, 2.2));
    c.drawArc(Rect.fromCenter(center: const Offset(60, 62), width: 92, height: 84), math.pi, math.pi, true,
        fill(C.greenDark));
    final s = fill(const Color(0xFF5ED394));
    c.drawCircle(const Offset(44, 42), 8, s);
    c.drawCircle(const Offset(66, 34), 8, s);
    c.drawCircle(const Offset(80, 52), 7, s);
    c.drawCircle(const Offset(34, 56), 6, s);
  }
}

// ---------------------------------------------------------------- objects

class ApplePainter extends ViewBoxPainter {
  ApplePainter() : super(100, 100);
  @override
  void draw(Canvas c) {
    final body = Path()
      ..moveTo(50, 30)
      ..cubicTo(42, 22, 20, 22, 16, 44)
      ..cubicTo(12, 66, 28, 90, 42, 90)
      ..cubicTo(46, 90, 48, 88, 50, 88)
      ..cubicTo(52, 88, 54, 90, 58, 90)
      ..cubicTo(72, 90, 88, 66, 84, 44)
      ..cubicTo(80, 22, 58, 22, 50, 30)
      ..close();
    c.drawPath(body, fill(const Color(0xFFE63946)));
    c.drawRRect(RRect.fromLTRBR(47, 12, 53, 32, const Radius.circular(3)), fill(const Color(0xFF6B4226)));
    rotated(c, -25, 64, 18, () => oval(c, 64, 18, 12, 6, fill(C.green)));
    rotated(c, 20, 32, 48, () => oval(c, 32, 48, 5, 9, fill(const Color(0x73FFFFFF))));
  }
}

class OrangePainter extends ViewBoxPainter {
  OrangePainter() : super(60, 60);
  @override
  void draw(Canvas c) {
    c.drawCircle(const Offset(30, 34), 24, fill(C.orangeStar));
    c.drawCircle(const Offset(30, 11), 2.6, fill(const Color(0xFF6B4226)));
    rotated(c, -20, 38, 9, () => oval(c, 38, 9, 8, 4, fill(C.greenDark)));
    c.drawCircle(const Offset(21, 26), 4.5, fill(const Color(0x80FFFFFF)));
  }
}

class PanPainter extends ViewBoxPainter {
  PanPainter() : super(100, 100);
  @override
  void draw(Canvas c) {
    c.drawRRect(RRect.fromLTRBR(58, 44, 98, 55, const Radius.circular(5.5)), fill(const Color(0xFF6B4226)));
    c.drawCircle(const Offset(38, 50), 30, fill(C.muted));
    c.drawCircle(const Offset(38, 50), 23, fill(const Color(0xFF8A96B0)));
    oval(c, 30, 42, 7, 4, fill(const Color(0x66FFFFFF)));
  }
}

class PinPainter extends ViewBoxPainter {
  PinPainter() : super(100, 100);
  @override
  void draw(Canvas c) {
    c.drawLine(const Offset(50, 58), const Offset(50, 94), stroke(const Color(0xFF8A96B0), 5));
    c.drawRRect(RRect.fromLTRBR(34, 40, 66, 58, const Radius.circular(5)), fill(C.red));
    c.drawRRect(RRect.fromLTRBR(40, 12, 60, 42, const Radius.circular(6)), fill(C.red));
    c.drawRRect(RRect.fromLTRBR(30, 8, 70, 20, const Radius.circular(6)), fill(const Color(0xFFC9354F)));
  }
}

class NetPainter extends ViewBoxPainter {
  NetPainter() : super(100, 100);
  @override
  void draw(Canvas c) {
    rotated(c, 40, 62, 56,
        () => c.drawRRect(RRect.fromLTRBR(62, 56, 96, 65, const Radius.circular(4.5)), fill(const Color(0xFF6B4226))));
    c.drawCircle(const Offset(40, 40), 28, stroke(C.blue, 7));
    final s = stroke(C.blue, 2.5)..strokeCap = StrokeCap.butt;
    c.save();
    c.clipPath(Path()..addOval(Rect.fromCircle(center: const Offset(40, 40), radius: 28)));
    for (final l in const [
      [20.0, 30.0, 60.0, 30.0], [18.0, 42.0, 62.0, 42.0], [22.0, 54.0, 58.0, 54.0],
      [30.0, 16.0, 30.0, 64.0], [42.0, 13.0, 42.0, 67.0], [54.0, 18.0, 54.0, 62.0],
    ]) {
      c.drawLine(Offset(l[0], l[1]), Offset(l[2], l[3]), s);
    }
    c.restore();
  }
}

// ---------------------------------------------------------------- shapes

enum ShapeKind { circle, square, triangle, rectangle, star, heart }

extension ShapeKindX on ShapeKind {
  String get label => name;
}

Path shapePath(ShapeKind k) {
  switch (k) {
    case ShapeKind.circle:
      return Path()..addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 38));
    case ShapeKind.square:
      return Path()..addRRect(RRect.fromLTRBR(13, 13, 87, 87, const Radius.circular(10)));
    case ShapeKind.triangle:
      return Path()
        ..moveTo(50, 11)
        ..lineTo(90, 85)
        ..lineTo(10, 85)
        ..close();
    case ShapeKind.rectangle:
      return Path()..addRRect(RRect.fromLTRBR(6, 28, 94, 72, const Radius.circular(8)));
    case ShapeKind.star:
      final p = Path();
      for (var i = 0; i < 10; i++) {
        final r = i.isEven ? 42.0 : 18.0;
        final a = -math.pi / 2 + i * math.pi / 5;
        final o = Offset(50 + r * math.cos(a), 54 + r * math.sin(a));
        i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
      }
      return p..close();
    case ShapeKind.heart:
      return Path()
        ..moveTo(50, 86)
        ..cubicTo(20, 66, 8, 48, 14, 32)
        ..cubicTo(20, 16, 42, 14, 50, 30)
        ..cubicTo(58, 14, 80, 16, 86, 32)
        ..cubicTo(92, 48, 80, 66, 50, 86)
        ..close();
  }
}

Path dashPath(Path source, double dash, double gap) {
  final out = Path();
  for (final m in source.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      out.addPath(m.extractPath(d, math.min(d + dash, m.length)), Offset.zero);
      d += dash + gap;
    }
  }
  return out;
}

class ShapePainter extends ViewBoxPainter {
  final ShapeKind kind;
  final Color? fillColor;
  final Color? strokeColor;
  final bool dashed;
  final double rotation;
  ShapePainter(this.kind, {this.fillColor, this.strokeColor, this.dashed = false, this.rotation = 0})
      : super(100, 100);

  @override
  void draw(Canvas c) {
    rotated(c, rotation, 50, 50, () {
      final p = shapePath(kind);
      if (fillColor != null) c.drawPath(p, fill(fillColor!));
      if (strokeColor != null) c.drawPath(dashed ? dashPath(p, 10, 8) : p, stroke(strokeColor!, 5));
    });
  }
}

class ShapeArt extends StatelessWidget {
  final ShapeKind kind;
  final double size;
  final Color? color;
  final Color? outline;
  final bool dashed;
  final double rotation;
  const ShapeArt(this.kind,
      {super.key, this.size = 80, this.color, this.outline, this.dashed = false, this.rotation = 0});

  @override
  Widget build(BuildContext context) => SizedBox.square(
      dimension: size,
      child: CustomPaint(
          painter: ShapePainter(kind, fillColor: color, strokeColor: outline, dashed: dashed, rotation: rotation)));
}

// ---------------------------------------------------------------- faces

enum Feeling { happy, sad, sleepy, scared, surprised, cross, proud }

class FacePainter extends ViewBoxPainter {
  final Feeling f;
  FacePainter(this.f) : super(100, 100);
  @override
  void draw(Canvas c) {
    c.drawCircle(const Offset(50, 50), 44, fill(C.gold));
    final s = stroke(C.ink, 5);
    if (f == Feeling.sleepy) {
      c.drawPath(Path()..moveTo(30, 46)..quadraticBezierTo(36, 51, 42, 46), stroke(C.ink, 4));
      c.drawPath(Path()..moveTo(58, 46)..quadraticBezierTo(64, 51, 70, 46), stroke(C.ink, 4));
    } else if (f == Feeling.proud) {
      c.drawPath(Path()..moveTo(30, 46)..quadraticBezierTo(36, 40, 42, 46), stroke(C.ink, 4));
      c.drawPath(Path()..moveTo(58, 46)..quadraticBezierTo(64, 40, 70, 46), stroke(C.ink, 4));
    } else {
      final r = (f == Feeling.scared || f == Feeling.surprised) ? 6.5 : 5.0;
      c.drawCircle(const Offset(36, 44), r, fill(C.ink));
      c.drawCircle(const Offset(64, 44), r, fill(C.ink));
    }
    switch (f) {
      case Feeling.happy:
      case Feeling.proud:
        c.drawPath(Path()..moveTo(34, 62)..quadraticBezierTo(50, 78, 66, 62), s);
      case Feeling.sad:
        c.drawPath(Path()..moveTo(36, 70)..quadraticBezierTo(50, 58, 64, 70), s);
        oval(c, 66, 56, 4, 6, fill(C.blue));
      case Feeling.sleepy:
        c.drawLine(const Offset(40, 66), const Offset(60, 66), s);
      case Feeling.scared:
        c.drawPath(Path()..moveTo(34, 70)..lineTo(40, 66)..lineTo(46, 70)..lineTo(52, 66)..lineTo(58, 70)..lineTo(64, 66), stroke(C.ink, 4));
        c.drawLine(const Offset(28, 32), const Offset(40, 28), stroke(C.ink, 4));
        c.drawLine(const Offset(60, 28), const Offset(72, 32), stroke(C.ink, 4));
      case Feeling.surprised:
        oval(c, 50, 68, 7, 9, fill(C.ink));
        c.drawPath(Path()..moveTo(28, 30)..quadraticBezierTo(36, 24, 44, 30), stroke(C.ink, 4));
        c.drawPath(Path()..moveTo(56, 30)..quadraticBezierTo(64, 24, 72, 30), stroke(C.ink, 4));
      case Feeling.cross:
        c.drawLine(const Offset(38, 68), const Offset(62, 68), s);
        c.drawLine(const Offset(28, 32), const Offset(42, 38), stroke(C.ink, 4));
        c.drawLine(const Offset(72, 32), const Offset(58, 38), stroke(C.ink, 4));
    }
  }
}

// ---------------------------------------------------------------- picture

/// A picture used in games. Built-in painted art for a few keys, and
/// system emoji (rendered on-device, no download) for the larger word bank.
class Pic extends StatelessWidget {
  final String id;
  final double size;
  const Pic(this.id, {super.key, this.size = 64});

  static final _painters = <String, CustomPainter Function()>{
    'apple': ApplePainter.new,
    'orange': OrangePainter.new,
    'pan': PanPainter.new,
    'pin': PinPainter.new,
    'net': NetPainter.new,
    'turtle': TurtlePainter.new,
  };

  @override
  Widget build(BuildContext context) {
    final p = _painters[id];
    if (p != null) return SizedBox.square(dimension: size, child: CustomPaint(painter: p()));
    if (id.startsWith('txt:')) {
      final t = id.substring(4);
      return SizedBox.square(
        dimension: size,
        child: FittedBox(child: Text(t, style: baloo(size * .8, color: C.tiko, height: 1.1))),
      );
    }
    if (id.startsWith('face:')) {
      final f = Feeling.values.byName(id.substring(5));
      return SizedBox.square(dimension: size, child: CustomPaint(painter: FacePainter(f)));
    }
    if (id.startsWith('shape:')) {
      final parts = id.split(':');
      return ShapeArt(ShapeKind.values.byName(parts[1]),
          size: size, color: parts.length > 2 ? Color(int.parse(parts[2], radix: 16)) : C.blue);
    }
    return SizedBox.square(
      dimension: size,
      child: FittedBox(
        child: Text(id, style: TextStyle(fontSize: size * .8, height: 1.1, fontFamily: null)),
      ),
    );
  }
}
