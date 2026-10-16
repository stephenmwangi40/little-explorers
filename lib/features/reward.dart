import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../content/levels.dart';
import '../core/audio.dart';
import '../core/state/scope.dart';
import '../core/theme.dart';
import '../core/widgets/art.dart';
import '../core/widgets/buttons.dart';
import '../core/widgets/glass.dart';
import '../core/widgets/scene.dart';
import '../core/widgets/tiko.dart';
import 'home.dart';
import 'rest.dart';
import 'world_map.dart';

/// A predictable reward every time: 3 stars and a sticker.
/// No loot boxes, no random prizes, no timers.
class RewardScreen extends StatefulWidget {
  final Level? level;
  final bool adventure;
  final bool together;
  const RewardScreen({super.key, this.level, this.adventure = false, this.together = false});
  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();

  @override
  void initState() {
    super.initState();
    Audio.I.sfx('reward');
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Audio.I.say(widget.together ? 'You played together. Lovely!' : 'Amazing! Three stars and a new sticker!'));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _keepGoing() {
    final s = AppScope.read(context);
    if (widget.together || widget.level == null) {
      Navigator.pop(context);
      return;
    }
    if (widget.adventure) {
      continueAdventure(context, replace: true);
      return;
    }
    if (s.restNow) {
      go(context, const RestScreen(), replace: true);
      return;
    }
    final lv = widget.level!;
    final list = s.visibleLevels(lv.world);
    final idx = list.indexWhere((l) => l.id == lv.id);
    if (idx >= 0 && idx + 1 < list.length) {
      playLevel(context, list[idx + 1], replace: true);
    } else {
      go(context, WorldMapScreen(world: lv.world), replace: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final still = reduceMotion(context);
    const cols = [C.coral, C.green, C.blue, C.purple, Colors.white, C.red];
    return Scene(
      bg: const Color(0xFFFFC93C),
      lightStatus: false,
      extras: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(painter: _RaysPainter(still ? 0 : _c.value)),
            ),
          ),
        ),
        if (!still)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) => CustomPaint(painter: _ConfettiPainter(_c.value * 40, cols)),
              ),
            ),
          ),
      ],
      child: Column(children: [
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Tiko(size: 130, mood: TikoMood.cheer),
                const SizedBox(height: 10),
                SizedBox(
                  width: 420,
                  child: GlassPanel(
                    tone: GlassTone.strong,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(widget.together ? 'Lovely teamwork!' : 'Amazing!', style: baloo(42, color: C.ink, height: 1)),
                      const SizedBox(height: 6),
                      const Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Icon(Icons.star_rounded, size: 50, color: C.orangeStar),
                        Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Icon(Icons.star_rounded, size: 64, color: C.orangeStar)),
                        Icon(Icons.star_rounded, size: 50, color: C.orangeStar),
                      ]),
                      if (widget.level != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(color: Color(0xFFFFF4D6), shape: BoxShape.circle),
                              child: Pic(widget.level!.sticker, size: 36),
                            ),
                            const SizedBox(width: 12),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('New sticker!', style: baloo(16, color: C.ink)),
                              Text('Added to your sticker book', style: baloo(13, weight: 600, color: C.ink.withValues(alpha: .7))),
                            ]),
                          ]),
                        ),
                      ],
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Row(children: [
            Expanded(
              flex: 10,
              child: ChunkyButton.text('Home',
                  color: Colors.white, shadow: const Color(0x2E1F2A44), textColor: C.ink, onTap: () => goHome(context)),
            ),
            const SizedBox(width: 12),
            Expanded(flex: 14, child: ChunkyButton.text(widget.together ? 'Back' : 'Keep going', onTap: _keepGoing)),
          ]),
        ),
        const SizedBox(height: 6),
      ]),
    );
  }
}

class _RaysPainter extends CustomPainter {
  final double t;
  _RaysPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * .4);
    final r = math.max(size.width, size.height);
    final p = Paint()..color = const Color(0xFFFFD45E);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(t * 2 * math.pi);
    for (var i = 0; i < 12; i++) {
      final a1 = (i * 30 - 7) * math.pi / 180, a2 = (i * 30 + 7) * math.pi / 180;
      canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(r * math.cos(a1), r * math.sin(a1))
            ..lineTo(r * math.cos(a2), r * math.sin(a2))
            ..close(),
          p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RaysPainter o) => o.t != t;
}

class _ConfettiPainter extends CustomPainter {
  final double secs;
  final List<Color> cols;
  _ConfettiPainter(this.secs, this.cols);
  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 22; i++) {
      final dur = 3 + (i % 5) * .6;
      final phase = ((secs + i * .4) % dur) / dur;
      final x = ((i * 47) % 100) / 100 * size.width;
      final y = -20 + phase * (size.height + 40);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(phase * 3 * math.pi);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -8, 10, 16), const Radius.circular(3)),
          Paint()..color = cols[i % cols.length]);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter o) => true;
}
