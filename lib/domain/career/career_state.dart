import '../club/agent.dart';
import '../club/contract.dart';
import '../club/finance.dart';
import '../club/transfer_offer.dart';
import '../player/player.dart';
import '../social/event_models.dart';
import '../social/relationships.dart';
import 'match_record.dart';
import 'player_status.dart';
import 'season_calendar.dart';

/// Bir kayıt slotundaki tüm kariyer durumu. Sonraki fazlarda genişler.
class CareerState {
  const CareerState({
    required this.player,
    this.season = 1,
    this.week = 1,
    this.status = const PlayerStatus(),
    this.stats = const CareerStats(),
    this.worldSeed = 1,
    this.contract,
    this.agent,
    this.finance = const Finance(),
    this.offers = const [],
    this.results = const [],
    this.relations = const Relationships(),
    this.pendingEvents = const [],
    this.news = const [],
    this.eventSeen = const {},
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
    worldSeed: json['worldSeed'] as int? ?? 1,
    contract: json['contract'] == null
        ? null
        : Contract.fromJson(json['contract'] as Map<String, dynamic>),
    agent: json['agent'] == null
        ? null
        : Agent.fromJson(json['agent'] as Map<String, dynamic>),
    finance: json['finance'] == null
        ? const Finance()
        : Finance.fromJson(json['finance'] as Map<String, dynamic>),
    offers: [
      for (final o in (json['offers'] as List<dynamic>? ?? const []))
        TransferOffer.fromJson(o as Map<String, dynamic>),
    ],
    results: [
      for (final r in (json['results'] as List<dynamic>? ?? const []))
        MatchRecord.fromJson(r as Map<String, dynamic>),
    ],
    relations: json['relations'] == null
        ? const Relationships()
        : Relationships.fromJson(json['relations'] as Map<String, dynamic>),
    pendingEvents: [
      for (final e in (json['pendingEvents'] as List<dynamic>? ?? const []))
        PendingEvent.fromJson(e as Map<String, dynamic>),
    ],
    news: [
      for (final n in (json['news'] as List<dynamic>? ?? const []))
        NewsItem.fromJson(n as Map<String, dynamic>),
    ],
    eventSeen: Map<String, int>.from(
      (json['eventSeen'] as Map<String, dynamic>?) ?? const {},
    ),
  );

  final Player player;
  final int season;
  final int week;
  final PlayerStatus status;
  final CareerStats stats;

  /// Lig piramidini üreten seed (kayıtta yalnızca bu saklanır).
  final int worldSeed;

  /// null = kulübü yok (serbest oyuncu).
  final Contract? contract;
  final Agent? agent;
  final Finance finance;
  final List<TransferOffer> offers;

  /// Bu sezon oynanan lig maçlarının skorları.
  final List<MatchRecord> results;

  /// Çevreyle ilişkiler (teknik direktör, takım, taraftar, aile, medya).
  final Relationships relations;

  /// Cevap bekleyen olaylar (basın toplantısı, kişisel gelişmeler...).
  final List<PendingEvent> pendingEvents;

  /// Haber akışı, en yeni başta.
  final List<NewsItem> news;

  /// Olay kimliği -> en son çıktığı mutlak hafta (tekrarı önlemek için).
  final Map<String, int> eventSeen;

  bool get isFreeAgent => contract == null;

  /// Sezonlar boyunca artan hafta sayacı (tekliflerin son geçerlilik günü için).
  int get absoluteWeek => (season - 1) * SeasonCalendar.weeksPerSeason + week;

  CareerState copyWith({
    Player? player,
    int? season,
    int? week,
    PlayerStatus? status,
    CareerStats? stats,
    int? worldSeed,
    Contract? contract,
    bool clearContract = false,
    Agent? agent,
    bool clearAgent = false,
    Finance? finance,
    List<TransferOffer>? offers,
    List<MatchRecord>? results,
    Relationships? relations,
    List<PendingEvent>? pendingEvents,
    List<NewsItem>? news,
    Map<String, int>? eventSeen,
  }) => CareerState(
    player: player ?? this.player,
    season: season ?? this.season,
    week: week ?? this.week,
    status: status ?? this.status,
    stats: stats ?? this.stats,
    worldSeed: worldSeed ?? this.worldSeed,
    contract: clearContract ? null : (contract ?? this.contract),
    agent: clearAgent ? null : (agent ?? this.agent),
    finance: finance ?? this.finance,
    offers: offers ?? this.offers,
    results: results ?? this.results,
    relations: relations ?? this.relations,
    pendingEvents: pendingEvents ?? this.pendingEvents,
    news: news ?? this.news,
    eventSeen: eventSeen ?? this.eventSeen,
  );

  Map<String, dynamic> toJson() => {
    'player': player.toJson(),
    'season': season,
    'week': week,
    'status': status.toJson(),
    'stats': stats.toJson(),
    'worldSeed': worldSeed,
    'contract': contract?.toJson(),
    'agent': agent?.toJson(),
    'finance': finance.toJson(),
    'offers': [for (final o in offers) o.toJson()],
    'results': [for (final r in results) r.toJson()],
    'relations': relations.toJson(),
    'pendingEvents': [for (final e in pendingEvents) e.toJson()],
    'news': [for (final n in news) n.toJson()],
    'eventSeen': eventSeen,
  };
}
