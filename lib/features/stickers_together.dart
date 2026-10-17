import 'package:flutter/material.dart';

import '../content/levels.dart';
import '../content/phonics.dart';
import '../core/responsive.dart';
import '../core/state/scope.dart';
import '../core/theme.dart';
import '../core/widgets/art.dart';
import '../core/widgets/buttons.dart';
import '../core/widgets/glass.dart';
import '../core/widgets/scene.dart';
import '../core/widgets/tiko.dart';
import '../content/stories_extra.dart';
import 'home.dart';
import 'reward.dart';

// ---------------------------------------------------------------- sticker book

class StickerBookScreen extends StatelessWidget {
  const StickerBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.current!;
    final total = WorldId.values.fold<int>(0, (a, w) => a + allLevels[w]!.length);
    return Scene(
      bg: C.lab,
      blobs: const [
        Blob(280, 280, Color(0xFF6FB6FF), right: -120, top: 120),
        Blob(220, 220, C.blueDark, left: -100, bottom: 60),
      ],
      child: Responsive(builder: (context, l) {
        final cols = l.large || l.twoCol ? 6 : 4;
        final got = p.stickers.map(levelById).whereType<Level>().toList();
        final slots = ((got.length ~/ cols) + 2) * cols;
        return Column(children: [
          TopBar([
            GlassIconButton(
                icon: Icons.arrow_back_ios_new_rounded, label: 'Back', onTap: () => Navigator.of(context).maybePop()),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: GlassPill(
                    child: Text('My Sticker Book',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: baloo(17, color: Colors.white))),
              ),
            ),
            GlassPill(child: Text('${got.length} / $total', style: baloo(15, color: Colors.white))),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: CustomScrollView(slivers: [
                  SliverGrid.count(
                    crossAxisCount: l.large ? 2 : 1,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: l.large ? 5.2 : 5.2,
                    children: [
                      for (final w in WorldId.values)
                        GlassPanel(
                          radius: 22,
                          padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
                          child: Row(children: [
                            WorldTile(w, size: 42),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(worldName(context, w), style: baloo(15, color: Colors.white)),
                                const SizedBox(height: 3),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: LinearProgressIndicator(
                                    value: s.doneCount(w) / allLevels[w]!.length,
                                    minHeight: 10,
                                    color: Colors.white,
                                    backgroundColor: Colors.white.withValues(alpha: .28),
                                  ),
                                ),
                              ]),
                            ),
                          ]),
                        ),
                    ],
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverGrid.count(
                    crossAxisCount: cols,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      for (var i = 0; i < slots; i++)
                        i < got.length
                            ? Semantics(
                                label: 'Sticker: ${got[i].title}',
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Color(0x261F2A44), offset: Offset(0, 5))]),
                                  child: Pic(got[i].sticker, size: 36),
                                ),
                              )
                            : Opacity(
                                opacity: .6,
                                child: GlassPanel(
                                  radius: 200,
                                  child: Center(child: Text('?', style: baloo(24, color: Colors.white))),
                                ),
                              ),
                    ],
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ]),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}

// ---------------------------------------------------------------- play together

class TogetherCard {
  final String title, tag, text;
  const TogetherCard(this.title, this.tag, this.text);
}

