import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../content/levels.dart';
import '../core/audio.dart';
import '../core/responsive.dart';
import '../core/state/scope.dart';
import '../core/theme.dart';
import '../core/widgets/buttons.dart';
import '../core/widgets/glass.dart';
import '../core/widgets/scene.dart';
import '../core/widgets/tiko.dart';
import '../features/reward.dart';
import '../learning/mastery.dart';
import 'games.dart';

/// What a game can ask of the shell.
class GameApi {
  final int round;
  final int rounds;
  final int hintLevel; // 0 none, 1 replay/hint, 2 model (highlight), 3 together
  final int choices; // adaptive: 2..4
  final int delta; // adaptive difficulty: -1, 0, +1
  final int age;
  final bool leftHanded;
  final Random rng;
  final void Function(String text, {String? speech}) say;
  final void Function({String? skill, String? praise}) correct;
  final void Function({String? hint, String? skill, String? model, String? retry}) wrong;
  final void Function({String? praise}) finishRound; // for activities with no wrong answers

  const GameApi({
    required this.round,
    required this.rounds,
    required this.hintLevel,
    required this.choices,
    required this.delta,
    required this.age,
    required this.leftHanded,
    required this.rng,
    required this.say,
    required this.correct,
    required this.wrong,
    required this.finishRound,
  });
}

class GameShell extends StatefulWidget {
  final Level level;
  final bool adventure;
  const GameShell({super.key, required this.level, this.adventure = false});

  @override
  State<GameShell> createState() => _GameShellState();
}

class _GameShellState extends State<GameShell> {
  int _round = 0;
  int _hint = 0;
  int _earned = 0;
  bool _busy = false;
  String _coach = '';
  // Duolingo-style instant feedback banner: null, true (right) or false (try again).
  bool? _feedback;
  String _feedbackText = '';
  late int _rounds;
  final _rng = Random();
  Timer? _t;

  Level get level => widget.level;

  @override
  void initState() {
    super.initState();
    final s = AppScope.read(context);
    _rounds = roundsFor(level, widget.adventure ? s.roundsPerStep : 5);
    Audio.I.musicOff();
  }

  @override
  void dispose() {
    _t?.cancel();
    Audio.I.stopSpeaking();
    super.dispose();
  }

  void _say(String text, {String? speech}) {
    if (!mounted) return;
    setState(() => _coach = text);
    Audio.I.say(text, speech: speech);
  }

  /// A right answer: explain why it is right, then wait for "Next".
  void _correct({String? skill, String? praise}) {
    if (_busy) return;
    _busy = true;
    final s = AppScope.read(context);
    s.recordAnswer(skill ?? level.skill, ok: true, hint: _hint > 0);
    Audio.I.sfx('correct');
    HapticFeedback.mediumImpact();
    final line = praise ?? 'That’s right! Well done!';
    _showFeedback(true, line);
    _earned++;
  }

  /// A wrong answer is called wrong, explained, and the child tries again.
  /// The game never moves on until the right answer is chosen.
  void _wrong({String? hint, String? skill, String? model, String? retry}) {
    if (_busy) return;
    final s = AppScope.read(context);
    s.recordAnswer(skill ?? level.skill, ok: false);
    Audio.I.sfx('try');
    HapticFeedback.lightImpact();
    setState(() => _hint++);
    final why = hint ?? 'Look again carefully.';
    // From the second miss, Tiko shows the right answer (it shines) and the
    // child still has to choose it.
    final line = _hint >= 2
        ? 'That’s not right. ${model ?? why} ${retry ?? 'Now tap the shining answer.'}'
        : 'That’s not right. $why ${retry ?? 'Try again!'}';
    _showFeedback(false, line);
  }

  void _showFeedback(bool right, String text) {
    if (!mounted) return;
    setState(() {
      _feedback = right;
      _feedbackText = text;
    });
    Audio.I.say(text);
  }

