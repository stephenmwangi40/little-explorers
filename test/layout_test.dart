// Renders every screen and one level of every game type at phone, iPad
// portrait, iPad landscape, a narrow Split View width and phone landscape,
// and fails on any layout overflow or exception.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_explorers/content/levels.dart';
import 'package:little_explorers/core/state/app_state.dart';
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

const sizes = {
  'phone 390x844': Size(390, 844),
  'small phone 360x640': Size(360, 640),
  'iPad portrait 820x1180': Size(820, 1180),
  'iPad landscape 1180x820': Size(1180, 820),
  'Split View 400x1000': Size(400, 1000),
  'phone landscape 844x390': Size(844, 390),
  'iPad 13in landscape 1366x1024': Size(1366, 1024),
};

AppState makeState() {
  final s = AppState()..clock = () => DateTime(2026, 10, 16, 10);
  s.addProfile(age: 4, color: C.coral, hat: 'cap');
  final lv = allLevels[WorldId.alpha]!;
  for (final l in lv.take(3)) {
    s.completeLevel(l, learned: l.title);
  }
  return s;
}

Future<void> pumpAt(WidgetTester t, Size size, Widget page, {AppState? state, double text = 1}) async {
  t.view.physicalSize = size * 2;
  t.view.devicePixelRatio = 2;
  await t.pumpWidget(AppScope(
    state: state ?? makeState(),
    child: MaterialApp(
      theme: buildTheme(),
      builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(text)), child: child!),
      home: page,
    ),
  ));
  for (var i = 0; i < 4; i++) {
    await t.pump(const Duration(milliseconds: 300));
  }
}

Future<void> tidy(WidgetTester t) async {
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(seconds: 3));
  t.view.resetPhysicalSize();
  t.view.resetDevicePixelRatio();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final screens = <String, Widget Function()>{
    'splash': () => const SplashScreen(),
    'age': () => const AgeScreen(),
    'avatar': () => const AvatarScreen(age: 4),
    'profiles': () => const ProfilesScreen(),
    'home': () => const HomeScreen(),
    'world map': () => const WorldMapScreen(world: WorldId.alpha),
    'reward': () => RewardScreen(level: allLevels[WorldId.alpha]!.first),
    'rest': () => const RestScreen(),
    'together': () => const TogetherScreen(),
    'stickers': () => const StickerBookScreen(),
    'gate': () => const GateScreen(),
    'parent': () => const ParentDashboard(),
    'report': () => const ReportScreen(),
    'settings': () => const SettingsScreen(),
    'subscribe': () => const SubscriptionScreen(),
    'privacy': () => const PrivacyScreen(),
    'terms': () => const TermsScreen(),
  };

  // One level of every game type (plus a few harder ones).
  final games = <Level>[];
  final seen = <GameType>{};
  for (final ls in allLevels.values) {
    for (final l in ls) {
      if (seen.add(l.type)) games.add(l);
    }
  }
  games.addAll([
    allLevels[WorldId.alpha]![38], // digraphs
    allLevels[WorldId.alpha]![39], // digraph blends
    allLevels[WorldId.math]![39], // count to 10 array
    allLevels[WorldId.math]![37], // numerals to 20
    allLevels[WorldId.math]![24], // make 10
    allLevels[WorldId.shapes]![35], // 4-shape sort with stars
  ]);

  for (final e in sizes.entries) {
    group(e.key, () {
      for (final sc in screens.entries) {
        testWidgets('screen ${sc.key}', (t) async {
          await pumpAt(t, e.value, sc.value());
          expect(t.takeException(), isNull);
          await tidy(t);
        });
      }
      for (final g in games) {
        testWidgets('game ${g.id} ${g.type.name}', (t) async {
          await pumpAt(t, e.value, GameShell(level: g));
          expect(t.takeException(), isNull);
          await tidy(t);
        });
      }
    });
  }

  for (final sz in const [Size(390, 844), Size(360, 640), Size(1180, 820)]) {
    group('largest text size at ${sz.width.toInt()}x${sz.height.toInt()}', () {
      for (final sc in screens.entries) {
        testWidgets('screen ${sc.key}', (t) async {
          await pumpAt(t, sz, sc.value(), text: 1.3);
          expect(t.takeException(), isNull);
          await tidy(t);
        });
      }
      for (final g in games) {
        testWidgets('game ${g.id}', (t) async {
          await pumpAt(t, sz, GameShell(level: g), text: 1.3);
          expect(t.takeException(), isNull);
          await tidy(t);
        });
      }
    });
  }

  testWidgets('left-handed mode and age 3 still lay out', (t) async {
    final s = makeState();
    s.settings.leftHanded = true;
    s.current!.age = 3;
    for (final g in games) {
      await pumpAt(t, const Size(1180, 820), GameShell(level: g), state: s);
      expect(t.takeException(), isNull);
    }
    await tidy(t);
  });
}
