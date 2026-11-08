/// Oyuncunun bir lig maçının skoru (puan durumunda kendi maçı yerine geçer).
class MatchRecord {
  const MatchRecord({
    required this.round,
    required this.clubId,
    required this.scoreFor,
    required this.scoreAgainst,
  });

  factory MatchRecord.fromJson(Map<String, dynamic> json) => MatchRecord(
    round: json['round'] as int,
    clubId: json['clubId'] as String,
    scoreFor: json['scoreFor'] as int,
    scoreAgainst: json['scoreAgainst'] as int,
  );

  /// Lig turu (1-34).
  final int round;
  final String clubId;
  final int scoreFor;
  final int scoreAgainst;

  Map<String, dynamic> toJson() => {
    'round': round,
    'clubId': clubId,
    'scoreFor': scoreFor,
    'scoreAgainst': scoreAgainst,
  };
}
