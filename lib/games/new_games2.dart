import 'dart:math';

import 'package:flutter/material.dart';

import '../content/explore_more.dart';
import '../content/levels.dart';
import '../content/phonics.dart';
import '../core/theme.dart';
import '../core/widgets/art.dart';
import 'game_shell.dart';

/// Common layout for "prompt + picture/word choices" games.
class _Pick extends StatelessWidget {
  final GameApi api;
  final String coach;
  final Widget question;
  final List<Widget> options;
  final List<String> labels;
  final int answer;
  final VoidCallback onSpeaker;
  final void Function(int) onPick;
  final List<Color>? colors;
  const _Pick({
    required this.api,
    required this.coach,
    required this.question,
    required this.options,
    required this.labels,
    required this.answer,
    required this.onSpeaker,
    required this.onPick,
    this.colors,
  });

  @override
  Widget build(BuildContext context) => GameSplit(
        leftHanded: api.leftHanded,
        onSpeaker: onSpeaker,
        question: question,
        coach: gameCoach(coach),
        answers: ChoiceRow(
          count: options.length,
          correctIndex: answer,
          hintLevel: api.hintLevel,
          label: (i) => labels[i],
          color: colors == null ? null : (i) => ChoiceRow.tileColors[i % 4].$1,
          shadow: colors == null ? null : (i) => ChoiceRow.tileColors[i % 4].$2,
          builder: (i) => options[i],
          onPick: onPick,
        ),
      );
}

List<BlendWord> _wordsUpTo(int set) {
  final taught = taughtUpTo(min(set, phonicsSets.length));
  final seen = <String>{};
  return [
    for (final e in blendWords.entries)
      if (e.key <= set)
        for (final w in e.value)
          if ((e.key == 9 || w.sounds.every(taught.contains)) && seen.add(w.pic)) w
  ];
}

// ---------------------------------------------------------------- read a word

/// Real reading: see a written word (no sound given), find its picture.
class ReadWordGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const ReadWordGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<ReadWordGame> createState() => _ReadWordState();
}

class _ReadWordState extends State<ReadWordGame> {
  late BlendWord word;
  late List<BlendWord> opts;

  @override
  void initState() {
    super.initState();
    final r = widget.api.rng;
    final pool = _wordsUpTo(widget.level.p['set'] as int);
    word = pool[(widget.level.number * 3 + widget.api.round * 5 + r.nextInt(pool.length)) % pool.length];
    final others = pool.where((w) => w.pic != word.pic).toList()..shuffle(r);
    opts = [word, ...others.take(widget.api.choices - 1)]..shuffle(r);
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.api.say('Read the word. Which picture is it?'));
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return _Pick(
      api: api,
      coach: widget.coach,
      onSpeaker: () => api.say('Sound it out: ${word.sounds.map((s) => '/$s/').join(' ')}'),
      question: Column(mainAxisSize: MainAxisSize.min, children: [
        qText('Read the word', size: 22),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
          child: Text(word.word, style: baloo(76, color: C.coralDark, height: 1.2)),
        ),
        if (api.hintLevel >= 1) ...[
          const SizedBox(height: 8),
          qText(word.sounds.join(' - '), size: 26),
        ],
      ]),
      options: [for (final o in opts) Pic(o.pic, size: 64)],
      labels: [for (final o in opts) o.word],
      answer: opts.indexOf(word),
      onPick: (i) => opts[i] == word
          ? api.correct(
              praise: 'That’s right! You read “${word.word}”: ${word.sounds.map((s) => '/$s/').join(' ')}, ${word.word}. This is the ${word.word}.')
          : api.wrong(
              hint: 'That picture is ${opts[i].word}, but the word says ${word.word}. Sound it out: ${word.sounds.map((s) => '/$s/').join(' ')}.',
              model: '${word.sounds.map((s) => '/$s/').join(' ')} makes ${word.word}. The ${word.word} is shining.'),
    );
  }
}

// ---------------------------------------------------------------- spelling

/// Spelling: a picture and its word with one sound missing.
class MissingLetterGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const MissingLetterGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<MissingLetterGame> createState() => _MissingLetterState();
}

class _MissingLetterState extends State<MissingLetterGame> {
  late BlendWord word;
  late int gap;
  late List<String> opts;

  @override
  void initState() {
    super.initState();
    final r = widget.api.rng;
    final set = widget.level.p['set'] as int;
    final pool = _wordsUpTo(set);
    word = pool[(widget.level.number * 7 + widget.api.round * 3 + r.nextInt(pool.length)) % pool.length];
    gap = r.nextInt(word.sounds.length);
    final right = word.sounds[gap];
    final taught = taughtUpTo(min(set, phonicsSets.length));
    final others = taught.where((g) => g != right && speakSound[g] != speakSound[right]).toList()..shuffle(r);
    opts = [right, ...others.take(widget.api.choices - 1)]..shuffle(r);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
  }

