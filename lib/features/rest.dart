import 'package:flutter/material.dart';

import '../core/audio.dart';
import '../core/state/app_state.dart';
import '../core/state/scope.dart';
import '../core/theme.dart';
import '../core/widgets/glass.dart';
import '../core/widgets/scene.dart';
import '../core/widgets/tiko.dart';
import 'gate.dart';

/// A calm, guilt-free end once the daily adventure or time limit is
/// reached. More time needs a grown-up, through the gate.
class RestScreen extends StatefulWidget {
  const RestScreen({super.key});
  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> {
  @override
  void initState() {
    super.initState();
    Audio.I.musicOff();
    WidgetsBinding.instance.addPostFrameCallback((_) => Audio.I.say(_message(AppScope.read(context))));
  }

  String _message(AppState s) => s.isBedtime && !s.bedtimeOverridden
      ? 'It’s sleepy time. Tiko is going to bed too. See you tomorrow!'
      : 'What a great adventure! Time to rest your eyes and go play.';

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.current;
    final learned = p?.learnedToday ?? const <String>[];
    final mins = s.minutesToday.round();
    return Scene(
      bg: C.night,
      blobs: const [
        Blob(90, 90, Color(0xFFFFE8A3), right: 40, top: 80),
        Blob(300, 300, Color(0xFF3B4A72), left: -130, bottom: 40),
        Blob(6, 6, Colors.white, left: 80, top: 120),
        Blob(5, 5, Colors.white, left: 230, top: 170),
        Blob(7, 7, Colors.white, left: 140, top: 260),
        Blob(5, 5, Colors.white, right: 90, top: 300),
        Blob(6, 6, Colors.white, right: 200, top: 60),
      ],
      child: Column(children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Tiko(size: 140, mood: TikoMood.sleep),
                const SizedBox(height: 14),
                Text(s.isBedtime && !s.bedtimeOverridden ? 'Sleepy time!' : 'What a great adventure!',
                    textAlign: TextAlign.center, style: baloo(30, color: Colors.white, height: 1.1)),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(
                    s.isBedtime && !s.bedtimeOverridden
                        ? 'Tiko is going to bed too. See you tomorrow!'
                        : 'Time to rest your eyes and go play. Tiko is having a nap too.',
                    textAlign: TextAlign.center,
                    style: nunito(17, weight: 600, color: Colors.white.withValues(alpha: .85)),
                  ),
                ),
                const SizedBox(height: 14),
                if (learned.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: GlassPanel(
                      tone: GlassTone.dark,
                      radius: 22,
                      padding: const EdgeInsets.all(15),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text('Today you learned', style: nunito(15, weight: 800, color: Colors.white))),
                          Text('$mins min', style: nunito(12.5, color: Colors.white.withValues(alpha: .8))),
                        ]),
                        const SizedBox(height: 10),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          for (final t in learned)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: Text(t, style: nunito(11.5, weight: 800, color: C.ink)),
                            ),
                        ]),
                      ]),
                    ),
                  ),
              ]),
            ),
          ),
        ),
        Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 10, children: [
          if (!s.restNow)
            GlassPill(
              tone: GlassTone.dark,
              onTap: () => goHome(context),
              child: Row(children: [
                const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text('Home', style: nunito(15, weight: 800, color: Colors.white)),
              ]),
            ),
          GlassPill(
            tone: GlassTone.dark,
            onTap: () async {
              if (await passGate(context) && context.mounted) {
                AppScope.read(context).grantExtraTime(10);
                goHome(context);
              }
            },
            child: Row(children: [
              const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text('Grown-up: more time', style: nunito(15, weight: 800, color: Colors.white)),
            ]),
          ),
        ]),
        const SizedBox(height: 6),
      ]),
    );
  }
}
