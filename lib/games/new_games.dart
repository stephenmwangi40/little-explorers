import 'dart:math';

import 'package:flutter/material.dart';

import '../content/levels.dart';
import '../content/phonics.dart';
import '../content/stories_extra.dart';
import '../content/stories_more.dart';
import '../core/theme.dart';
import '../core/widgets/art.dart';
import 'game_shell.dart';

/// Shared scaffold for simple "prompt + choices" games.
abstract class _PickGameState<T extends StatefulWidget> extends State<T> {
  GameApi get api;
  String get coach;
  late List<Object> options;
  late int answer;

  String get prompt;
  String? get speech => null;
  Widget question();
  Widget option(int i);
  String label(int i);
  String praise() => 'Yes! Well done!';
  String hint(int i);
  String model();
  Color? tileColor(int i) => null;
  Color? tileShadow(int i) => null;

  @override
  void initState() {
    super.initState();
    setup(api.rng);
    WidgetsBinding.instance.addPostFrameCallback((_) => say());
  }

  void setup(Random r);
  void say() => api.say(prompt, speech: speech);

  @override
  Widget build(BuildContext context) => GameSplit(
        leftHanded: api.leftHanded,
        onSpeaker: say,
        question: question(),
        coach: gameCoach(coach),
        answers: ChoiceRow(
          count: options.length,
          correctIndex: answer,
          hintLevel: api.hintLevel,
          label: label,
          color: tileColor(0) == null ? null : (i) => tileColor(i)!,
          shadow: tileShadow(0) == null ? null : (i) => tileShadow(i)!,
          builder: option,
          onPick: (i) => i == answer ? api.correct(praise: praise()) : api.wrong(hint: hint(i), model: model()),
        ),
      );
}

List<E> _pick<E>(Random r, E must, Iterable<E> pool, int n) {
  final others = pool.where((e) => e != must).toSet().toList()..shuffle(r);
  return [must, ...others.take(n - 1)]..shuffle(r);
}

// ---------------------------------------------------------------- letters

/// Match a small letter to its capital letter.
class CaseMatchGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const CaseMatchGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<CaseMatchGame> createState() => _CaseMatchState();
}

class _CaseMatchState extends _PickGameState<CaseMatchGame> {
  late String letter;
  @override
  GameApi get api => widget.api;
  @override
  String get coach => widget.coach;

  @override
  void setup(Random r) {
    final letters = (widget.level.p['letters'] as List).cast<String>();
    letter = letters[(api.round + r.nextInt(letters.length)) % letters.length];
    const all = 'abcdefghijklmnopqrstuvwxyz';
    final pool = letters.length >= api.choices ? letters : all.split('');
    options = _pick<String>(r, letter.toUpperCase(), pool.map((l) => l.toUpperCase()), api.choices);
    answer = options.indexOf(letter.toUpperCase());
  }

  @override
  String get prompt => 'Find the capital letter for $letter!';
  @override
  String get speech => 'Find the capital letter ${letter.toUpperCase()}. Its sound is ${speakSound[letter] ?? letter}.';
  @override
  Widget question() => Column(mainAxisSize: MainAxisSize.min, children: [
        qText('Find the capital letter', size: 22),
        Text(letter, style: baloo(130, color: Colors.white, height: 1.1)),
      ]);
  @override
  Widget option(int i) => Text('${options[i]}', style: baloo(52, color: Colors.white, height: 1.1));
  @override
  Color? tileColor(int i) => ChoiceRow.tileColors[i % 4].$1;
  @override
  Color? tileShadow(int i) => ChoiceRow.tileColors[i % 4].$2;
  @override
  String label(int i) => 'Capital ${options[i]}';
  @override
  String praise() => 'That’s right! Capital ${letter.toUpperCase()} and small $letter are the same letter. They make the same sound.';
  @override
  String hint(int i) => 'That is capital ${options[i]}, the big letter for ${(options[i] as String).toLowerCase()}. We need the big letter for $letter.';
  @override
  String model() => 'This is capital ${letter.toUpperCase()}. Small $letter, big ${letter.toUpperCase()}.';
}

/// Find a "tricky" word by sight.
class SightWordGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const SightWordGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<SightWordGame> createState() => _SightWordState();
}

