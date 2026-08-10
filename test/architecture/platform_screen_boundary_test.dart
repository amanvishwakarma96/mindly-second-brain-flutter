import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('platform screen folders never import sibling screen folders', () {
    final platformFolders = ['mobile', 'desktop', 'web'];

    for (final platform in platformFolders) {
      final directory = Directory('lib/screens/$platform');
      final forbidden = platformFolders.where((value) => value != platform);

      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }

        final source = entity.readAsStringSync();
        for (final sibling in forbidden) {
          expect(
            source.contains('package:mindly/screens/$sibling/'),
            isFalse,
            reason: '${entity.path} imports the $sibling screen layer.',
          );
        }
      }
    }
  });

  test('shared layers never import platform screens', () {
    for (final root in ['lib/core', 'lib/features', 'lib/shared']) {
      final directory = Directory(root);
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }

        final source = entity.readAsStringSync();
        expect(
          source.contains('package:mindly/screens/'),
          isFalse,
          reason:
              '${entity.path} leaks a screen dependency into a shared layer.',
        );
      }
    }
  });
}
