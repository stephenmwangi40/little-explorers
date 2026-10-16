import 'package:flutter/material.dart';

import '../audio.dart';
import '../state/scope.dart';
import '../theme.dart';

/// Solid colour button with a solid offset "pressable" shadow. No shading.
class ChunkyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color shadow;
  final EdgeInsetsGeometry padding;
  final double radius;
  final String? semantics;
  final double? width, height;
  final bool silent;

  const ChunkyButton({
    super.key,
    required this.child,
    required this.onTap,
    this.color = C.green,
    this.shadow = C.greenDark,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.radius = 24,
    this.semantics,
    this.width,
    this.height,
    this.silent = false,
  });

  /// Common text button.
  factory ChunkyButton.text(String text,
          {Key? key,
          required VoidCallback? onTap,
          Color color = C.green,
          Color shadow = C.greenDark,
          Color textColor = Colors.white,
          double size = 20,
          IconData? icon,
          double? width,
          String family = 'Baloo2'}) =>
      ChunkyButton(
        key: key,
        onTap: onTap,
        color: color,
        shadow: shadow,
        width: width,
        semantics: text,
        child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, color: textColor, size: size * 1.2), const SizedBox(width: 6)],
          Flexible(
            child: Text(text,
                textAlign: TextAlign.center,
                style: family == 'Nunito' ? nunito(size, weight: 800, color: textColor) : baloo(size, color: textColor)),
          ),
        ]),
      );

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    final depth = _down ? 2.0 : 6.0;
    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.semantics,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: disabled ? null : (_) => setState(() => _down = false),
        onTap: disabled
            ? null
            : () {
                if (!widget.silent) Audio.I.sfx('tap');
                widget.onTap!();
              },
        child: AnimatedContainer(
          duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 80),
          width: widget.width,
          height: widget.height,
          constraints: const BoxConstraints(minHeight: 56, minWidth: 64),
          transform: Matrix4.translationValues(0, 6 - depth, 0),
          padding: widget.padding,
          // Only centre inside a fixed size; otherwise hug the label.
          alignment: widget.width != null || widget.height != null ? Alignment.center : null,
          decoration: BoxDecoration(
            color: disabled ? widget.color.withValues(alpha: .5) : widget.color,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [BoxShadow(color: widget.shadow, offset: Offset(0, depth))],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Big square answer tile (letters, numbers or pictures).
class AnswerTile extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final Color shadow;
  final double size;
  final String semantics;
  final bool highlight;

  const AnswerTile({
    super.key,
    required this.child,
    required this.onTap,
    required this.size,
    required this.semantics,
    this.color = Colors.white,
    this.shadow = const Color(0x2E1F2A44),
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final tile = ChunkyButton(
      onTap: onTap,
      color: color,
      shadow: shadow,
      width: size,
      height: size,
      radius: size * .3,
      padding: EdgeInsets.all(size * .1),
      semantics: semantics,
      child: FittedBox(child: child),
    );
    if (!highlight) return tile;
    return _Glow(child: tile);
  }
}

/// Hint step 2 ("model it"): a pulsing white ring around the right answer.
class _Glow extends StatefulWidget {
  final Widget child;
  const _Glow({required this.child});
  @override
  State<_Glow> createState() => _GlowState();
}

class _GlowState extends State<_Glow> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(color: Colors.white.withValues(alpha: .5 + .5 * _c.value), spreadRadius: 4 + 6 * _c.value),
            ],
          ),
          child: child,
        ),
        child: widget.child,
      );
}

/// Plays a short shake when [trigger] changes (gentle "try again").
class Shake extends StatefulWidget {
  final Widget child;
  final int trigger;
  const Shake({super.key, required this.child, required this.trigger});
  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && !reduceMotion(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = _c.value;
          final dx = t == 0 || t == 1 ? 0.0 : 10 * (1 - t) * (t * 20).floor().isEven.toSign();
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: widget.child,
      );
}

extension on bool {
  double toSign() => this ? 1 : -1;
}

/// Plays a short pop (scale up then back) when [trigger] changes.
class Pop extends StatefulWidget {
  final Widget child;
  final int trigger;
  const Pop({super.key, required this.child, required this.trigger});
  @override
  State<Pop> createState() => _PopState();
}

class _PopState extends State<Pop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

  @override
  void didUpdateWidget(Pop old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && !reduceMotion(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = _c.value;
          final s = t < .4 ? 1 + .22 * (t / .4) : 1.22 - .22 * ((t - .4) / .6);
          return Transform.scale(scale: t == 0 ? 1 : s, child: child);
        },
        child: widget.child,
      );
}
