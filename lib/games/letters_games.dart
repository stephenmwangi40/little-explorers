import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../content/levels.dart';
import '../content/phonics.dart';
import '../core/audio.dart';
import '../core/responsive.dart';
import '../core/state/scope.dart';
import '../core/theme.dart';
import '../core/widgets/art.dart';
import '../core/widgets/buttons.dart';
import '../core/widgets/glass.dart';
import 'game_shell.dart';

List<String> _distractors(String target, List<String> taught, int n, Random r) {
  final sound = speakSound[target];
  // Choices come from the sounds taught so far plus the current phonics set.
  final all = {...taught, ...phonicsSets[setOf(target) - 1]}.toList();
  final pool = all.where((g) => g != target && speakSound[g] != sound).toList()..shuffle(r);
  // Prefer recently taught sounds: they need the most practice.
  pool.sort((a, b) => all.indexOf(b).compareTo(all.indexOf(a)));
  return (pool.take(n + 2).toList()..shuffle(r)).take(n).toList();
}

// ---------------------------------------------------------------- letter sound

class LetterSoundGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const LetterSoundGame({super.key, required this.level, required this.api, required this.coach});

  @override
  State<LetterSoundGame> createState() => _LetterSoundGameState();
}

class _LetterSoundGameState extends State<LetterSoundGame> {
  late final String target;
  late final Keyword kw;
  late final List<String> options;
  late final int correct;

  @override
  void initState() {
    super.initState();
    final api = widget.api;
    final targets = (widget.level.p['targets'] as List).cast<String>();
    final taught = (widget.level.p['taught'] as List).cast<String>();
    target = targets.length > 2 ? targets[api.rng.nextInt(targets.length)] : targets[api.round % targets.length];
    final kws = keywords[target]!;
    kw = kws[(api.round ~/ targets.length + api.rng.nextInt(2)) % kws.length];
    options = [target, ..._distractors(target, taught, api.choices - 1, api.rng)]..shuffle(api.rng);
    correct = options.indexOf(target);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
  }

  void _prompt() => widget.api.say('Listen… /$target/ /$target/ ${kw.word}!',
      speech: 'Which letter says ${speakSound[target]}? ${speakSound[target]}, ${speakSound[target]}, ${kw.word}!');

  void _pick(int i) {
    if (i == correct) {
      widget.api.correct(
          skill: 'snd_$target',
          praise: 'That’s right! The letter $target says /$target/. You can hear /$target/ '
              '${kw.ending ? 'at the end of' : 'in'} ${kw.word}.');
    } else {
      final g = options[i];
      final other = keywords[g]!.first.word;
      widget.api.wrong(
        skill: 'snd_$target',
        hint: 'The letter $g says /$g/, like $other. We are listening for /$target/, like ${kw.word}.',
        model: 'The letter $target says /$target/, like ${kw.word}.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    // Blank the sound where it appears: start, middle (vowel teams) or end.
    final at = kw.ending ? kw.word.lastIndexOf(target) : kw.word.indexOf(target);
    final before = at <= 0 ? '' : kw.word.substring(0, at);
    final after = at < 0 ? kw.word : kw.word.substring(at + target.length);
    final blank = Container(
      width: 30.0 * target.length + 10,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white, width: 6))),
    );
    return GameSplit(
      leftHanded: api.leftHanded,
      onSpeaker: _prompt,
      question: Column(mainAxisSize: MainAxisSize.min, children: [
        Pic(kw.pic, size: 120),
        const SizedBox(height: 8),
        Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (before.isNotEmpty) Text(before, style: baloo(46, color: Colors.white, height: 1)),
          blank,
          if (after.isNotEmpty) Text(after, style: baloo(46, color: Colors.white, height: 1)),
        ]),
        const SizedBox(height: 8),
        qText('Which letter says /$target/?', size: 19),
      ]),
      coach: gameCoach(widget.coach),
      answers: ChoiceRow(
        count: options.length,
        correctIndex: correct,
        hintLevel: api.hintLevel,
        label: (i) => 'Letter ${options[i]}',
        color: (i) => ChoiceRow.tileColors[i % 4].$1,
        shadow: (i) => ChoiceRow.tileColors[i % 4].$2,
        builder: (i) => Text(options[i], style: baloo(52, color: Colors.white, height: 1.1)),
        onPick: _pick,
      ),
    );
  }
}

