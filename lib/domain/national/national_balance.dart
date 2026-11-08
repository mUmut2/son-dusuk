/// Milli takım ve turnuva denge parametreleri (tek yer).
abstract final class NationalBalance {
  // --- Takvim ---
  /// Turnuva her [tournamentEvery] sezonda bir yapılır (çift sezonlar).
  static const int tournamentEvery = 2;

  /// Sezon arası haftalarında eleme turları: 39 Son 16, 40 Çeyrek, 41 Yarı, 42 Final.
  static const int firstRoundWeek = 39;
  static const int roundCount = 4;
  static const int nationCount = 16;

  // --- Ülkeler ---
  static const double homeStrength = 74;
  static const double otherMean = 66;
  static const double otherStdDev = 7;

  /// Her turnuvada ülke gücüne eklenen rastgele oynama (std sapma).
  static const double yearlyJitter = 3;

  /// Penaltı atışlarında her güç farkı puanı için kazanma olasılığı payı.
  static const double shootoutSlope = 0.004;

  // --- Çağrılma ---
  static const int minAge = 18;

  /// Çağrılma puanı = genel güç + lig kademesi payı + form payı.
  static const List<double> tierBonus = [4, 1, -2, -5, -8];
  static const double formShare = 0.4;
  static const double callUpScore = 70;
  static const double rotationScore = 77;
  static const double starterScore = 84;

  /// Turnuva maçında ilk 11'de yer alma olasılığı (kadro rolüne göre).
  static const double reserveChance = 0.35;
  static const double rotationChance = 0.7;
  static const double starterChance = 0.95;

  // --- Ödüller (haftalık maaşın katı; en az [wageFloor] üzerinden) ---
  static const int wageFloor = 1500;
  static const double appearanceFee = 0.5;
  static const double prizeChampion = 6;
  static const double prizeRunnerUp = 3;
  static const double prizeSemi = 1.5;
  static const double prizeQuarter = 0.75;

  // --- Moral ve ilişkiler ---
  static const double callUpMorale = 5;
  static const double callUpMedia = 2;
  static const double callUpFamily = 2;

  /// Turnuva sonunda (kadrodaysan): ilişki ve moral etkisi.
  static const double championMorale = 15;
  static const double runnerUpMorale = 5;
  static const double semiMorale = 2;
  static const double earlyExitMorale = -3;
}
