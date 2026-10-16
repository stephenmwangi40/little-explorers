import 'dart:ui';

import 'package:flutter/material.dart';

import '../audio.dart';
import '../state/scope.dart';
import '../theme.dart';

enum GlassTone { clear, strong, dark }

/// "Liquid glass": a blurred, translucent SOLID tint with a light border.
/// Falls back to a plain translucent fill when motion/transparency is reduced.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final GlassTone tone;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Color? tint;
  final double? width, height;
  final Border? border;

  const GlassPanel({
    super.key,
    required this.child,
    this.tone = GlassTone.clear,
    this.radius = 26,
    this.padding,
    this.tint,
    this.width,
    this.height,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final plain = reduceMotion(context);
    final fillColor = tint ??
        switch (tone) {
          GlassTone.clear => Colors.white.withValues(alpha: plain ? .34 : .26),
          GlassTone.strong => Colors.white.withValues(alpha: plain ? .8 : .64),
          GlassTone.dark => Colors.white.withValues(alpha: plain ? .18 : .14),
        };
    final borderColor = tone == GlassTone.dark ? Colors.white.withValues(alpha: .35) : Colors.white.withValues(alpha: .62);
    final r = BorderRadius.circular(radius);
    final box = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: r,
        border: border ?? Border.all(color: borderColor, width: 1.5),
      ),
      child: child,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
              color: (tone == GlassTone.dark ? Colors.black : C.ink).withValues(alpha: tone == GlassTone.dark ? .2 : .14),
              blurRadius: 28,
              offset: const Offset(0, 10),
              // Like CSS box-shadow: never visible through the translucent glass.
              blurStyle: BlurStyle.outer),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: plain
            ? box
            : BackdropFilter.grouped(filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), child: box),
      ),
    );
  }
}

/// Glass round icon button (back, pause, close, speaker).
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final GlassTone tone;
  final Color? color;
  final double size;
  const GlassIconButton(
      {super.key,
      required this.icon,
      required this.onTap,
      required this.label,
      this.tone = GlassTone.clear,
      this.color,
      this.size = 48});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: () {
            Audio.I.sfx('tap');
            onTap();
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            // Keep the hit area at least 64 px for small hands.
            padding: EdgeInsets.all(((64 - size) / 2).clamp(0, 12)),
            child: GlassPanel(
              tone: tone,
              radius: size / 2,
              width: size,
              height: size,
              child: Icon(icon, color: color ?? Colors.white, size: size * .48),
            ),
          ),
        ),
      );
}

/// Glass pill (labels, star counts, profile chip).
class GlassPill extends StatelessWidget {
  final Widget child;
  final GlassTone tone;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  const GlassPill(
      {super.key,
      required this.child,
      this.tone = GlassTone.clear,
      this.onTap,
      this.padding = const EdgeInsets.symmetric(horizontal: 15)});

  @override
  Widget build(BuildContext context) {
    final w = GlassPanel(
      tone: tone,
      radius: 22,
      height: 46,
      padding: padding,
      child: Row(mainAxisSize: MainAxisSize.min, children: [Flexible(child: child)]),
    );
    if (onTap == null) return w;
    return GestureDetector(
        onTap: () {
          Audio.I.sfx('tap');
          onTap!();
        },
        child: w);
  }
}

class StarPill extends StatelessWidget {
  final int n;
  final bool ink;
  const StarPill(this.n, {super.key, this.ink = false});

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$n stars',
        child: GlassPill(
          tone: ink ? GlassTone.strong : GlassTone.clear,
          child: Row(children: [
            Icon(Icons.star_rounded, color: ink ? C.orangeStar : C.gold, size: 22),
            const SizedBox(width: 6),
            Text('$n', style: baloo(18, color: ink ? C.ink : Colors.white)),
          ]),
        ),
      );
}
