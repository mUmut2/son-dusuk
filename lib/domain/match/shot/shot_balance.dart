/// Şut mini oyununun TÜM denge parametreleri (kod içine gömülmez).
///
/// Koordinatlar "kale düzlemi" birimidir: X -1 (sol direk) .. +1 (sağ direk),
/// Y 0 (zemin) .. 1 (üst direk). |X|>1 veya Y>1 isabetsiz demektir.
abstract final class ShotBalance {
  // --- Zamanlama halkası ---
  /// Halkanın küçülme süresi (sn); Sakinlik uzatır, zorluk çarpar.
  static const double ringSecondsBase = 1.5;
  static const double ringSecondsComposureSpan = 0.3; // 0.85 .. 1.15 çarpan
  static const int ringMaxCycles = 3;

  /// "Mükemmel" zamanlama penceresi (halka ilerlemesi, ±) ve kalite 0'a
  /// düştüğü geniş pencere (Şut niteliği genişletir).
  static const double perfectHalfWindow = 0.06;
  static const double goodHalfWindow = 0.35;

  // --- Sapma (hedeften rastgele kayma) ---
  static const double sigmaBase = 0.28;
  static const double sigmaFinesseGain = 0.12;
  static const double sigmaShootingGain = 0.08;

  /// Zamanlama kalitesi 1 -> çarpan (1.55 - 0.85) = 0.70, kalite 0 -> 1.55.
  static const double timingSigmaMax = 2.2;
  static const double timingSigmaSpan = 1.6;

  /// Kötü zamanlamada "kötü vuruş" (mishit) olasılığı = çarpan * (1-kalite)^2.
  /// Kötü vuruşta sapma ve kaleci erişimi artar, güç düşer.
  static const double mishitChance = 0.9;
  static const double mishitSigma = 2.0;
  static const double mishitPower = 0.5;

  /// Baskı altında sapma artışı (Sakinlik azaltır).
  static const double pressureSigmaGain = 0.6;

  /// Çok sert vuruşta isabet düşer.
  static const double powerSigmaThreshold = 0.8;
  static const double powerSigmaGain = 0.6;

  // --- Falso ---
  /// Tam falsonun (curve = ±1) kale düzleminde kaydırdığı mesafe.
  static const double curveGainBase = 0.25;
  static const double curveGainFinesse = 0.35;

  // --- Güç ---
  static const double powerEfficiencyBase = 0.8;
  static const double powerEfficiencyShooting = 0.3;

  // --- Kaleci ---
  static const double keeperReachBase = 0.2;
  static const double keeperReachSkill = 0.35;

  /// Güç kaleci erişimini azaltır: çarpan = a - b * güç.
  static const double keeperPowerA = 1.2;
  static const double keeperPowerB = 0.5;

  /// Üst köşelere (Y > eşik) erişim bu çarpanla azalır.
  static const double keeperHighThreshold = 0.75;
  static const double keeperHighFactor = 0.6;

  /// Kalecinin şutun yönünü okuma olasılığı = base + skill * gain.
  static const double keeperReadBase = 0.1;
  static const double keeperReadSkill = 0.4;
  static const double keeperReadNoise = 0.12;
  static const double keeperGuessNoise = 0.10;
  static const List<double> keeperGuessZones = [-0.65, 0, 0.65];

  // --- Savunmacı ---
  /// Şut çizgisi savunmacıya bu kadar yakınsa blok ihtimali vardır.
  static const double blockWidth = 0.35;

  /// Yerden şutlar daha kolay engellenir; Y bu değere ulaşınca blok -%80.
  static const double blockHeightScale = 0.8;
  static const double blockHeightReduction = 0.8;

  // --- Direk / üst direk ---
  static const double woodworkMargin = 0.06;

  // --- Bağlam (kritik anın zorluğu) ---
  static const double keeperSkillMean = 0.55;
  static const double keeperSkillStdDev = 0.12;
  static const double pressureMax = 0.8;
  static const double defenderAimRange = 0.7;

  // --- Zorluk seviyesi (Kolay / Normal / Zor) ---
  static const double easyRing = 1.25;
  static const double hardRing = 0.85;
  static const double easyWindow = 1.3;
  static const double hardWindow = 0.8;
  static const double easyKeeperDelta = -0.1;
  static const double hardKeeperDelta = 0.1;

  // --- Görsel/etkileşim (oyun katmanı) ---
  /// Swipe hızı (px/sn) bu değerde güç = 1.
  static const double maxSwipeSpeed = 2800;
  static const double minSwipeSpeed = 350;

  /// Yolun akorddan sapması / akord uzunluğu bu orana ulaşınca falso = ±1.
  static const double fullCurveRatio = 0.3;
  static const double ballFlightSeconds = 0.7;
}
