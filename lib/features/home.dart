import 'package:flutter/material.dart';

import '../content/levels.dart';
import '../core/audio.dart';
import '../core/responsive.dart';
import '../core/state/scope.dart';
import '../core/theme.dart';
import '../core/widgets/art.dart';
import '../core/widgets/buttons.dart';
import '../core/widgets/glass.dart';
import '../core/widgets/scene.dart';
import '../games/game_shell.dart';
import 'gate.dart';
import 'onboarding.dart';
import 'parents.dart';
import 'rest.dart';
import 'stickers_together.dart';
import 'world_map.dart';

String worldName(BuildContext context, WorldId w) {
  final en = AppScope.of(context).settings.english;
  return switch (w) {
    WorldId.alpha => 'Letters & Sounds',
    WorldId.math => en == 'US' ? 'Math Jungle' : 'Maths Jungle',
    WorldId.shapes => 'Shapes & Patterns',
    WorldId.story => 'Story Tree',
    WorldId.lab => 'Wonder Lab',
    WorldId.move => 'Move & Groove',
  };
}

/// The small white glyph used on each world tile.
class WorldGlyph extends StatelessWidget {
  final WorldId w;
  final double size;
  final Color color;
  const WorldGlyph(this.w, {super.key, required this.size, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    final white = color;
    return switch (w) {
      WorldId.alpha => Text('Aa', style: baloo(size * .4, color: white, height: 1.1)),
      WorldId.math => Text('123', style: baloo(size * .36, color: white, height: 1.1)),
      WorldId.shapes => SizedBox.square(
          dimension: size * .66,
          child: CustomPaint(painter: _ShapesGlyph(color)),
        ),
      WorldId.story => Icon(Icons.menu_book_rounded, color: white, size: size * .6),
      WorldId.lab => Icon(Icons.science_rounded, color: white, size: size * .6),
      WorldId.move => Icon(Icons.directions_run_rounded, color: white, size: size * .62),
    };
  }
}

class _ShapesGlyph extends ViewBoxPainter {
  final Color color;
  _ShapesGlyph(this.color) : super(60, 60);
  @override
  void draw(Canvas c) {
    final p = fill(color);
    c.drawCircle(const Offset(17, 20), 10, p);
    c.drawRRect(RRect.fromLTRBR(33, 10, 52, 29, const Radius.circular(3)), p);
    c.drawPath(Path()..moveTo(30, 34)..lineTo(42, 52)..lineTo(18, 52)..close(), p);
  }
}

class WorldTile extends StatelessWidget {
  final WorldId w;
  final double size;
  const WorldTile(this.w, {super.key, required this.size});
  @override
  Widget build(BuildContext context) {
    final ws = WorldStyle.of(w);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ws.bg,
        borderRadius: BorderRadius.circular(size * .32),
        boxShadow: [BoxShadow(color: ws.d, offset: const Offset(0, 4))],
      ),
      child: WorldGlyph(w, size: size),
    );
  }
}

/// Starts a level (used by Home, the world map and rewards).
void playLevel(BuildContext context, Level level, {bool adventure = false, bool replace = false}) {
  final s = AppScope.read(context);
  if (s.restNow) {
    go(context, const RestScreen(), replace: replace);
    return;
  }
  go(context, GameShell(level: level, adventure: adventure), replace: replace);
}

