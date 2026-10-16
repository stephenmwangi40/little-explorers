// Renders PNG screenshots of key screens at phone and iPad sizes.
// Run: flutter test test/screenshots_test.dart --dart-define=SCREENSHOTS=true
// Output: build/screenshots/<size>/<screen>.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_explorers/content/levels.dart';
import 'package:little_explorers/core/state/app_state.dart';
import 'package:little_explorers/core/state/models.dart';
import 'package:little_explorers/core/state/scope.dart';
import 'package:little_explorers/core/theme.dart';
import 'package:little_explorers/features/gate.dart';
import 'package:little_explorers/features/home.dart';
import 'package:little_explorers/features/onboarding.dart';
import 'package:little_explorers/features/parents.dart';
import 'package:little_explorers/features/rest.dart';
import 'package:little_explorers/features/reward.dart';
import 'package:little_explorers/features/stickers_together.dart';
import 'package:little_explorers/features/world_map.dart';
import 'package:little_explorers/games/game_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

const run = bool.fromEnvironment('SCREENSHOTS');

// Logical size and pixel ratio (store sizes: iPhone 6.9" 1320x2868, iPad 13" 2064x2752).
const sizes = {
  'iphone_6.9': (Size(440, 956), 3.0),
  'ipad_13_portrait': (Size(1032, 1376), 2.0),
  'ipad_13_landscape': (Size(1376, 1032), 2.0),
  'android_phone': (Size(412, 915), 2.625),
};

AppState makeState() {
  final s = AppState()..clock = () => DateTime(2026, 10, 16, 10);
  s.addProfile(age: 4, color: C.coral, hat: 'cap');
  s.addProfile(age: 5, color: C.purple, hat: 'flower');
  s.selectProfile(s.profiles.first.id);
  for (final w in WorldId.values) {
    for (final l in allLevels[w]!.take(2)) {
      s.completeLevel(l, learned: l.title);
    }
  }
  s.current!.advStep = 2;
  s.current!.minutes[dayKey(DateTime(2026, 10, 16))] = 12;
  s.current!.minutes[dayKey(DateTime(2026, 10, 15))] = 18;
  s.current!.minutes[dayKey(DateTime(2026, 10, 13))] = 9;
  s.current!.recentSkills.addAll(['snd_a', 'count_5', 'story_feel']);
  return s;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Level lv(WorldId w, int n) => allLevels[w]![n - 1];
  final screens = <String, Widget Function()>{
    '01_splash': () => const SplashScreen(),
    '02_age': () => const AgeScreen(),
    '03_avatar': () => const AvatarScreen(age: 4),
    '04_profiles': () => const ProfilesScreen(),
    '05_home': () => const HomeScreen(),
    '06_world_map': () => const WorldMapScreen(world: WorldId.math),
    '07_letter_sound': () => GameShell(level: lv(WorldId.alpha, 2)),
    '08_trace': () => GameShell(level: lv(WorldId.alpha, 4)),
    '09_blend': () => GameShell(level: lv(WorldId.alpha, 8)),
    '10_count': () => GameShell(level: lv(WorldId.math, 6)),
    '11_compare': () => GameShell(level: lv(WorldId.math, 4)),
    '12_shapes': () => GameShell(level: lv(WorldId.shapes, 4)),
    '13_pattern': () => GameShell(level: lv(WorldId.shapes, 2)),
    '14_story': () => GameShell(level: lv(WorldId.story, 3)),
    '15_lab': () => GameShell(level: lv(WorldId.lab, 1)),
    '16_move': () => GameShell(level: lv(WorldId.move, 3)),
    '17_reward': () => RewardScreen(level: lv(WorldId.alpha, 2)),
    '18_rest': () => const RestScreen(),
    '19_together': () => const TogetherScreen(),
    '20_stickers': () => const StickerBookScreen(),
    '21_gate': () => const GateScreen(),
    '22_parent': () => const ParentDashboard(),
    '23_report': () => const ReportScreen(),
    '24_settings': () => const SettingsScreen(),
    '25_subscribe': () => const SubscriptionScreen(),
    '26_make10': () => GameShell(level: lv(WorldId.math, 25)),
    '27_quick_look': () => GameShell(level: lv(WorldId.math, 5)),
  };

  for (final sz in sizes.entries) {
    for (final sc in screens.entries) {
      testWidgets('${sz.key} ${sc.key}', skip: !run, (t) async {
        final (size, dpr) = sz.value;
        t.view.physicalSize = size * dpr;
        t.view.devicePixelRatio = dpr;
        final key = GlobalKey();
        await t.pumpWidget(RepaintBoundary(
          key: key,
          child: AppScope(state: makeState(), child: MaterialApp(debugShowCheckedModeBanner: false, theme: buildTheme(), home: sc.value())),
        ));
        for (var i = 0; i < 6; i++) {
          await t.pump(const Duration(milliseconds: 250));
        }
        await t.runAsync(() async {
          final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final img = await b.toImage(pixelRatio: dpr);
          final data = await img.toByteData(format: ui.ImageByteFormat.png);
          final f = File('build/screenshots/${sz.key}/${sc.key}.png')..createSync(recursive: true);
          f.writeAsBytesSync(data!.buffer.asUint8List());
        });
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(seconds: 3));
        t.view.resetPhysicalSize();
        t.view.resetDevicePixelRatio();
      });
    }
  }
}