class _SightWordState extends _PickGameState<SightWordGame> {
  late String word;
  late bool showWord;
  @override
  GameApi get api => widget.api;
  @override
  String get coach => widget.coach;

  @override
  void setup(Random r) {
    final words = (widget.level.p['words'] as List).cast<String>();
    final known = (widget.level.p['known'] as List).cast<String>();
    word = words[(api.round + r.nextInt(words.length)) % words.length];
    // Easier: see the word and match it. Harder: just hear it.
    showWord = widget.level.difficulty < 2 || api.delta < 0 || api.age <= 4;
    options = _pick<String>(r, word, known, api.choices);
    answer = options.indexOf(word);
  }

  @override
  String get prompt => showWord ? 'Find the word “$word”.' : 'Listen. Find the word “$word”.';
  @override
  String get speech => 'Find the word: $word.';
  @override
  Widget question() => Column(mainAxisSize: MainAxisSize.min, children: [
        qText('Find the word', size: 22),
        const SizedBox(height: 8),
        showWord || api.hintLevel >= 1
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                child: Text(word, style: baloo(64, color: C.coralDark, height: 1.2)),
              )
            : const Icon(Icons.hearing_rounded, color: Colors.white, size: 96),
      ]);
  @override
  Widget option(int i) => Text('${options[i]}', style: nunito(30, weight: 800, color: C.ink));
  @override
  String label(int i) => 'Word ${options[i]}';
  @override
  String praise() => 'That’s right! That word says “$word”.';
  @override
  String hint(int i) => 'That word says “${options[i]}”. We are looking for the word “$word”.';
  @override
  String model() => 'This one says “$word”. Let’s read it together: $word!';
}

/// Which picture rhymes?
class RhymeGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const RhymeGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<RhymeGame> createState() => _RhymeState();
}

class _RhymeState extends _PickGameState<RhymeGame> {
  late (String, String) prompt0;
  late List<(String, String)> opts;
  @override
  GameApi get api => widget.api;
  @override
  String get coach => widget.coach;

  @override
  void setup(Random r) {
    final off = widget.level.p['offset'] as int;
    final set = rhymeSets[(off + api.round * 5 + r.nextInt(3)) % rhymeSets.length];
    final pair = [...set]..shuffle(r);
    prompt0 = pair[0];
    final right = pair[1];
    final others = [for (final s in rhymeSets) if (!identical(s, set)) ...s]
        .where((o) => o.$2 != prompt0.$2 && o.$2 != right.$2 && !set.any((x) => x.$1 == o.$1))
        .toList()
      ..shuffle(r);
    opts = [right, ...others.take(api.choices - 1)]..shuffle(r);
    options = opts.map((o) => o.$1).toList();
    answer = opts.indexOf(right);
  }

  @override
  String get prompt => 'Which one rhymes with ${prompt0.$1}?';
  @override
  Widget question() => Column(mainAxisSize: MainAxisSize.min, children: [
        qText('What rhymes with…', size: 22),
        const SizedBox(height: 6),
        Pic(prompt0.$2, size: 120),
        qText(prompt0.$1, size: 30),
      ]);
  @override
  Widget option(int i) => Pic(opts[i].$2, size: 64);
  @override
  String label(int i) => opts[i].$1;
  @override
  String praise() => 'That’s right! ${prompt0.$1} and ${opts[answer].$1} rhyme: they sound the same at the end.';
  @override
  String hint(int i) => '${prompt0.$1} and ${opts[i].$1} do not sound the same at the end, so they do not rhyme.';
  @override
  String model() => '${prompt0.$1} and ${opts[answer].$1} rhyme. They end the same way!';
}

// ---------------------------------------------------------------- math

Widget _num(int n) => Text('$n', style: baloo(52, color: Colors.white, height: 1.1));

/// Picture addition and subtraction.
class AddSubGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const AddSubGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<AddSubGame> createState() => _AddSubState();
}

class _AddSubState extends _PickGameState<AddSubGame> {
  late int a, b, result;
  late bool add;
  late String item;
  @override
  GameApi get api => widget.api;
  @override
  String get coach => widget.coach;

