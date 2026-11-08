import '../player/player.dart';

/// Bir kayıt slotundaki tüm kariyer durumu. Sonraki fazlarda genişler.
class CareerState {
  const CareerState({required this.player, this.season = 1, this.week = 1});

  factory CareerState.fromJson(Map<String, dynamic> json) => CareerState(
    player: Player.fromJson(json['player'] as Map<String, dynamic>),
    season: json['season'] as int? ?? 1,
    week: json['week'] as int? ?? 1,
  );

  final Player player;
  final int season;
  final int week;

  CareerState copyWith({Player? player, int? season, int? week}) => CareerState(
    player: player ?? this.player,
    season: season ?? this.season,
    week: week ?? this.week,
  );

  Map<String, dynamic> toJson() => {
    'player': player.toJson(),
    'season': season,
    'week': week,
  };
}
