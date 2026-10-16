// Renders every round of all 960 levels and fails on any exception or
// layout overflow. Phone size for every round; iPad sizes for round 1
// (including the "shining answer" hint state).
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_explorers/content/levels.dart';
import 'package:little_explorers/core/state/app_state.dart';
import 'package:little_explorers/core/state/scope.dart';
import 'package:little_explorers/core/theme.dart';
import 'package:little_explorers/core/widgets/scene.dart';
import 'package:little_explorers/games/game_shell.dart';
import 'package:little_explorers/games/games.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> render(WidgetTester t, AppState s, Level l, int round, {int hint = 0, int age = 4}) async {
    final api = GameApi(
      round: round,
      rounds: 5,
      hintLevel: hint,
      choices: age <= 3 ? 2 : (l.difficulty >= 3 ? 4 : 3),
      delta: 0,
      age: age,
      leftHanded: false,
      rng: Random(l.number * 31 + round),
      say: (_, {speech}) {},
      correct: ({skill, praise}) {},
      wrong: ({hint, skill, model}) {},
      finishRound: () {},
    );
    await t.pumpWidget(AppScope(
      state: s,
      child: MaterialApp(
        theme: buildTheme(),
        home: Scene(bg: WorldStyle.of(l.world).bg, child: buildGame(l, api, 'Coach line')),
      ),
    ));
    await t.pump(const Duration(milliseconds: 100));
    final e = t.takeException();
    expect(e, isNull, reason: '${l.id} (${l.title}) round $round: $e');
  }

  for (final w in WorldId.values) {
    testWidgets('every level and round in ${w.name} (phone)', (t) async {
      t.view.physicalSize = const Size(390, 844) * 2;
      t.view.devicePixelRatio = 2;
      final s = AppState()..addProfile(age: 4, color: C.coral, hat: 'cap');
      for (final l in allLevels[w]!) {
        final rounds = roundsFor(l, 5);
        for (var r = 0; r < rounds; r++) {
          await render(t, s, l, r);
        }
      }
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 3));
      t.view.resetPhysicalSize();
      t.view.resetDevicePixelRatio();
    }, timeout: const Timeout(Duration(minutes: 10)));

    for (final size in const [Size(1180, 820), Size(820, 1180), Size(844, 390), Size(400, 1000)]) {
      testWidgets('every level in ${w.name} at ${size.width.toInt()}x${size.height.toInt()} with hints', (t) async {
        t.view.physicalSize = size * 2;
        t.view.devicePixelRatio = 2;
        final s = AppState()..addProfile(age: 3, color: C.coral, hat: 'cap');
        for (final l in allLevels[w]!) {
          await render(t, s, l, 1, hint: 2, age: l.number.isEven ? 3 : 6);
        }
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(seconds: 3));
        t.view.resetPhysicalSize();
        t.view.resetDevicePixelRatio();
      }, timeout: const Timeout(Duration(minutes: 10)));
    }
  }
}