  @override
  void setup(Random r) {
    final op = widget.level.p['op'] as String;
    add = op == 'add' || (op == 'mix' && r.nextBool());
    final maxN = ((widget.level.p['max'] as int) + api.delta * 2).clamp(3, 20);
    if (add) {
      a = 1 + r.nextInt(maxN - 1);
      b = 1 + r.nextInt(max(1, maxN - a));
      result = a + b;
    } else {
      a = 2 + r.nextInt(maxN - 1);
      b = 1 + r.nextInt(a - 1);
      result = a - b;
    }
    item = const ['apple', 'orange', '🍓', '🐟', '🐞', '⭐'][(api.round + r.nextInt(6)) % 6];
    options = pickNumbers(r, result, api.choices, 0, 20);
    answer = options.indexOf(result);
  }

  @override
  String get prompt => add ? '$a and $b more. How many altogether?' : '$a, then $b go away. How many are left?';
  @override
  Widget question() {
    final s = max(26.0, 44.0 - (a + (add ? b : 0)));
    Widget group(int n, {int faded = 0}) => ConstrainedBox(
          constraints: BoxConstraints(maxWidth: s * 5.6),
          child: Wrap(spacing: 4, runSpacing: 4, children: [
            for (var i = 0; i < n; i++)
              Opacity(opacity: i >= n - faded ? .3 : 1, child: Stack(alignment: Alignment.center, children: [
                Pic(item, size: s),
                if (i >= n - faded) Icon(Icons.close_rounded, color: C.ink, size: s),
              ])),
          ]),
        );
    return Column(mainAxisSize: MainAxisSize.min, children: [
      qText(add ? '$a + $b = ?' : '$a − $b = ?', size: 36),
      const SizedBox(height: 10),
      if (add)
        Row(mainAxisSize: MainAxisSize.min, children: [
          group(a),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: qText('+', size: 40)),
          group(b),
        ])
      else
        group(a, faded: b),
    ]);
  }

  @override
  Widget option(int i) => _num(options[i] as int);
  @override
  Color? tileColor(int i) => [C.coral, C.blue, C.sun, C.purple][i % 4];
  @override
  Color? tileShadow(int i) => [C.coralDark, C.blueDark, C.amberDark, C.purpleDark][i % 4];
  @override
  String label(int i) => 'Number ${options[i]}';
  @override
  String praise() => add
      ? 'That’s right! $a and $b more make $result. $a plus $b equals $result.'
      : 'That’s right! We had $a, and $b went away, so $result are left. $a take away $b equals $result.';
  @override
  String hint(int i) => add
      ? '$a and $b more is not ${options[i]}. Count all of them together, one by one.'
      : '$a take away $b is not ${options[i]}. Count only the ones that are left, not the crossed-out ones.';
  @override
  String model() => add ? '$a and $b more is $result. Count: ${List.generate(result, (i) => i + 1).join(', ')}.' : '$a take away $b is $result.';
}

/// What comes next / before / missing in a number line (also skip counting).
class NumberOrderGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const NumberOrderGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<NumberOrderGame> createState() => _NumberOrderState();
}

class _NumberOrderState extends _PickGameState<NumberOrderGame> {
  late List<int> seq;
  late int gap, value, step;
  @override
  GameApi get api => widget.api;
  @override
  String get coach => widget.coach;

  @override
  void setup(Random r) {
    step = widget.level.p['step'] as int;
    final maxN = widget.level.p['max'] as int;
    final back = widget.level.p['back'] == true && r.nextBool();
    final count = 5;
    final startMax = max(1, maxN ~/ step - count + 1);
    final start = (step == 1 ? 1 : 0) + r.nextInt(startMax) * 1;
    seq = [for (var i = 0; i < count; i++) (start + i) * step];
    if (back) seq = seq.reversed.toList();
    final mode = widget.level.p['mode'] as String;
    gap = mode == 'next' ? count - 1 : (mode == 'missing' ? 1 + r.nextInt(count - 2) : r.nextInt(count));
    value = seq[gap];
    final near = {for (var d = -2; d <= 2; d++) value + d * step}.where((v) => v >= 0).toList();
    options = _pick<int>(r, value, near, api.choices);
    answer = options.indexOf(value);
  }

