import 'spending_balance.dart';

/// Satın alınabilen kalıcı mülkler (hepsi kurgusaldır).
enum Property { watch, car, flat, villa, yacht }

/// Tekrar yapılabilen harcamalar.
enum Donation { charity, familyGift }

/// Bir maçta tahmin: ev sahibi / beraberlik / deplasman.
enum BetPick { home, draw, away }

/// Verilmiş (henüz sonuçlanmamış) bahis. Oyun parasıyla, kurgusal.
class PlacedBet {
  const PlacedBet({
    required this.homeId,
    required this.awayId,
    required this.pick,
    required this.stake,
    required this.odds,
    required this.season,
    required this.week,
  });

  factory PlacedBet.fromJson(Map<String, dynamic> json) => PlacedBet(
    homeId: json['home'] as String,
    awayId: json['away'] as String,
    pick: BetPick.values.byName(json['pick'] as String),
    stake: json['stake'] as int,
    odds: (json['odds'] as num).toDouble(),
    season: json['season'] as int,
    week: json['week'] as int,
  );

  final String homeId;
  final String awayId;
  final BetPick pick;
  final int stake;
  final double odds;

  /// Bahsin yapıldığı sezon ve hafta (o haftanın maçı oynanınca sonuçlanır).
  final int season;
  final int week;

  Map<String, dynamic> toJson() => {
    'home': homeId,
    'away': awayId,
    'pick': pick.name,
    'stake': stake,
    'odds': odds,
    'season': season,
    'week': week,
  };
}

/// Sonuçlanmış bahis (son birkaçı gösterilir).
class SettledBet {
  const SettledBet({
    required this.homeId,
    required this.awayId,
    required this.pick,
    required this.homeGoals,
    required this.awayGoals,
    required this.stake,
    required this.payout,
    required this.season,
    required this.week,
  });

  factory SettledBet.fromJson(Map<String, dynamic> json) => SettledBet(
    homeId: json['home'] as String,
    awayId: json['away'] as String,
    pick: BetPick.values.byName(json['pick'] as String),
    homeGoals: json['hg'] as int,
    awayGoals: json['ag'] as int,
    stake: json['stake'] as int,
    payout: json['payout'] as int,
    season: json['season'] as int,
    week: json['week'] as int,
  );

  final String homeId;
  final String awayId;
  final BetPick pick;
  final int homeGoals;
  final int awayGoals;
  final int stake;

  /// Geri ödenen tutar (kaybedilen bahiste 0).
  final int payout;
  final int season;
  final int week;

  bool get won => payout > 0;

  Map<String, dynamic> toJson() => {
    'home': homeId,
    'away': awayId,
    'pick': pick.name,
    'hg': homeGoals,
    'ag': awayGoals,
    'stake': stake,
    'payout': payout,
    'season': season,
    'week': week,
  };
}

/// Harcama ve "şans köşesi" durumu: mülkler, bahisler, alışkanlık ve cezalar.
class Spending {
  const Spending({
    this.properties = const [],
    this.bets = const [],
    this.settled = const [],
    this.habit = 0,
    this.penaltyStage = 0,
    this.suspendedWeeks = 0,
    this.totalStaked = 0,
    this.totalWon = 0,
    this.totalFines = 0,
    this.lastDonationWeek = 0,
    this.raceWeek = 0,
  });

  factory Spending.fromJson(Map<String, dynamic> json) => Spending(
    properties: [
      for (final p in (json['properties'] as List<dynamic>? ?? const []))
        Property.values.byName(p as String),
    ],
    bets: [
      for (final b in (json['bets'] as List<dynamic>? ?? const []))
        PlacedBet.fromJson(b as Map<String, dynamic>),
    ],
    settled: [
      for (final b in (json['settled'] as List<dynamic>? ?? const []))
        SettledBet.fromJson(b as Map<String, dynamic>),
    ],
    habit: (json['habit'] as num? ?? 0).toDouble(),
    penaltyStage: json['penaltyStage'] as int? ?? 0,
    suspendedWeeks: json['suspendedWeeks'] as int? ?? 0,
    totalStaked: json['totalStaked'] as int? ?? 0,
    totalWon: json['totalWon'] as int? ?? 0,
    totalFines: json['totalFines'] as int? ?? 0,
    lastDonationWeek: json['lastDonationWeek'] as int? ?? 0,
    raceWeek: json['raceWeek'] as int? ?? 0,
  );

  final List<Property> properties;

  /// Bu haftanın sonuçlanmamış bahisleri.
  final List<PlacedBet> bets;

  /// Son sonuçlanan bahisler, en yeni başta.
  final List<SettledBet> settled;

  /// Şans alışkanlığı 0-100. Bahis oynadıkça artar, oynamayınca azalır.
  final double habit;

  /// 0 yok, 1 uyarıldı, 2 para cezası aldı, 3 kadro dışı bırakıldı.
  final int penaltyStage;

  /// Kadro dışı kalınacak hafta sayısı.
  final int suspendedWeeks;
  final int totalStaked;
  final int totalWon;
  final int totalFines;

  /// En son bağış/hediye yapılan mutlak hafta.
  final int lastDonationWeek;

  /// En son at yarışı izlenen mutlak hafta (haftada bir yarış).
  final int raceWeek;

  bool owns(Property p) => properties.contains(p);

  bool get suspended => suspendedWeeks > 0;

  /// Mülklerin haftalık moral katkısı (üst sınırlı).
  double get moraleBonus {
    final sum = properties.fold(
      0.0,
      (a, p) => a + SpendingBalance.propertyMorale[p]!,
    );
    return sum > SpendingBalance.propertyMoraleCap
        ? SpendingBalance.propertyMoraleCap
        : sum;
  }

  Spending copyWith({
    List<Property>? properties,
    List<PlacedBet>? bets,
    List<SettledBet>? settled,
    double? habit,
    int? penaltyStage,
    int? suspendedWeeks,
    int? totalStaked,
    int? totalWon,
    int? totalFines,
    int? lastDonationWeek,
    int? raceWeek,
  }) => Spending(
    properties: properties ?? this.properties,
    bets: bets ?? this.bets,
    settled: settled ?? this.settled,
    habit: habit ?? this.habit,
    penaltyStage: penaltyStage ?? this.penaltyStage,
    suspendedWeeks: suspendedWeeks ?? this.suspendedWeeks,
    totalStaked: totalStaked ?? this.totalStaked,
    totalWon: totalWon ?? this.totalWon,
    totalFines: totalFines ?? this.totalFines,
    lastDonationWeek: lastDonationWeek ?? this.lastDonationWeek,
    raceWeek: raceWeek ?? this.raceWeek,
  );

  Map<String, dynamic> toJson() => {
    'properties': [for (final p in properties) p.name],
    'bets': [for (final b in bets) b.toJson()],
    'settled': [for (final b in settled) b.toJson()],
    'habit': habit,
    'penaltyStage': penaltyStage,
    'suspendedWeeks': suspendedWeeks,
    'totalStaked': totalStaked,
    'totalWon': totalWon,
    'totalFines': totalFines,
    'lastDonationWeek': lastDonationWeek,
    'raceWeek': raceWeek,
  };
}