void continueAdventure(BuildContext context, {bool replace = false}) {
  final s = AppScope.read(context);
  if (s.adventureDone || s.restNow) {
    go(context, const RestScreen(), replace: replace);
    return;
  }
  final w = s.adventureWorlds[s.adventureStep];
  playLevel(context, s.adventureLevel(w), adventure: true, replace: replace);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = AppScope.read(context);
      s.childMode = true;
      Audio.I.musicOn();
      if (s.restNow) {
        go(context, const RestScreen());
      } else {
        Audio.I.say(s.adventureStep == 0 ? 'Ready for today’s adventure?' : 'Welcome back! Let’s keep exploring.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.current;
    if (p == null) return const AgeScreen();
    return Scene(
      bg: C.sky,
      lightStatus: false,
      blobs: const [
        Blob(120, 120, C.gold, right: -20, top: 90),
        Blob(560, 320, C.grass, left: -120, bottom: -200),
        Blob(460, 280, C.grassDark, right: -180, bottom: -210),
      ],
      extras: const [
        Positioned(left: -30, top: 140, child: Cloud(scale: .9)),
        Positioned(right: 40, top: 300, child: Cloud(scale: .7, opacity: .55)),
      ],
      child: Responsive(builder: (context, l) {
        final top = TopBar([
          GlassPill(
            tone: GlassTone.strong,
            padding: const EdgeInsets.only(left: 6, right: 15),
            onTap: () => go(context, const ProfilesScreen()),
            child: Row(children: [
              Explorer(size: 32, color: Color(p.color), hat: p.hat),
              const SizedBox(width: 6),
              Text(p.name, style: baloo(17, color: C.ink)),
            ]),
          ),
          const Spacer(),
          StarPill(p.stars, ink: true),
        ]);
        final adventure = _AdventureCard(large: l.large);
        final worlds = _WorldGrid(columns: l.large || l.twoCol ? 3 : 2, large: l.large);
        final dock = ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: const _Dock());
        final coach = Coach(s.adventureDone ? 'You finished today’s adventure!' : 'Ready for today’s adventure?',
            size: 74, center: true);
        final explore = Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
          child: Text('Explore', style: baloo(16, color: C.ink.withValues(alpha: .8))),
        );
        if (l.twoCol) {
          return Column(children: [
            top,
            const SizedBox(height: 14),
            Expanded(
              child: Row(children: [
                Expanded(
                    flex: 4,
                    child: Center(
                        child: SingleChildScrollView(
                            child: Column(mainAxisSize: MainAxisSize.min, children: [coach, const SizedBox(height: 10), adventure])))),
                const SizedBox(width: 24),
                Expanded(
                    flex: 5,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [explore, worlds]),
                      ),
                    )),
              ]),
            ),
            const SizedBox(height: 12),
            dock,
          ]);
        }
        return Column(children: [
          top,
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
                    coach,
                    const SizedBox(height: 10),
                    adventure,
                    const SizedBox(height: 12),
                    explore,
                    worlds,
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          dock,
        ]);
      }),
    );
  }
}

class _AdventureCard extends StatelessWidget {
  final bool large;
  const _AdventureCard({required this.large});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final step = s.adventureStep;
    final worlds = s.adventureWorlds;
    // Shrink the step dots when there are many steps on a narrow screen.
    final steps0 = worlds.length + 1;
    final sz = large ? 52.0 : (MediaQuery.sizeOf(context).width < 400 && steps0 > 6 ? 36.0 : 44.0);
    Widget dot(int i, Color c, Widget glyph) {
      final done = i < step;
      final cur = i == step;
      return Container(
        width: sz,
        height: sz,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: done || cur ? c : C.ink.withValues(alpha: .12),
          shape: BoxShape.circle,
          boxShadow: cur ? [const BoxShadow(color: Colors.white, spreadRadius: 3), BoxShadow(color: c, spreadRadius: 6)] : null,
        ),
        child: done ? const Icon(Icons.check_rounded, color: Colors.white) : glyph,
      );
    }

    final line = Expanded(
        child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(color: C.ink.withValues(alpha: .15), borderRadius: BorderRadius.circular(2))));
    final steps = <Widget>[];
    for (var i = 0; i < worlds.length; i++) {
      if (i > 0) steps.add(line);
      final w = worlds[i];
      steps.add(dot(
          i,
          WorldStyle.of(w).bg,
          i < step || i == step
              ? WorldGlyph(w, size: sz * .9)
              : WorldGlyph(w, size: sz * .9, color: C.ink.withValues(alpha: .8)),
          ));
    }
    steps
      ..add(line)
      ..add(dot(worlds.length, C.night, const Icon(Icons.nightlight_round, color: Colors.white, size: 20)));

    return GlassPanel(
      tone: GlassTone.strong,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Expanded(child: Text('Today’s adventure', style: baloo(large ? 21 : 18, color: C.ink))),
          Text('about ${s.settings.adventureMinutes} min', style: nunito(13, color: C.ink.withValues(alpha: .7))),
        ]),
        const SizedBox(height: 12),
        Semantics(label: 'Step ${step + 1} of ${worlds.length + 1}', child: Row(children: steps)),
        const SizedBox(height: 14),
        ChunkyButton.text(
          s.adventureDone ? 'Rest time' : (step == 0 ? 'Start' : 'Continue'),
          icon: s.adventureDone ? Icons.nightlight_round : Icons.play_arrow_rounded,
          size: 19,
          onTap: () => continueAdventure(context),
        ),
      ]),
    );
  }
}