  @override
  String get prompt => 'Which number is missing?';
  @override
  String get speech => 'Which number is missing? ${[for (var i = 0; i < seq.length; i++) i == gap ? 'hmm' : '${seq[i]}'].join(', ')}';
  @override
  Widget question() => Column(mainAxisSize: MainAxisSize.min, children: [
        qText(step > 1 ? 'Count by ${step}s!' : 'Which number is missing?', size: 24),
        const SizedBox(height: 12),
        Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < seq.length; i++)
            Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == gap ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: i == gap ? Border.all(color: Colors.white, width: 3) : null,
              ),
              child: Text(i == gap ? '?' : '${seq[i]}',
                  style: baloo(34, color: i == gap ? Colors.white : C.greenDark, height: 1.1)),
            ),
        ]),
      ]);
  @override
  Widget option(int i) => _num(options[i] as int);
  @override
  Color? tileColor(int i) => [C.coral, C.blue, C.sun, C.purple][i % 4];
  @override
  Color? tileShadow(int i) => [C.coralDark, C.blueDark, C.amberDark, C.purpleDark][i % 4];
  @override
  String label(int i) => 'Number ${options[i]}';
  @override
  String praise() => 'That’s right! $value goes there: ${seq.join(', ')}.${step > 1 ? ' We count on by $step each time.' : ''}';
  @override
  String hint(int i) => '${options[i]} does not fit there. Count along the line${step > 1 ? ' in ${step}s' : ''} and see which number is missing.';
  @override
  String model() => 'Let’s count: ${seq.join(', ')}. The missing number is $value.';
}

/// Which number is bigger / smaller?
class CompareNumbersGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const CompareNumbersGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<CompareNumbersGame> createState() => _CompareNumbersState();
}

class _CompareNumbersState extends _PickGameState<CompareNumbersGame> {
  late bool bigger;
  late int target;
  @override
  GameApi get api => widget.api;
  @override
  String get coach => widget.coach;

  @override
  void setup(Random r) {
    final maxN = widget.level.p['max'] as int;
    bigger = r.nextBool();
    final nums = <int>{};
    final n = min(api.choices, 3);
    while (nums.length < n) {
      nums.add(r.nextInt(maxN + 1));
    }
    options = nums.toList()..shuffle(r);
    target = bigger ? nums.reduce(max) : nums.reduce(min);
    answer = options.indexOf(target);
  }

  @override
  String get prompt => bigger ? 'Which number is bigger?' : 'Which number is smaller?';
  @override
  Widget question() => Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(bigger ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: Colors.white, size: 90),
        qText(bigger ? 'Which number is bigger?' : 'Which number is smaller?', size: 26),
        if (api.hintLevel >= 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: qText('Count up: the bigger number comes later.', size: 16),
          ),
      ]);
  @override
  Widget option(int i) => _num(options[i] as int);
  @override
  Color? tileColor(int i) => [C.coral, C.blue, C.sun, C.purple][i % 4];
  @override
  Color? tileShadow(int i) => [C.coralDark, C.blueDark, C.amberDark, C.purpleDark][i % 4];
  @override
  String label(int i) => 'Number ${options[i]}';
  @override
  String praise() => 'That’s right! $target is ${bigger ? 'the biggest' : 'the smallest'} number here. When we count, it comes ${bigger ? 'after' : 'before'} the others.';
  @override
  String hint(int i) => '${options[i]} is not the ${bigger ? 'biggest' : 'smallest'}. Count up from zero: the ${bigger ? 'biggest' : 'smallest'} number comes ${bigger ? 'last' : 'first'}.';
  @override
  String model() => '$target is ${bigger ? 'bigger' : 'smaller'}. It comes ${bigger ? 'later' : 'sooner'} when we count.';
}

// ---------------------------------------------------------------- shapes

const solids = {
  'sphere': ('a ball (sphere)', ['⚽', '🏀', '🌍', '🔮', 'orange']),
  'cube': ('a box (cube)', ['🎲', '🧊', '📦', '🎁']),
  'cylinder': ('a can (cylinder)', ['🥫', '🔋', '🥤', '🪵']),
  'cone': ('a cone', ['🍦', '🎉']),
};

class SolidGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const SolidGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<SolidGame> createState() => _SolidState();
}

class _SolidState extends _PickGameState<SolidGame> {
  late String kind;
  late List<String> kinds;
  @override
  GameApi get api => widget.api;
  @override
  String get coach => widget.coach;

