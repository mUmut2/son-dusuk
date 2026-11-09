import 'dart:math' as math;

import '../../../core/game_random.dart';
import '../moment_resolver.dart';
import 'mini_balance.dart';

class DribbleResult {
  const DribbleResult({required this.beaten, required this.outcome});

  /// Savunma hattı geçildi mi.
  final bool beaten;
  final MomentOutcome outcome;
}

/// Savunmacı dalgası: iki savunmacı arasında bir geçit açılır.
class DribbleWave {
  const DribbleWave({
    required this.arrival,
    required this.gapCenter,
    required this.phase,
  });

  /// Dalganın oyuncunun hizasına ulaştığı an (sn).
  final double arrival;

  /// Geçidin ekran genişliğine oranla merkezi (0-1).
  final double gapCenter;

  /// Yana salınım fazı (rad).
  final double phase;
}

/// Dribling: parmağınla oyuncuyu sürükleyip savunmacı dalgalarının arasındaki
/// geçitten geç. Beceri oyuncudadır; nitelikler geçidi genişletir.
abstract final class DribbleResolver {
  /// Dalgaları üretir. Her geçit bir öncekinden ulaşılabilir uzaklıktadır.
  /// [tempo] > 1 ise dalgalar daha sık gelir.
  static List<DribbleWave> generateWaves(
    GameRandom random, {
    double tempo = 1,
  }) {
    final waves = <DribbleWave>[];
    var center =
        MiniBalance.dribbleGapMin +
        random.nextDouble() *
            (MiniBalance.dribbleGapMax - MiniBalance.dribbleGapMin);
    for (var i = 0; i < MiniBalance.dribbleWaves; i++) {
      if (i > 0) {
        var dir = random.chance(0.5) ? 1.0 : -1.0;
        final shift =
            MiniBalance.dribbleMinShift +
            random.nextDouble() *
                (MiniBalance.dribbleMaxShift - MiniBalance.dribbleMinShift);
        // Kenara sıkışırsa yön değiştir; geçit hep sınırlar içinde kalır.
        if (center + dir * shift > MiniBalance.dribbleGapMax ||
            center + dir * shift < MiniBalance.dribbleGapMin) {
          dir = -dir;
        }
        center = (center + dir * shift).clamp(
          MiniBalance.dribbleGapMin,
          MiniBalance.dribbleGapMax,
        );
      }
      waves.add(
        DribbleWave(
          arrival:
              (MiniBalance.dribbleFirstArrival +
                  i * MiniBalance.dribbleWaveInterval) /
              tempo,
          gapCenter: center,
          phase: random.nextDouble() * 2 * math.pi,
        ),
      );
    }
    return waves;
  }

  /// Geçit yarı genişliği (ekran oranı). [skill] 0-1 (dribling, çeviklik, top
  /// kontrolü ortalaması), [windowScale] zorluk, [performance] form çarpanı.
  static double gapHalf({
    required double skill,
    double windowScale = 1,
    double performance = 1,
  }) {
    final spread = MiniBalance.dribbleGapSkillSpread;
    return MiniBalance.dribbleGapHalf *
        windowScale *
        (1 - spread / 2 + spread * skill.clamp(0.0, 1.0)) *
        performance.clamp(0.85, 1.15);
  }

  /// Savunmacı hattının yana salınım genliği (ekran oranı).
  static double swayAmplitude(double defenderSkill) =>
      MiniBalance.dribbleSway * defenderSkill;

  /// [t] anında geçidin merkezi (ekran oranı).
  static double gapCenterAt(DribbleWave wave, double t, double amplitude) =>
      wave.gapCenter +
      amplitude * math.sin(MiniBalance.dribbleSwayRate * t + wave.phase);

  /// Dalga oyuncunun hizasındayken oyuncu ([playerX], ekran oranı) bir
  /// savunmacıya çarpıyor mu.
  static bool isHit({
    required double playerX,
    required DribbleWave wave,
    required double amplitude,
    required double gapHalf,
  }) => (playerX - gapCenterAt(wave, wave.arrival, amplitude)).abs() > gapHalf;

  /// Savunmacıların geçide göre yatay uzaklığı: geçit kenarı + çarpışma payı.
  static double defenderOffset(double gapHalf) =>
      gapHalf + MiniBalance.dribbleDefenderHalf + MiniBalance.dribblePlayerHalf;

  /// [hits] çarpışma sayısı. Hiç çarpmadan geçmek çalımı tutturur.
  static DribbleResult resolve({
    required int hits,
    required GameRandom random,
    int allowedHits = 0,
  }) {
    final beaten = hits <= allowedHits;
    final assist =
        beaten && random.chance(MiniBalance.dribbleAssistGivenSuccess);
    return DribbleResult(
      beaten: beaten,
      outcome: assist ? MomentOutcome.assist : MomentOutcome.none,
    );
  }
}