// ---------------------------------------------------------------- blend

class BlendGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const BlendGame({super.key, required this.level, required this.api, required this.coach});

  @override
  State<BlendGame> createState() => _BlendGameState();
}

class _BlendGameState extends State<BlendGame> {
  late final BlendWord word;
  late final List<BlendWord> options;
  late final int correct;
  final Set<int> _said = {};
  int? _saying;
  bool _blended = false;

  @override
  void initState() {
    super.initState();
    final taught = (widget.level.p['taught'] as List).cast<String>();
    final pool = <BlendWord>[];
    final only = widget.level.p['only'] as int?;
    for (final ws in only != null ? [blendWords[only]!] : blendWords.values) {
      for (final w in ws) {
        if ((only != null || w.sounds.every(taught.contains)) && pool.every((p) => p.pic != w.pic)) pool.add(w);
      }
    }
    final r = widget.api.rng;
    // Favour words with the newest sounds.
    int newest(BlendWord w) => w.sounds.map(taught.indexOf).reduce(max);
    pool.sort((a, b) => newest(b).compareTo(newest(a)));
    final top = pool.take(max(4, pool.length ~/ 2)).toList();
    word = top[(widget.api.round + r.nextInt(top.length)) % top.length];
    final others = pool.where((w) => w.word != word.word).toList()..shuffle(r);
    options = [word, ...others.take(widget.api.choices - 1)]..shuffle(r);
    correct = options.indexOf(word);
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.api.say('Tap each sound, then blend!'));
  }

  void _sound(int i) {
    setState(() {
      _said.add(i);
      _saying = i;
    });
    Audio.I.sfx('tap');
    widget.api.say('/${word.sounds[i]}/');
    Timer(const Duration(milliseconds: 650), () {
      if (mounted && _saying == i) setState(() => _saying = null);
    });
  }

  void _blend() {
    setState(() => _blended = true);
    final parts = word.sounds.map((s) => '/$s/').join(' ');
    widget.api.say('$parts… ${word.word}! Which picture is ${word.word}?',
        speech: '${word.sounds.map((s) => speakSound[s]).join('… ')}… ${word.word}! Which picture is ${word.word}?');
  }

  void _pick(int i) {
    if (i == correct) {
      final parts = word.sounds.map((s) => '/$s/').join(' ');
      widget.api.correct(praise: 'That’s right! $parts blend together to make ${word.word}, and this picture is ${word.word}.');
    } else {
      final w = options[i];
      final parts = word.sounds.map((s) => '/$s/').join(' ');
      widget.api.wrong(
        hint: 'That picture is ${w.word}, which sounds ${w.sounds.map((s) => '/$s/').join(' ')}. '
            'We blended $parts, which makes ${word.word}.',
        model: '$parts makes ${word.word}. The ${word.word} is shining.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return Responsive(builder: (context, l) {
      final w = l.large ? 96.0 : 70.0;
      final h = l.large ? 116.0 : 84.0;
      final tiles = Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < word.sounds.length; i++)
          AnimatedContainer(
            duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 500),
            margin: EdgeInsets.symmetric(horizontal: _blended ? 0 : 5),
            child: Semantics(
              button: true,
              label: 'Sound ${word.sounds[i]}',
              child: GestureDetector(
                onTap: () => _sound(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: w * (word.sounds[i].length > 1 ? 1.3 : 1),
                  height: h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (_blended || _saying == i) ? Colors.white : Colors.white.withValues(alpha: .18),
                    border: Border.all(color: Colors.white.withValues(alpha: .7), width: 2),
                    borderRadius: _blended
                        ? BorderRadius.horizontal(
                            left: Radius.circular(i == 0 ? 20 : 0),
                            right: Radius.circular(i == word.sounds.length - 1 ? 20 : 0))
                        : BorderRadius.circular(20),
                  ),
                  child: Text(word.sounds[i],
                      style: baloo(h * .62,
                          color: (_blended || _saying == i) ? C.coralDark : Colors.white, height: 1.1)),
                ),
              ),
            ),
          ),
      ]);
      return GameSplit(
        leftHanded: api.leftHanded,
        question: Column(mainAxisSize: MainAxisSize.min, children: [
          qText(_blended ? 'Which picture is it?' : 'Tap each sound, then blend!', size: 19),
          const SizedBox(height: 14),
          tiles,
          const SizedBox(height: 18),
          if (!_blended)
            ChunkyButton.text('Blend it!',
                onTap: _blend, color: Colors.white, shadow: const Color(0x331F2A44), textColor: C.coralDark),
        ]),
        coach: gameCoach(widget.coach),
        answers: _blended
            ? ChoiceRow(
                count: options.length,
                correctIndex: correct,
                hintLevel: api.hintLevel,
                label: (i) => options[i].word,
                builder: (i) => Pic(options[i].pic, size: 64),
                onPick: _pick,
              )
            : null,
      );
    });
  }
}