  @override
  void setup(Random r) {
    final keys = solids.keys.toList();
    kind = keys[(api.round + r.nextInt(4)) % 4];
    kinds = _pick<String>(r, kind, keys, min(api.choices, 4));
    options = [for (final k in kinds) solids[k]!.$2[r.nextInt(solids[k]!.$2.length)]];
    answer = kinds.indexOf(kind);
  }

  @override
  String get prompt => 'Which one is shaped like ${solids[kind]!.$1}?';
  @override
  Widget question() => Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 90),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: qText('Which one is shaped like ${solids[kind]!.$1}?', size: 24),
        ),
      ]);
  @override
  Widget option(int i) => Pic('${options[i]}', size: 64);
  @override
  String label(int i) => kinds[i];
  @override
  String praise() => 'That’s right! That is shaped like ${solids[kind]!.$1}.';
  @override
  String hint(int i) => 'That is shaped like ${solids[kinds[i]]!.$1}, not like ${solids[kind]!.$1}.';
  @override
  String model() => 'This one is shaped like ${solids[kind]!.$1}.';
}

/// Position words: on, under, next to, in.
class PositionGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const PositionGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<PositionGame> createState() => _PositionState();
}

class _PositionState extends _PickGameState<PositionGame> {
  static const words = ['on', 'under', 'next to', 'in'];
  late String where;
  late String pet;
  late String thing;
  @override
  GameApi get api => widget.api;
  @override
  String get coach => widget.coach;

  @override
  void setup(Random r) {
    pet = const ['🐱', '🐶', '🐰', '🐸', '🐭'][(api.round + r.nextInt(5)) % 5];
    thing = const ['📦', '🪑', '🛏️'][r.nextInt(3)];
    final pool = thing == '📦' ? words : words.take(3);
    where = pool.toList()[r.nextInt(pool.length)];
    options = _pick<String>(r, where, pool, min(api.choices, pool.length));
    answer = options.indexOf(where);
  }

  String get thingName => switch (thing) { '📦' => 'box', '🪑' => 'chair', _ => 'bed' };

  @override
  String get prompt => 'Find the picture: the animal is $where the $thingName.';
  @override
  Widget question() => Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [Pic(pet, size: 70), Pic(thing, size: 90)]),
        const SizedBox(height: 8),
        qText('Find: $where the $thingName', size: 28),
      ]);
  @override
  Widget option(int i) {
    final w = options[i] as String;
    const s = 100.0;
    final pos = switch (w) {
      'on' => const Offset(.5, .2),
      'under' => const Offset(.5, .92),
      'next to' => const Offset(.12, .62),
      _ => const Offset(.5, .62),
    };
    return SizedBox.square(
      dimension: s,
      child: Stack(children: [
        Positioned(left: s * .3, top: s * .4, child: Pic(thing, size: s * .48)),
        if (w == 'in')
          Positioned(left: s * pos.dx - s * .12, top: s * pos.dy - s * .18, child: Pic(pet, size: s * .24))
        else
          Positioned(left: s * pos.dx - s * .15, top: s * pos.dy - s * .15, child: Pic(pet, size: s * .3)),
      ]),
    );
  }

  @override
  String label(int i) => '${options[i]} the $thingName';
  @override
  String praise() => 'That’s right! In this picture the animal is $where the $thingName.';
  @override
  String hint(int i) => 'In that picture the animal is ${options[i]} the $thingName, not $where it.';
  @override
  String model() => 'Here it is: $where the $thingName.';
}

/// How many triangles (etc.) can you see?
class ShapeCountGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const ShapeCountGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<ShapeCountGame> createState() => _ShapeCountState();
}

class _ShapeCountState extends _PickGameState<ShapeCountGame> {
  late ShapeKind target;
  late List<(ShapeKind, double, Color)> items;
  late int n;
  @override
  GameApi get api => widget.api;
  @override
  String get coach => widget.coach;

