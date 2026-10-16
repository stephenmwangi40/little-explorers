import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/audio.dart';
import 'core/state/app_state.dart';
import 'services/subscriptions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final state = AppState();
  await state.load();
  await Audio.I.init(state.settings);
  // Store connection runs in the background; the child never waits for it.
  Subscriptions.I.init(state);
  runApp(LittleExplorersApp(state: state));
}