  void _prompt() => widget.api.say('${word.word}. Which sound is missing?',
      speech: '${word.word}. ${word.sounds.map((s) => speakSound[s] ?? s).join('… ')}. Which sound is missing?');

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return _Pick(
      api: api,
      coach: widget.coach,
      onSpeaker: _prompt,
      colors: const [],
      question: Column(mainAxisSize: MainAxisSize.min, children: [
        Pic(word.pic, size: 110),
        const SizedBox(height: 10),
        Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < word.sounds.length; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              constraints: const BoxConstraints(minWidth: 56, minHeight: 70),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == gap ? Colors.transparent : Colors.white,
                border: i == gap ? Border.all(color: Colors.white, width: 3) : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(i == gap ? '?' : word.sounds[i],
                  style: baloo(46, color: i == gap ? Colors.white : C.coralDark, height: 1.1)),
            ),
        ]),
      ]),
      options: [for (final o in opts) Text(o, style: baloo(50, color: Colors.white, height: 1.1))],
      labels: [for (final o in opts) 'Letter $o'],
      answer: opts.indexOf(word.sounds[gap]),
      onPick: (i) => opts[i] == word.sounds[gap]
          ? api.correct(
              praise: 'That’s right! ${word.word} needs the sound /${word.sounds[gap]}/: ${word.sounds.map((s) => '/$s/').join(' ')}, ${word.word}.')
          : api.wrong(
              hint: '${opts[i]} says /${opts[i]}/. Say the word slowly: ${word.word}. Which sound is missing?',
              model: '${word.word} needs /${word.sounds[gap]}/: ${word.sounds.map((s) => '/$s/').join(' ')}.'),
    );
  }
}

// ---------------------------------------------------------------- clock

class ClockPainter extends ViewBoxPainter {
  final int hour, minute;
  ClockPainter(this.hour, this.minute) : super(100, 100);
  @override
  void draw(Canvas c) {
    c.drawCircle(const Offset(50, 50), 46, fill(Colors.white));
    c.drawCircle(const Offset(50, 50), 46, stroke(C.ink, 3));
    for (var i = 1; i <= 12; i++) {
      final a = (i / 12) * 2 * pi - pi / 2;
      final tp = TextPainter(
        text: TextSpan(text: '$i', style: baloo(9, color: C.ink, height: 1)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, Offset(50 + 37 * cos(a) - tp.width / 2, 50 + 37 * sin(a) - tp.height / 2));
    }
    final ma = (minute / 60) * 2 * pi - pi / 2;
    final ha = ((hour % 12) + minute / 60) / 12 * 2 * pi - pi / 2;
    c.drawLine(const Offset(50, 50), Offset(50 + 24 * cos(ha), 50 + 24 * sin(ha)), stroke(C.coral, 5));
    c.drawLine(const Offset(50, 50), Offset(50 + 34 * cos(ma), 50 + 34 * sin(ma)), stroke(C.blue, 3.5));
    c.drawCircle(const Offset(50, 50), 3.5, fill(C.ink));
  }
}

String timeName(int h, int m) => m == 0 ? '$h o’clock' : 'half past $h';

class ClockGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const ClockGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<ClockGame> createState() => _ClockState();
}

class _ClockState extends State<ClockGame> {
  late (int, int) time;
  late List<(int, int)> opts;

  @override
  void initState() {
    super.initState();
    final r = widget.api.rng;
    final half = widget.level.p['half'] == true;
    (int, int) rand() => (1 + r.nextInt(12), half && r.nextBool() ? 30 : 0);
    time = rand();
    final set = <(int, int)>{time};
    while (set.length < min(widget.api.choices, 3)) {
      set.add(rand());
    }
    opts = set.toList()..shuffle(r);
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.api.say('What time is it?'));
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return _Pick(
      api: api,
      coach: widget.coach,
      onSpeaker: () => api.say('What time is it? The short hand shows the hour.'),
      question: Column(mainAxisSize: MainAxisSize.min, children: [
        qText('What time is it?', size: 24),
        const SizedBox(height: 10),
        SizedBox.square(dimension: 200, child: CustomPaint(painter: ClockPainter(time.$1, time.$2))),
      ]),
      options: [
        for (final o in opts)
          SizedBox(width: 110, child: Text(timeName(o.$1, o.$2), textAlign: TextAlign.center, style: nunito(22, weight: 800, color: C.ink, height: 1.1))),
      ],
      labels: [for (final o in opts) timeName(o.$1, o.$2)],
      answer: opts.indexOf(time),
      onPick: (i) => opts[i] == time
          ? api.correct(praise: 'That’s right! It’s ${timeName(time.$1, time.$2)}. ${clockWhy(time.$1, time.$2)}')
          : api.wrong(
              hint: 'It is not ${timeName(opts[i].$1, opts[i].$2)}. The short orange hand shows the hour, and the long blue hand shows the minutes.',
              model: '${clockWhy(time.$1, time.$2)} So it’s ${timeName(time.$1, time.$2)}.'),
    );
  }
}