// ---------------------------------------------------------------- trace

/// Start dot (x, y in the letter's ink box) and first direction for each
/// traced letter, so children learn correct formation.
const _starts = <String, List<double>>{
  'a': [.86, .28, -1, 0], 'b': [.14, .02, 0, 1], 'c': [.86, .22, -1, 0], 'd': [.62, .42, -1, 0],
  'e': [.1, .55, 1, 0], 'f': [.85, .1, -1, 0], 'g': [.84, .12, -1, 0], 'h': [.14, .02, 0, 1],
  'i': [.5, .32, 0, 1], 'k': [.14, .02, 0, 1], 'l': [.5, .02, 0, 1], 'm': [.08, .05, 0, 1],
  'n': [.12, .05, 0, 1], 'o': [.5, .03, -1, 0], 'p': [.14, .03, 0, 1], 'r': [.14, .05, 0, 1],
  's': [.84, .16, -1, 0], 't': [.42, .02, 0, 1], 'u': [.12, .03, 0, 1],
  'j': [.62, .3, 0, 1], 'v': [.04, .05, .45, 1], 'w': [.03, .05, .3, 1], 'x': [.05, .05, 1, 1],
  'y': [.06, .04, .5, 1], 'z': [.08, .06, 1, 0],
};

class TraceGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const TraceGame({super.key, required this.level, required this.api, required this.coach});

  @override
  State<TraceGame> createState() => _TraceGameState();
}

class _TraceGameState extends State<TraceGame> {
  static const grid = 60;
  late final String letter = widget.level.p['letter'] as String;
  final List<List<Offset>> _strokes = []; // normalised 0..1 in the box
  List<bool>? _mask;
  Rect _ink = const Rect.fromLTWH(.25, .2, .5, .6);

