import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../content/levels.dart';
import '../core/audio.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/widgets/art.dart';
import '../core/widgets/glass.dart';
import 'game_shell.dart';

const _words = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten'];
String _cap(String s) => s[0].toUpperCase() + s.substring(1);

Widget _numberChoices(GameApi api, List<int> nums, int answer, void Function(int) pick) => ChoiceRow(
      count: nums.length,
      correctIndex: nums.indexOf(answer),
      hintLevel: api.hintLevel,
      label: (i) => 'Number ${nums[i]}',
      color: (i) => [C.coral, C.blue, C.sun, C.purple][i % 4],
      shadow: (i) => [C.coralDark, C.blueDark, C.amberDark, C.purpleDark][i % 4],
      builder: (i) => Text('${nums[i]}', style: baloo(52, color: Colors.white, height: 1.1)),
      onPick: (i) => pick(nums[i]),
    );

// ---------------------------------------------------------------- count

class CountGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const CountGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<CountGame> createState() => _CountGameState();
}

class _CountGameState extends State<CountGame> {
  late final int n;
  late final String item;
  late final String layout;
  late final List<int> options;
  late final List<Offset> spots;
  final Map<int, int> _badge = {};
  Timer? _model;

  @override
  void initState() {
    super.initState();
    final api = widget.api;
    final maxN = ((widget.level.p['max'] as int) + api.delta).clamp(2, 20);
    final minN = max(1, maxN - 4);
    n = minN + api.rng.nextInt(maxN - minN + 1);
    item = widget.level.p['item'] as String;
    layout = widget.level.p['layout'] as String;
    options = pickNumbers(api.rng, n, api.choices, 1, max(10, maxN));
    spots = _scatter(api.rng, n);
    WidgetsBinding.instance.addPostFrameCallback((_) => api.say('Tap each one to count!'));
  }

  @override
  void dispose() {
    _model?.cancel();
    super.dispose();
  }

  /// Non-overlapping positions inside a 1 x 0.62 box.
  static List<Offset> _scatter(Random r, int n) {
    final out = <Offset>[];
    var guard = 0;
    while (out.length < n && guard++ < 2000) {
      final o = Offset(.08 + r.nextDouble() * .84, .1 + r.nextDouble() * .42);
      if (out.every((p) => (p - o).distance > .19)) out.add(o);
    }
    while (out.length < n) {
      out.add(Offset(.1 + (out.length % 5) * .2, .15 + (out.length ~/ 5) * .3));
    }
    return out;
  }

  void _tap(int i) {
    if (_badge.containsKey(i)) return;
    setState(() => _badge[i] = _badge.length + 1);
    final c = _badge.length;
    Audio.I.sfx('tap');
    widget.api.say(c == n ? '${_cap(_words[c])}! The last number is how many.' : '${_cap(_words[c])}!');
  }

  void _pick(int v) {
    if (v == n) {
      widget.api.correct(praise: 'Yes! There are $n.');
    } else {
      widget.api.wrong(
        hint: _badge.length == n ? 'Close! The last number you said tells how many.' : 'Let’s count together. Tap each one once!',
        model: 'Let’s count together: ${List.generate(n, (i) => i + 1).join(', ')}. $n!',
      );
      if (widget.api.hintLevel >= 1) _modelCount();
    }
  }

  /// Hint: Tiko models one-to-one counting by numbering each item in turn.
  void _modelCount() {
    _model?.cancel();
    setState(_badge.clear);
    var i = 0;
    _model = Timer.periodic(const Duration(milliseconds: 650), (t) {
      if (!mounted || i >= n) {
        t.cancel();
        return;
      }
      setState(() => _badge[i] = i + 1);
      i++;
    });
  }

  Widget _thing(int i, double s) => Semantics(
        button: true,
        label: _badge.containsKey(i) ? 'counted ${_badge[i]}' : 'item to count',
        child: GestureDetector(
          onTap: () => _tap(i),
          child: SizedBox.square(
            dimension: s,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(child: AnimatedOpacity(
                  opacity: _badge.containsKey(i) ? .75 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Pic(item, size: s))),
              if (_badge.containsKey(i))
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: s * .44,
                    height: s * .44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x26000000), offset: Offset(0, 3))]),
                    child: Text('${_badge[i]}', style: baloo(s * .3, color: C.greenDark, height: 1.1)),
                  ),
                ),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return Responsive(builder: (context, l) {
      final s = l.large ? 84.0 : 64.0;
      Widget tray;
      if (layout == 'scatter') {
        tray = SizedBox(
          width: s * 6,
          height: s * 6 * .62,
          child: Stack(children: [
            for (var i = 0; i < n; i++)
              Positioned(left: spots[i].dx * s * 6 - s / 2, top: spots[i].dy * s * 6 * .62 + s * .1, child: _thing(i, s)),
          ]),
        );
      } else if (layout == 'line') {
        tray = Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < n; i++) Padding(padding: const EdgeInsets.all(5), child: _thing(i, s)),
        ]);
      } else {
        tray = Column(mainAxisSize: MainAxisSize.min, children: [
          for (var row = 0; row * 5 < n; row++)
            Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = row * 5; i < min(n, row * 5 + 5); i++) Padding(padding: const EdgeInsets.all(6), child: _thing(i, s)),
            ]),
        ]);
      }
      return GameSplit(
        leftHanded: api.leftHanded,
        onSpeaker: () => api.say('How many? Tap each one to count!'),
        question: Column(mainAxisSize: MainAxisSize.min, children: [
          qText('How many?', size: 24),
          const SizedBox(height: 10),
          tray,
        ]),
        coach: gameCoach(widget.coach),
        answers: _numberChoices(api, options, n, _pick),
      );
    });
  }
}

