import 'package:flutter/material.dart';

import '../content/levels.dart';
import '../core/audio.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/widgets/art.dart';
import '../core/widgets/buttons.dart';
import '../core/widgets/glass.dart';
import 'game_shell.dart';

/// Shape + colour are always named together (colour is never the only cue).
const shapeColors = {
  ShapeKind.circle: (C.red, 'red'),
  ShapeKind.square: (C.blue, 'blue'),
  ShapeKind.triangle: (C.gold, 'yellow'),
  ShapeKind.rectangle: (C.green, 'green'),
  ShapeKind.star: (Color(0xFFFF9F1C), 'orange'),
  ShapeKind.heart: (Color(0xFFE86A92), 'pink'),
};

String shapeName(ShapeKind k) => '${shapeColors[k]!.$2} ${k.name}';

// ---------------------------------------------------------------- shape homes

class ShapeSortGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const ShapeSortGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<ShapeSortGame> createState() => _ShapeSortGameState();
}

class _ShapeSortGameState extends State<ShapeSortGame> {
  late final List<ShapeKind> homes;
  late final List<ShapeKind> pieces;
  late final Map<ShapeKind, double> rot;
  late final Map<ShapeKind, double> scale;
  final Set<ShapeKind> _placed = {};
  ShapeKind? _sel;
  int _misses = 0;

  @override
  void initState() {
    super.initState();
    final p = widget.level.p;
    final r = widget.api.rng;
    final kinds = [ShapeKind.circle, ShapeKind.square, ShapeKind.triangle];
    if (p['four'] == true && widget.api.age > 3) kinds.add(ShapeKind.rectangle);
    if (p['star'] == true && widget.api.delta >= 0) kinds[r.nextInt(kinds.length)] = ShapeKind.star;
    homes = [...kinds]..shuffle(r);
    pieces = [...kinds]..shuffle(r);
    final rotate = p['rotate'] == true;
    rot = {for (final k in kinds) k: rotate ? (r.nextDouble() * 70 - 35) : 0};
    scale = {for (final k in kinds) k: rotate ? .75 + r.nextDouble() * .35 : 1};
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.api.say('Put each shape in its home!'));
  }

  void _drop(ShapeKind home, ShapeKind piece) {
    if (_placed.contains(home)) return;
    if (home == piece) {
      setState(() {
        _placed.add(home);
        _sel = null;
      });
      Audio.I.sfx('correct');
      if (_placed.length == homes.length) {
        widget.api.correct(praise: 'All home! ${_cap(shapeName(home))}!');
      } else {
        widget.api.say('${_cap(shapeName(home))}!');
      }
    } else {
      _misses++;
      setState(() => _sel = null);
      if (_misses <= 2) {
        Audio.I.sfx('try');
        widget.api.say('Hmm, that’s a ${piece.name}. Look at the shape of the home!');
      } else {
        widget.api.wrong(
            hint: 'Hmm, look at the corners and sides!', model: 'A ${piece.name} goes in the ${piece.name} home.');
      }
    }
  }

  String _cap(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return Responsive(builder: (context, l) {
      final home = l.large ? 92.0 : (l.size.height < 520 ? 52.0 : 66.0);
      final piece = l.large ? 100.0 : 76.0;
      final slots = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final k in homes)
            Flexible(
              child: DragTarget<ShapeKind>(
                onAcceptWithDetails: (d) => _drop(k, d.data),
                builder: (context, cand, rej) => Semantics(
                  button: true,
                  label: '${shapeName(k)} home',
                  child: GestureDetector(
                    onTap: () {
                      if (_sel == null) {
                        api.say('Pick a shape first!');
                      } else {
                        _drop(k, _sel!);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: GlassPanel(
                        border: cand.isNotEmpty || (api.hintLevel >= 2 && _sel == k)
                            ? Border.all(color: Colors.white, width: 4)
                            : null,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          _placed.contains(k)
                              ? ShapeArt(k, size: home, color: shapeColors[k]!.$1)
                              : ShapeArt(k, size: home, outline: Colors.white, dashed: true),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: shapeColors[k]!.$1 == C.gold ? const Color(0xFFE0A100) : shapeColors[k]!.$1,
                                borderRadius: BorderRadius.circular(10)),
                            child: FittedBox(
                                child: Text(_cap(shapeName(k)), style: baloo(12, color: Colors.white))),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
      final tray = Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 10, children: [
        for (final k in pieces)
          if (!_placed.contains(k))
            Draggable<ShapeKind>(
              data: k,
              feedback: ShapeArt(k, size: piece * scale[k]!, color: shapeColors[k]!.$1, rotation: rot[k]!),
              childWhenDragging: SizedBox.square(dimension: piece),
              child: Semantics(
                button: true,
                label: shapeName(k),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _sel = k);
                    Audio.I.sfx('tap');
                    api.say('${_cap(shapeName(k))}. Now tap its home!');
                  },
                  child: AnimatedScale(
                    scale: _sel == k ? 1.15 : 1,
                    duration: const Duration(milliseconds: 150),
                    child: SizedBox.square(
                      dimension: piece,
                      child: Center(
                          child: ShapeArt(k, size: piece * scale[k]!, color: shapeColors[k]!.$1, rotation: rot[k]!)),
                    ),
                  ),
                ),
              ),
            ),
      ]);
      final coach = gameCoach(widget.coach);
      final title = qText('Put each shape in its home!', size: l.large ? 28 : 22);
      if (l.twoCol) {
        final left = Column(mainAxisAlignment: MainAxisAlignment.center, children: [slots]);
        final right = SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [coach, const SizedBox(height: 14), tray]));
        return Column(children: [
          title,
          const SizedBox(height: 12),
          Expanded(
              child: Row(
                  children: api.leftHanded
                      ? [Expanded(flex: 4, child: Center(child: right)), const SizedBox(width: 20), Expanded(flex: 5, child: left)]
                      : [Expanded(flex: 5, child: left), const SizedBox(width: 20), Expanded(flex: 4, child: Center(child: right))])),
        ]);
      }
      return Column(children: [
        title,
        const Spacer(),
        slots,
        const Spacer(flex: 2),
        coach,
        const SizedBox(height: 10),
        tray,
        const SizedBox(height: 6),
      ]);
    });
  }
}

