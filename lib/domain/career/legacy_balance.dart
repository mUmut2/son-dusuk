/// Emeklilik ve "miras puanı" denge parametreleri (tek yer).
abstract final class LegacyBalance {
  // --- Emeklilik ---
  /// Bu yaştan itibaren oyuncu kendi isteğiyle emekli olabilir.
  static const int voluntaryAge = 30;

  /// Bu yaşa gelen oyuncu sezon başında otomatik emekli olur.
  static const int forcedAge = 40;

  // --- Miras puanı ---
  static const double perGoal = 1.0;
  static const double perAssist = 0.6;
  static const double perMatch = 0.12;
  static const double perCap = 0.8;
  static const double perNationalGoal = 2.0;
  static const double topLeagueTitle = 80;
  static const double otherTitle = 25;
  static const double nationalTitle = 150;
  static const double nationalFinal = 30;

  /// Zirve gücün 60'ın üstündeki her puanı.
  static const double perPeakPoint = 6;

  /// Ulaşılan en üst kademe: (5 - kademe) x bu değer.
  static const double perTierStep = 20;
  static const double perAchievement = 6;

  /// Sıralama eşikleri (miras puanı): amatör, yerel, profesyonel, yıldız, efsane.
  static const List<double> rankThresholds = [0, 400, 650, 950, 1300];
}