  @override
  void setup(Random r) {
    const kinds = [ShapeKind.circle, ShapeKind.square, ShapeKind.triangle, ShapeKind.rectangle, ShapeKind.star];
    target = kinds[(api.round + r.nextInt(5)) % 5];
    n = 1 + r.nextInt((4 + widget.level.difficulty + api.delta).clamp(2, 8));
    final others = 2 + r.nextInt(4);
    const palette = [C.red, C.blue, C.gold, C.green, C.purple];
    items = [
      for (var i = 0; i < n; i++) (target, r.nextDouble() * 60 - 30, palette[r.nextInt(5)]),
      for (var i = 0; i < others; i++) (kinds.where((k) => k != target).toList()[r.nextInt(4)], r.nextDouble() * 60 - 30, palette[r.nextInt(5)]),
    ]..shuffle(r);
    options = pickNumbers(r, n, api.choices, 1, 10);
    answer = options.indexOf(n);
  }

  @override
  String get prompt => 'How many ${target.name}s can you see?';
  @override
  Widget question() => Column(mainAxisSize: MainAxisSize.min, children: [
        qText('How many ${target.name}s?', size: 26),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            for (final (k, rot, c) in items)
              Container(
                decoration: api.hintLevel >= 2 && k == target
                    ? BoxDecoration(border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(12))
                    : null,
                child: ShapeArt(k, size: 54, color: c, rotation: rot),
              ),
          ]),
        ),
      ]);
  @override
  Widget option(int i) => _num(options[i] as int);
  @override
  Color? tileColor(int i) => [C.coral, C.blue, C.sun, C.purple][i % 4];
  @override
  Color? tileShadow(int i) => [C.coralDark, C.blueDark, C.amberDark, C.purpleDark][i % 4];
  @override
  String label(int i) => 'Number ${options[i]}';
  @override
  String praise() => 'That’s right! There ${n == 1 ? 'is' : 'are'} $n ${target.name}${n == 1 ? '' : 's'}. We only count the ${target.name}s.';
  @override
  String hint(int i) => 'There are not ${options[i]} ${target.name}s. Count only the ${target.name}s, touching each one once.';
  @override
  String model() => 'Look at the shining ones: there are $n.';
}

// ---------------------------------------------------------------- feelings

class FeelingsGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const FeelingsGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<FeelingsGame> createState() => _FeelingsState();
}

class _FeelingsState extends _PickGameState<FeelingsGame> {
  late Scenario sc;
  @override
  GameApi get api => widget.api;
  @override
  String get coach => widget.coach;

  @override
  void setup(Random r) {
    final off = widget.level.p['offset'] as int;
    sc = feelingsBook[(off + api.round * 7) % feelingsBook.length];
    const faces = ['face:happy', 'face:sad', 'face:sleepy', 'face:scared', 'face:surprised', 'face:cross', 'face:proud'];
    // Never offer a feeling that could also fairly be right.
    final pool = faces.where((f) => !(closeFeelings[sc.feeling] ?? const <String>{}).contains(f)).toList();
    options = _pick<String>(r, sc.feeling, pool, min(api.choices, 3));
    answer = options.indexOf(sc.feeling);
  }

  String _name(String f) => f.substring(5) == 'cross' ? 'cross' : f.substring(5);

  @override
  String get prompt => '${sc.text} How would you feel?';
  @override
  Widget question() => Column(mainAxisSize: MainAxisSize.min, children: [
        Pic(sc.pic, size: 110),
        const SizedBox(height: 8),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 360), child: qText(sc.text, size: 24)),
        const SizedBox(height: 6),
        qText('How would you feel?', size: 18),
      ]);
  @override
  Widget option(int i) => Pic('${options[i]}', size: 70);
  @override
  String label(int i) => _name('${options[i]}');
  @override
  String praise() => 'That’s right! ${sc.text} Most people would feel ${_name(sc.feeling)}. It’s okay to feel that way.';
  @override
  String hint(int i) => 'Most people would not feel ${_name('${options[i]}')} here. Think about what happened: ${sc.text}';
  @override
  String model() => 'Many people would feel ${_name(sc.feeling)}. All feelings are okay.';
}

/// Feelings that are too close to tell apart fairly in a scenario.
const closeFeelings = <String, Set<String>>{
  'face:happy': {'face:proud', 'face:surprised'},
  'face:proud': {'face:happy', 'face:surprised'},
  'face:surprised': {'face:happy', 'face:proud', 'face:scared'},
  'face:scared': {'face:surprised', 'face:sad'},
  'face:sad': {'face:scared', 'face:cross', 'face:sleepy'},
  'face:cross': {'face:sad'},
  'face:sleepy': {'face:sad'},
};