// ---------------------------------------------------------------- odd one out

class OddOneOutGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const OddOneOutGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<OddOneOutGame> createState() => _OddState();
}

class _OddState extends State<OddOneOutGame> {
  late List<String> pics;
  late List<String> names;
  late int odd;
  late String why;

  @override
  void initState() {
    super.initState();
    final r = widget.api.rng;
    final useThings = widget.level.difficulty >= 2 && r.nextBool();
    if (useThings) {
      // Two clear groups that cannot be confused (never fruit with vegetable,
      // or a teddy with animals).
      final cats = [...clearCategories]..shuffle(r);
      while ((categoryConflicts[cats[0]] ?? const <String>{}).contains(cats[1])) {
        cats.shuffle(r);
      }
      final same = things.where((t) => t.cat == cats[0]).toList()..shuffle(r);
      final other = things.where((t) => t.cat == cats[1]).toList()..shuffle(r);
      final list = [...same.take(3), other.first]..shuffle(r);
      pics = [for (final t in list) t.pic];
      names = [for (final t in list) t.word];
      odd = list.indexOf(other.first);
      why = 'The ${other.first.word} is not ${categoryNames[cats[0]]}.';
    } else {
      const kinds = ['circle', 'square', 'triangle', 'star', 'rectangle'];
      const cols = ['FFEF476F', 'FF4DA3FF', 'FFFFD166', 'FF3DBE7A', 'FF9B6BFF'];
      final k = [...kinds]..shuffle(r);
      final list = [for (var i = 0; i < 3; i++) 'shape:${k[0]}:${cols[(i + r.nextInt(5)) % 5]}', 'shape:${k[1]}:${cols[r.nextInt(5)]}']
        ..shuffle(r);
      pics = list;
      names = [for (final p in list) p.split(':')[1]];
      odd = list.indexWhere((p) => p.split(':')[1] == k[1]);
      why = 'The others are ${k[0]}s. This one is a ${k[1]}.';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.api.say('Which one does not belong?'));
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return _Pick(
      api: api,
      coach: widget.coach,
      onSpeaker: () => api.say('Three are the same kind. Which one does not belong?'),
      question: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.search_rounded, color: Colors.white, size: 90),
        qText('Which one does not belong?', size: 26),
      ]),
      options: [for (final p in pics) Pic(p, size: 64)],
      labels: names,
      answer: odd,
      onPick: (i) => i == odd
          ? api.correct(praise: 'That’s right! $why So it does not belong.')
          : api.wrong(hint: 'That ${names[i]} belongs with others like it. Look for the one that is different. ', model: why),
    );
  }
}

// ---------------------------------------------------------------- picture quiz

/// Word Garden and Healthy Me questions.
class QuizGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const QuizGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<QuizGame> createState() => _QuizState();
}

class _QuizState extends State<QuizGame> {
  late QuizQ q;

  @override
  void initState() {
    super.initState();
    final p = widget.level.p;
    final api = widget.api;
    q = widget.level.world == WorldId.health
        ? healthQuestion(p['kind'] as String, api.round, p['offset'] as int, api.choices, api.rng)
        : wordQuestion(p['kind'] as String, api.round, p['offset'] as int, api.choices, api.rng);
    WidgetsBinding.instance.addPostFrameCallback((_) => api.say(q.prompt));
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return _Pick(
      api: api,
      coach: widget.coach,
      onSpeaker: () => api.say(q.prompt),
      question: Column(mainAxisSize: MainAxisSize.min, children: [
        if (q.pic != null) ...[Pic(q.pic!, size: 110), const SizedBox(height: 10)],
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 380), child: qText(q.prompt, size: 26)),
      ]),
      options: [for (final c in q.choices) Pic(c, size: 64)],
      labels: q.labels,
      answer: q.answer,
      onPick: (i) => i == q.answer
          ? api.correct(praise: 'That’s right! ${q.explain}')
          : api.wrong(hint: '${q.labels[i][0].toUpperCase()}${q.labels[i].substring(1)} is not the answer. ${q.explain}', model: q.explain),
    );
  }
}

/// Explains how to read the clock face for a time.
String clockWhy(int h, int m) => m == 0
    ? 'The short hand points to $h and the long hand points to 12, so it is exactly $h o’clock.'
    : 'The long hand points to 6, which means half past, and the short hand is just past $h.';
