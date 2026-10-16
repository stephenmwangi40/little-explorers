import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../content/levels.dart';
import '../core/audio.dart';
import '../core/responsive.dart';
import '../core/state/app_state.dart';
import '../core/state/models.dart';
import '../core/state/scope.dart';
import '../core/theme.dart';
import '../core/widgets/art.dart';
import '../core/widgets/buttons.dart';
import '../core/widgets/glass.dart';
import '../core/widgets/scene.dart';
import '../core/widgets/tiko.dart';
import '../services/subscriptions.dart';
import 'onboarding.dart';
import 'stickers_together.dart';

// ---------------------------------------------------------------- shared

class _ParentPage extends StatelessWidget {
  final String title;
  final List<Widget> cards; // a card wrapped in _Wide spans both columns
  final Color bg;
  final List<Blob> blobs;
  final bool dark;
  final IconData backIcon;
  const _ParentPage({
    required this.title,
    required this.cards,
    this.bg = C.parents,
    this.blobs = const [
      Blob(300, 300, Color(0xFFCFE0F3), right: -130, top: 80),
      Blob(240, 240, Color(0xFFFFE7B8), left: -120, top: 420),
      Blob(200, 200, Color(0xFFD9D3FF), right: -80, bottom: 40),
    ],
    this.dark = false,
    this.backIcon = Icons.arrow_back_ios_new_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Scene(
      bg: bg,
      lightStatus: dark,
      blobs: blobs,
      child: Responsive(builder: (context, l) {
        return Column(children: [
          Row(children: [
            GlassIconButton(
              icon: backIcon,
              label: 'Back',
              tone: dark ? GlassTone.dark : GlassTone.strong,
              color: dark ? Colors.white : C.ink,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(title, style: nunito(23, weight: 800, color: dark ? Colors.white : C.ink))),
          ]),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView(padding: const EdgeInsets.only(bottom: 30), children: [_grid(l, cards)]),
              ),
            ),
          ),
        ]);
      }),
    );
  }

  static Widget _grid(Layout l, List<Widget> cards) {
    final two = l.size.width >= 600;
    if (!two) {
      return Column(children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 12), child: c)]);
    }
    final rows = <Widget>[];
    var i = 0;
    while (i < cards.length) {
      final c = cards[i];
      if (c is _Wide || i + 1 >= cards.length || cards[i + 1] is _Wide) {
        rows.add(Padding(padding: const EdgeInsets.only(bottom: 12), child: c));
        i++;
      } else {
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: c),
              const SizedBox(width: 12),
              Expanded(child: cards[i + 1]),
            ]),
          ),
        ));
        i += 2;
      }
    }
    return Column(children: rows);
  }
}

class _Wide extends StatelessWidget {
  final Widget child;
  const _Wide(this.child);
  @override
  Widget build(BuildContext context) => child;
}

class _Card extends StatelessWidget {
  final String? title;
  final String? aside;
  final Widget child;
  final GlassTone tone;
  const _Card({this.title, this.aside, required this.child, this.tone = GlassTone.strong});

  @override
  Widget build(BuildContext context) {
    final dark = tone == GlassTone.dark;
    return GlassPanel(
      tone: tone,
      radius: 22,
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Expanded(child: Text(title!, style: nunito(15, weight: 800, color: dark ? Colors.white : C.ink))),
            if (aside != null) Text(aside!, style: nunito(12.5, color: dark ? Colors.white70 : C.muted)),
          ]),
          const SizedBox(height: 10),
        ],
        child,
      ]),
    );
  }
}

Widget _chip(String t, {Color bg = Colors.white, Color fg = C.ink, IconData? icon, VoidCallback? onTap, Widget? lead}) {
  final w = Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (lead != null) ...[lead, const SizedBox(width: 4)],
      if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
      Text(t, style: nunito(12, weight: 800, color: fg)),
    ]),
  );
  return onTap == null ? w : GestureDetector(onTap: onTap, child: w);
}

/// Skill areas with curriculum tags. Wording: "supports", never "certified".
class SkillArea {
  final String name;
  final Color color;
  final Set<GameType> types;
  final List<String> tags;
  const SkillArea(this.name, this.color, this.types, this.tags);
}

