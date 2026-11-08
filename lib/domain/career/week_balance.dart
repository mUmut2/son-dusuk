import 'player_status.dart';
import 'weekly_plan.dart';

/// Haftalık yaşam döngüsünün TÜM denge parametreleri.
abstract final class WeekBalance {
  // --- Antrenman kazanımı (odaktaki her nitelik için, hafta başına puan) ---
  static const double trainingGainBase = 0.05;
  static const Map<TrainingIntensity, double> intensityGain = {
    TrainingIntensity.light: 0.6,
    TrainingIntensity.normal: 1.0,
    TrainingIntensity.hard: 1.5,
  };

  /// Yaşa göre antrenman verimi çarpanı (genç daha çok kazanır).
  static double ageGainMultiplier(int age) {
    if (age <= 21) return 1.0;
    if (age <= 26) return 0.7;
    if (age <= 30) return 0.4;
    return 0.2;
  }

  // --- Kondisyon ---
  static const double weeklyRecovery = 30;
  static const Map<TrainingIntensity, double> trainingCondition = {
    TrainingIntensity.light: -5,
    TrainingIntensity.normal: -10,
    TrainingIntensity.hard: -18,
  };

  /// Dinlenme odağı kondisyonu ekstra yeniler.
  static const double restRecovery = 15;
  static const double matchCondition = -15;
  static const Map<SocialActivity, double> socialCondition = {
    SocialActivity.none: 0,
    SocialActivity.family: 0,
    SocialActivity.friends: -3,
    SocialActivity.hobby: 2,
  };

  // --- Sakatlık ---
  static const double injuryBase = 0.01;
  static const double injuryProneGain = 0.015;

  /// Kondisyon 60'ın altına düştükçe eklenen risk (0'da +0.06).
  static const double lowConditionThreshold = 60;
  static const double lowConditionRisk = 0.06;
  static const double matchRisk = 0.01;
  static const Map<TrainingIntensity, double> intensityRisk = {
    TrainingIntensity.light: 0.0,
    TrainingIntensity.normal: 0.005,
    TrainingIntensity.hard: 0.015,
  };

  /// Tür olasılıkları ve süre aralıkları (hafta, uçlar dahil).
  static const Map<InjuryType, double> injuryTypeWeight = {
    InjuryType.muscle: 0.6,
    InjuryType.ligament: 0.3,
    InjuryType.fracture: 0.1,
  };
  static const Map<InjuryType, (int, int)> injuryWeeks = {
    InjuryType.muscle: (1, 4),
    InjuryType.ligament: (4, 10),
    InjuryType.fracture: (8, 16),
  };

  /// Dinlenme odağında iyileşmenin bir hafta daha kısalma olasılığı.
  static const double restHealChance = 0.25;

  /// Riskli erken dönüş: tekrar sakatlanma riski, kondisyon cezası, tekrarda süre çarpanı.
  static const double earlyReturnRelapseRisk = 0.35;
  static const double earlyReturnCondition = -10;
  static const double relapseDurationMultiplier = 1.5;
  static const double relapseRiskDecay = 0.5;

  // --- Form ---
  /// Form = (ortalama reyting - 6) * bu çarpan, [-10, 10]. 5 maçlık pencere.
  static const double formPerRating = 5;
  static const int ratingWindow = 5;

  /// Maç oynanmayan haftada formun sıfıra doğru sönümü (oran / sakatken mutlak puan).
  static const double formDecay = 0.2;
  static const double formDecayInjured = 1.0;

  // --- Moral ---
  static const double moraleBaseline = 60;
  static const double moraleDrift = 0.08;
  static const double moraleWin = 3;
  static const double moraleLoss = -3;
  static const double moraleGreatRating = 3; // reyting >= 7.5
  static const double moralePoorRating = -3; // reyting <= 5
  static const double moraleInjuredWeek = -2;
  static const double moraleInjuryOnset = -6;
  static const double moraleHealed = 3;
  static const double moraleExhausted = -3; // kondisyon < 30
  static const double moraleHardTraining = -1;
  static const Map<SocialActivity, double> socialMorale = {
    SocialActivity.none: 0,
    SocialActivity.family: 4,
    SocialActivity.friends: 5,
    SocialActivity.hobby: 3,
  };
}
