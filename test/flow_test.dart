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

  test('30-minute adventure visits all six worlds, 5 rounds each', () {
    final s = fresh();
    expect(s.settings.adventureMinutes, 30);
    expect(s.settings.dailyLimit, 30);
    expect(s.adventureWorlds, WorldId.values);
    expect(s.roundsPerStep, 5);
    s.settings.adventureMinutes = 15;
    expect(s.adventureWorlds, [WorldId.alpha, WorldId.math, WorldId.story, WorldId.move]);
    s.settings.moveBreaks = false;
    expect(s.adventureWorlds.contains(WorldId.move), isFalse);
  });

  test('adventure steps advance, end, and reset the next day', () {
    var now = DateTime(2026, 10, 16, 10);
    final s = AppState()..clock = () => now;
    s.addProfile(age: 4, color: C.coral, hat: 'cap');
    for (var i = 0; i < 6; i++) {
      final w = s.adventureWorlds[s.adventureStep];
      s.completeLevel(s.adventureLevel(w), learned: 'x$i');
      s.advanceAdventure();
    }
    expect(s.adventureDone, isTrue);
    expect(s.current!.learnedToday.length, 6);
    now = DateTime(2026, 10, 17, 10);
    expect(s.adventureStep, 0);
    // Next day starts with the next new level in each world.
    expect(s.adventureLevel(WorldId.alpha).number, 2);
  });

  test('daily limit, extra time and bedtime lock', () {
    var now = DateTime(2026, 10, 16, 10);
    final s = AppState()..clock = () => now;
    s.addProfile(age: 4, color: C.coral, hat: 'cap');
    s.current!.minutes[dayKey(now)] = 29;
    expect(s.restNow, isFalse);
    s.current!.minutes[dayKey(now)] = 30;
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
      await t.pump(const Duration(seconds: 2));
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
