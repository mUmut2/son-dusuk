enum InjuryType { muscle, ligament, fracture }

class Injury {
  const Injury({
    required this.type,
    required this.weeksLeft,
    required this.totalWeeks,
    this.isRelapse = false,
  });

  factory Injury.fromJson(Map<String, dynamic> json) => Injury(
    type: InjuryType.values.byName(json['type'] as String),
    weeksLeft: json['weeksLeft'] as int,
    totalWeeks: json['totalWeeks'] as int,
    isRelapse: json['isRelapse'] as bool? ?? false,
  );

  final InjuryType type;
  final int weeksLeft;
  final int totalWeeks;
  final bool isRelapse;

  Injury copyWith({int? weeksLeft}) => Injury(
    type: type,
    weeksLeft: weeksLeft ?? this.weeksLeft,
    totalWeeks: totalWeeks,
    isRelapse: isRelapse,
  );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'weeksLeft': weeksLeft,
    'totalWeeks': totalWeeks,
    'isRelapse': isRelapse,
  };
}

/// Kondisyon, form, moral ve sakatlık: enerji sisteminin yerini alan,
/// birbirini etkileyen durum değerleri.
class PlayerStatus {
  const PlayerStatus({
    this.condition = 100,
    this.form = neutralForm,
    this.morale = 60,
    this.injury,
    this.relapseRisk = 0,
    this.recentRatings = const [],
  });

  factory PlayerStatus.fromJson(Map<String, dynamic> json) => PlayerStatus(
    condition: (json['condition'] as num?)?.toDouble() ?? 100,
    form: (json['form'] as num?)?.toDouble() ?? neutralForm,
    morale: (json['morale'] as num?)?.toDouble() ?? 60,
    injury: json['injury'] == null
        ? null
        : Injury.fromJson(json['injury'] as Map<String, dynamic>),
    relapseRisk: (json['relapseRisk'] as num?)?.toDouble() ?? 0,
    recentRatings: [
      for (final r in (json['recentRatings'] as List<dynamic>? ?? const []))
        (r as num).toDouble(),
    ],
  );

  /// Maç yoksa varsayılan form (ortalama bir performans).
  static const double neutralForm = 6.0;

  /// 0-100. Düşükken performans ve sakatlık riski kötüleşir.
  final double condition;

  /// 0-10. Son 5 maçın reyting ortalaması (10 en iyi, 0 en kötü); hiç maç
  /// yoksa 6.0.
  final double form;

  /// 0-100.
  final double morale;

  final Injury? injury;

  /// Riskli erken dönüşten sonra tekrar sakatlanma riski (0-1, zamanla söner).
  final double relapseRisk;

  /// Son (en fazla 5) maç reytingi, eskiden yeniye.
  final List<double> recentRatings;

  bool get isInjured => injury != null;

  /// Formun performansa etkisi, "puan" cinsinden (-10..+10): her form puanı
  /// 6'nın üstünde/altında 2.5 puan eder (form 10 -> +10, form ≤2 -> -10).
  double get formBonus => ((form - neutralForm) * 2.5).clamp(-10.0, 10.0);

  /// Mini oyun ve otomatik çözüm için performans çarpanı (~0.6-1.15).
  /// Form +-%10'a kadar, düşük kondisyon %24'e, düşük moral %12'ye kadar etkiler.
  double get performanceMultiplier {
    final value =
        1 +
        0.01 * formBonus -
        (60 - condition).clamp(0.0, 60.0) * 0.004 -
        (40 - morale).clamp(0.0, 40.0) * 0.003;
    return value.clamp(0.6, 1.15);
  }

  PlayerStatus copyWith({
    double? condition,
    double? form,
    double? morale,
    Injury? injury,
    bool clearInjury = false,
    double? relapseRisk,
    List<double>? recentRatings,
  }) => PlayerStatus(
    condition: (condition ?? this.condition).clamp(0.0, 100.0),
    form: (form ?? this.form).clamp(0.0, 10.0),
    morale: (morale ?? this.morale).clamp(0.0, 100.0),
    injury: clearInjury ? null : (injury ?? this.injury),
    relapseRisk: (relapseRisk ?? this.relapseRisk).clamp(0.0, 1.0),
    recentRatings: recentRatings ?? this.recentRatings,
  );

  Map<String, dynamic> toJson() => {
    'condition': condition,
    'form': form,
    'morale': morale,
    'injury': injury?.toJson(),
    'relapseRisk': relapseRisk,
    'recentRatings': recentRatings,
  };
}

/// Kariyer istatistikleri (başarımlar ve kariyer özeti için).
class CareerStats {
  const CareerStats({
    this.matches = 0,
    this.goals = 0,
    this.assists = 0,
    this.ratingSum = 0,
    this.penaltyZones = const [0, 0, 0, 0, 0, 0],
    this.transfers = 0,
  });

  factory CareerStats.fromJson(Map<String, dynamic> json) => CareerStats(
    matches: json['matches'] as int? ?? 0,
    goals: json['goals'] as int? ?? 0,
    assists: json['assists'] as int? ?? 0,
    ratingSum: (json['ratingSum'] as num?)?.toDouble() ?? 0,
    penaltyZones: [
      for (final z in (json['penaltyZones'] as List<dynamic>? ?? const []))
        z as int,
    ].followedBy(List.filled(6, 0)).take(6).toList(),
    transfers: json['transfers'] as int? ?? 0,
  );

  final int matches;
  final int goals;
  final int assists;
  final double ratingSum;

  /// Kulüp değiştirdiği transfer sayısı (yenilemeler sayılmaz).
  final int transfers;

  /// Penaltılarda 6 bölgeden her birinin kaç kez seçildiği (kaleci okur).
  final List<int> penaltyZones;

  double get averageRating => matches == 0 ? 0 : ratingSum / matches;

  CareerStats addMatch({
    required int goals,
    required int assists,
    required double rating,
  }) => CareerStats(
    matches: matches + 1,
    goals: this.goals + goals,
    assists: this.assists + assists,
    ratingSum: ratingSum + rating,
    penaltyZones: penaltyZones,
    transfers: transfers,
  );

  CareerStats addPenalty(int zone) => CareerStats(
    matches: matches,
    goals: goals,
    assists: assists,
    ratingSum: ratingSum,
    penaltyZones: [
      for (var i = 0; i < penaltyZones.length; i++)
        penaltyZones[i] + (i == zone ? 1 : 0),
    ],
    transfers: transfers,
  );

  CareerStats addTransfer() => CareerStats(
    matches: matches,
    goals: goals,
    assists: assists,
    ratingSum: ratingSum,
    penaltyZones: penaltyZones,
    transfers: transfers + 1,
  );

  Map<String, dynamic> toJson() => {
    'matches': matches,
    'goals': goals,
    'assists': assists,
    'ratingSum': ratingSum,
    'penaltyZones': penaltyZones,
    'transfers': transfers,
  };
}