const skillAreas = [
  SkillArea('Letter sounds (s a t p i n …)', Color(0xFFFF7A59), {GameType.letterSound, GameType.trace}, [
    'US · CCSS RF.K.3a', 'US · Head Start ELOF: Literacy', 'AU · EYLF Outcome 5', 'AU · AC v9 English F (phonics)',
    'EU · Aistear: Communicating'
  ]),
  SkillArea('Blending words', Color(0xFFE05A3A), {GameType.blend},
      ['US · CCSS RF.K.2, RF.K.3', 'US · ELOF: Literacy', 'AU · EYLF Outcome 5', 'AU · AC v9 English F', 'EU · Aistear: Communicating']),
  SkillArea('Counting & cardinality', Color(0xFF3DBE7A), {GameType.count, GameType.numeral, GameType.quickLook, GameType.makeN},
      ['US · CCSS K.CC.4, K.CC.5', 'US · ELOF: Mathematics', 'AU · AC9MFN01, AC9MFN02', 'AU · EYLF Outcome 4', 'EU · Aistear: Exploring & Thinking']),
  SkillArea('Comparing groups', Color(0xFF2A9D60), {GameType.compare},
      ['US · CCSS K.CC.6', 'US · ELOF: Mathematics', 'AU · AC v9 Maths F (Number)', 'EU · Aistear: Exploring & Thinking']),
  SkillArea('Shapes & patterns', Color(0xFF9B6BFF), {GameType.shapeSort, GameType.pattern, GameType.shapeFind, GameType.size},
      ['US · CCSS K.G.2', 'US · ELOF: Geometry & Patterning', 'AU · AC v9 Maths F (Space, Algebra)', 'EU · Aistear: Exploring & Thinking']),
  SkillArea('Feelings & story', Color(0xFFE86A92), {GameType.story},
      ['US · CCSS RL.K.1', 'US · ELOF: Social & Emotional', 'AU · EYLF Outcomes 1, 3 & 5', 'EU · Aistear: Well-being; Identity & Belonging']),
  SkillArea('Science: predict & test', Color(0xFF4DA3FF), {GameType.lab},
      ['US · ELOF: Scientific Reasoning', 'AU · EYLF Outcome 4', 'AU · AC v9 Science F', 'EU · Aistear: Exploring & Thinking']),
  SkillArea('Movement', Color(0xFFFFB703), {GameType.move},
      ['US · ELOF: Perceptual, Motor & Physical', 'AU · EYLF Outcome 3', 'EU · Aistear: Well-being']),
];

List<Level> _levelsOf(SkillArea a) =>
    [for (final ls in allLevels.values) ...ls.where((l) => a.types.contains(l.type))];

(int done, int total, Level? next) areaProgress(AppState s, SkillArea a) {
  final ls = _levelsOf(a);
  final done = ls.where(s.isDone).length;
  final next = ls.where((l) => !s.isDone(l)).firstOrNull;
  return (done, ls.length, next);
}

Widget _bar(double v, Color c) => ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: LinearProgressIndicator(value: v.clamp(0, 1), minHeight: 10, color: c, backgroundColor: const Color(0xFFD6E2F0)),
    );

