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
  static const double safeRisk = 0.08;
  static const double safeReward = 0.04;
  static const double safePower = 0.35;
  static const double forwardRisk = 0.2;
  static const double forwardReward = 0.09;
  static const double forwardPower = 0.55;
  static const double throughRisk = 0.5;
  static const double throughReward = 0.16;
  static const double throughPower = 0.7;
  static const double switchRisk = 0.3;
  static const double switchReward = 0.10;
  static const double switchPower = 0.85;

  /// Vizyon: ödül x (1 + a x vizyon), risk x (1 - b x vizyon).
  static const double visionRewardGain = 0.4;
  static const double visionRiskCut = 0.3;

  /// İbre isabeti: |güç - ideal| bu toleransın içindeyse kısmen doğru.
  static const double passPowerTolerance = 0.35;
  static const double passMeterPeriod = 1.4;
  static const double passMaxSeconds = 8;

  // ---------------- DRIBLING ----------------
  /// Savunmacı "atılma" gecikmesi (sn) ve çalım penceresi yarıçapı (sn).
  static const double lungeDelayMin = 1.4;
  static const double lungeDelayMax = 2.6;
  static const double lungeTelegraph = 0.55;
  static const double dribbleGoodWindow = 0.28;
  static const double dribblePerfectWindow = 0.06;

  /// Başarı olasılığı = (taban + zamanlama x genişlik) x yetenek x savunmacı.
  static const double dribbleBase = 0.2;
  static const double dribbleSpan = 0.7;
  static const double dribbleWrongDirection = 0.05;
  static const double dribbleSkillSpread = 0.6;
  static const double dribbleDefenderEdge = 0.35;

  /// Çalım sonrası asist olasılığı.
  static const double dribbleAssistGivenSuccess = 0.08;

  // ---------------- MUDAHALE ----------------
  /// Rakip topu ayağından bu periyotla açar; en uzak an müdahale penceresidir.
  static const double tacklePeriod = 0.9;
  static const double tackleApproachSeconds = 4.5;
  static const double tackleGoodWindow = 0.3;

  /// Hizalama bu değerin altındaysa rakip geçer.
  static const double tackleMinAlignment = 0.3;
  static const double tackleBase = 0.5;
  static const double tackleSpan = 0.6;
  static const double tackleSkillSpread = 0.6;
  static const double tackleAttackerEdge = 0.3;

  /// Başarısızlıkta faul olasılığı = (1 - zamanlama) x bu x (1 - 0.4 x Defans).
  static const double foulChance = 0.5;
  static const double foulConcedeChance = 0.08;
  static const double beatenConcedeChance = 0.12;
}