  @override
  void initState() {
    super.initState();
    _buildMask();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.api.say(_instruction));
  }

  String get _instruction {
    final s = _starts[letter];
    if (s == null) return 'Trace the letter $letter!';
    return s[3] > 0 ? 'Start at the green dot. Go down!' : 'Start at the green dot. Round we go!';
  }

  TextPainter _painter(double box) => TextPainter(
        text: TextSpan(text: letter, style: baloo(box * .78, color: Colors.white, height: 1)),
        textDirection: TextDirection.ltr,
      )..layout();

  /// Rasterises the letter to find where its ink is (for the accuracy check).
  Future<void> _buildMask() async {
    const box = 240.0;
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    final tp = _painter(box);
    tp.paint(c, Offset((box - tp.width) / 2, (box - tp.height) / 2));
    final img = await rec.endRecording().toImage(box.toInt(), box.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null || !mounted) return;
    final mask = List<bool>.filled(grid * grid, false);
    var minX = grid, minY = grid, maxX = 0, maxY = 0;
    for (var gy = 0; gy < grid; gy++) {
      for (var gx = 0; gx < grid; gx++) {
        final px = (gx + .5) * box / grid, py = (gy + .5) * box / grid;
        final a = data.getUint8(((py.toInt() * box.toInt()) + px.toInt()) * 4 + 3);
        if (a > 100) {
          mask[gy * grid + gx] = true;
          minX = min(minX, gx);
          minY = min(minY, gy);
          maxX = max(maxX, gx);
          maxY = max(maxY, gy);
        }
      }
    }
    setState(() {
      _mask = mask;
      if (maxX > minX) _ink = Rect.fromLTRB(minX / grid, minY / grid, (maxX + 1) / grid, (maxY + 1) / grid);
    });
  }

  bool _near(List<bool> m, int x, int y, int r) {
    for (var dy = -r; dy <= r; dy++) {
      for (var dx = -r; dx <= r; dx++) {
        final nx = x + dx, ny = y + dy;
        if (nx >= 0 && ny >= 0 && nx < grid && ny < grid && m[ny * grid + nx]) return true;
      }
    }
    return false;
  }

  /// Returns (accuracy: share of ink on the letter, coverage: share of the
  /// letter that was traced).
  (double, double) _score() {
    final m = _mask;
    final pts = [for (final s in _strokes) ...s];
    if (m == null || pts.length < 8) return (0, 0);
    var on = 0;
    final drawn = List<bool>.filled(grid * grid, false);
    for (final p in pts) {
      final x = (p.dx * grid).floor().clamp(0, grid - 1), y = (p.dy * grid).floor().clamp(0, grid - 1);
      drawn[y * grid + x] = true;
      if (_near(m, x, y, 3)) on++;
    }
    var total = 0, covered = 0;
    for (var y = 0; y < grid; y++) {
      for (var x = 0; x < grid; x++) {
        if (!m[y * grid + x]) continue;
        total++;
        if (_near(drawn, x, y, 4)) covered++;
      }
    }
    return (on / pts.length, total == 0 ? 0 : covered / total);
  }

  void _done() {
    final (acc, cov) = _score();
    if (acc >= .6 && cov >= .5) {
      widget.api.correct(
          praise: 'That’s right! You traced the letter $letter: you followed its shape all the way along.');
    } else if (cov < .5) {
      widget.api.wrong(
          hint: 'Part of the letter $letter is not traced yet. Follow the whole letter, from the green dot to the end.',
          model: 'Start at the green dot and follow the faint letter $letter all the way to the end.',
          retry: 'Try tracing it again.');
      setState(_strokes.clear);
    } else {
      widget.api.wrong(
          hint: 'Your line went off the letter $letter. Start at the green dot and stay on the faint letter.',
          model: 'Start at the green dot and keep your finger on the faint letter $letter.',
          retry: 'Try tracing it again.');
      setState(_strokes.clear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return _TraceSplit(
      leftHanded: api.leftHanded,
      onSpeaker: () => api.say(_instruction),
      coach: gameCoach(widget.coach),
      answers: Row(mainAxisSize: MainAxisSize.min, children: [
        GlassIconButton(
            icon: Icons.close_rounded, label: 'Clear', size: 60, onTap: () => setState(_strokes.clear)),
        const SizedBox(width: 12),
        ChunkyButton.text('Done!', onTap: _done),
      ]),
      box: _traceBox(),
    );
  }

  Widget _traceBox() => LayoutBuilder(builder: (context, c) {
        final box = min(c.maxWidth, c.maxHeight) * .92;
        final start = _starts[letter];
        final pulse = widget.api.hintLevel >= 1;
        return Center(
          child: SizedBox.square(
            dimension: box,
            child: GestureDetector(
              onPanStart: (d) => setState(() => _strokes.add([d.localPosition / box])),
              onPanUpdate: (d) => setState(() => _strokes.last.add(d.localPosition / box)),
              child: CustomPaint(
                painter: _TracePainter(
                  letter: letter,
                  strokes: _strokes,
                  ink: _ink,
                  start: start,
                  pulse: pulse,
                  font: baloo(box * .78, color: Colors.white.withValues(alpha: .5), height: 1),
                ),
              ),
            ),
          ),
        );
      });
}

/// Like [GameSplit], with the drawing area as the question panel.
class _TraceSplit extends StatelessWidget {
  final bool leftHanded;
  final VoidCallback onSpeaker;
  final Widget coach;
  final Widget answers;
  final Widget box;
  const _TraceSplit(
      {required this.leftHanded,
      required this.onSpeaker,
      required this.coach,
      required this.answers,
      required this.box});

  @override
  Widget build(BuildContext context) => Responsive(builder: (context, l) {
        final q = Stack(children: [
          Positioned.fill(child: GlassPanel(child: Padding(padding: const EdgeInsets.all(8), child: box))),
          Positioned(
            top: 0,
            right: 0,
            child: GlassIconButton(icon: Icons.volume_up_rounded, label: 'Hear it again', onTap: onSpeaker),
          ),
        ]);
        final side = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          coach,
          const SizedBox(height: 12),
          Center(child: answers),
        ]);
        if (l.twoCol) {
          final kids = [
            Expanded(flex: 5, child: q),
            const SizedBox(width: 20),
            Expanded(flex: 4, child: Center(child: SingleChildScrollView(child: side))),
          ];
          return Row(children: leftHanded ? kids.reversed.toList() : kids);
        }
        return Column(children: [Expanded(child: q), const SizedBox(height: 12), side]);
      });
}