// ---------------------------------------------------------------- dashboard

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.current;
    if (p == null) return const SizedBox();
    final now = s.clock();
    final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
    final mins = days.map((d) => s.minutesOn(p, d)).toList();
    final total = mins.fold<double>(0, (a, b) => a + b);
    final active = mins.where((m) => m > 0).length;
    final maxM = [s.settings.dailyLimit.toDouble(), ...mins].reduce((a, b) => a > b ? a : b);
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final tip = togetherCards(p.recentSkills, p.stickers).first;
    final trialEnds = s.trialEnds;

    return _ParentPage(
      title: 'Grown-ups',
      cards: [
        _Wide(_Card(
          child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            for (final q in s.profiles)
              _chip('${q.name} · ${q.age}',
                  bg: q.id == p.id ? C.ink : Colors.white,
                  fg: q.id == p.id ? Colors.white : C.ink,
                  lead: Explorer(size: 18, color: Color(q.color), hat: q.hat),
                  onTap: () => s.selectProfile(q.id)),
            if (s.profiles.length < AppState.maxProfiles)
              _chip('+ Add', onTap: () => go(context, const AgeScreen(adding: true))),
          ]),
        )),
        if (trialEnds != null && trialEnds.difference(now).inDays <= 2)
          _Wide(_Card(
            title: 'Your free trial ends soon',
            aside: '${trialEnds.day}/${trialEnds.month}/${trialEnds.year}',
            child: Text(
                'Explorer Plus will start billing after the trial ends. To cancel: Settings → your name → Subscriptions (iPhone/iPad), or Play Store → Payments & subscriptions (Android).',
                style: nunito(14, color: C.ink, height: 1.45)),
          )),
        _Card(
          title: 'This week',
          aside: '${total.round()} min · avg ${(active == 0 ? 0 : total / active).round()} min/day',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 100,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: (mins[i] / maxM).clamp(.04, 1),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: i == 6 ? C.blue : const Color(0xFFA9CCF5), borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(dayLetters[days[i].weekday - 1], style: nunito(11, color: C.muted)),
                      ]),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 8),
            Text('Daily limit ${s.settings.dailyLimit} min · under the 1-hour daily guidance for ages 2–5',
                style: nunito(12, color: C.muted)),
          ]),
        ),
        _Card(
          title: 'Learning so far',
          aside: p.name,
          child: Column(children: [
            for (final a in skillAreas.take(5))
              Builder(builder: (context) {
                final (done, tot, _) = areaProgress(s, a);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: [
                    SizedBox(
                        width: 96,
                        child: Text(a.name.split(' (').first.split(' &').first, style: nunito(13.5, color: C.ink))),
                    Expanded(child: _bar(done / tot, a.color)),
                    SizedBox(
                        width: 54,
                        child: Text('$done / $tot', textAlign: TextAlign.right, style: nunito(12.5, color: C.muted))),
                  ]),
                );
              }),
          ]),
        ),
        _Card(title: 'Try at home', aside: tip.tag, child: Text(tip.text, style: nunito(14.5, color: C.ink, height: 1.45))),
        _Card(
          title: 'Today',
          aside: '${s.minutesToday.round()} of ${s.allowedToday} min',
          child: Text(
              s.adventureDone
                  ? 'Today’s adventure is finished.'
                  : 'Today’s adventure: step ${s.adventureStep + 1} of ${s.adventureWorlds.length + 1}.',
              style: nunito(14.5, color: C.ink, height: 1.45)),
        ),
        _Wide(LayoutBuilder(builder: (context, c) {
          final links = [
            _PLink(Icons.bar_chart_rounded, 'Learning report', 'Mapped to US · AU · EU', C.blue,
                () => go(context, const ReportScreen())),
            _PLink(Icons.settings_rounded, 'Settings', 'Time, language, access', C.muted,
                () => go(context, const SettingsScreen())),
            _PLink(Icons.star_rounded, 'Explorer Plus', s.plus ? 'Active' : '7-day free trial', const Color(0xFF2F3E66),
                () => go(context, const SubscriptionScreen()),
                iconColor: C.sun),
            _PLink(Icons.favorite_rounded, 'Play together', 'Ideas for today', C.story,
                () => go(context, const TogetherScreen())),
          ];
          final cols = c.maxWidth >= 600 ? 4 : 2;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: cols == 4 ? 2.1 : 2.3,
            children: links,
          );
        })),
        _Wide(_Card(
          title: 'Privacy',
          child: Wrap(spacing: 6, runSpacing: 6, children: [
            for (final t in const [
              'No ads',
              'No chat',
              'No third-party tracking',
              'Progress stays on this device',
              'Delete all data anytime'
            ])
              _chip(t, icon: Icons.shield_rounded),
          ]),
        )),
      ],
    );
  }
}

class _PLink extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final Color color;
  final VoidCallback onTap;
  final Color iconColor;
  const _PLink(this.icon, this.title, this.sub, this.color, this.onTap, {this.iconColor = Colors.white});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: title,
        child: GestureDetector(
          onTap: () {
            Audio.I.sfx('tap');
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: nunito(14.5, weight: 800, color: Colors.white)),
                  Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: nunito(12, weight: 600, color: Colors.white.withValues(alpha: .85))),
                ]),
              ),
            ]),
          ),
        ),
      );
}

