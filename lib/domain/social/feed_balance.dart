import 'event_models.dart';
import 'feed_models.dart';

/// Oyuncunun kendi paylaşımının kuralı: sonuç, ters tepme ve takipçi etkisi.
class OwnPostRule {
  const OwnPostRule({
    required this.effect,
    required this.followerGain,
    this.alt,
    this.altChance = 0,
    this.altFollowerLoss = 0,
  });

  final EventEffect effect;

  /// Takipçi sayısına oransal artış (0.05 = %5).
  final double followerGain;

  /// Ters tepme sonucu ve olasılığı.
  final EventEffect? alt;
  final double altChance;
  final double altFollowerLoss;
}

/// Sosyal ağ akışı denge parametreleri (tek yer).
abstract final class FeedBalance {
  // --- Hesap ---
  /// Takipçi tavanı; büyüme bu değere yaklaştıkça yavaşlar.
  static const int maxFollowers = 20000000;

  /// Akışta tutulan paylaşım sayısı.
  static const int postCap = 40;

  // --- Üretim ---
  /// Bir maç haftasında ana paylaşımın yanına ikinci bir hesabın eklenme olasılığı.
  static const double extraPostChance = 0.35;

  /// Maçsız (paylaşımsız) haftada "gündem" paylaşımı gelme olasılığı.
  static const double quietPostChance = 0.7;

  /// Yıldız performanslı haftada ek dedikodu paylaşımı olasılığı.
  static const double rumorChance = 0.25;

  /// Beğeni = takipçi x [likeRate] x (0.5..1.5) x konu ağırlığı.
  static const double likeRate = 0.08;
  static const int minLikes = 3;

  /// Bir paylaşımın altındaki en çok yorum.
  static const int maxComments = 4;

  /// Takipçisi bu sayının altındaki hesaba en çok 2 yorum gelir.
  static const int smallAccountFollowers = 300;

  // --- Takipçi büyümesi (haftalık, oransal; tavana yaklaştıkça yavaşlar) ---
  static const double growthBase = 0.012;
  static const double growthWin = 0.02;
  static const double growthPerGoal = 0.03;
  static const int growthGoalCap = 3;
  static const double growthStar = 0.04;
  static const double growthLoss = -0.012;
  static const double growthFlop = -0.025;
  static const double growthSigned = 0.08;
  static const double growthAchievement = 0.05;
  static const double growthNational = 0.05;
  static const double growthInterview = 0.02;

  // --- Yorum havası ---
  /// Taraftar ilişkisi 50'den her 50 puan uzaklaşınca praise/jeer payı kayması.
  static const double fanMoodShift = 0.25;

  /// Konuya göre yorum havası olasılıkları (praise, joke, jeer, support).
  static const Map<FeedKind, List<double>> toneMix = {
    FeedKind.win: [0.6, 0.3, 0.1, 0.0],
    FeedKind.loss: [0.1, 0.2, 0.4, 0.3],
    FeedKind.draw: [0.3, 0.3, 0.25, 0.15],
    FeedKind.scorer: [0.65, 0.3, 0.05, 0.0],
    FeedKind.hatTrick: [0.7, 0.28, 0.02, 0.0],
    FeedKind.star: [0.65, 0.3, 0.05, 0.0],
    FeedKind.flop: [0.05, 0.25, 0.5, 0.2],
    FeedKind.benched: [0.1, 0.2, 0.2, 0.5],
    FeedKind.injury: [0.1, 0.0, 0.0, 0.9],
    FeedKind.signed: [0.5, 0.3, 0.1, 0.1],
    FeedKind.interview: [0.35, 0.4, 0.2, 0.05],
    FeedKind.achievement: [0.7, 0.25, 0.05, 0.0],
    FeedKind.national: [0.65, 0.3, 0.05, 0.0],
    FeedKind.shopping: [0.3, 0.4, 0.25, 0.05],
    FeedKind.donation: [0.8, 0.15, 0.0, 0.05],
    FeedKind.betFined: [0.05, 0.15, 0.7, 0.1],
    FeedKind.horseWin: [0.3, 0.5, 0.15, 0.05],
    FeedKind.rumor: [0.3, 0.4, 0.25, 0.05],
    FeedKind.hype: [0.6, 0.3, 0.05, 0.05],
    FeedKind.fanArt: [0.85, 0.1, 0.0, 0.05],
    FeedKind.streak: [0.75, 0.2, 0.0, 0.05],
    FeedKind.ownThanks: [0.7, 0.2, 0.0, 0.1],
    FeedKind.ownFunny: [0.4, 0.55, 0.05, 0.0],
    FeedKind.ownTraining: [0.6, 0.25, 0.05, 0.1],
    FeedKind.ownSpicy: [0.35, 0.3, 0.3, 0.05],
  };

  /// Konuya göre beğeni çarpanı (büyük anlar daha çok beğenilir).
  static const Map<FeedKind, double> likeWeight = {
    FeedKind.win: 1,
    FeedKind.loss: 0.7,
    FeedKind.draw: 0.6,
    FeedKind.scorer: 1.2,
    FeedKind.hatTrick: 2.5,
    FeedKind.star: 1.5,
    FeedKind.flop: 0.8,
    FeedKind.benched: 0.5,
    FeedKind.injury: 1,
    FeedKind.signed: 2.5,
    FeedKind.interview: 1,
    FeedKind.achievement: 1.6,
    FeedKind.national: 2,
    FeedKind.shopping: 1.5,
    FeedKind.donation: 1.3,
    FeedKind.betFined: 2,
    FeedKind.horseWin: 1.5,
    FeedKind.rumor: 1.4,
    FeedKind.hype: 0.9,
    FeedKind.fanArt: 1.1,
    FeedKind.streak: 1.6,
    FeedKind.ownThanks: 1.2,
    FeedKind.ownFunny: 1.5,
    FeedKind.ownTraining: 0.9,
    FeedKind.ownSpicy: 2,
  };

  // --- Oyuncunun kendi paylaşımı ---
  static const Map<FeedKind, OwnPostRule> ownRules = {
    FeedKind.ownThanks: OwnPostRule(
      effect: EventEffect(fans: 2, family: 1, media: 1),
      followerGain: 0.02,
    ),
    FeedKind.ownFunny: OwnPostRule(
      effect: EventEffect(fans: 3, teammates: 1, morale: 1),
      followerGain: 0.05,
      alt: EventEffect(coach: -2, media: -2),
      altChance: 0.15,
      altFollowerLoss: 0.01,
    ),
    FeedKind.ownTraining: OwnPostRule(
      effect: EventEffect(coach: 1, fans: 1, morale: 1),
      followerGain: 0.015,
    ),
    FeedKind.ownSpicy: OwnPostRule(
      effect: EventEffect(media: 3, fans: 2),
      followerGain: 0.1,
      alt: EventEffect(coach: -4, media: -3, fans: -2, teammates: -1),
      altChance: 0.35,
      altFollowerLoss: 0.03,
    ),
  };
}
