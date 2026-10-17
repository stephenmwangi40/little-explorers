import 'dart:async';

import 'package:flutter/material.dart';

import '../content/lab_move.dart';
import '../content/levels.dart';
import '../content/stories.dart';
import '../content/stories_extra.dart';
import '../core/audio.dart';
import '../core/responsive.dart';
import '../core/state/scope.dart';
import '../core/theme.dart';
import '../core/widgets/art.dart';
import '../core/widgets/buttons.dart';
import '../core/widgets/glass.dart';
import '../core/widgets/tiko.dart';
import 'game_shell.dart';

// ---------------------------------------------------------------- story

class StoryGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const StoryGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<StoryGame> createState() => _StoryGameState();
}

class _StoryGameState extends State<StoryGame> {
  late final Story story = storyBook[widget.level.p['story'] as int];
  int _page = 0;
  int _word = -1;
  Timer? _t;
  bool get _asking => _page >= story.pages.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _read());
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  /// Narrated read-along: each word lights up in turn.
  void _read() {
    _t?.cancel();
    if (_asking) {
      widget.api.say(story.question);
      return;
    }
    final words = story.pages[_page].split(' ');
    Audio.I.say(story.pages[_page]);
    final slow = AppScope.read(context).settings.slowNarration;
    setState(() => _word = 0);
    _t = Timer.periodic(Duration(milliseconds: slow ? 560 : 420), (t) {
      if (!mounted) return t.cancel();
      if (_word + 1 >= words.length) {
        t.cancel();
        Timer(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _word = -1);
        });
      }
      setState(() => _word++);
    });
  }

  void _turn() {
    setState(() {
      _page++;
      _word = -1;
    });
    _read();
  }

  Widget _illustration(double s) => SizedBox(
        width: 220 * s,
        height: 130 * s,
        child: Stack(children: [
          Positioned(right: 10 * s, top: 0, child: Pic(story.scene.first, size: 70 * s)),
          if (story.scene.length > 1) Positioned(right: 90 * s, top: 34 * s, child: Pic(story.scene[1], size: 48 * s)),
          Positioned(left: 0, bottom: 0, child: SizedBox(width: 120 * s, height: 80 * s, child: CustomPaint(painter: TurtlePainter()))),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    final captions = AppScope.of(context).settings.captions;
    return Responsive(builder: (context, l) {
      final words = _asking ? <String>[] : story.pages[_page].split(' ');
      final page = Column(mainAxisSize: MainAxisSize.min, children: [
        _illustration(l.large ? 1.6 : 1),
        const SizedBox(height: 8),
        if (!_asking && captions)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Wrap(alignment: WrapAlignment.center, children: [
              for (var i = 0; i < words.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                      color: i == _word ? C.gold : Colors.transparent, borderRadius: BorderRadius.circular(6)),
                  child: Text(words[i], style: baloo(l.large ? 28 : 21, weight: 700, color: C.ink, height: 1.35)),
                ),
            ]),
          ),
        if (_asking)
          Text(story.question,
              textAlign: TextAlign.center, style: baloo(l.large ? 24 : 19, color: const Color(0xFFC9507A))),
        const SizedBox(height: 4),
        Text(_asking ? '' : 'Page ${_page + 1} of ${story.pages.length}', style: nunito(12, color: C.muted)),
      ]);
      final next = Row(mainAxisSize: MainAxisSize.min, children: [
        GlassIconButton(icon: Icons.replay_rounded, label: 'Read it again', color: Colors.white, onTap: _read),
        const SizedBox(width: 10),
        ChunkyButton.text(_page == story.pages.length - 1 ? 'Question' : 'Next page',
            icon: Icons.arrow_forward_rounded, onTap: _turn),
      ]);
      return Column(children: [
        Expanded(
          child: GameSplit(
            leftHanded: api.leftHanded,
            question: page,
            onSpeaker: _read,
            coach: gameCoach(_asking ? widget.coach : 'Listen to the story…', size: 58),
            answers: _asking
                ? ChoiceRow(
                    count: story.choices.length,
                    correctIndex: story.answer,
                    hintLevel: api.hintLevel,
                    label: (i) => story.choices[i].startsWith('face:') ? story.choices[i].substring(5) : 'picture ${i + 1}',
                    builder: (i) => Pic(story.choices[i], size: 70),
                    onPick: (i) {
                      String? face(int k) =>
                          story.choices[k].startsWith('face:') ? story.choices[k].substring(5) : null;
                      final clue = story.hint.endsWith('?') ? '' : ' ${story.hint}';
                      if (i == story.answer) {
                        api.correct(
                            praise: story.feelings
                                ? 'That’s right! The answer is ${face(i)}.$clue You noticed how they feel.'
                                : 'That’s right!$clue You listened carefully to the story.');
                      } else {
                        api.wrong(
                            hint: face(i) != null
                                ? 'Not ${face(i)}. ${story.hint}'
                                : 'That is not what happened in the story. ${story.hint}',
                            model: 'Let’s look back. ${story.pages.join(' ')}');
                      }
                    },
                  )
                : next,
          ),
        ),
      ]);
    });
  }
}

