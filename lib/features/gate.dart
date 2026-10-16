import 'dart:math';

import 'package:flutter/material.dart';

import '../core/audio.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/widgets/buttons.dart';
import '../core/widgets/glass.dart';
import '../core/widgets/scene.dart';

/// Shows the parental gate. Returns true when a grown-up passes it.
Future<bool> passGate(BuildContext context) async {
  final ok = await go<bool>(context, const GateScreen());
  return ok ?? false;
}

/// Numbers are written as words, so pre-readers can't pass.
/// A new random code every time.
class GateScreen extends StatefulWidget {
  final Random? rng;
  const GateScreen({super.key, this.rng});
  @override
  State<GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends State<GateScreen> {
  static const words = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];
  late List<int> _code;
  String _typed = '';
  int _shake = 0;

  @override
  void initState() {
    super.initState();
    _newCode();
    Audio.I.stopSpeaking();
  }

  void _newCode() {
    final r = widget.rng ?? Random();
    _code = List.generate(3, (_) => r.nextInt(10));
  }

  void _key(int n) {
    Audio.I.sfx('tap');
    setState(() => _typed += '$n');
    if (_typed.length == 3) {
      if (_typed == _code.join()) {
        Navigator.pop(context, true);
      } else {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          setState(() {
            _typed = '';
            _shake++;
            _newCode();
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scene(
      bg: C.night,
      blobs: const [
        Blob(300, 300, Color(0xFF3B4A72), left: -120, top: 40),
        Blob(220, 220, C.tiko, right: -90, bottom: 120),
      ],
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GlassIconButton(
              icon: Icons.close_rounded, label: 'Close', tone: GlassTone.dark, onTap: () => Navigator.pop(context, false)),
        ),
        Expanded(
          child: Center(
            child: Responsive(builder: (context, l) {
              final k = l.large ? 76.0 : 62.0;
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Shake(
                  trigger: _shake,
                  child: GlassPanel(
                    tone: GlassTone.dark,
                    radius: 22,
                    padding: const EdgeInsets.all(22),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.lock_rounded, color: C.sun, size: 34),
                      const SizedBox(height: 6),
                      Text('Grown-ups only', style: baloo(26, color: Colors.white)),
                      Text('To continue, tap these numbers:',
                          style: nunito(15, weight: 600, color: Colors.white.withValues(alpha: .85))),
                      const SizedBox(height: 6),
                      Semantics(
                        label: 'Code: ${_code.map((d) => words[d]).join(' ')}',
                        child: Text(_code.map((d) => words[d]).join(' · '),
                            style: nunito(22, weight: 800, color: Colors.white)),
                      ),
                      const SizedBox(height: 8),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        for (var i = 0; i < 3; i++)
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < _typed.length ? Colors.white : Colors.transparent,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                      ]),
                      const SizedBox(height: 8),
                      for (final row in const [
                        [1, 2, 3],
                        [4, 5, 6],
                        [7, 8, 9],
                        [-1, 0, -1],
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            for (final n in row)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: n < 0
                                    ? SizedBox(width: k, height: k)
                                    : Semantics(
                                        button: true,
                                        label: '$n',
                                        child: GestureDetector(
                                          onTap: () => _key(n),
                                          child: GlassPanel(
                                            tone: GlassTone.dark,
                                            radius: k / 2,
                                            width: k,
                                            height: k,
                                            child: Center(child: Text('$n', style: baloo(26, color: Colors.white, height: 1.1))),
                                          ),
                                        ),
                                      ),
                              ),
                          ]),
                        ),
                    ]),
                  ),
                ),
              );
            }),
          ),
        ),
      ]),
    );
  }
}