class _TracePainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> strokes;
  final Rect ink;
  final List<double>? start;
  final bool pulse;
  final TextStyle font;
  _TracePainter(
      {required this.letter,
      required this.strokes,
      required this.ink,
      required this.start,
      required this.pulse,
      required this.font});

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(text: TextSpan(text: letter, style: font), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));

    if (start != null) {
      final p = Offset(ink.left + start![0] * ink.width, ink.top + start![1] * ink.height).scale(size.width, size.height);
      final r = size.width * .045;
      if (pulse) canvas.drawCircle(p, r * 1.9, Paint()..color = Colors.white.withValues(alpha: .6));
      canvas.drawCircle(p, r, Paint()..color = C.green);
      // Direction arrow.
      final d = Offset(start![2], start![3]);
      final a = p + d * r * 2.6;
      final perp = Offset(-d.dy, d.dx);
      final arrow = Path()
        ..moveTo(a.dx - d.dx * r + perp.dx * r * .8, a.dy - d.dy * r + perp.dy * r * .8)
        ..lineTo(a.dx, a.dy)
        ..lineTo(a.dx - d.dx * r - perp.dx * r * .8, a.dy - d.dy * r - perp.dy * r * .8);
      canvas.drawPath(
          arrow,
          Paint()
            ..color = C.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * .55
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }

    final ink2 = Paint()
      ..color = C.tiko
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .065
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final s in strokes) {
      if (s.isEmpty) continue;
      final path = Path()..moveTo(s.first.dx * size.width, s.first.dy * size.height);
      for (final o in s.skip(1)) {
        path.lineTo(o.dx * size.width, o.dy * size.height);
      }
      if (s.length == 1) path.lineTo(s.first.dx * size.width + .1, s.first.dy * size.height);
      canvas.drawPath(path, ink2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

