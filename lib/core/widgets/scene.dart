import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../audio.dart';
import '../responsive.dart';
import '../state/scope.dart';
import '../theme.dart';
import 'glass.dart';
import 'tiko.dart';

/// A decorative solid-colour circle behind the glass.
class Blob {
  final double w, h;
  final Color color;
  final double? left, top, right, bottom;
  const Blob(this.w, this.h, this.color, {this.left, this.top, this.right, this.bottom});
}

/// Full-screen solid background with decorative blobs/clouds, safe areas
/// and a shared backdrop group for all glass panels on the screen.
class Scene extends StatelessWidget {
  final Color bg;
  final List<Blob> blobs;
  final List<Widget> extras;
  final Widget child;
  final bool lightStatus;
  final bool scroll;
  final double? maxWidth;

  const Scene({
    super.key,
    required this.bg,
    required this.child,
    this.blobs = const [],
    this.extras = const [],
    this.lightStatus = true,
    this.scroll = false,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightStatus ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bg,
        body: BackdropGroup(
          child: Stack(
            fit: StackFit.expand,
            children: [
              for (final b in blobs)
                Positioned(
                  left: b.left,
                  top: b.top,
                  right: b.right,
                  bottom: b.bottom,
                  child: IgnorePointer(
                    child: Container(
                      width: b.w,
                      height: b.h,
                      decoration: BoxDecoration(color: b.color, borderRadius: BorderRadius.all(Radius.elliptical(b.w / 2, b.h / 2))),
                    ),
                  ),
                ),
              ...extras,
              SafeArea(
                child: Responsive(
                  builder: (context, l) => Padding(
                    padding: EdgeInsets.fromLTRB(l.pad, l.large ? 18 : 10, l.pad, l.large ? 18 : 10),
                    child: maxWidth == null
                        ? child
                        : Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth!), child: child)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A soft cloud made of three solid circles.
class Cloud extends StatelessWidget {
  final double scale;
  final double opacity;
  const Cloud({super.key, this.scale = 1, this.opacity = .7});

  @override
  Widget build(BuildContext context) {
    final c = Colors.white.withValues(alpha: opacity);
    Widget dot(double s, double l, double t) =>
        Positioned(left: l * scale, top: t * scale, child: Container(width: s * scale, height: s * scale, decoration: BoxDecoration(color: c, shape: BoxShape.circle)));
    return IgnorePointer(
      child: SizedBox(
        width: 120 * scale,
        height: 60 * scale,
        child: Stack(children: [dot(50, 10, 10), dot(60, 36, 0), dot(46, 74, 14)]),
      ),
    );
  }
}

/// Tiko with a speech bubble. Shows the live narration caption when
/// captions are on. Tap the bubble to hear it again (hint step 1).
class Coach extends StatelessWidget {
  final String text;
  final double size;
  final TikoMood mood;
  final bool center;
  const Coach(this.text, {super.key, this.size = 64, this.mood = TikoMood.bob, this.center = false});

  @override
  Widget build(BuildContext context) {
    final captions = AppScope.of(context).settings.captions;
    return Responsive(builder: (context, l) {
      final s = l.large ? size * 1.25 : size;
      final m = mood == TikoMood.bob ? (GameMood.maybeOf(context) ?? mood) : mood;
      return Row(
        mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Tiko(size: s, mood: m),
          const SizedBox(width: 8),
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(bottom: s * .22),
              child: GestureDetector(
                onTap: () => Audio.I.say(text),
                child: GlassPanel(
                  tone: GlassTone.strong,
                  radius: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Semantics(
                    liveRegion: true,
                    label: text,
                    child: ExcludeSemantics(
                      child: Text(captions ? text : '…',
                          style: baloo(l.large ? 21 : 17, weight: 700, color: C.ink, height: 1.2)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// Simple top bar row.
class TopBar extends StatelessWidget {
  final List<Widget> children;
  const TopBar(this.children, {super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: 10), children[i]],
      ]);
}

/// Navigation helpers with a gentle fade.
Future<T?> go<T>(BuildContext context, Widget page, {bool replace = false}) {
  final route = PageRouteBuilder<T>(
    pageBuilder: (context, a, b) => page,
    transitionDuration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 260),
    transitionsBuilder: (context, a, b, child) => FadeTransition(opacity: a, child: child),
  );
  return replace ? Navigator.of(context).pushReplacement(route) : Navigator.of(context).push(route);
}

void goHome(BuildContext context) => Navigator.of(context).popUntil((r) => r.isFirst);

/// Lets a game screen set Tiko's mood (cheer when right, think on a miss).
class GameMood extends InheritedWidget {
  final TikoMood mood;
  const GameMood({super.key, required this.mood, required super.child});
  static TikoMood? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<GameMood>()?.mood;
  @override
  bool updateShouldNotify(GameMood old) => old.mood != mood;
}
