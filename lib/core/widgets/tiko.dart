import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../state/scope.dart';
import 'art.dart';

/// Tiko's moods. The painter is original art drawn in code.
enum TikoMood { idle, bob, wave, jump, cheer, sleep, think }

class TikoPainter extends ViewBoxPainter {
  final double blink; // 1 open, 0 closed
  final double wingL, wingR; // degrees
  final bool asleep;
  TikoPainter({this.blink = 1, this.wingL = 0, this.wingR = 0, this.asleep = false}) : super(120, 124);

  @override
  void draw(Canvas c) {
    const wing = Color(0xFF4E3FC9);
    oval(c, 60, 119, 30, 4.5, fill(const Color(0x261F2A44)));
    c.drawPath(Path()..moveTo(28, 34)..lineTo(33, 9)..lineTo(50, 26)..close(), fill(wing));
    c.drawPath(Path()..moveTo(92, 34)..lineTo(87, 9)..lineTo(70, 26)..close(), fill(wing));
    rotated(c, wingL, 20, 58.6, () => oval(c, 20, 74, 10, 22, fill(wing)));
    rotated(c, wingR, 100, 58.6, () => oval(c, 100, 74, 10, 22, fill(wing)));
    oval(c, 60, 66, 42, 46, fill(const Color(0xFF6C5CE7)));
    oval(c, 60, 84, 25, 24, fill(const Color(0xFFFFE8B6)));
    final f = stroke(const Color(0xFFF2C879), 2.2);
    for (final o in const [Offset(50, 82), Offset(62, 82), Offset(56, 92)]) {
      c.drawPath(Path()..moveTo(o.dx, o.dy)..quadraticBezierTo(o.dx + 4, o.dy + 4, o.dx + 8, o.dy), f);
    }
    if (asleep) {
      final s = stroke(const Color(0xFF1F2A44), 4);
      c.drawPath(Path()..moveTo(33, 54)..quadraticBezierTo(44, 63, 55, 54), s);
      c.drawPath(Path()..moveTo(65, 54)..quadraticBezierTo(76, 63, 87, 54), s);
    } else {
      c.save();
      c.translate(0, 52);
      c.scale(1, math.max(.1, blink));
      c.translate(0, -52);
      final w = fill(Colors.white);
      c.drawCircle(const Offset(44, 52), 15, w);
      c.drawCircle(const Offset(76, 52), 15, w);
      c.drawCircle(const Offset(46, 54), 7.5, fill(const Color(0xFF1F2A44)));
      c.drawCircle(const Offset(74, 54), 7.5, fill(const Color(0xFF1F2A44)));
      c.drawCircle(const Offset(48.5, 51), 2.6, w);
      c.drawCircle(const Offset(76.5, 51), 2.6, w);
      c.restore();
    }
    c.drawPath(Path()..moveTo(53, 66)..lineTo(67, 66)..lineTo(60, 76)..close(), fill(const Color(0xFFFF9F1C)));
    c.drawCircle(const Offset(30, 69), 5, fill(const Color(0xFFFF8FAB)));
    c.drawCircle(const Offset(90, 69), 5, fill(const Color(0xFFFF8FAB)));
    oval(c, 48, 111, 8, 4, fill(const Color(0xFFFF9F1C)));
    oval(c, 72, 111, 8, 4, fill(const Color(0xFFFF9F1C)));
  }
}

/// Animated Tiko. Respects reduce-motion (app setting and OS setting).
class Tiko extends StatefulWidget {
  final double size;
  final TikoMood mood;
  const Tiko({super.key, required this.size, this.mood = TikoMood.bob});

  @override
  State<Tiko> createState() => _TikoState();
}

class _TikoState extends State<Tiko> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));

  @override
  void initState() {
    super.initState();
    _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _wave(double t, double period) => math.sin(t * 4200 / period * 2 * math.pi);

  @override
  Widget build(BuildContext context) {
    final still = reduceMotion(context);
    final h = widget.size * 124 / 120;
    return Semantics(
      label: 'Tiko the owl',
      image: true,
      child: SizedBox(
        width: widget.size,
        height: h,
        child: still
            ? CustomPaint(painter: TikoPainter(asleep: widget.mood == TikoMood.sleep))
            : AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  final t = _c.value;
                  final ms = t * 4200;
                  final blinkPhase = t;
                  final blink = (blinkPhase > .94 && blinkPhase < 1) ? (1 - math.sin((blinkPhase - .94) / .06 * math.pi)) : 1.0;
                  double dy = 0, sy = 1, scale = 1, wl = 0, wr = 0;
                  switch (widget.mood) {
                    case TikoMood.bob:
                    case TikoMood.wave:
                    case TikoMood.think:
                      dy = -7 * (0.5 - 0.5 * math.cos(ms / 2600 * 2 * math.pi));
                    case TikoMood.jump:
                    case TikoMood.cheer:
                      final p = (ms % 1100) / 1100;
                      if (p < .4) {
                        dy = -22 * math.sin(p / .4 * math.pi / 2);
                      } else if (p < .8) {
                        dy = -22 * math.cos((p - .4) / .4 * math.pi / 2);
                        sy = 1 - .06 * ((p - .4) / .4);
                      } else {
                        sy = .94 + .06 * ((p - .8) / .2);
                      }
                    case TikoMood.sleep:
                      scale = 1 + .015 * (1 - math.cos(ms / 4000 * 2 * math.pi));
                    case TikoMood.idle:
                      break;
                  }
                  if (widget.mood == TikoMood.cheer) {
                    final f = (_wave(t, 700) + 1) / 2;
                    wr = -40 * f;
                    wl = 40 * f;
                  } else if (widget.mood == TikoMood.wave) {
                    wr = -40 * (_wave(t, 1200) + 1) / 2;
                  }
                  return Transform.translate(
                    offset: Offset(0, dy * widget.size / 120),
                    child: Transform.scale(
                      scaleX: scale,
                      scaleY: scale * sy,
                      alignment: Alignment.bottomCenter,
                      child: CustomPaint(
                        size: Size(widget.size, h),
                        painter: TikoPainter(
                            blink: blink, wingL: wl, wingR: wr, asleep: widget.mood == TikoMood.sleep),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
