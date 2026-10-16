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
        home: const SplashScreen(),
      ),
    );
  }
}
