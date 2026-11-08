import '../../../core/game_random.dart';
import '../../career/difficulty.dart';
import '../../career/player_status.dart';
import '../../player/attribute.dart';
import '../../player/player.dart';
import 'shot_balance.dart';

/// Oyuncunun swipe + zamanlama ile ürettiği şut girdisi (kale düzleminde).
class ShotInput {
  const ShotInput({
    required this.aimX,
    required this.aimY,
    required this.power,
    required this.curve,
    required this.timing,
  });

  /// Hedef nokta (kale düzlemi birimi).
  final double aimX;
  final double aimY;

  /// Swipe hızından türeyen güç (0-1).
  final double power;

  /// Falso (-1 sol .. +1 sağ).
  final double curve;

  /// Zamanlama kalitesi (0-1, 1 = mükemmel).
  final double timing;
}

/// Oyuncunun niteliklerinden türetilen şut parametreleri.
class ShotProfile {
  const ShotProfile({
    required this.ringSeconds,
    required this.goodHalfWindow,
    required this.sigma,
    required this.curveGain,
    required this.powerEfficiency,
    required this.composure,
    required this.keeperSkillDelta,
  });

  /// Normal şut. [status]: form halkayı yavaşlatır; düşük kondisyon hız ve
  /// isabet cezası, düşük moral küçük bir isabet cezası verir.
  factory ShotProfile.fromPlayer(
    Player player,
    Difficulty difficulty, {
    PlayerStatus? status,
  }) => ShotProfile._build(
    player,
    difficulty,
    status,
    precisionA: Attribute.finesse,
    precisionB: Attribute.shooting,
    windowAttribute: Attribute.shooting,
    curveAttribute: Attribute.finesse,
    curveBase: ShotBalance.curveGainBase,
    curveSpan: ShotBalance.curveGainFinesse,
    powerAttribute: Attribute.shooting,
  );

  /// Bire bir: aynı fizik, daha kısa karar süresi (kaleci çok yakın).
  factory ShotProfile.oneOnOne(
    Player player,
    Difficulty difficulty, {
    PlayerStatus? status,
  }) => ShotProfile._build(
    player,
    difficulty,
    status,
    precisionA: Attribute.finesse,
    precisionB: Attribute.shooting,
    windowAttribute: Attribute.shooting,
    curveAttribute: Attribute.finesse,
    curveBase: ShotBalance.curveGainBase,
    curveSpan: ShotBalance.curveGainFinesse,
    powerAttribute: Attribute.shooting,
    ringFactor: ShotBalance.oneOnOneRingFactor,
  );

  /// Serbest vuruş: Duran Top ve Plase belirler, falso çok daha etkilidir.
  factory ShotProfile.freeKick(
    Player player,
    Difficulty difficulty, {
    PlayerStatus? status,
  }) => ShotProfile._build(
    player,
    difficulty,
    status,
    precisionA: Attribute.finesse,
    precisionB: Attribute.setPieces,
    windowAttribute: Attribute.setPieces,
    curveAttribute: Attribute.setPieces,
    curveBase: ShotBalance.freeKickCurveBase,
    curveSpan: ShotBalance.freeKickCurveSpan,
    powerAttribute: Attribute.setPieces,
  );

  /// Kafa vuruşu: Kafa Vuruşu ve Güç belirler; falso yoktur.
  factory ShotProfile.header(
    Player player,
    Difficulty difficulty, {
    PlayerStatus? status,
  }) => ShotProfile._build(
    player,
    difficulty,
    status,
    precisionA: Attribute.heading,
    precisionB: Attribute.strength,
    windowAttribute: Attribute.heading,
    curveAttribute: Attribute.heading,
    curveBase: 0,
    curveSpan: 0,
    powerAttribute: Attribute.strength,
  );