// ---------------------------------------------------------------- report

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.current!;
    return _ParentPage(
      title: 'Learning report',
      cards: [
        for (final a in skillAreas)
          Builder(builder: (context) {
            final (done, tot, next) = areaProgress(s, a);
            final secure = p.skills.entries
                .where((e) => e.value.secure && _levelsOf(a).any((l) => l.skill == e.key))
                .length;
            return _Card(
              title: a.name,
              aside: '${(done / tot * 100).round()}%',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _bar(done / tot, a.color),
                const SizedBox(height: 8),
                Text(next == null ? 'All levels finished. Lovely work!' : 'Next: ${next.title}',
                    style: nunito(13.5, color: C.ink)),
                if (secure > 0)
                  Text('$secure skill${secure == 1 ? '' : 's'} secure (8 of 10 right, on 2+ days)',
                      style: nunito(12, color: C.muted)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final t in a.tags) _chip(t, bg: const Color(0xFFEEF3FA)),
                ]),
              ]),
            );
          }),
        _Wide(_Card(
          child: Text(
            'These activities support the outcomes listed. They do not replace a teacher, preschool or school assessment. '
            'Lesson content should be reviewed by a qualified early-years teacher in each region before release.',
            style: nunito(12.5, weight: 600, color: C.muted, height: 1.45),
          ),
        )),
      ],
    );
  }
}

// ---------------------------------------------------------------- settings

class _Seg extends StatelessWidget {
  final List<String> options;
  final int selected;
  final void Function(int) onTap;
  const _Seg(this.options, this.selected, this.onTap);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: const Color(0xFFD6E2F0), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < options.length; i++)
            Semantics(
              button: true,
              selected: i == selected,
              label: options[i],
              child: GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 34, minWidth: 34),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: i == selected
                      ? BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [BoxShadow(color: C.ink.withValues(alpha: .12), blurRadius: 6, offset: const Offset(0, 2))])
                      : null,
                  child: Text(options[i], style: nunito(12.5, weight: 800, color: C.ink)),
                ),
              ),
            ),
        ]),
      );
}

class _Row extends StatelessWidget {
  final String label;
  final String? sub;
  final Widget trailing;
  final Color color;
  const _Row(this.label, this.trailing, {this.sub, this.color = C.ink});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: nunito(14.5, color: color)),
              if (sub != null) Text(sub!, style: nunito(12, weight: 600, color: C.muted)),
            ]),
          ),
          const SizedBox(width: 10),
          trailing,
        ]),
      );
}

Widget _toggle(bool v, void Function(bool) f, {bool enabled = true}) =>
    Switch.adaptive(value: v, onChanged: enabled ? f : null, activeTrackColor: C.green);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final st = s.settings;
    void set(void Function(Settings) f) {
      s.updateSettings(f);
      Audio.I.apply(s.settings);
    }

    return _ParentPage(
      title: 'Settings',
      cards: [
        _Card(
          title: 'Time',
          child: Column(children: [
            _Row('Adventure length',
                _Seg(const ['10', '15', '20 min'], [10, 15, 20].indexOf(st.adventureMinutes), (i) => set((x) => x.adventureMinutes = [10, 15, 20][i]))),
            _Row('Daily limit',
                _Seg(const ['20', '30', '45', '60'], [20, 30, 45, 60].indexOf(st.dailyLimit), (i) => set((x) => x.dailyLimit = [20, 30, 45, 60][i]))),
            _Row('Bedtime lock', _toggle(st.bedtimeLock, (v) => set((x) => x.bedtimeLock = v)), sub: 'No play 7 pm – 7 am'),
            _Row('Movement breaks', _toggle(st.moveBreaks, (v) => set((x) => x.moveBreaks = v)), sub: 'In every daily adventure'),
          ]),
        ),
        _Card(
          title: 'Language',
          child: Column(children: [
            _Row('English', _Seg(const ['US', 'UK', 'AU'], ['US', 'UK', 'AU'].indexOf(st.english), (i) => set((x) => x.english = ['US', 'UK', 'AU'][i])),
                sub: '“zee” or “zed”, “math” or “maths”'),
            _Row('Narration speed', _Seg(const ['Slow', 'Normal'], st.slowNarration ? 0 : 1, (i) => set((x) => x.slowNarration = i == 0))),
            _Row('Narration (Tiko speaks)', _toggle(st.narration, (v) => set((x) => x.narration = v))),
            _Row('Captions under narration', _toggle(st.captions, (v) => set((x) => x.captions = v))),
          ]),
        ),
        _Card(
          title: 'Access',
          child: Column(children: [
            _Row('Reduce motion', _toggle(st.reduceMotion, (v) => set((x) => x.reduceMotion = v)), sub: 'Also turns off glass blur'),
            _Row('Left-handed mode', _toggle(st.leftHanded, (v) => set((x) => x.leftHanded = v)), sub: 'Answers and tracing tools on the left'),
            _Row('Sound effects', _toggle(st.sound, (v) => set((x) => x.sound = v))),
            _Row('Music', _toggle(st.music, (v) => set((x) => x.music = v))),
          ]),
        ),
        _Card(
          title: 'Data',
          child: Column(children: [
            _Row('All lessons on this device', const Icon(Icons.check_circle_rounded, color: C.green),
                sub: 'Everything works offline. Nothing to download.'),
            _Row('Cloud backup', _toggle(false, (_) {}, enabled: false), sub: 'Off · needs a parent account (coming later)'),
            _Row('Privacy policy', TextButton(onPressed: () => go(context, const PrivacyScreen()), child: const Text('Open'))),
            _Row('Export data', TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: s.exportJson()));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data copied to the clipboard as JSON.')));
                }
              },
              child: const Text('Copy'),
            ), sub: 'Copies everything stored, as text'),
            _Row('Delete all data', IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () => _confirmDelete(context, s),
            ), color: C.danger),
          ]),
        ),
        _Wide(_Card(
          title: 'Children',
          aside: '${s.profiles.length} of ${AppState.maxProfiles}',
          child: Column(children: [
            for (final q in s.profiles)
              _Row(
                '${q.name} · age ${q.age}',
                Row(mainAxisSize: MainAxisSize.min, children: [
                  _Seg(const ['3', '4', '5', '6'], q.age - 3, (i) => s.updateProfile(q, (x) => x.age = i + 3)),
                  IconButton(
                    tooltip: 'Remove ${q.name}',
                    icon: const Icon(Icons.delete_outline_rounded, color: C.danger),
                    onPressed: () => _confirmRemove(context, s, q),
                  ),
                ]),
                sub: '${q.stickers.length} stickers',
              ),
          ]),
        )),
      ],
    );
  }

  void _confirmRemove(BuildContext context, AppState s, Profile q) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Remove ${q.name}?'),
        content: const Text('This deletes this child’s progress and stickers from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok == true) {
      s.removeProfile(q.id);
      if (s.profiles.isEmpty && context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AgeScreen()), (_) => false);
      }
    }
  }

  void _confirmDelete(BuildContext context, AppState s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text('This removes every child profile, all progress, stickers and settings from this device. It cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Delete everything', style: TextStyle(color: C.danger))),
        ],
      ),
    );
    if (ok == true) {
      await s.deleteAll();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SplashScreen()), (_) => false);
      }
    }
  }
}

