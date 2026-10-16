import 'package:flutter/material.dart';

import 'core/state/app_state.dart';
import 'core/state/scope.dart';
import 'core/theme.dart';
import 'features/onboarding.dart';

class LittleExplorersApp extends StatelessWidget {
  final AppState state;
  const LittleExplorersApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Little Explorers',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        // Respect the system text size (Dynamic Type), within a range the
        // big, picture-led child layouts can hold.
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: mq.textScaler.clamp(minScaleFactor: 1, maxScaleFactor: 1.3)),
            child: child!,
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
