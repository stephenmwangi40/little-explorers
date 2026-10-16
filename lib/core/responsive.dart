import 'package:flutter/widgets.dart';

/// Layout is decided from the available size, never from the device name.
/// compact < 600, medium 600-899, expanded >= 900 logical pixels.
enum SizeClass { compact, medium, expanded }

class Layout {
  /// Space available to this widget.
  final Size size;

  /// The whole window (an iPad in Split View reports its slice, not the device).
  final Size screen;
  const Layout(this.size, [Size? screen]) : screen = screen ?? size;

  SizeClass get sizeClass => size.width >= 900
      ? SizeClass.expanded
      : size.width >= 600
          ? SizeClass.medium
          : SizeClass.compact;

  /// Tablet-sized window: bigger tiles and type.
  bool get large => screen.shortestSide >= 600;

  /// Two columns (question | answers) on landscape areas, as in the prototype;
  /// stacked in portrait (iPad portrait and Split View too).
  bool get twoCol => size.width >= 600 && size.width > size.height * 1.15;

  double get pad => large ? 30 : 16;
  double get tile => large ? 118 : (screen.height < 520 ? 72 : 86);
}

/// Builds a child with the current [Layout].
class Responsive extends StatelessWidget {
  final Widget Function(BuildContext, Layout) builder;
  const Responsive({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth.isFinite ? c.maxWidth : screen.width;
      final h = c.maxHeight.isFinite ? c.maxHeight : screen.height;
      return builder(context, Layout(Size(w, h), screen));
    });
  }
}