// ---------------------------------------------------------------- subscription

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _plan = Subscriptions.yearly;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final sub = Subscriptions.I;
    return ValueListenableBuilder(
      valueListenable: sub.products,
      builder: (context, products, _) {
        String price(String id, String fallback) => products[id]?.price ?? fallback;
        Widget plan(String id, String name, String small, String pr, {String? save}) {
          final sel = _plan == id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Semantics(
              button: true,
              selected: sel,
              label: '$name plan, $pr',
              child: GestureDetector(
                onTap: () => setState(() => _plan = id),
                child: GlassPanel(
                  tone: GlassTone.dark,
                  radius: 22,
                  border: sel ? Border.all(color: C.sun, width: 2.5) : null,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                  child: Row(children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, border: Border.all(color: sel ? C.sun : Colors.white, width: 2.5)),
                      child: sel
                          ? Container(width: 11, height: 11, decoration: const BoxDecoration(color: C.sun, shape: BoxShape.circle))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(name, style: nunito(16, weight: 800, color: Colors.white)),
                          if (save != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: C.sun, borderRadius: BorderRadius.circular(8)),
                              child: Text(save, style: nunito(11, weight: 800, color: C.ink)),
                            ),
                          ],
                        ]),
                        Text(small, style: nunito(12.5, color: Colors.white.withValues(alpha: .8))),
                      ]),
                    ),
                    Text(pr, style: nunito(17, weight: 800, color: Colors.white)),
                  ]),
                ),
              ),
            ),
          );
        }

        return _ParentPage(
          title: '',
          dark: true,
          bg: const Color(0xFF2F3E66),
          backIcon: Icons.close_rounded,
          blobs: const [
            Blob(260, 260, C.sun, right: -90, top: 60),
            Blob(300, 300, Color(0xFF3D4F80), left: -140, top: 360),
          ],
          cards: [
            _Wide(Row(children: [
              const Tiko(size: 80),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Explorer Plus', style: baloo(28, color: Colors.white, height: 1)),
                  const SizedBox(height: 4),
                  Text(s.plus ? 'Thank you! Every world and level is open.' : 'Free: the daily adventure and 1 level per world.',
                      style: nunito(14, weight: 600, color: Colors.white.withValues(alpha: .85))),
                ]),
              ),
            ])),
            _Card(
              tone: GlassTone.dark,
              child: Column(children: [
                for (final t in const [
                  'Every world, all 240 levels',
                  'Up to 4 child profiles',
                  'Full offline play',
                  'No ads, ever',
                  'Reminder 2 days before the trial ends',
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(color: C.green, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(t, style: nunito(14.5, color: Colors.white))),
                    ]),
                  ),
              ]),
            ),
            Column(children: [
              plan(Subscriptions.yearly, 'Yearly', 'Billed once a year after the trial', price(Subscriptions.yearly, '\$49.99'),
                  save: 'SAVE 40%'),
              plan(Subscriptions.monthly, 'Monthly', 'Cancel anytime', price(Subscriptions.monthly, '\$6.99')),
              ValueListenableBuilder(
                valueListenable: sub.busy,
                builder: (context, busy, _) => ChunkyButton.text(
                  s.plus ? 'Explorer Plus is active' : (busy ? 'Please wait…' : 'Start 7-day free trial'),
                  color: C.sun,
                  shadow: const Color(0xFFC98F00),
                  textColor: C.ink,
                  family: 'Nunito',
                  size: 18,
                  width: double.infinity,
                  onTap: s.plus || busy ? null : () => sub.buy(_plan),
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: sub.status,
                builder: (context, msg, _) => msg.isEmpty
                    ? const SizedBox()
                    : Text(msg, textAlign: TextAlign.center, style: nunito(13, color: Colors.white)),
              ),
            ]),
            _Wide(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Billed by the App Store or Google Play after the 7-day trial. We remind you 2 days before it ends. '
                'To cancel: Settings → your name → Subscriptions (iPhone/iPad), or Play Store → Payments & subscriptions (Android). '
                'Prices shown by your store may differ by country.',
                style: nunito(12.5, weight: 600, color: Colors.white.withValues(alpha: .8), height: 1.5),
              ),
              const SizedBox(height: 6),
              Wrap(spacing: 4, children: [
                TextButton(onPressed: sub.restore, child: Text('Restore purchases', style: nunito(13, weight: 800, color: Colors.white))),
                TextButton(
                    onPressed: () => go(context, const PrivacyScreen()),
                    child: Text('Privacy', style: nunito(13, weight: 800, color: Colors.white))),
              ]),
            ])),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------- privacy