  factory ShotProfile._build(
    Player player,
    Difficulty difficulty,
    PlayerStatus? status, {
    required Attribute precisionA,
    required Attribute precisionB,
    required Attribute windowAttribute,
    required Attribute curveAttribute,
    required double curveBase,
    required double curveSpan,
    required Attribute powerAttribute,
    double ringFactor = 1,
  }) {
    final form = status?.formBonus ?? 0;
    final tired = (60 - (status?.condition ?? 100)).clamp(0.0, 60.0);
    final lowMorale = (40 - (status?.morale ?? 60)).clamp(0.0, 40.0);
    double n(Attribute a) => player.attributes.raw(a) / 99;
    final composure = n(Attribute.composure);

    final ringDifficulty = switch (difficulty) {
      Difficulty.easy => ShotBalance.easyRing,
      Difficulty.normal => 1.0,
      Difficulty.hard => ShotBalance.hardRing,
    };
    final windowDifficulty = switch (difficulty) {
      Difficulty.easy => ShotBalance.easyWindow,
      Difficulty.normal => 1.0,
      Difficulty.hard => ShotBalance.hardWindow,
    };
    final keeperDelta = switch (difficulty) {
      Difficulty.easy => ShotBalance.easyKeeperDelta,
      Difficulty.normal => 0.0,
      Difficulty.hard => ShotBalance.hardKeeperDelta,
    };

    return ShotProfile(
      ringSeconds:
          ShotBalance.ringSecondsBase *
          (0.85 + ShotBalance.ringSecondsComposureSpan * composure) *
          ringDifficulty *
          ringFactor *
          (1 + 0.01 * form) *
          (1 - tired / 200),
      goodHalfWindow:
          ShotBalance.goodHalfWindow *
          (0.85 + 0.3 * n(windowAttribute)) *
          windowDifficulty,
      sigma:
          (ShotBalance.sigmaBase -
              ShotBalance.sigmaFinesseGain * n(precisionA) -
              ShotBalance.sigmaShootingGain * n(precisionB)) *
          (1 + tired / 100) *
          (1 + lowMorale / 200),
      curveGain: curveBase + curveSpan * n(curveAttribute),
      powerEfficiency:
          ShotBalance.powerEfficiencyBase +
          ShotBalance.powerEfficiencyShooting * n(powerAttribute),
      composure: composure,
      keeperSkillDelta: keeperDelta,
    );
  }

  /// Halkanın küçülme süresi (sn).
  final double ringSeconds;

  /// Zamanlama kalitesinin 0'a düştüğü pencere yarıçapı (halka ilerlemesi).
  final double goodHalfWindow;

  /// Temel sapma (kale düzlemi birimi).
  final double sigma;
  final double curveGain;
  final double powerEfficiency;
  final double composure;
  final double keeperSkillDelta;

  /// [ringProgress]: 0 = halka en büyük, 1 = topun üzerinde. 1'den büyük = geç.
  double timingQuality(double ringProgress) {
    final distance = (ringProgress - 1).abs();
    if (distance <= ShotBalance.perfectHalfWindow) return 1;
    final span = goodHalfWindow - ShotBalance.perfectHalfWindow;
    return (1 - (distance - ShotBalance.perfectHalfWindow) / span).clamp(
      0.0,
      1.0,
    );
  }
}

/// Anın zorluğu: kaleci, savunmacı baskısı ve savunmacının durduğu çizgi.
class ShotContext {
  const ShotContext({
    required this.keeperSkill,
    required this.pressure,
    required this.defenderAimX,
  });

  factory ShotContext.random(
    GameRandom random,
    Difficulty difficulty, {
    ShotProfile? profile,
  }) {
    final delta = profile?.keeperSkillDelta ?? 0;
    return ShotContext(
      keeperSkill:
          (random.gaussian(
                    mean: ShotBalance.keeperSkillMean,
                    stdDev: ShotBalance.keeperSkillStdDev,
                  ) +
                  delta)
              .clamp(0.2, 0.95),
      pressure: random.nextDouble() * ShotBalance.pressureMax,
      defenderAimX:
          (random.nextDouble() * 2 - 1) * ShotBalance.defenderAimRange,
    );
  }

  /// Kaleci becerisi (0-1).
  final double keeperSkill;

  /// Savunmacı baskısı (0-1).
  final double pressure;

  /// Savunmacının önünü kestiği şut çizgisi (hedef X cinsinden).
  final double defenderAimX;
}

enum ShotOutcome { goal, saved, blocked, offTarget, woodwork, timeout }

/// Şut mini oyununun domain'e döndürdüğü sonuç.
class ShotResult {
  const ShotResult({
    required this.outcome,
    required this.finalX,
    required this.finalY,
    required this.keeperX,
    required this.timing,
  });

  /// Süre dolup şut atılamadıysa.
  const ShotResult.timeout()
    : outcome = ShotOutcome.timeout,
      finalX = 0,
      finalY = 0,
      keeperX = 0,
      timing = 0;

  final ShotOutcome outcome;

  /// Topun kale düzlemine ulaştığı nokta.
  final double finalX;
  final double finalY;

  /// Kalecinin daldığı X.
  final double keeperX;
  final double timing;

  bool get isGoal => outcome == ShotOutcome.goal;
  bool get perfectTiming => timing >= 0.99;
}
