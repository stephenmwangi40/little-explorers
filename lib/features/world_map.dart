import 'package:flutter/material.dart';

import '../content/levels.dart';
import '../core/audio.dart';
import '../core/responsive.dart';
import '../core/state/scope.dart';
import '../core/theme.dart';
import '../core/widgets/buttons.dart';
import '../core/widgets/glass.dart';
import '../core/widgets/scene.dart';
import '../core/widgets/tiko.dart';
import 'home.dart';

/// Learning world map: a winding trail of levels (level 1 at the bottom).
/// Levels open in order. Locked levels show a padlock, never a paywall.
class WorldMapScreen extends StatefulWidget {
  final WorldId world;
  const WorldMapScreen({super.key, required this.world});
  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  static const offsets = [.08, .44, .70, .44, .12, .40];
  final _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final ws = WorldStyle.of(widget.world);
    final levels = allLevels[widget.world]!;
    final cur = s.currentLevel(widget.world);
    final stars = s.doneCount(widget.world) * 3;
    return Scene(
      bg: ws.bg,
      blobs: [
        Blob(320, 320, ws.b1, left: -150, top: 180),
        Blob(280, 280, ws.b1, right: -130, bottom: 120),
        Blob(120, 120, ws.b2, right: 30, top: 110),
      ],
      child: Responsive(builder: (context, l) {
        return Column(children: [
          TopBar([
            GlassIconButton(
                icon: Icons.arrow_back_ios_new_rounded, label: 'Back', onTap: () => Navigator.of(context).maybePop()),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: GlassPill(
                    child: Text(worldName(context, widget.world),
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: baloo(16, color: Colors.white))),
              ),
            ),
            StarPill(stars),
          ]),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: LayoutBuilder(builder: (context, c) {
                  return ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: levels.length,
                    itemBuilder: (context, i) => _row(context, levels[i], i, c.maxWidth, cur, ws),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: GlassPanel(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text('Level ${cur.number}', style: baloo(14, weight: 700, color: Colors.white.withValues(alpha: .85))),
                    Text(cur.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: baloo(20, color: Colors.white, height: 1.1)),
                  ]),
                ),
                ChunkyButton.text('Play',
                    color: Colors.white,
                    shadow: const Color(0x331F2A44),
                    textColor: ws.d,
                    onTap: () => playLevel(context, cur)),
              ]),
            ),
          ),
        ]);
      }),
    );
  }

  Widget _row(BuildContext context, Level lv, int i, double width, Level cur, WorldStyle ws) {
    final s = AppScope.read(context);
    final done = s.isDone(lv);
    final open = s.isOpen(lv);
    final isCur = lv.id == cur.id;
    final x = offsets[i % offsets.length];
    const d = 64.0;
    final left = x * (width - d - 20);
    final labelRight = x >= .55;
    Widget node;
    if (isCur) {
      node = _Ring(
        child: ChunkyButton(
          onTap: () => playLevel(context, lv),
          color: Colors.white,
          shadow: const Color(0x2E1F2A44),
          width: d,
          height: d,
          radius: d / 2,
          padding: EdgeInsets.zero,
          semantics: 'Level ${lv.number}, ${lv.title}. Play',
          child: Text('${lv.number}', style: baloo(26, color: ws.d, height: 1.1)),
        ),
      );
    } else if (done || open) {
      node = Semantics(
        button: true,
        label: 'Level ${lv.number}, ${lv.title}${done ? ', 3 stars' : ''}',
        child: GestureDetector(
          onTap: () {
            Audio.I.sfx('tap');
            playLevel(context, lv);
          },
          child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
            GlassPanel(
                radius: d / 2,
                width: d,
                height: d,
                child: Center(child: Text('${lv.number}', style: baloo(26, color: Colors.white, height: 1.1)))),
            if (done)
              const Positioned(
                bottom: -12,
                child: Row(children: [
                  Icon(Icons.star_rounded, size: 16, color: C.gold),
                  Icon(Icons.star_rounded, size: 16, color: C.gold),
                  Icon(Icons.star_rounded, size: 16, color: C.gold),
                ]),
              ),
          ]),
        ),
      );
    } else {
      node = Semantics(
        label: 'Level ${lv.number}, locked',
        child: GestureDetector(
          onTap: () => Audio.I.say(s.isInPlan(lv) ? 'Finish level ${lv.number - 1} first!' : 'This one opens later!'),
          child: Opacity(
            opacity: .7,
            child: GlassPanel(
                radius: d / 2, width: d, height: d, child: const Icon(Icons.lock_rounded, color: Colors.white, size: 24)),
          ),
        ),
      );
    }
    final label = Text(lv.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: baloo(14, color: Colors.white.withValues(alpha: open || done ? 1 : .75)));
    return SizedBox(
      height: 92,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(left: 10 + left, top: 10, child: node),
        if (labelRight)
          Positioned(right: width - left - 4, top: 30, width: left - 14, child: Align(alignment: Alignment.centerRight, child: label))
        else
          Positioned(left: left + d + 22, top: 30, right: 8, child: label),
        if (isCur && x > .2)
          Positioned(
              left: labelRight ? left + d + 26 : left - 56, top: 4, child: const Tiko(size: 52, mood: TikoMood.bob)),
      ]),
    );
  }
}

/// Pulsing ring around the current level.
class _Ring extends StatefulWidget {
  final Widget child;
  const _Ring({required this.child});
  @override
  State<_Ring> createState() => _RingState();
}

class _RingState extends State<_Ring> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        if (!reduceMotion(context))
          AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Transform.scale(
              scale: 1 + .35 * _c.value,
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: .9 * (1 - _c.value)), width: 4)),
              ),
            ),
          ),
        widget.child,
      ]);
}
