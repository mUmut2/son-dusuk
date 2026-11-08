import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Mimari kural: `domain` ve `core` katmanları saf Dart olmalı.
void main() {
  test('domain ve core katmanları flutter/flame import etmez', () {
    final forbidden = RegExp(
      r'''import\s+['"]package:(flutter|flame|flutter_riverpod|go_router)\b''',
    );
    final offenders = <String>[];

    for (final dir in ['lib/domain', 'lib/core']) {
      final directory = Directory(dir);
      if (!directory.existsSync()) continue;
      for (final file in directory.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.dart')) {
          if (forbidden.hasMatch(file.readAsStringSync())) {
            offenders.add(file.path);
          }
        }
      }
    }

    expect(offenders, isEmpty, reason: 'Yasak import: $offenders');
  });
}
