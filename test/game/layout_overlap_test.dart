import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/match/minigames/pass.dart';
import 'package:son_dusuk/game/pass/pass_geometry.dart';
import 'package:son_dusuk/game/shot/shot_geometry.dart';

/// Pas sahnesinde hiçbir figür bir başkasının üstüne binmemeli ve hepsi ekranda
/// kalmalı: telefon, küçük telefon, yatay ve tablet boyutlarında denenir.
void main() {
  const sizes = [
    Size(390, 700),
    Size(360, 640),
    Size(320, 568),
    Size(412, 915),
    Size(800, 600),
    Size(1024, 768),
    Size(800, 1600),
  ];

  for (final size in sizes) {
    test(
      'pas: figürler çakışmaz ve ekranda kalır (${size.width.toInt()}x${size.height.toInt()})',
      () {
        final layout = ShotLayout(size.width, size.height);
        for (var seed = 1; seed <= 60; seed++) {
          for (final vision in [10.0, 55.0, 95.0]) {
            final options = PassResolver.generateOptions(
              vision,
              GameRandom(seed),
            );
            final slots = PassGeometry.place(layout, options);
            final bounds = PassGeometry.allBounds(layout, slots);
            for (var i = 0; i < bounds.length; i++) {
              expect(
                bounds[i].left >= 0 && bounds[i].right <= size.width,
                isTrue,
                reason: 'figür yatayda taşıyor: ${bounds[i]}',
              );
              expect(bounds[i].top >= 0, isTrue, reason: 'üstten taşıyor');
              for (var j = i + 1; j < bounds.length; j++) {
                expect(
                  bounds[i].overlaps(bounds[j]),
                  isFalse,
                  reason:
                      'seed $seed vizyon $vision: ${bounds[i]} x ${bounds[j]}',
                );
              }
            }
          }
        }
      },
    );
  }
}
