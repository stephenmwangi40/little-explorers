import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the real bundled fonts so layout tests measure text like a device.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Future<void> load(String family, String path) async {
    final bytes = File(path).readAsBytesSync();
    final loader = FontLoader(family)..addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
    await loader.load();
  }

  await load('Baloo2', 'assets/fonts/Baloo2.ttf');
  await load('Nunito', 'assets/fonts/Nunito.ttf');
  // Material icons, so screenshots show real icons rather than boxes.
  final root = Platform.environment['FLUTTER_ROOT'] ?? '';
  final icons = File('$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf');
  if (icons.existsSync()) await load('MaterialIcons', icons.path);
  await testMain();
}
