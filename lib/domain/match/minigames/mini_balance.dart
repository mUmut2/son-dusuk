/// Şut dışındaki mini oyunların TÜM denge parametreleri (kod içine gömülmez).
/// Şut/serbest vuruş/kafa/bire bir için bkz. `shot/shot_balance.dart`.
abstract final class MiniBalance {
  // ---------------- PENALTI ----------------
  /// Kale bölgeleri 3 sütun x 2 satır (indeks = satır*3 + sütun, satır 0 = yer).
  static const List<double> penaltyZoneX = [-0.7, 0.0, 0.7];
  static const List<double> penaltyZoneY = [0.2, 0.75];

  /// Titreme (sapma) = base x (1 - kesinti x Sakinlik) x (1 + baskı x 0.5 x (1 - Sakinlik)).
  static const double penaltySigmaBase = 0.20;
  static const double penaltyComposureCut = 0.6;
  static const double penaltyPressure = 0.6;

  /// Güç ibresi: bu değerin üstü "aceleye gelir" (sapma x1.7), altı zayıf vuruş.
  static const double penaltyRushedPower = 0.93;
  static const double penaltyWeakPower = 0.45;
  static const double penaltyRushedSigma = 1.7;

  /// Kalecinin kurtarma olasılıkları (yakın bölge / komşu bölge) ve becerisi.
  static const double keeperSaveNear = 0.85;
  static const double keeperSaveAdjacent = 0.12;
  static const double keeperNearRadius = 0.4;
  static const double keeperAdjacentRadius = 0.85;
  static const double weakPowerSaveBonus = 0.15;

  /// Kalecinin eğilimi: eşit dağılım + oyuncunun geçmiş penaltı bölgeleri.
  static const double keeperHistoryWeight = 0.5;

  /// Güç ibresi tam salınım süresi (sn) ve beklenen süre sınırı.
  static const double penaltyMeterPeriod = 1.1;
  static const double penaltyMaxSeconds = 7;

  // ---------------- SERBEST VURUS ----------------
  /// Duvar yüksekliği (kale düzlemi Y birimi) ve zıplama bonusu/olasılığı.
  static const double wallHeight = 0.40;
  static const double wallJumpChance = 0.3;
  static const double wallJumpBonus = 0.25;
  static const double wallHalfWidthMin = 0.14;
  static const double wallHalfWidthMax = 0.30;

  /// Duvarı aşma: kalkış = aimY x (a + b x güç).
  static const double clearanceA = 0.5;
  static const double clearanceB = 0.3;

  // ---------------- KAFA ----------------
  static const double headerAimY = 0.35;
  static const double headerDuelPressureMax = 0.7;

  /// Havada mücadele kaybı: baskı x (1 - zamanlama) x (1 - güç x bu).
  static const double headerStrengthEdge = 0.5;
  static const double headerKeeperBonus = 0.25;

  // ---------------- PAS ----------------
  /// Vizyona göre seçenek sayısı: <40 -> 2, <70 -> 3, değilse 4.
  static const double visionTwo = 40;
  static const double visionThree = 70;

  /// Pas türleri: risk (kesilme), ödül (asist olasılığı), ideal güç.
  static const double safeRisk = 0.05;
  static const double safeReward = 0.04;
  static const double safePower = 0.35;
  static const double forwardRisk = 0.12;
  static const double forwardReward = 0.09;
  static const double forwardPower = 0.55;
  static const double throughRisk = 0.3;
  static const double throughReward = 0.16;
  static const double throughPower = 0.7;
  static const double switchRisk = 0.18;
  static const double switchReward = 0.10;
  static const double switchPower = 0.85;

  /// Vizyon: ödül x (1 + a x vizyon), risk x (1 - b x vizyon).
  static const double visionRewardGain = 0.4;
  static const double visionRiskCut = 0.3;

  /// İbre isabeti: |güç - ideal| bu toleransın içindeyse kısmen doğru.
  static const double passPowerTolerance = 0.45;
  static const double passMeterPeriod = 2.0;
  static const double passMaxSeconds = 12;

  // ---------------- DRIBLING (savunma hattından geç) ----------------
  /// Dalga sayısı; ilk dalganın oyuncuya ulaşma anı ve dalgalar arası süre (sn).
  static const int dribbleWaves = 4;
  static const double dribbleFirstArrival = 2.0;
  static const double dribbleWaveInterval = 1.25;

  /// Savunmacıların ekranın tepesinden oyuncuya inme süresi (sn).
  static const double dribbleTravelSeconds = 1.5;

  /// Geçit (iki savunmacı arası) yarı genişliği, ekran genişliğinin oranı.
  /// Yetenek: geçit x (1 - spread/2 + spread x yetenek).
  static const double dribbleGapHalf = 0.15;
  static const double dribbleGapSkillSpread = 0.3;

  /// Çarpışma payı: savunmacı ve oyuncu yarı genişliği (ekran oranı).
  /// Çizimlerin üst üste binmemesi için toplamı kişi çiziminin yarı
  /// genişliklerinin toplamından büyük olmalı (bkz. dribble_test).
  static const double dribbleDefenderHalf = 0.07;
  static const double dribblePlayerHalf = 0.05;

  /// Geçit merkezinin sınırları ve ardışık dalgalar arası kayma (ekran oranı).
  static const double dribbleGapMin = 0.25;
  static const double dribbleGapMax = 0.75;
  static const double dribbleMinShift = 0.15;
  static const double dribbleMaxShift = 0.4;

  /// Savunmacı hattının yana salınımı: genlik = bu x savunmacı gücü; hız rad/sn.
  static const double dribbleSway = 0.12;
  static const double dribbleSwayRate = 2.2;

  /// Oyuncunun en yüksek yanal hızı (ekran genişliği / sn).
  static const double dribblePlayerSpeed = 1.8;

  /// Çalım sonrası asist olasılığı.
  static const double dribbleAssistGivenSuccess = 0.08;

  // ---------------- MUDAHALE ----------------
  /// Rakip topu ayağından bu periyotla açar; en uzak an müdahale penceresidir.
  static const double tacklePeriod = 1.3;
  static const double tackleApproachSeconds = 6;
  static const double tackleGoodWindow = 0.45;

  /// Hizalama bu değerin altındaysa rakip geçer.
  static const double tackleMinAlignment = 0.12;
  static const double tackleBase = 0.6;
  static const double tackleSpan = 0.6;
  static const double tackleSkillSpread = 0.6;
  static const double tackleAttackerEdge = 0.3;

  /// Başarısızlıkta faul olasılığı = (1 - zamanlama) x bu x (1 - 0.4 x Defans).
  static const double foulChance = 0.5;
  static const double foulConcedeChance = 0.08;
  static const double beatenConcedeChance = 0.12;
}
