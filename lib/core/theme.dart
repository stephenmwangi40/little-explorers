import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Colour tokens from the design system. Solid colours only: no gradients.
class C {
  static const sky = Color(0xFF7ED3F7);
  static const skyLight = Color(0xFFA4E1FA);
  static const sun = Color(0xFFFFB703);
  static const letters = Color(0xFFFF7A59);
  static const jungle = Color(0xFF3DBE7A);
  static const shapes = Color(0xFF9B6BFF);
  static const story = Color(0xFFE86A92);
  static const lab = Color(0xFF4DA3FF);
  static const move = Color(0xFFFFB703);
  static const parents = Color(0xFFE3ECF7);
  static const night = Color(0xFF2E3A5C);
  static const ink = Color(0xFF1F2A44);
  static const muted = Color(0xFF5E6A85);
  static const grass = Color(0xFF8BD96B);
  static const grassDark = Color(0xFF6CC24A);
  static const gold = Color(0xFFFFD166);
  static const orangeStar = Color(0xFFFF9F1C);
  static const green = Color(0xFF3DBE7A);
  static const greenDark = Color(0xFF2A9D60);
  static const red = Color(0xFFEF476F);
  static const blue = Color(0xFF4DA3FF);
  static const blueDark = Color(0xFF2F86E0);
  static const purple = Color(0xFF9B6BFF);
  static const purpleDark = Color(0xFF7B4FE0);
  static const coral = Color(0xFFFF7A59);
  static const coralDark = Color(0xFFE05A3A);
  static const amberDark = Color(0xFFE09E00);
  static const tiko = Color(0xFF6C5CE7);
  static const danger = Color(0xFFD64545);
  static const white = Colors.white;

  static const avatarColors = [
    Color(0xFFFF7A59),
    Color(0xFF3DBE7A),
    Color(0xFF4DA3FF),
    Color(0xFF9B6BFF),
    Color(0xFFFFB703),
    Color(0xFFE86A92),
  ];
}

/// Children's type is Baloo 2; parents' type is Nunito. Both are bundled.
TextStyle baloo(double size, {double weight = 800, Color? color, double? height}) => TextStyle(
      fontFamily: 'Baloo2',
      fontSize: size,
      fontWeight: _w(weight),
      fontVariations: [FontVariation('wght', weight)],
      color: color,
      height: height,
    );

TextStyle nunito(double size, {double weight = 700, Color? color, double? height}) => TextStyle(
      fontFamily: 'Nunito',
      fontSize: size,
      fontWeight: _w(weight),
      fontVariations: [FontVariation('wght', weight)],
      color: color,
      height: height,
    );

FontWeight _w(double w) => FontWeight.values[((w / 100).round() - 1).clamp(0, 8)];

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.tiko),
    fontFamily: 'Nunito',
    splashFactory: NoSplash.splashFactory,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: C.ink, displayColor: C.ink),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}

enum WorldId { alpha, math, shapes, story, lab, move }

/// Per-world palette, matching the prototype.
class WorldStyle {
  final Color bg, b1, b2, d;
  const WorldStyle(this.bg, this.b1, this.b2, this.d);

  static const map = {
    WorldId.alpha: WorldStyle(Color(0xFFFF7A59), Color(0xFFFF9478), Color(0xFFE8603F), Color(0xFFE05A3A)),
    WorldId.math: WorldStyle(Color(0xFF3DBE7A), Color(0xFF5ED394), Color(0xFF2A9D60), Color(0xFF2A9D60)),
    WorldId.shapes: WorldStyle(Color(0xFF9B6BFF), Color(0xFFB391FF), Color(0xFF7B4FE0), Color(0xFF7B4FE0)),
    WorldId.story: WorldStyle(Color(0xFFE86A92), Color(0xFFF28AAB), Color(0xFFC9507A), Color(0xFFC9507A)),
    WorldId.lab: WorldStyle(Color(0xFF4DA3FF), Color(0xFF6FB6FF), Color(0xFF2F86E0), Color(0xFF2F86E0)),
    WorldId.move: WorldStyle(Color(0xFFFFB703), Color(0xFFFFC94D), Color(0xFFE09E00), Color(0xFFE09E00)),
  };
  static WorldStyle of(WorldId w) => map[w]!;
}
