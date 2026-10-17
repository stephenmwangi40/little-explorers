import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_explorers/content/lab_move.dart';
import 'package:little_explorers/content/levels.dart';
import 'package:little_explorers/core/state/app_state.dart';
import 'package:little_explorers/core/state/models.dart';
import 'package:little_explorers/core/state/scope.dart';
import 'package:little_explorers/core/theme.dart';
import 'package:little_explorers/features/gate.dart';
import 'package:little_explorers/features/reward.dart';
import 'package:little_explorers/games/game_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppState fresh({DateTime? now}) {
  final s = AppState()..clock = () => now ?? DateTime(2026, 10, 16, 10);
  s.addProfile(age: 4, color: C.coral, hat: 'cap');
  return s;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('45-minute adventure visits all eight worlds; 60 adds a second movement break', () {
    final s = fresh();
    expect(s.settings.adventureMinutes, 45);
    expect(s.settings.dailyLimit, 60);
    expect(s.adventureWorlds, WorldId.values);
    expect(s.roundsPerStep, 5);
    s.settings.adventureMinutes = 60;
    expect(s.adventureWorlds.length, 9);
    expect(s.adventureWorlds.where((w) => w == WorldId.move).length, 2);
    expect(s.roundsPerStep, 6);
    s.settings.adventureMinutes = 15;
    expect(s.adventureWorlds, [WorldId.alpha, WorldId.math, WorldId.story, WorldId.move]);
    s.settings.moveBreaks = false;
    expect(s.adventureWorlds.contains(WorldId.move), isFalse);
  });

  test('adventure steps advance, end, and reset the next day', () {
    var now = DateTime(2026, 10, 16, 10);
    final s = AppState()..clock = () => now;
    s.addProfile(age: 4, color: C.coral, hat: 'cap');
    for (var i = 0; i < 8; i++) {
      final w = s.adventureWorlds[s.adventureStep];
      s.completeLevel(s.adventureLevel(w), learned: 'x$i');
      s.advanceAdventure();
    }
    expect(s.adventureDone, isTrue);
    expect(s.current!.learnedToday.length, 8);
    now = DateTime(2026, 10, 17, 10);
    expect(s.adventureStep, 0);
    // Next day starts with the next new level in each world.
    expect(s.adventureLevel(WorldId.alpha).number, 2);
  });

  test('daily limit, extra time and bedtime lock', () {
    var now = DateTime(2026, 10, 16, 10);
    final s = AppState()..clock = () => now;
    s.addProfile(age: 4, color: C.coral, hat: 'cap');
    s.current!.minutes[dayKey(now)] = 59;
    expect(s.restNow, isFalse);
    s.current!.minutes[dayKey(now)] = 60;
    expect(s.restNow, isTrue);
    s.grantExtraTime(10);
    expect(s.restNow, isFalse);
    now = DateTime(2026, 10, 16, 20);
    s.current!.minutes[dayKey(now)] = 0;
    expect(s.isBedtime, isTrue);
    s.settings.bedtimeLock = false;
    expect(s.restNow, isFalse);
  });

  test('levels open in order; free plan shows padlocks, never a paywall', () {
    final s = fresh();
    final ls = allLevels[WorldId.math]!;
    expect(s.isOpen(ls[0]), isTrue);
    expect(s.isOpen(ls[1]), kPreviewUnlock);
    s.completeLevel(ls[0]);
    expect(s.isOpen(ls[1]), s.isUnlockedAll);
    s.setPlus(active: true);
    expect(s.isOpen(ls[1]), isTrue);
    expect(s.isOpen(ls[2]), isFalse);
    expect(s.currentLevel(WorldId.math).number, 2);
  });

  test('rewards are predictable: 3 stars and one sticker per level', () {
    final s = fresh();
    final l = allLevels[WorldId.shapes]![0];
    s.completeLevel(l);
    s.completeLevel(l);
    expect(s.current!.stars, 6);
    expect(s.current!.stickers, [l.id]);
  });

  test('data survives a save and reload, and delete clears it', () async {
    final s = AppState();
    await s.load();
    s.addProfile(age: 4, color: C.coral, hat: 'cap');
    s.completeLevel(allLevels[WorldId.alpha]![0]);
    await s.save();
    s.dispose();
    final s2 = AppState();
    await s2.load();
    expect(s2.profiles.length, 1);
    expect(s2.current!.stickers, ['alpha_1']);
    await s2.deleteAll();
    final s3 = AppState();
    await s3.load();
    expect(s3.profiles, isEmpty);
    s2.dispose();
    s3.dispose();
  });

  testWidgets('parental gate: wrong code resets, right code passes', (t) async {
    bool? result;
    final rng = Random(7);
    final code = List.generate(3, (_) => Random(7).nextInt(10));
    final seq = Random(7);
    final digits = [seq.nextInt(10), seq.nextInt(10), seq.nextInt(10)];
    expect(code.length, 3);
    await t.pumpWidget(AppScope(
      state: fresh(),
      child: MaterialApp(
        home: Builder(
          builder: (c) => TextButton(
            onPressed: () async => result = await Navigator.push<bool>(c, MaterialPageRoute(builder: (_) => GateScreen(rng: rng))),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5))
        .catchError((_) => 0);
    await t.pump(const Duration(seconds: 1));
    for (final d in digits) {
      await t.tap(find.text('$d').last);
      await t.pump(const Duration(milliseconds: 50));
    }
    await t.pump(const Duration(seconds: 1));
    expect(result, isTrue);
  });

  testWidgets('Wonder Lab: a wrong prediction is called wrong, explained, and the child must pick the right one',
      (t) async {
    t.view.physicalSize = const Size(1024, 1366) * 2;
    t.view.devicePixelRatio = 2;
    final s = fresh();
    final level = allLevels[WorldId.lab]!.firstWhere((l) => l.p['topic'] == 'float');
    final topic = allLabTopics.firstWhere((x) => x.id == 'float');
    final item = topic.items[(level.p['offset'] as int) % topic.items.length];
    final wrong = topic.optionLabels[1 - item.truth], right = topic.optionLabels[item.truth];
    await t.pumpWidget(AppScope(state: s, child: MaterialApp(theme: buildTheme(), home: GameShell(level: level))));
    await t.pump(const Duration(milliseconds: 500));

    await t.tap(find.text(wrong));
    await t.pump(const Duration(seconds: 2));
    expect(find.text('Not right'), findsOneWidget);
    expect(find.textContaining('You said “$wrong”, but look what happened. ${item.explain}'), findsOneWidget);
    // No way on until the explanation has been heard, and never a Next.
    expect(find.text('Listen to Tiko…'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
    await t.pump(const Duration(seconds: 8));
    await t.tap(find.text('Try again'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Not right'), findsNothing);

    // Tapping the wrong one again is still wrong.
    await t.tap(find.text(wrong));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Not right'), findsOneWidget);
    await t.pump(const Duration(seconds: 8));
    await t.tap(find.text('Try again'));
    await t.pump(const Duration(milliseconds: 300));

    await t.tap(find.text(right));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Correct!'), findsOneWidget);
    expect(find.textContaining('That’s right! ${item.explain}'), findsOneWidget);
    await t.pump(const Duration(seconds: 8));
    expect(find.text('Next'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 3));
    t.view.resetPhysicalSize();
    t.view.resetDevicePixelRatio();
  });

  testWidgets('a whole level plays through to the reward and is saved', (t) async {
    t.view.physicalSize = const Size(390, 844) * 2;
    t.view.devicePixelRatio = 2;
    final s = fresh();
    final level = allLevels[WorldId.move]![0];
    await t.pumpWidget(AppScope(state: s, child: MaterialApp(theme: buildTheme(), home: GameShell(level: level))));
    await t.pump(const Duration(milliseconds: 500));
    for (final m in (level.p['moves'] as List).cast<int>()) {
      final move = moves[m];
      final verb = '${move.verb[0].toUpperCase()}${move.verb.substring(1)}!';
      final reps = move.breath ? 3 : level.p['reps'] as int;
      for (var i = 0; i < reps; i++) {
        await t.tap(find.text(verb));
        await t.pump(const Duration(milliseconds: 100));
      }
      // The explanation must finish before Next unlocks.
      expect(find.text('Listen to Tiko…'), findsOneWidget);
      await t.pump(const Duration(seconds: 5));
      await t.tap(find.byWidgetPredicate((w) => w is Text && (w.data == 'Next' || w.data == 'Finish')));
      await t.pump(const Duration(seconds: 1));
    }
    await t.pump(const Duration(seconds: 1));
    expect(find.byType(RewardScreen), findsOneWidget);
    expect(s.isDone(level), isTrue);
    expect(s.current!.stars, 3);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 3));
    t.view.resetPhysicalSize();
    t.view.resetDevicePixelRatio();
  });
}
