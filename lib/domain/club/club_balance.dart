import '../player/attribute.dart';
import 'contract.dart';
import 'equipment.dart';
import 'finance.dart';

/// Kulüp, kontrat, transfer ve ekonomi denge parametreleri (tek yer).
/// Para birimi kurgusal ₺; maaşlar haftalıktır.
abstract final class ClubBalance {
  // --- Maaş ---
  /// Kademe (1 = en üst) başına, kademe ortalama gücündeki bir oyuncunun maaşı.
  static const List<double> tierWageBase = [80000, 24000, 6500, 1900, 600];

  /// Oyuncunun gücü kademe ortalamasından her puan yukarıdaysa maaş bu kadar çarpılır.
  static const double wagePerOverall = 1.045;

  static double ageWageFactor(int age) {
    if (age <= 17) return 0.5;
    if (age == 18) return 0.7;
    if (age <= 20) return 0.85;
    if (age >= 34) return 0.8;
    return 1.0;
  }

  static const Map<SquadRole, double> roleWage = {
    SquadRole.prospect: 0.6,
    SquadRole.rotation: 0.85,
    SquadRole.starter: 1.0,
    SquadRole.star: 1.4,
  };

  // --- Rol ve kadroya girme ---
  /// Kulüp "seviyesi" = takım gücü + bu fark. Ortalama bir oyuncu üst ligin
  /// değil orta kademelerin oyuncusudur; üst lig yalnızca en iyilere açıktır.
  static const double teamLevelOffset = 6;

  static double teamLevel(double strength) => strength + teamLevelOffset;

  /// Oyuncunun (etkin) gücü takım gücünün bu kadar üstündeyse rol belirlenir.
  static const double starMargin = 8;
  static const double starterMargin = 1;
  static const double rotationMargin = -6;

  /// Genç (≤ [youthMaxAge]) oyuncu, bu farka kadar gerideki bir kulüpte yedek
  /// olarak (prospect) teklif alabilir.
  static const double youthProspectMargin = -10;
  static const int youthMaxAge = 20;

  /// 21 yaşa kadar potansiyelin bu payı etkin güce eklenir (kulüpler gelecek görür).
  static const int potentialMaxAge = 21;
  static const double potentialShare = 0.2;

  /// Lig maçında ilk 11'de yer alma olasılığı.
  static const Map<SquadRole, double> rolePlayChance = {
    SquadRole.prospect: 0.35,
    SquadRole.rotation: 0.7,
    SquadRole.starter: 0.95,
    SquadRole.star: 1.0,
  };

  // --- Sözleşme ---
  static const int startingContractYears = 2;
  static const int maxYears = 4;
  static const int renewalMaxYears = 3;

  /// İmza parası = yeni haftalık maaş × bu çarpan.
  static const double signingBonusWeeks = 8;

  // --- Teklifler ---
  /// Transfer penceresinde haftalık teklif gelme olasılığı (taban).
  static const double offerChance = 0.3;
  static const double freeAgentOfferChance = 0.9;
  static const int maxPendingOffers = 3;
  static const int offerLifetimeWeeks = 3;

  /// Aday kulüp gücü: etkin güç - [candidateBelow] .. + [candidateAbove].
  static const double candidateBelow = 14;
  static const double candidateAbove = 3;

  /// Teklif edilen maaş = adil maaş × (1 - offerLow .. 1 + offerHigh).
  static const double offerLow = 0.1;
  static const double offerHigh = 0.05;

  /// Kulübün çıkabileceği üst sınır = adil maaş × (maxWageBase + 0..maxWageSpread + menajer).
  static const double maxWageBase = 1.12;
  static const double maxWageSpread = 0.1;

  /// İstenen maaş üst sınırın bu katını aşarsa kulüp teklifi geri çeker.
  static const double walkAwayFactor = 1.12;

  /// Pazarlıkta istenebilecek en yüksek zam (teklife göre).
  static const double maxAsk = 0.4;

  // --- Yenileme ---
  static const int renewalWeekFrom = 30;
  static const Map<SquadRole, double> renewalChance = {
    SquadRole.prospect: 0.25,
    SquadRole.rotation: 0.5,
    SquadRole.starter: 0.8,
    SquadRole.star: 0.95,
  };

  // --- Piyasa değeri ---
  static const double valueBase = 40000;
  static const double valueBaseOverall = 40;
  static const double valueGrowth = 0.11;

  static double ageValueFactor(int age) {
    if (age <= 23) return 1.2;
    if (age <= 28) return 1.0;
    if (age <= 31) return 0.7;
    return 0.4;
  }

  // --- Menajer (seviye 1-3) ---
  static const Map<int, double> agentCommission = {1: 0.05, 2: 0.08, 3: 0.12};

  /// Pazarlıkta kulübün üst sınırına eklenen oran.
  static const Map<int, double> agentNegotiation = {1: 0.03, 2: 0.08, 3: 0.15};

  /// Teklif gelme olasılığı çarpanı.
  static const Map<int, double> agentOfferBoost = {1: 1.0, 2: 1.35, 3: 1.8};

  /// Menajeri tutmak için gereken en düşük genel güç.
  static const Map<int, int> agentMinOverall = {1: 0, 2: 50, 3: 68};

  // --- Finans ---
  static const int startingBalance = 1500;

  /// Haftalık yaşam gideri.
  static const Map<Lifestyle, int> lifestyleCost = {
    Lifestyle.modest: 150,
    Lifestyle.comfortable: 1200,
    Lifestyle.lavish: 12000,
  };

  /// Haftalık moral etkisi.
  static const Map<Lifestyle, double> lifestyleMorale = {
    Lifestyle.modest: 0,
    Lifestyle.comfortable: 1,
    Lifestyle.lavish: 2.5,
  };

  // --- Ekipman (Faz 9) ---
  static const int equipmentMaxLevel = 3;

  /// Seviye başına fiyat (1., 2., 3. seviye). Kademe/gelir eğrisine göre.
  static const Map<EquipmentSlot, List<int>> equipmentPrice = {
    EquipmentSlot.boots: [6000, 50000, 400000],
    EquipmentSlot.trainingKit: [5000, 40000, 300000],
    EquipmentSlot.recoveryKit: [5000, 35000, 280000],
    EquipmentSlot.shinGuards: [4000, 30000, 250000],
  };

  /// Krampon: seviye başına maç niteliklerine artı ve artı alan nitelikler.
  static const int bootsBonusPerLevel = 2;
  static const List<Attribute> bootsAttributes = [
    Attribute.shooting,
    Attribute.finesse,
    Attribute.dribbling,
    Attribute.pace,
    Attribute.agility,
    Attribute.ballControl,
  ];

  /// Antrenman seti: seviye başına kazanç artışı (oran).
  static const double trainingKitPerLevel = 0.12;

  /// Toparlanma seti: seviye başına haftalık ek kondisyon.
  static const double recoveryKitPerLevel = 4;

  /// Tekmelik: seviye başına sakatlanma riski azalması (oran).
  static const double shinGuardsPerLevel = 0.1;

  /// Bakiye eksideyken haftalık moral cezası.
  static const double debtMorale = -2;

  /// Galibiyet ve gol primi (haftalık maaşın oranı).
  static const double winBonusShare = 0.25;
  static const double goalBonusShare = 0.15;
}