/// Play Together ideas, chosen from what the child practised recently.
List<TogetherCard> togetherCards(List<String> recent, List<String> stickers) {
  final out = <TogetherCard>[];
  void add(TogetherCard c) {
    if (out.every((o) => o.title != c.title)) out.add(c);
  }

  for (final sk in recent) {
    if (sk.startsWith('snd_') || sk.startsWith('blend_') || sk.startsWith('trace_') || sk == 'rhyme' || sk == 'sight' || sk == 'case') {
      var g = sk.startsWith('snd_') ? sk.substring(4) : (sk.startsWith('trace_') ? sk.substring(6) : 'p');
      if (!speakSound.containsKey(g)) g = 'p';
      add(TogetherCard('Talk about it', '2 min',
          'Ask: "What else starts with /$g/?" Take turns finding things in the room that start with that sound.'));
      if (sk.startsWith('trace_')) {
        add(TogetherCard('Draw it big', 'off screen',
            'Draw the letter $g in the air, on a steamy window or in sand. Start at the top!'));
      }
    } else if (sk.startsWith('count') || sk.startsWith('numeral') || sk == 'subitise' || sk.startsWith('add') || sk.startsWith('subtract') || sk == 'order' || sk.startsWith('skip')) {
      add(const TogetherCard('Snack-time counting', 'off screen',
          'Count crackers or grapes together, touching each one. "How many? Who has more?"'));
    } else if (sk.startsWith('compare')) {
      add(const TogetherCard('More or fewer?', 'off screen', 'Make two piles of socks. Which pile has more? Which has fewer?'));
    } else if (sk.startsWith('make_')) {
      add(const TogetherCard('Fingers make ten', '2 min', 'Hold up 7 fingers. How many more to make 10? Take turns.'));
    } else if (sk.startsWith('shape') || sk.startsWith('pattern') || sk == 'size' || sk == 'solids' || sk == 'position') {
      add(const TogetherCard('Shape hunt', 'outside', 'Find a circle, a square and a triangle on a walk. Take turns pointing.'));
      add(const TogetherCard('Clap a pattern', '2 min', 'Clap, stamp, clap, stamp… what comes next? Then let your child lead.'));
    } else if (sk.startsWith('story') || sk == 'feelings') {
      final idx = stickers.reversed.map(levelById).whereType<Level>().where((l) => l.type == GameType.story).firstOrNull;
      add(TogetherCard('Retell the story', 'bedtime',
          idx != null ? storyBook[idx.p['story'] as int].talk : 'How did Momo feel? What would you do to help?'));
    } else if (sk.startsWith('lab_')) {
      add(const TogetherCard('Kitchen science', 'off screen',
          'Fill a bowl with water. Guess first: will a spoon, a cork and a leaf float or sink? Then test!'));
    } else if (sk == 'move') {
      add(const TogetherCard('Move together', '3 min', 'Put on a song. Freeze when it stops. Take turns choosing the animal move!'));
    }
  }
  const defaults = [
    TogetherCard('Talk about it', '2 min', 'Ask: "What else starts with /p/?" Take turns: pot, pen, pear… Who can find one in the room?'),
    TogetherCard('Snack-time counting', 'off screen', 'Count crackers together, touching each one. "How many? Who has more?"'),
    TogetherCard('Retell Momo’s story', 'bedtime', '"How did Momo feel when her kite got stuck? What would you do to help?"'),
    TogetherCard('Shape hunt', 'outside', 'Find a circle, a square and a triangle on a walk. Take turns pointing.'),
  ];
  for (final d in defaults) {
    if (out.length >= 4) break;
    add(d);
  }
  return out.take(4).toList();
}

class TogetherScreen extends StatelessWidget {
  const TogetherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.current!;
    final cards = togetherCards(p.recentSkills, p.stickers);
    return Scene(
      bg: const Color(0xFFFFE7B8),
      lightStatus: false,
      blobs: const [
        Blob(300, 300, Color(0xFFFFD98A), right: -130, top: 60),
        Blob(240, 240, Color(0xFFFFF1D1), left: -110, bottom: 60),
      ],
      child: Responsive(builder: (context, l) {
        return Column(children: [
          Row(children: [
            GlassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                label: 'Back',
                tone: GlassTone.strong,
                color: C.ink,
                onTap: () => Navigator.of(context).maybePop()),
            const SizedBox(width: 6),
            Expanded(child: Text('Play together', style: nunito(23, weight: 800, color: C.ink))),
            const Tiko(size: 54),
            Explorer(size: 48, color: Color(p.color), hat: p.hat),
          ]),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView(padding: const EdgeInsets.only(bottom: 30), children: [
                  _grid(l, [
                    for (final c in cards)
                      GlassPanel(
                        tone: GlassTone.strong,
                        radius: 22,
                        padding: const EdgeInsets.all(15),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(c.title, style: nunito(15, weight: 800, color: C.ink))),
                            Text(c.tag, style: nunito(12.5, color: C.muted)),
                          ]),
                          const SizedBox(height: 10),
                          Text(c.text, style: nunito(15, color: C.ink, height: 1.45)),
                        ]),
                      ),
                  ]),
                  const SizedBox(height: 14),
                  ChunkyButton.text('We did it together!',
                      family: 'Nunito', size: 18, onTap: () => go(context, const RewardScreen(together: true), replace: true)),
                ]),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}

/// Two-column card grid on wider screens.
Widget _grid(Layout l, List<Widget> kids) {
  if (l.sizeClass == SizeClass.compact) {
    return Column(children: [
      for (final k in kids) Padding(padding: const EdgeInsets.only(bottom: 12), child: k),
    ]);
  }
  final rows = <Widget>[];
  for (var i = 0; i < kids.length; i += 2) {
    rows.add(Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: kids[i]),
          const SizedBox(width: 12),
          Expanded(child: i + 1 < kids.length ? kids[i + 1] : const SizedBox()),
        ]),
      ),
    ));
  }
  return Column(children: rows);
}
