import 'dart:async';

import 'package:flutter/material.dart';

import '../core/audio.dart';
import '../core/responsive.dart';
import '../core/state/scope.dart';
import '../core/theme.dart';
import '../core/widgets/art.dart';
import '../core/widgets/buttons.dart';
import '../core/widgets/glass.dart';
import '../core/widgets/scene.dart';
import '../core/widgets/tiko.dart';
import 'gate.dart';
import 'home.dart';

// ---------------------------------------------------------------- splash

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  Timer? _t;
  late final AnimationController _dots =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(milliseconds: 2600), _next);
  }

  @override
  void dispose() {
    _t?.cancel();
    _dots.dispose();
    super.dispose();
  }

  void _next() {
    _t?.cancel();
    if (!mounted) return;
    final s = AppScope.read(context);
    // First launch -> Age; returning -> Who's playing?
    go(context, s.profiles.isEmpty ? const AgeScreen() : const ProfilesScreen(), replace: true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _next,
      child: Scene(
        bg: C.sun,
        lightStatus: false,
        blobs: const [
          Blob(300, 300, Color(0xFFFFC94D), left: -110, top: 60),
          Blob(240, 240, Color(0xFFFFC94D), right: -90, bottom: 90),
          Blob(90, 90, Color(0xFFFFD97A), right: 46, top: 130),
        ],
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              GlassPanel(
                radius: 105,
                width: 210,
                height: 210,
                child: const Center(child: Tiko(size: 146, mood: TikoMood.jump)),
              ),
              const SizedBox(height: 16),
              Text('Little\nExplorers', textAlign: TextAlign.center, style: baloo(46, color: C.ink, height: .95)),
              const SizedBox(height: 8),
              Text('Learn · Play · Grow', style: baloo(17, weight: 700, color: C.ink.withValues(alpha: .75))),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _dots,
                builder: (context, _) => Row(mainAxisSize: MainAxisSize.min, children: [
                  for (var i = 0; i < 3; i++)
                    Builder(builder: (context) {
                      final t = ((_dots.value - i * .15) % 1.0);
                      final up = reduceMotion(context) ? 0.0 : (t < .5 ? t * 2 : (1 - t) * 2);
                      return Transform.translate(
                        offset: Offset(0, -8 * up),
                        child: Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .5 + .5 * up), shape: BoxShape.circle),
                        ),
                      );
                    }),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- age

class AgeScreen extends StatefulWidget {
  final bool adding;
  const AgeScreen({super.key, this.adding = false});
  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Audio.I.say('Hi! I’m Tiko. How old are you?'));
  }

  @override
  Widget build(BuildContext context) {
    const ages = [(3, C.coral, C.coralDark), (4, C.green, C.greenDark), (5, C.purple, C.purpleDark), (6, C.sun, C.amberDark)];
    return Scene(
      bg: C.sky,
      lightStatus: false,
      blobs: const [
        Blob(300, 300, C.skyLight, right: -120, top: -60),
        Blob(240, 240, C.skyLight, left: -110, bottom: 40),
      ],
      child: Responsive(builder: (context, l) {
        return Column(children: [
          if (widget.adding)
            Align(
              alignment: Alignment.centerLeft,
              child: GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded, label: 'Back', color: C.ink, onTap: () => Navigator.pop(context)),
            ),
          const Coach('Hi! I’m Tiko.\nHow old are you?', size: 96, mood: TikoMood.wave, center: true),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: l.large || l.twoCol ? 820 : 440),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: l.large || l.twoCol ? 4 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: .95,
                    children: [
                      for (final (n, c, d) in ages)
                        Semantics(
                          button: true,
                          label: '$n years old',
                          child: GestureDetector(
                            onTap: () {
                              Audio.I.sfx('tap');
                              go(context, AvatarScreen(age: n));
                            },
                            child: GlassPanel(
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                IgnorePointer(
                                  child: ChunkyButton(
                                    onTap: () {},
                                    color: c,
                                    shadow: d,
                                    width: 80,
                                    height: 80,
                                    radius: 40,
                                    padding: EdgeInsets.zero,
                                    child: Text('$n', style: baloo(46, color: Colors.white, height: 1.1)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('years old', style: baloo(18, color: C.ink)),
                              ]),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Text('Grown-ups: we never ask for a child’s name, email or photo',
              textAlign: TextAlign.center, style: nunito(13, color: C.ink.withValues(alpha: .75))),
        ]);
      }),
    );
  }
}

// ---------------------------------------------------------------- avatar

class AvatarScreen extends StatefulWidget {
  final int age;
  const AvatarScreen({super.key, required this.age});
  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  Color _c = C.avatarColors.first;
  String _h = 'cap';
  static const hats = ['cap', 'flower', 'crown', 'helmet', 'none'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Audio.I.say('Make your explorer! Pick a colour and a hat.'));
  }

  @override
  Widget build(BuildContext context) {
    return Scene(
      bg: C.sky,
      lightStatus: false,
      blobs: const [
        Blob(280, 280, C.skyLight, left: -110, top: 80),
        Blob(200, 200, C.grass, right: -70, bottom: -40),
      ],
      child: Column(children: [
        Row(children: [
          GlassIconButton(
              icon: Icons.arrow_back_ios_new_rounded, label: 'Back', color: C.ink, onTap: () => Navigator.pop(context)),
          Expanded(
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Make your explorer!', textAlign: TextAlign.center, style: baloo(24, color: C.ink)))),
          const SizedBox(width: 64),
        ]),
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                GlassPanel(
                    radius: 95,
                    width: 190,
                    height: 190,
                    child: Center(child: Explorer(size: 130, color: _c, hat: _h))),
                const SizedBox(height: 18),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  for (final c in C.avatarColors)
                    Semantics(
                      button: true,
                      selected: c == _c,
                      label: 'colour',
                      child: GestureDetector(
                        onTap: () {
                          Audio.I.sfx('tap');
                          setState(() => _c = c);
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: c == _c ? const [BoxShadow(color: C.ink, spreadRadius: 4)] : null,
                          ),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(height: 14),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  for (final h in hats)
                    Semantics(
                      button: true,
                      selected: h == _h,
                      label: h == 'none' ? 'no hat' : h,
                      child: GestureDetector(
                        onTap: () {
                          Audio.I.sfx('tap');
                          setState(() => _h = h);
                        },
                        child: GlassPanel(
                          radius: 20,
                          width: 66,
                          height: 66,
                          tint: h == _h ? Colors.white : null,
                          child: Center(child: Explorer(size: 44, color: const Color(0xFFC5CFDD), hat: h)),
                        ),
                      ),
                    ),
                ]),
              ]),
            ),
          ),
        ),
        ChunkyButton.text('That’s me!', onTap: () {
          final s = AppScope.read(context);
          s.addProfile(age: widget.age, color: _c, hat: _h);
          Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(pageBuilder: (_, a, b) => const HomeScreen(), transitionsBuilder: (_, a, b, c) => FadeTransition(opacity: a, child: c)),
              (_) => false);
        }),
        const SizedBox(height: 6),
      ]),
    );
  }
}