  void _tryAgain() {
    if (!mounted) return;
    setState(() => _feedback = null);
  }

  void _next() {
    if (!mounted) return;
    _feedback = null;
    if (_round + 1 >= _rounds) {
      final s = AppScope.read(context);
      s.completeLevel(level, learned: widget.adventure ? learnedLabel(level) : null);
      if (widget.adventure) s.advanceAdventure();
      go(context, RewardScreen(level: level, adventure: widget.adventure), replace: true);
      return;
    }
    setState(() {
      _round++;
      _hint = 0;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final ws = WorldStyle.of(level.world);
    final rec = s.skill(level.skill);
    final delta = MasteryEngine.difficultyDelta(rec);
    final age = s.current?.age ?? 4;
    final choices = ((age <= 3 ? 2 : 3) + delta + (level.difficulty >= 3 ? 1 : 0)).clamp(2, 4);
    final api = GameApi(
      round: _round,
      rounds: _rounds,
      hintLevel: _hint,
      choices: choices,
      delta: delta,
      age: age,
      leftHanded: s.settings.leftHanded,
      rng: _rng,
      say: _say,
      correct: _correct,
      wrong: _wrong,
      finishRound: ({String? praise}) {
        if (_busy) return;
        _busy = true;
        _earned++;
        Audio.I.sfx('correct');
        _showFeedback(true, praise ?? 'Well done! You finished this part.');
      },
    );
    final light = level.world != WorldId.move;
    return Scene(
      bg: ws.bg,
      lightStatus: light,
      blobs: [
        Blob(300, 300, ws.b1, left: -120, top: 60),
        Blob(240, 240, ws.b2, right: -110, bottom: 160),
      ],
      child: Column(children: [
        TopBar([
          GlassIconButton(
              icon: Icons.pause_rounded,
              label: 'Pause and go back',
              color: light ? Colors.white : C.ink,
              onTap: () => Navigator.of(context).maybePop()),
          Expanded(child: _Progress((_round + (_busy ? 1 : 0)) / _rounds)),
          StarPill((s.current?.stars ?? 0) + _earned, ink: !light),
        ]),
        const SizedBox(height: 10),
        Expanded(
          child: Stack(children: [
            Positioned.fill(
              child: GameMood(
                mood: _feedback == null ? TikoMood.bob : (_feedback! ? TikoMood.cheer : TikoMood.think),
                child: KeyedSubtree(
                  key: ValueKey('${level.id}-$_round'),
                  child: buildGame(level, api, _coach),
                ),
              ),
            ),
            // While Tiko explains, the game waits: nothing else can be tapped.
            if (_feedback != null)
              Positioned.fill(child: ModalBarrier(color: C.ink.withValues(alpha: .25), dismissible: false)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FeedbackPanel(
                right: _feedback,
                text: _feedbackText,
                last: _round + 1 >= _rounds,
                onNext: _next,
                onTryAgain: _tryAgain,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Progress extends StatelessWidget {
  final double value;
  const _Progress(this.value);
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Progress ${(value * 100).round()} percent',
        child: Container(
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .28),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: Colors.white.withValues(alpha: .6), width: 1.5),
          ),
          child: LayoutBuilder(
            builder: (context, c) => Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: c.maxWidth * value.clamp(0, 1),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
              ),
            ),
          ),
        ),
      );
}

// ---------------------------------------------------------------- layout

/// Question | answers. Two columns on wide screens; stacked otherwise.
/// Left-handed mode mirrors the columns so the answers sit on the left.
class GameSplit extends StatelessWidget {
  final Widget question;
  final Widget? coach;
  final Widget? answers;
  final bool leftHanded;
  final bool questionGlass;
  final VoidCallback? onSpeaker;
  final EdgeInsets questionPadding;

  const GameSplit({
    super.key,
    required this.question,
    this.coach,
    this.answers,
    this.leftHanded = false,
    this.questionGlass = true,
    this.onSpeaker,
    this.questionPadding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Responsive(builder: (context, l) {
      // Phones: shrink to fit if needed. Tablets: also grow, like the prototype.
      Widget q = Padding(
        padding: questionPadding,
        child: l.large
            ? LayoutBuilder(
                builder: (context, c) => Center(
                  child: SizedBox(
                    width: c.maxWidth * .82,
                    height: c.maxHeight * .74,
                    child: FittedBox(fit: BoxFit.contain, child: question),
                  ),
                ),
              )
            : Center(child: FittedBox(fit: BoxFit.scaleDown, child: question)),
      );
      if (questionGlass) q = GlassPanel(child: SizedBox.expand(child: q));
      if (onSpeaker != null) {
        q = Stack(children: [
          Positioned.fill(child: q),
          Positioned(
              top: 0,
              right: 0,
              child: GlassIconButton(icon: Icons.volume_up_rounded, label: 'Hear it again', onTap: onSpeaker!)),
        ]);
      }
      final side = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?coach,
          if (coach != null && answers != null) SizedBox(height: l.large ? 18 : 10),
          if (answers != null) Center(child: answers),
        ],
      );
      if (l.twoCol) {
        final kids = [
          Expanded(flex: 5, child: q),
          SizedBox(width: l.large ? 24 : 14),
          Expanded(flex: 4, child: Center(child: SingleChildScrollView(child: side))),
        ];
        return Row(children: leftHanded ? kids.reversed.toList() : kids);
      }
      return Column(children: [
        Expanded(child: q),
        const SizedBox(height: 12),
        side,
      ]);
    });
  }
}

/// A row of answer tiles; highlights the right one at hint step 2+.
class ChoiceRow extends StatelessWidget {
  final int count;
  final int correctIndex;
  final int hintLevel;
  final Widget Function(int i) builder;
  final String Function(int i) label;
  final Color Function(int i)? color;
  final Color Function(int i)? shadow;
  final void Function(int i) onPick;
  final double? size;

  const ChoiceRow({
    super.key,
    required this.count,
    required this.correctIndex,
    required this.hintLevel,
    required this.builder,
    required this.label,
    required this.onPick,
    this.color,
    this.shadow,
    this.size,
  });

  static const tileColors = [
    (C.green, C.greenDark),
    (C.blue, C.blueDark),
    (C.purple, C.purpleDark),
    (C.coral, C.coralDark),
  ];

  @override
  Widget build(BuildContext context) {
    return Responsive(builder: (context, l) {
      final sz = size ?? l.tile;
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: l.large ? 22 : 14,
        runSpacing: 16,
        children: [
          for (var i = 0; i < count; i++)
            _Picked(
              correct: i == correctIndex,
              child: AnswerTile(
                size: sz,
                semantics: label(i),
                color: color?.call(i) ?? Colors.white,
                shadow: shadow?.call(i) ?? const Color(0x2E1F2A44),
                highlight: hintLevel >= 2 && i == correctIndex,
                onTap: () => onPick(i),
                child: builder(i),
              ),
            ),
        ],
      );
    });
  }
}

/// Wrong picks shake; right picks pop.
class _Picked extends StatefulWidget {
  final Widget child;
  final bool correct;
  const _Picked({required this.child, required this.correct});
  @override
  State<_Picked> createState() => _PickedState();
}

class _PickedState extends State<_Picked> {
  int _n = 0;
  @override
  Widget build(BuildContext context) => Listener(
        onPointerUp: (_) => setState(() => _n++),
        child: widget.correct ? Pop(trigger: _n, child: widget.child) : Shake(trigger: _n, child: widget.child),
      );
}

/// Shared coach used inside games (shows the shell's current line).
Widget gameCoach(String text, {double size = 64, TikoMood mood = TikoMood.bob}) =>
    Coach(text, size: size, mood: mood);

/// Big question text in white.
Widget qText(String t, {double size = 22, Color color = Colors.white}) => Text(t,
    textAlign: TextAlign.center, style: baloo(size, color: color, height: 1.15));

/// Helper: a list of distinct ints from [from]..[to] containing [must].
List<int> pickNumbers(Random r, int must, int count, int from, int to) {
  final set = <int>{must};
  var guard = 0;
  while (set.length < count && guard++ < 200) {
    final d = must + r.nextInt(5) - 2;
    if (d >= from && d <= to) set.add(d);
  }
  var x = from;
  while (set.length < count) {
    set.add(x++);
  }
  return set.toList()..shuffle(r);
}

/// Primary call-to-action used by several games.
Widget doneButton(String text, VoidCallback onTap) => ChunkyButton.text(text, onTap: onTap);


/// Feedback after every answer, at the bottom of the screen (like Duolingo):
/// - right: "Correct!", the full explanation, then "Next";
/// - wrong: "Not right", why, then "Try again".
/// Buttons stay off until Tiko has finished explaining, so the child
/// always hears (and sees) the whole explanation before going on.
class FeedbackPanel extends StatelessWidget {
  final bool? right;
  final String text;
  final bool last;
  final VoidCallback onNext;
  final VoidCallback onTryAgain;
  const FeedbackPanel({
    super.key,
    required this.right,
    required this.text,
    required this.last,
    required this.onNext,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final show = right != null;
    final ok = right ?? true;
    final still = reduceMotion(context);
    final bg = ok ? const Color(0xFFE7F8EE) : const Color(0xFFFFECE6);
    final accent = ok ? C.greenDark : C.coralDark;
    return AnimatedSlide(
      offset: show ? Offset.zero : const Offset(0, 1.2),
      duration: still ? Duration.zero : const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: !show
          ? const SizedBox.shrink()
          : Semantics(
              liveRegion: true,
              label: '${ok ? 'Correct' : 'Not right'}. $text',
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: accent, width: 2.5),
                  boxShadow: [BoxShadow(color: accent.withValues(alpha: .35), offset: const Offset(0, 6))],
                ),
                child: Responsive(builder: (context, l) {
                  final title = Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                      child: Icon(ok ? Icons.check_rounded : Icons.close_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(ok ? 'Correct!' : 'Not right', style: baloo(l.large ? 30 : 24, color: accent, height: 1.1)),
                    ),
                    GlassIconButton(
                      icon: Icons.volume_up_rounded,
                      label: 'Hear it again',
                      color: accent,
                      tone: GlassTone.strong,
                      size: 44,
                      onTap: () => Audio.I.say(text),
                    ),
                  ]);
                  final words = ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: l.size.height < 500 ? 90 : 200),
                    child: SingleChildScrollView(
                      child: Text(text, style: baloo(l.large ? 22 : 18, weight: 700, color: C.ink, height: 1.3)),
                    ),
                  );
                  final button = ValueListenableBuilder<bool>(
                    valueListenable: Audio.I.speaking,
                    builder: (context, talking, _) => ChunkyButton(
                      onTap: talking ? null : (ok ? onNext : onTryAgain),
                      color: ok ? C.green : C.coral,
                      shadow: ok ? C.greenDark : C.coralDark,
                      width: double.infinity,
                      semantics: talking ? 'Listening' : (ok ? (last ? 'Finish' : 'Next') : 'Try again'),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(talking ? Icons.hearing_rounded : (ok ? Icons.arrow_forward_rounded : Icons.replay_rounded),
                            color: Colors.white),
                        const SizedBox(width: 8),
                        Text(talking ? 'Listen to Tiko…' : (ok ? (last ? 'Finish' : 'Next') : 'Try again'),
                            style: baloo(22, color: Colors.white)),
                      ]),
                    ),
                  );
                  return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    title,
                    const SizedBox(height: 10),
                    words,
                    const SizedBox(height: 14),
                    button,
                  ]);
                }),
              ),
            ),
    );
  }
}
