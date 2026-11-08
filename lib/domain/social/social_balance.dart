import 'relationships.dart';

/// Sosyal sistem ve olay motoru denge parametreleri (tek yer).
abstract final class SocialBalance {
  // --- Tetikleme ---
  /// Aynı anda bekleyebilecek en fazla olay.
  static const int pendingCap = 3;

  /// Maç sonrası basın sorusu gelme olasılığı (olağan / dikkat çekici maç).
  static const double pressChance = 0.45;
  static const double pressChanceNotable = 0.9;

  /// Maçtan bağımsız haftalık olay olasılığı.
  static const double randomChance = 0.22;

  /// Cevapsız kalan olay kaç hafta sonra kapanır (basın / diğer).
  static const int pressLifetimeWeeks = 2;
  static const int eventLifetimeWeeks = 5;

  /// Bir olay bu kadar hafta tekrar gelmez.
  static const int defaultCooldownWeeks = 12;

  // --- Haftalık ilişki değişimi ---
  /// Her hafta nötr değere yaklaşma payı.
  static const double driftRate = 0.03;
  static const Map<Relation, double> winDelta = {
    Relation.fans: 1.5,
    Relation.teammates: 1,
  };
  static const Map<Relation, double> lossDelta = {
    Relation.fans: -1.5,
    Relation.teammates: -0.5,
  };
  static const double fanPerGoal = 1;
  static const int fanGoalCap = 3;
  static const double greatRatingCoach = 1.5;
  static const double greatRatingMedia = 1;
  static const double poorRatingCoach = -1.5;
  static const double poorRatingMedia = -1;
  static const double injuredFamily = 1;

  /// Dikkat çekici maç eşikleri.
  static const double notableRatingHigh = 7.5;
  static const double notableRatingLow = 5;
  static const int notableGoals = 2;

  // --- Oyuna etkileri ---
  /// Teknik direktör ilişkisi 0..100 -> maça çıkma olasılığına ±bu kadar.
  static const double coachSelectionRange = 0.1;

  /// Medya ilişkisi 0..100 -> teklif sıklığı çarpanı (0.85 .. 1.15).
  static const double mediaOfferLow = 0.85;
  static const double mediaOfferHigh = 1.15;

  /// Aile ve takım arkadaşları morale yöneldiği taban değeri kaydırır:
  /// (aile-50)*[familyMoraleShare] + (takım-50)*[teamMoraleShare].
  static const double familyMoraleShare = 0.2;
  static const double teamMoraleShare = 0.1;

  /// Haber akışında tutulan kayıt sayısı.
  static const int newsCap = 25;

  /// Sponsor olayında paranın taban haftalık maaşı (düşük maaşta anlamlı olsun).
  static const int minWageForMoney = 500;
}
