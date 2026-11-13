import '../club/agent.dart';
import '../club/contract.dart';
import '../club/equipment.dart';
import '../club/finance.dart';
import '../club/transfer_offer.dart';
import '../national/national_career.dart';
import '../player/player.dart';
import '../goals/goal_models.dart';
import '../social/event_models.dart';
import '../social/feed_models.dart';
import '../social/relationships.dart';
import '../spending/spending_models.dart';
import 'match_record.dart';
import 'player_status.dart';
import 'season_record.dart';
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
    this.seasonStats = const CareerStats(),
    this.history = const [],
    this.national = const NationalCareer(),
    this.achievements = const {},
    this.retired = false,
    this.equipment = const Equipment(),
    this.feed = const SocialFeed(),
    this.spending = const Spending(),
    this.goals = const Goals(),
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
    seasonStats: json['seasonStats'] == null
        ? const CareerStats()
        : CareerStats.fromJson(json['seasonStats'] as Map<String, dynamic>),
    history: [
      for (final r in (json['history'] as List<dynamic>? ?? const []))
        SeasonRecord.fromJson(r as Map<String, dynamic>),
    ],
    national: json['national'] == null
        ? const NationalCareer()
        : NationalCareer.fromJson(json['national'] as Map<String, dynamic>),
    achievements: Map<String, int>.from(
      (json['achievements'] as Map<String, dynamic>?) ?? const {},
    ),
    retired: json['retired'] as bool? ?? false,
    equipment: json['equipment'] == null
        ? const Equipment()
        : Equipment.fromJson(json['equipment'] as Map<String, dynamic>),
    feed: json['feed'] == null
        ? const SocialFeed()
        : SocialFeed.fromJson(json['feed'] as Map<String, dynamic>),
    spending: json['spending'] == null
        ? const Spending()
        : Spending.fromJson(json['spending'] as Map<String, dynamic>),
    goals: json['goals'] == null
        ? const Goals()
        : Goals.fromJson(json['goals'] as Map<String, dynamic>),
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

  /// Bu sezonun istatistikleri (sezon sonunda [history]'ye yazılıp sıfırlanır).
  final CareerStats seasonStats;

  /// Biten sezonların özeti, eskiden yeniye.
  final List<SeasonRecord> history;

  /// Milli takım kariyeri ve turnuvalar.
  final NationalCareer national;

  /// Açılan başarımlar: kimlik -> açıldığı mutlak hafta.
  final Map<String, int> achievements;

  /// Kariyer bitti (emeklilik); oyun yalnızca kariyer özetini gösterir.
  final bool retired;

  /// Satın alınan ekipmanlar (krampon, antrenman seti, ...).
  final Equipment equipment;

  /// Sosyal ağ hesabı: takipçiler ve akış.
  final SocialFeed feed;

  /// Mülkler, bahisler, şans alışkanlığı ve cezalar.
  final Spending spending;

  /// Haftalık hedeflerin serisi ve toplamları.
  final Goals goals;

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
    CareerStats? seasonStats,
    List<SeasonRecord>? history,
    NationalCareer? national,
    Map<String, int>? achievements,
    bool? retired,
    Equipment? equipment,
    SocialFeed? feed,
    Spending? spending,
    Goals? goals,
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
    seasonStats: seasonStats ?? this.seasonStats,
    history: history ?? this.history,
    national: national ?? this.national,
    achievements: achievements ?? this.achievements,
    retired: retired ?? this.retired,
    equipment: equipment ?? this.equipment,
    feed: feed ?? this.feed,
    spending: spending ?? this.spending,
    goals: goals ?? this.goals,
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
    'seasonStats': seasonStats.toJson(),
    'history': [for (final r in history) r.toJson()],
    'national': national.toJson(),
    'achievements': achievements,
    'retired': retired,
    'equipment': equipment.toJson(),
    'feed': feed.toJson(),
    'spending': spending.toJson(),
    'goals': goals.toJson(),
  };
}