// ---------------------------------------------------------------- profiles

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scene(
      bg: C.sky,
      lightStatus: false,
      blobs: const [
        Blob(300, 300, C.skyLight, right: -120, top: -60),
        Blob(260, 260, C.grass, left: -100, bottom: -120),
      ],
      child: Responsive(builder: (context, l) {
        return Column(children: [
          const Coach('Who’s exploring today?', size: 84, center: true),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: l.large ? 820 : 440),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final p in s.profiles)
                        _ProfileTile(
                          label: p.name,
                          onTap: () {
                            s.selectProfile(p.id);
                            Navigator.of(context).pushAndRemoveUntil(
                                PageRouteBuilder(
                                    pageBuilder: (_, a, b) => const HomeScreen(),
                                    transitionsBuilder: (_, a, b, c) => FadeTransition(opacity: a, child: c)),
                                (_) => false);
                          },
                          child: Explorer(size: 80, color: Color(p.color), hat: p.hat),
                        ),
                      if (s.profiles.length < 4)
                        _ProfileTile(
                          label: 'Add (grown-up)',
                          clear: true,
                          onTap: () async {
                            if (await passGate(context) && context.mounted) {
                              go(context, const AgeScreen(adding: true));
                            }
                          },
                          child: const SizedBox(width: 80, height: 88, child: Icon(Icons.lock_rounded, size: 34, color: C.ink)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String label;
  final Widget child;
  final VoidCallback onTap;
  final bool clear;
  const _ProfileTile({required this.label, required this.child, required this.onTap, this.clear = false});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: () {
            Audio.I.sfx('tap');
            onTap();
          },
          child: Opacity(
            opacity: clear ? .85 : 1,
            child: GlassPanel(
              tone: clear ? GlassTone.clear : GlassTone.strong,
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                child,
                const SizedBox(height: 6),
                Text(label, textAlign: TextAlign.center, style: baloo(18, color: C.ink)),
              ]),
            ),
          ),
        ),
      );
}