class _WorldGrid extends StatelessWidget {
  final int columns;
  final bool large;
  const _WorldGrid({required this.columns, required this.large});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    const ws = WorldId.values;
    for (var i = 0; i < ws.length; i += columns) {
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          for (var j = i; j < i + columns; j++) ...[
            if (j > i) const SizedBox(width: 10),
            Expanded(child: j < ws.length ? _WorldButton(ws[j], large: large) : const SizedBox()),
          ],
        ]),
      ));
    }
    return Column(children: rows);
  }
}

class _WorldButton extends StatelessWidget {
  final WorldId w;
  final bool large;
  const _WorldButton(this.w, {required this.large});

  @override
  Widget build(BuildContext context) {
    final name = worldName(context, w);
    return Semantics(
      button: true,
      label: name,
      child: GestureDetector(
        onTap: () {
          Audio.I.sfx('tap');
          Audio.I.say(name);
          go(context, WorldMapScreen(world: w));
        },
        child: GlassPanel(
          tone: GlassTone.strong,
          padding: EdgeInsets.all(large ? 16 : 9),
          child: large
              ? Column(children: [
                  WorldTile(w, size: 70),
                  const SizedBox(height: 10),
                  Text(name, textAlign: TextAlign.center, maxLines: 2, style: baloo(18, color: C.ink, height: 1.1)),
                ])
              : Row(children: [
                  WorldTile(w, size: 46),
                  const SizedBox(width: 10),
                  Expanded(child: Text(name, maxLines: 2, style: baloo(15, color: C.ink, height: 1.1))),
                ]),
        ),
      ),
    );
  }
}

class _Dock extends StatelessWidget {
  const _Dock();

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData i, String t, VoidCallback? onTap, {bool on = false}) => Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Semantics(
          button: true,
          label: t,
          child: GestureDetector(
            onTap: onTap == null
                ? null
                : () {
                    Audio.I.sfx('tap');
                    onTap();
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: on
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: C.ink.withValues(alpha: .12), blurRadius: 12, offset: const Offset(0, 4))])
                  : null,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(i, color: C.ink, size: 24),
                Text(t, style: baloo(12.5, weight: 700, color: C.ink, height: 1.1)),
              ]),
            ),
          ),
        )));
    return GlassPanel(
      radius: 35,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        btn(Icons.home_rounded, 'Home', () {}, on: true),
        btn(Icons.menu_book_rounded, 'Stickers', () => go(context, const StickerBookScreen())),
        btn(Icons.favorite_rounded, 'Together', () => go(context, const TogetherScreen())),
        btn(Icons.lock_rounded, 'Grown-ups', () => openParents(context)),
      ]),
    );
  }
}

/// Opens the parent area behind the parental gate.
Future<void> openParents(BuildContext context) async {
  if (await passGate(context) && context.mounted) {
    final s = AppScope.read(context);
    s.childMode = false;
    Audio.I.musicOff();
    await go(context, const ParentDashboard());
    s.childMode = true;
  }
}