// ---------------------------------------------------------------- wonder lab

class LabGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const LabGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<LabGame> createState() => _LabGameState();
}

class _LabGameState extends State<LabGame> {
  late final LabTopic topic = allLabTopics.firstWhere((t) => t.id == widget.level.p['topic']);
  late final LabItem item;
  int? _guess;
  bool _tested = false;

  @override
  void initState() {
    super.initState();
    final off = widget.level.p['offset'] as int;
    item = topic.items[(off + widget.api.round) % topic.items.length];
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.api.say('${topic.question(item)} What do you think?'));
  }

  bool _revealing = false;

  String get _rightLabel => topic.optionLabels[item.truth];

  /// First tap: the child predicts, we test it, then say plainly whether the
  /// prediction was right and why. After a wrong prediction the child must tap
  /// the correct answer (it shines) before moving on.
  void _predict(int i) {
    if (_revealing) return;
    if (_tested) {
      if (i == item.truth) {
        widget.api.correct(praise: 'That’s right! ${item.explain}');
      } else {
        widget.api.wrong(
            hint: 'Look at what happened. ${item.explain}',
            model: item.explain,
            retry: 'Tap “$_rightLabel”.');
      }
      return;
    }
    setState(() {
      _guess = i;
      _revealing = true;
    });
    Audio.I.sfx('tap');
    widget.api.say('You said “${topic.optionLabels[i]}”. Let’s test it and see…');
    Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        _tested = true;
        _revealing = false;
      });
      if (i == item.truth) {
        widget.api.correct(praise: 'That’s right! ${item.explain}');
      } else {
        widget.api.wrong(
            hint: 'You said “${topic.optionLabels[i]}”, but look what happened. ${item.explain}',
            model: item.explain,
            retry: 'Now tap “$_rightLabel”.');
      }
    });
  }

  Widget _stage(Layout l) {
    final s = l.large ? 1.35 : 1.0;
    if (topic.id == 'float') {
      final floats = item.truth == 0;
      return SizedBox(
        width: 220 * s,
        height: 200 * s,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(children: [
            Positioned.fill(child: Container(color: Colors.white.withValues(alpha: .2))),
            Positioned(left: 0, right: 0, bottom: 0, height: 124 * s, child: Container(color: const Color(0xFF5FB8FF))),
            Positioned(left: 0, right: 0, bottom: 124 * s, height: 4, child: Container(color: const Color(0xFFBFE3FF))),
            AnimatedPositioned(
              duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 1200),
              curve: Curves.easeOutBack,
              left: 110 * s - 35 * s,
              top: !_tested ? 6 * s : (floats ? 52 * s : 128 * s),
              child: Pic(item.pic, size: 70 * s),
            ),
          ]),
        ),
      );
    }
    if (topic.id == 'magnet') {
      final pulls = item.truth == 0;
      return SizedBox(
        width: 260 * s,
        height: 140 * s,
        child: Stack(children: [
          Positioned(left: 0, top: 30 * s, child: Pic('🧲', size: 80 * s)),
          AnimatedPositioned(
            duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 900),
            curve: Curves.easeIn,
            left: _tested && pulls ? 80 * s : 180 * s,
            top: 40 * s,
            child: Pic(item.pic, size: 64 * s),
          ),
        ]),
      );
    }
    return Pic(item.pic, size: 120 * s);
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return Responsive(builder: (context, l) {
      final opts = Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 12, children: [
        for (var i = 0; i < topic.options.length; i++)
          Opacity(
                  opacity: _revealing && _guess != i ? .5 : 1,
                  child: ChunkyButton(
                    onTap: _revealing ? null : () => _predict(i),
                    color: _tested && i == item.truth ? C.green : Colors.white,
                    shadow: _tested && i == item.truth ? C.greenDark : const Color(0x331F2A44),
                    semantics: topic.optionLabels[i],
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Pic(topic.options[i], size: 34),
                      const SizedBox(width: 8),
                      Text(topic.optionLabels[i],
                          style: baloo(20, color: _tested && i == item.truth ? Colors.white : C.blueDark)),
                    ]),
                  ),
                ),
      ]);
      return GameSplit(
        leftHanded: api.leftHanded,
        onSpeaker: () => api.say(topic.question(item)),
        question: Column(mainAxisSize: MainAxisSize.min, children: [
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360), child: qText(topic.question(item), size: 22)),
          const SizedBox(height: 12),
          _stage(l),
        ]),
        coach: gameCoach(widget.coach, mood: _tested ? TikoMood.cheer : TikoMood.think),
        answers: opts,
      );
    });
  }
}

