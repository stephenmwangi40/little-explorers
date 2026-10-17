import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_explorers/features/parents.dart';

void main() {
  test('the version shown in Settings matches pubspec.yaml', () {
    final line = File('pubspec.yaml').readAsLinesSync().firstWhere((l) => l.startsWith('version:'));
    expect(line.split(':')[1].trim().split('+').first, kAppVersion);
  });
}
