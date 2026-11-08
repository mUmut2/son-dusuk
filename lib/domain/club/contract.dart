/// Kulüpteki rol: ne sıklıkla ilk 11'de başlayacağını ve maaşı belirler.
enum SquadRole { prospect, rotation, starter, star }

/// Oyuncunun kulüple sözleşmesi. Maaş haftalıktır (₺).
class Contract {
  const Contract({
    required this.clubId,
    required this.weeklyWage,
    required this.endSeason,
    required this.role,
  });

  factory Contract.fromJson(Map<String, dynamic> json) => Contract(
    clubId: json['clubId'] as String,
    weeklyWage: json['weeklyWage'] as int,
    endSeason: json['endSeason'] as int,
    role: SquadRole.values.byName(json['role'] as String),
  );

  final String clubId;
  final int weeklyWage;

  /// Sözleşmenin son sezonu (o sezonun sonunda biter).
  final int endSeason;
  final SquadRole role;

  /// [season] dahil kalan sezon sayısı.
  int yearsLeft(int season) => endSeason - season + 1;

  Contract copyWith({int? weeklyWage, int? endSeason, SquadRole? role}) =>
      Contract(
        clubId: clubId,
        weeklyWage: weeklyWage ?? this.weeklyWage,
        endSeason: endSeason ?? this.endSeason,
        role: role ?? this.role,
      );

  Map<String, dynamic> toJson() => {
    'clubId': clubId,
    'weeklyWage': weeklyWage,
    'endSeason': endSeason,
    'role': role.name,
  };
}
