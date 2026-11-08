import '../../../core/game_random.dart';
import 'shot_balance.dart';
import 'shot_models.dart';

/// Şutun fiziğini kale düzleminde çözer (saf Dart, seed'li, test edilebilir).
/// Flame katmanı yalnızca girdiyi toplar ve sonucu canlandırır.
abstract final class ShotResolver {
  static ShotResult resolve({
    required ShotInput input,
    required ShotProfile profile,
    required ShotContext context,
    required GameRandom random,
  }) {
    final mishit = random.chance(
      ShotBalance.mishitChance * (1 - input.timing) * (1 - input.timing),
    );
    final power =
        (input.power *
                profile.powerEfficiency *
                (mishit ? ShotBalance.mishitPower : 1))
            .clamp(0.1, 1.0);

    // 1) Savunmacı: düz şut çizgisi ona yakınsa ve şut yerdeyse engelleyebilir.
    final lineDistance = (input.aimX - context.defenderAimX).abs();
    if (lineDistance < ShotBalance.blockWidth) {
      final closeness = 1 - lineDistance / ShotBalance.blockWidth;
      final heightFactor =
          1 -
          (input.aimY / ShotBalance.blockHeightScale).clamp(0.0, 1.0) *
              ShotBalance.blockHeightReduction;
      if (random.chance(context.pressure * closeness * heightFactor)) {
        return ShotResult(
          outcome: ShotOutcome.blocked,
          finalX: input.aimX,
          finalY: input.aimY,
          keeperX: 0,
          timing: input.timing,
        );
      }
    }

    // 2) Sapma: zamanlama, baskı ve aşırı güç dağılımı büyütür.
    final sigma =
        profile.sigma *
        (mishit ? ShotBalance.mishitSigma : 1) *
        (ShotBalance.timingSigmaMax -
            ShotBalance.timingSigmaSpan * input.timing) *
        (1 +
            context.pressure *
                ShotBalance.pressureSigmaGain *
                (1 - profile.composure)) *
        (1 +
            ShotBalance.powerSigmaGain *
                (power - ShotBalance.powerSigmaThreshold).clamp(0.0, 1.0));

    final finalX =
        input.aimX +
        input.curve * profile.curveGain +
        random.gaussian(stdDev: sigma);
    final finalY = input.aimY + random.gaussian(stdDev: sigma * 0.7);

    // 3) Kaleci karar verir (top kale düzlemine varmadan hareket eder).
    final keeperX = _keeperDive(finalX, context.keeperSkill, random);

    ShotResult result(ShotOutcome outcome) => ShotResult(
      outcome: outcome,
      finalX: finalX,
      finalY: finalY,
      keeperX: keeperX,
      timing: input.timing,
    );

    // 4) İsabet / direk / üst direk.
    const m = ShotBalance.woodworkMargin;
    if (finalX.abs() > 1 + m || finalY > 1 + m || finalY < -m) {
      return result(ShotOutcome.offTarget);
    }
    if (finalX.abs() > 1 || finalY > 1) return result(ShotOutcome.woodwork);

    // 5) Kaleci kurtarışı.
    var reach =
        (ShotBalance.keeperReachBase +
            ShotBalance.keeperReachSkill * context.keeperSkill) *
        (ShotBalance.keeperPowerA - ShotBalance.keeperPowerB * power);
    if (finalY > ShotBalance.keeperHighThreshold) {
      reach *= ShotBalance.keeperHighFactor;
    }
    if ((finalX - keeperX).abs() < reach) return result(ShotOutcome.saved);

    return result(ShotOutcome.goal);
  }

  static double _keeperDive(double shotX, double skill, GameRandom random) {
    final reads = random.chance(
      ShotBalance.keeperReadBase + ShotBalance.keeperReadSkill * skill,
    );
    final target = reads
        ? shotX + random.gaussian(stdDev: ShotBalance.keeperReadNoise)
        : random.pick(ShotBalance.keeperGuessZones) +
              random.gaussian(stdDev: ShotBalance.keeperGuessNoise);
    return target.clamp(-1.0, 1.0);
  }
}