const privacyPolicy = '''
Little Explorers is made for children aged 3 to 6 and their families.

What we collect
• Nothing is sent from this app to us or to anyone else. There are no ads, no analytics, no tracking, no chat and no location.
• On this device only, the app stores: a nickname such as "Explorer 1", an age band (3, 4, 5 or 6), an avatar colour and hat, learning progress, stickers, minutes played per day and your settings.
• We never ask for a child's real name, birthday, photo, email or voice.

Purchases
• Explorer Plus is billed by Apple or Google. We never see your card details. The store tells the app only whether a subscription is active.

Text-to-speech
• Tiko's voice uses your device's built-in text-to-speech engine. Check your device settings for how that engine handles data; the app only sends it the words to read.

How long we keep data (retention schedule)
• Progress, stickers and settings: kept on this device until you delete a child profile, tap "Delete all data", or uninstall the app.
• Minutes played: the last 60 days only; older days are deleted automatically.
• Answer history used for learning: the last 30 answers per skill; older answers are deleted automatically.
• Cloud backup: off. It will only ever be available with a parent account and your consent.

Your choices
• Export: Grown-ups → Settings → Export data copies everything stored, as text.
• Delete: Grown-ups → Settings → Delete all data removes everything immediately.

Laws and store rules we follow
• US COPPA, EU GDPR, the Australian Privacy Act and the UK Age Appropriate Design Code principles: data minimisation, high-privacy defaults and no nudges to share data.
• Apple Kids Category (guidelines 1.3 and 5.1.4) and the Google Play Families Policy: no third-party advertising or analytics, no advertising ID, and a parental gate before purchases and settings.

Contact
• Add your support email address here before publishing.
''';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext context) => _ParentPage(
        title: 'Privacy policy',
        cards: [
          _Wide(_Card(child: SelectableText(privacyPolicy.trim(), style: nunito(14.5, weight: 600, color: C.ink, height: 1.5)))),
        ],
      );
}
