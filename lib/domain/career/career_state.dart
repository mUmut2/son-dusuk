import '../player/player.dart';
import 'player_status.dart';

/// Bir kayıt slotundaki tüm kariyer durumu. Sonraki fazlarda genişler.
class CareerState {
  const CareerState({
    required this.player,
    this.season = 1,
    this.week = 1,
    this.status = const PlayerStatus(),
    this.stats = const CareerStats(),
  });

  factory CareerState.fromJson(Map<String, dynamic> json) => CareerState(
    player: Player.fromJson(json['player'] as Map<String, dynamic>),
    season: json['season'] as int? ?? 1,
    week: json['week'] as int? ?? 1,
    status: json['status'] == null
        ? const PlayerStatus()
        : PlayerStatus.fromJson(json['status'] as Map<String, dynamic>),
    stats: json['stats'] == null
        ? const CareerStats()
        : CareerStats.fromJson(json['stats'] as Map<String, dynamic>),
  );

  final Player player;
  final int season;
  final int week;
  final PlayerStatus status;
  final CareerStats stats;

  CareerState copyWith({
    Player? player,
    int? season,
    int? week,
    PlayerStatus? status,
    CareerStats? stats,
  }) => CareerState(
    player: player ?? this.player,
    season: season ?? this.season,
    week: week ?? this.week,
    status: status ?? this.status,
    stats: stats ?? this.stats,
  );

  Map<String, dynamic> toJson() => {
    'player': player.toJson(),
    'season': season,
    'week': week,
    'status': status.toJson(),
    'stats': stats.toJson(),
  };
}