// ---------------------------------------------------------------- pattern

class PatternGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const PatternGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<PatternGame> createState() => _PatternGameState();
}

class _PatternGameState extends State<PatternGame> {
  late final List<String> seq; // element ids
  late final String answer;
  late final List<String> options;
  late final Map<String, String> names;

  static const _shapeEls = ['shape:circle:FFEF476F', 'shape:square:FF4DA3FF', 'shape:triangle:FFFFD166', 'shape:star:FFFF9F1C'];
  static const _shapeNames = ['red circle', 'blue square', 'yellow triangle', 'orange star'];
  static const _fruitEls = ['apple', '🍌', '🍇', 'orange'];
  static const _fruitNames = ['apple', 'banana', 'grapes', 'orange'];

  @override
  void initState() {
    super.initState();
    final r = widget.api.rng;
    var pat = widget.level.p['pattern'] as String;
    if (widget.api.delta < 0 && pat.length > 2) pat = 'AB';
    final fruit = widget.level.p['fruit'] == true;
    final els = fruit ? _fruitEls : _shapeEls;
    final nm = fruit ? _fruitNames : _shapeNames;
    final order = List.generate(4, (i) => i)..shuffle(r);
    final map = <String, int>{'A': order[0], 'B': order[1], 'C': order[2]};
    names = {for (var i = 0; i < 4; i++) els[i]: nm[i]};
    final unit = pat.split('').map((ch) => els[map[ch]!]).toList();
    final len = unit.length <= 2 ? 5 : (unit.length == 3 ? 6 : 7);
    final full = List.generate(len + 1, (i) => unit[i % unit.length]);
    seq = full.sublist(0, len);
    answer = full[len];
    final distract = els.where((e) => e != answer).toList()..shuffle(r);
    options = [answer, ...distract.take(widget.api.choices - 1)]..shuffle(r);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
  }