// ---------------------------------------------------------------- move & groove

class MoveGame extends StatefulWidget {
  final Level level;
  final GameApi api;
  final String coach;
  const MoveGame({super.key, required this.level, required this.api, required this.coach});
  @override
  State<MoveGame> createState() => _MoveGameState();
}

class _MoveGameState extends State<MoveGame> {
  late final Move move;
  late final int reps;
  int _count = 0;
  int _pop = 0;

  @override
  void initState() {
    super.initState();
    final idx = (widget.level.p['moves'] as List).cast<int>();
    move = moves[idx[widget.api.round % idx.length]];
    reps = move.breath ? 3 : (widget.level.p['reps'] as int) + (widget.api.age >= 6 ? 2 : 0);
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.api.say(_title));
  }

  String get _title => move.breath ? 'Calm break! ${move.name}, $reps times' : 'Wiggle break! ${move.name} $reps times';

  void _tap() {
    if (_count >= reps) return;
    setState(() {
      _count++;
      _pop++;
    });
    Audio.I.sfx('tap');
    if (_count >= reps) {
      Audio.I.sfx('correct');
      widget.api.finishRound(
          praise: move.breath
              ? 'Well done! You took $reps slow breaths. Slow breathing helps your body feel calm.'
              : 'Well done! You did it $reps times. Moving makes your body strong and helps your brain wake up.');
    } else {
      widget.api.say(move.breath ? (_count.isOdd ? 'Breathe in… and out.' : 'Slowly in… and out.') : '$_count!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    final verb = move.verb[0].toUpperCase() + move.verb.substring(1);
    return Responsive(builder: (context, l) {
      return Column(children: [
        qText(move.breath ? '${move.name} $reps times' : 'Wiggle break! ${move.name} $reps times',
            size: l.large ? 28 : 22, color: C.ink),
        const SizedBox(height: 10),
        Expanded(
          child: GameSplit(
            leftHanded: api.leftHanded,
            question: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Tiko(size: 140, mood: move.breath ? TikoMood.idle : (move.verb == 'flap' ? TikoMood.cheer : TikoMood.jump)),
                const SizedBox(width: 6),
                Pic(move.pic, size: 64),
              ]),
              Pop(
                trigger: _pop,
                child: Text('$_count/$reps', style: baloo(76, color: C.ink, height: 1)),
              ),
            ]),
            answers: Column(mainAxisSize: MainAxisSize.min, children: [
              ChunkyButton(
                onTap: _count >= reps ? null : _tap,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                semantics: '$verb! Tap each time',
                child: Text('$verb!', style: baloo(28, color: Colors.white)),
              ),
              const SizedBox(height: 10),
              Text(move.breath ? 'Tap after each breath' : 'Tap each time you $verb'.toLowerCase().replaceFirst('tap', 'Tap'),
                  style: nunito(15, color: C.ink.withValues(alpha: .75))),
            ]),
          ),
        ),
      ]);
    });
  }
}
