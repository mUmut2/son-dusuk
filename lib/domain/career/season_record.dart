/// Biten bir sezonun özeti (kariyer özeti ve başarımlar için).
class SeasonRecord {
  const SeasonRecord({
    required this.season,
    required this.age,
    required this.overall,
    this.clubId,
    this.tier = 0,
    this.position = 0,
    this.matches = 0,
    this.goals = 0,
    this.assists = 0,
    this.averageRating = 0,
  });

  factory SeasonRecord.fromJson(Map<String, dynamic> json) => SeasonRecord(
    season: json['season'] as int,
    age: json['age'] as int,
    overall: json['overall'] as int? ?? 0,
    clubId: json['clubId'] as String?,
    tier: json['tier'] as int? ?? 0,
    position: json['position'] as int? ?? 0,
    matches: json['matches'] as int? ?? 0,
    goals: json['goals'] as int? ?? 0,
    assists: json['assists'] as int? ?? 0,
    averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
  );

  final int season;
  final int age;

  /// Sezon sonundaki genel güç.
  final int overall;

  /// Sezonu bitirdiği kulüp (serbest oyuncuysa null).
  final String? clubId;

  /// 1 = en üst lig; 0 = kulübü yok.
  final int tier;

  /// Ligi bitirdiği sıra (1 = şampiyon); 0 = bilinmiyor.
  final int position;
  final int matches;
  final int goals;
  final int assists;
  final double averageRating;

  bool get champion => position == 1;

  Map<String, dynamic> toJson() => {
    'season': season,
    'age': age,
    'overall': overall,
    'clubId': clubId,
    'tier': tier,
    'position': position,
    'matches': matches,
    'goals': goals,
    'assists': assists,
    'averageRating': averageRating,
  };
}