  void _prompt() => widget.api.say('${seq.map((e) => names[e]).join(', ')}… what comes next?');

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return GameSplit(
      leftHanded: api.leftHanded,
      onSpeaker: _prompt,
      question: Column(mainAxisSize: MainAxisSize.min, children: [
        qText('What comes next?', size: 24),
        const SizedBox(height: 12),
        Row(mainAxisSize: MainAxisSize.min, children: [
          for (final e in seq) Padding(padding: const EdgeInsets.all(3), child: Pic(e, size: 54)),
          Container(
            width: 62,
            height: 62,
            margin: const EdgeInsets.only(left: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Text('?', style: baloo(34, color: Colors.white, height: 1.1)),
          ),
        ]),
      ]),
      coach: gameCoach(widget.coach),
      answers: ChoiceRow(
        count: options.length,
        correctIndex: options.indexOf(answer),
        hintLevel: api.hintLevel,
        label: (i) => names[options[i]]!,
        builder: (i) => Pic(options[i], size: 60),
        onPick: (i) {
          if (options[i] == answer) {
            api.correct(praise: 'Yes! ${names[answer]} comes next!');
          } else if (!seq.contains(options[i])) {
            api.wrong(hint: 'There’s no ${names[options[i]]} in this pattern. Look again!', model: 'Say it with me: ${seq.map((e) => names[e]).join(', ')}, ${names[answer]}!');
          } else {
            api.wrong(hint: 'Say it out loud: ${seq.map((e) => names[e]).join(', ')}… what’s next?', model: 'Say it with me: ${seq.map((e) => names[e]).join(', ')}, ${names[answer]}!');
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------- shape hunt

class ShapeFindGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const ShapeFindGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<ShapeFindGame> createState() => _ShapeFindGameState();
}

class _ShapeFindGameState extends State<ShapeFindGame> {
  late final ShapeKind target;
  late final List<ShapeKind> options;
  late final List<double> rot, size;
  late final List<Color> colors;

  @override
  void initState() {
    super.initState();
    final r = widget.api.rng;
    target = ShapeKind.values.byName(widget.level.p['target'] as String);
    final n = ((widget.level.p['choices'] as int) + widget.api.delta).clamp(2, 4);
    final others = [ShapeKind.circle, ShapeKind.square, ShapeKind.triangle, ShapeKind.rectangle, ShapeKind.star]
        .where((k) => k != target)
        .toList()
      ..shuffle(r);
    options = [target, ...others.take(n - 1)]..shuffle(r);
    // Shapes appear turned, resized and in any colour: learn the shape itself.
    rot = [for (final _ in options) widget.level.difficulty == 0 ? 0 : r.nextDouble() * 90 - 45];
    size = [for (final _ in options) .7 + r.nextDouble() * .3];
    const palette = [C.red, C.blue, C.gold, C.green, C.purple];
    colors = [for (var i = 0; i < options.length; i++) palette[(i + r.nextInt(5)) % 5]];
    WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
  }

  void _prompt() => widget.api.say('Find the ${target.name}!');

  String get _clue => switch (target) {
        ShapeKind.circle => 'A circle is round all the way, with no corners.',
        ShapeKind.square => 'A square has 4 sides, all the same length.',
        ShapeKind.triangle => 'A triangle has 3 sides and 3 corners.',
        ShapeKind.rectangle => 'A rectangle has 4 sides: 2 long and 2 short.',
        ShapeKind.star => 'A star has 5 points.',
        ShapeKind.heart => 'A heart has a point at the bottom.',
      };

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return GameSplit(
      leftHanded: api.leftHanded,
      onSpeaker: _prompt,
      question: Column(mainAxisSize: MainAxisSize.min, children: [
        qText('Find the ${target.name}!', size: 26),
        const SizedBox(height: 10),
        ShapeArt(target, size: 120, outline: Colors.white, dashed: true),
      ]),
      coach: gameCoach(widget.coach),
      answers: ChoiceRow(
        count: options.length,
        correctIndex: options.indexOf(target),
        hintLevel: api.hintLevel,
        label: (i) => options[i].name,
        builder: (i) => ShapeArt(options[i], size: 70 * size[i], color: colors[i], rotation: rot[i]),
        onPick: (i) {
          if (options[i] == target) {
            api.correct(praise: 'Yes! That’s a ${target.name}, even when it’s turned!');
          } else {
            api.wrong(hint: 'That’s a ${options[i].name}. $_clue', model: 'Here’s the ${target.name}. $_clue');
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------- big & small

class SizeGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const SizeGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<SizeGame> createState() => _SizeGameState();
}

class _SizeGameState extends State<SizeGame> {
  late final bool bigger;
  late final String pic;
  late final List<double> sizes;
  late final int answer;

  @override
  void initState() {
    super.initState();
    final r = widget.api.rng;
    bigger = widget.level.p['ask'] == 'bigger' ? widget.api.round.isEven : widget.api.round.isOdd;
    pic = ['🐘', '🐻', 'apple', '🌳', '🏠', '🐟', '🎈', 'turtle'][(widget.api.round + r.nextInt(8)) % 8];
    final n = ((widget.level.p['choices'] as int)).clamp(2, 3);
    // Closer sizes are harder.
    final step = widget.api.delta > 0 ? .18 : .3;
    sizes = [for (var i = 0; i < n; i++) 1 - i * step]..shuffle(r);
    answer = bigger ? sizes.indexOf(sizes.reduce((a, b) => a > b ? a : b)) : sizes.indexOf(sizes.reduce((a, b) => a < b ? a : b));
    WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
  }

  void _prompt() => widget.api.say(bigger ? 'Which one is bigger?' : 'Which one is smaller?');

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return Responsive(builder: (context, l) {
      final base = l.large ? 170.0 : 110.0;
      return Column(children: [
        qText(bigger ? 'Which one is bigger?' : 'Which one is smaller?', size: l.large ? 28 : 22),
        const SizedBox(height: 10),
        Expanded(
          child: GlassPanel(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (var i = 0; i < sizes.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: AnswerTile(
                        size: base * 1.15,
                        color: Colors.white.withValues(alpha: .0),
                        shadow: Colors.transparent,
                        highlight: api.hintLevel >= 2 && i == answer,
                        semantics: i == answer ? (bigger ? 'big one' : 'small one') : 'picture',
                        onTap: () {
                          if (i == answer) {
                            api.correct(praise: bigger ? 'Yes! That one is bigger!' : 'Yes! That one is smaller!');
                          } else {
                            api.wrong(
                                hint: bigger ? 'Look for the one that takes up the most space!' : 'Look for the tiny one!',
                                model: bigger ? 'This one is the biggest!' : 'This one is the smallest!');
                          }
                        },
                        child: SizedBox.square(
                            dimension: base, child: Center(child: Pic(pic, size: base * sizes[i]))),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        gameCoach(widget.coach),
      ]);
    });
  }
}