// ---------------------------------------------------------------- numeral

class NumeralGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const NumeralGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<NumeralGame> createState() => _NumeralGameState();
}

class _NumeralGameState extends State<NumeralGame> {
  late final int n;
  late final List<int> options;

  @override
  void initState() {
    super.initState();
    final api = widget.api;
    final maxN = ((widget.level.p['max'] as int) + api.delta * 2).clamp(3, 20);
    n = 1 + api.rng.nextInt(maxN);
    options = pickNumbers(api.rng, n, api.choices, 1, maxN);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
  }

  void _prompt() => widget.api.say('Find the number $n!', speech: 'Find the number $n');

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return GameSplit(
      leftHanded: api.leftHanded,
      onSpeaker: _prompt,
      question: Column(mainAxisSize: MainAxisSize.min, children: [
        qText('Find the number', size: 24),
        const SizedBox(height: 8),
        // Dots show the amount as a second cue (shown from hint 1, always for ages 3).
        if (api.hintLevel >= 1 || api.age <= 3)
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (var i = 0; i < n; i++)
              Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ])
        else
          const Icon(Icons.volume_up_rounded, color: Colors.white, size: 80),
      ]),
      coach: gameCoach(widget.coach),
      answers: _numberChoices(api, options, n, (v) {
        if (v == n) {
          api.correct(praise: 'Yes! That’s $n!');
        } else {
          api.wrong(hint: 'That’s $v. Listen: find $n!', model: 'This is $n. Look at its shape!');
        }
      }),
    );
  }
}

// ---------------------------------------------------------------- quick look

class QuickLookGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const QuickLookGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<QuickLookGame> createState() => _QuickLookGameState();
}

class _QuickLookGameState extends State<QuickLookGame> {
  late final int n;
  late final List<int> options;
  bool _show = true;
  Timer? _t;

  static const _dice = <int, List<Offset>>{
    1: [Offset(.5, .5)],
    2: [Offset(.28, .28), Offset(.72, .72)],
    3: [Offset(.25, .25), Offset(.5, .5), Offset(.75, .75)],
    4: [Offset(.28, .28), Offset(.72, .28), Offset(.28, .72), Offset(.72, .72)],
    5: [Offset(.25, .25), Offset(.75, .25), Offset(.5, .5), Offset(.25, .75), Offset(.75, .75)],
    6: [Offset(.28, .22), Offset(.72, .22), Offset(.28, .5), Offset(.72, .5), Offset(.28, .78), Offset(.72, .78)],
  };

  @override
  void initState() {
    super.initState();
    final api = widget.api;
    final maxN = ((widget.level.p['max'] as int) + api.delta).clamp(2, 6);
    n = 1 + api.rng.nextInt(maxN);
    options = pickNumbers(api.rng, n, api.choices, 1, 7);
    _flash();
  }

  void _flash() {
    setState(() => _show = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.api.say('Quick look! How many dots?'));
    _t?.cancel();
    _t = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _show = false);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return GameSplit(
      leftHanded: api.leftHanded,
      onSpeaker: _flash,
      question: Column(mainAxisSize: MainAxisSize.min, children: [
        qText('Quick look!', size: 24),
        const SizedBox(height: 10),
        SizedBox.square(
          dimension: 200,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _show
                ? Container(
                    key: const ValueKey('dots'),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                    child: Stack(children: [
                      for (final o in _dice[n]!)
                        Positioned(
                          left: o.dx * 200 - 18,
                          top: o.dy * 200 - 18,
                          child: Container(
                              width: 36, height: 36, decoration: const BoxDecoration(color: C.coral, shape: BoxShape.circle)),
                        ),
                    ]),
                  )
                : GestureDetector(
                    key: const ValueKey('hidden'),
                    onTap: _flash,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .25),
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(28)),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('?', style: baloo(80, color: Colors.white, height: 1)),
                        Text('Tap to look again', style: baloo(16, color: Colors.white)),
                      ]),
                    ),
                  ),
          ),
        ),
      ]),
      coach: gameCoach(widget.coach),
      answers: _numberChoices(api, options, n, (v) {
        if (v == n) {
          api.correct(praise: 'Yes! $n dots. You saw it fast!');
        } else {
          api.wrong(hint: 'Look again!', model: 'There were $n dots. Look: ${List.generate(n, (i) => i + 1).join(', ')}.');
          _flash();
        }
      }),
    );
  }
}

// ---------------------------------------------------------------- compare

class CompareGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const CompareGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<CompareGame> createState() => _CompareGameState();
}

class _CompareGameState extends State<CompareGame> {
  late final int a, b;
  late final bool askMore;
  late final String item;

  @override
  void initState() {
    super.initState();
    final api = widget.api;
    final mode = widget.level.p['mode'] as String;
    askMore = mode == 'more' || (mode == 'mixed' && api.rng.nextBool());
    final maxN = ((widget.level.p['max'] as int) + api.delta).clamp(3, 10);
    // Bigger gaps are easier; the gap shrinks as children improve.
    final gap = api.delta < 0 ? 3 : (api.delta > 0 ? 1 : 2);
    final small = 1 + api.rng.nextInt(max(1, maxN - gap));
    final big = min(maxN, small + gap);
    if (api.rng.nextBool()) {
      a = small;
      b = big;
    } else {
      a = big;
      b = small;
    }
    item = ['apple', 'orange', '🍓', '🐟'][api.round % 4];
    WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
  }

  String get _q => askMore ? 'Which basket has more?' : 'Which basket has fewer?';
  void _prompt() => widget.api.say(_q);

  void _pick(int side) {
    final mine = side == 0 ? a : b;
    final other = side == 0 ? b : a;
    final right = askMore ? mine > other : mine < other;
    if (right) {
      widget.api.correct(praise: askMore ? 'Yes! $mine is more than $other.' : 'Yes! $mine is fewer than $other.');
    } else {
      widget.api.wrong(
          hint: 'This one has $mine. Count the other one!',
          model: '${max(a, b)} is more than ${min(a, b)}. ${askMore ? 'More' : 'Fewer'} is this one!');
    }
  }

  Widget _basket(int side, int count, Layout l) {
    final correct = askMore ? count == max(a, b) : count == min(a, b);
    final glow = widget.api.hintLevel >= 2 && correct;
    final s = l.large ? 56.0 : 44.0;
    return Expanded(
      child: Semantics(
        button: true,
        label: 'Basket with $count',
        child: GestureDetector(
          onTap: () => _pick(side),
          child: GlassPanel(
            border: glow ? Border.all(color: Colors.white, width: 5) : null,
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [for (var i = 0; i < count; i++) Pic(item, size: s)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return Responsive(builder: (context, l) {
      final baskets = Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _basket(0, a, l),
        const SizedBox(width: 14),
        _basket(1, b, l),
      ]);
      final coach = gameCoach(widget.coach);
      return Column(children: [
        qText(_q, size: l.large ? 28 : 22),
        const SizedBox(height: 10),
        Expanded(
          child: l.twoCol
              ? Row(
                  children: api.leftHanded
                      ? [Expanded(flex: 4, child: Center(child: coach)), const SizedBox(width: 20), Expanded(flex: 5, child: baskets)]
                      : [Expanded(flex: 5, child: baskets), const SizedBox(width: 20), Expanded(flex: 4, child: Center(child: coach))])
              : Column(children: [Expanded(child: baskets), const SizedBox(height: 12), coach]),
        ),
      ]);
    });
  }
}

// ---------------------------------------------------------------- make 5 / 10

class MakeNGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const MakeNGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<MakeNGame> createState() => _MakeNGameState();
}

class _MakeNGameState extends State<MakeNGame> {
  late final int target, have;
  late final List<int> options;

  @override
  void initState() {
    super.initState();
    final api = widget.api;
    target = widget.level.p['target'] as int;
    have = 1 + api.rng.nextInt(target - 1);
    options = pickNumbers(api.rng, target - have, api.choices, 0, target);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
  }

  void _prompt() => widget.api.say('How many more to make $target?');

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    final need = target - have;
    final cells = target;
    Widget cell(int i) {
      final filled = i < have;
      final ghost = !filled && api.hintLevel >= 2;
      return Container(
        width: 52,
        height: 52,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: filled
            ? Container(width: 36, height: 36, decoration: const BoxDecoration(color: C.red, shape: BoxShape.circle))
            : ghost
                ? Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, border: Border.all(color: C.blue, width: 4)))
                : null,
      );
    }

    return GameSplit(
      leftHanded: api.leftHanded,
      onSpeaker: _prompt,
      question: Column(mainAxisSize: MainAxisSize.min, children: [
        qText('Make $target', size: 26),
        const SizedBox(height: 4),
        qText('$have here. How many more?', size: 18),
        const SizedBox(height: 12),
        // A ten-frame (or five-frame): part-part-whole.
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: C.greenDark, borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (var r = 0; r * 5 < cells; r++)
              Row(mainAxisSize: MainAxisSize.min, children: [for (var i = r * 5; i < min(cells, r * 5 + 5); i++) cell(i)]),
          ]),
        ),
      ]),
      coach: gameCoach(widget.coach),
      answers: _numberChoices(api, options, need, (v) {
        if (v == need) {
          api.correct(praise: 'Yes! $have and $need make $target!');
        } else {
          api.wrong(hint: 'Count the empty boxes!', model: '$have and $need make $target. Count the empty boxes: $need!');
        }
      }),
    );
  }
}
