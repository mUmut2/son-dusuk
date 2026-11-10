import '../career/career_state.dart';
import 'relationships.dart';

enum EventKind { press, personal, career, money }

/// Röportaj cevabının tavrı (yalnızca arayüzde etiket olarak gösterilir).
enum EventTone { humble, funny, cool, harsh, honest, silent }

/// Bir seçimin sonucu. Değerler bir kerelik değişimdir.
class EventEffect {
  const EventEffect({
    this.morale = 0,
    this.condition = 0,
    this.moneyWeeks = 0,
    this.money = 0,
    this.healWeeks = 0,
    this.relapseRisk = 0,
    this.coach = 0,
    this.teammates = 0,
    this.fans = 0,
    this.family = 0,
    this.media = 0,
  });

  final double morale;
  final double condition;

  /// Haftalık maaşın katı olarak para (eksi = harcama).
  final double moneyWeeks;

  /// Sabit para (₺).
  final int money;

  /// Sakatlık süresinden düşülecek hafta (en az 1 hafta kalır).
  final int healWeeks;

  /// Tekrar sakatlanma riskine eklenir.
  final double relapseRisk;
  final double coach;
  final double teammates;
  final double fans;
  final double family;
  final double media;

  Map<Relation, double> get relations => {
    Relation.coach: coach,
    Relation.teammates: teammates,
    Relation.fans: fans,
    Relation.family: family,
    Relation.media: media,
  };

  /// Seçim ipucu için: değişen ilişkiler.
  Iterable<Relation> get relationsAffected => [
    for (final e in relations.entries)
      if (e.value != 0) e.key,
  ];

  bool get touchesMoney => moneyWeeks != 0 || money != 0;
}

/// Bir seçenek. [alt] varsa [altChance] olasılıkla asıl sonuç yerine o olur.
class EventChoice {
  const EventChoice(this.effect, {this.alt, this.altChance = 0, this.tone});

  final EventEffect effect;

  /// Cevabın tavrı (röportaj sorularında).
  final EventTone? tone;
  final EventEffect? alt;
  final double altChance;

  bool get risky => alt != null;
}

/// Olay şablonu: ne zaman çıkar, hangi seçenekleri sunar.
/// Metinler ARB'de `ev_<id>_*` anahtarlarında.
class EventTemplate {
  const EventTemplate({
    required this.id,
    required this.kind,
    required this.choices,
    required this.when,
    this.weight = 1,
    this.cooldownWeeks = 12,
    this.ignore = const EventEffect(),
  });

  final String id;
  final EventKind kind;
  final List<EventChoice> choices;
  final bool Function(EventContext c) when;
  final double weight;
  final int cooldownWeeks;

  /// Cevapsız kalırsa uygulanan sonuç.
  final EventEffect ignore;
}

/// Şablonun tetiklenme koşulları için bağlam.
class EventContext {
  const EventContext({
    required this.state,
    this.rating,
    this.goals = 0,
    this.won = false,
    this.lost = false,
    this.benched = false,
  });

  final CareerState state;

  /// Bu hafta maç oynandıysa reyting ve sonuç.
  final double? rating;
  final int goals;
  final bool won;
  final bool lost;
  final bool benched;

  bool get playedMatch => rating != null;

  /// Bu hafta maç oynandı ve berabere bitti.
  bool get drawn => playedMatch && !won && !lost;
}

/// Oyuncunun cevap bekleyen olayı.
class PendingEvent {
  const PendingEvent({
    required this.id,
    required this.createdAt,
    required this.expiresAt,
    this.params = const {},
  });

  factory PendingEvent.fromJson(Map<String, dynamic> json) => PendingEvent(
    id: json['id'] as String,
    createdAt: json['createdAt'] as int,
    expiresAt: json['expiresAt'] as int,
    params: Map<String, String>.from(
      (json['params'] as Map<String, dynamic>?) ?? const {},
    ),
  );

  final String id;
  final int createdAt;

  /// Son cevap haftası (mutlak hafta).
  final int expiresAt;

  /// Metinlere gömülen değerler: rakip, skor, kulüp...
  final Map<String, String> params;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'expiresAt': expiresAt,
    'params': params,
  };
}

enum NewsKind { match, signed, event, injury, national, achievement, retired }

/// Haber akışındaki bir satır. Metin arayüzde, [kind] ve [params]'tan üretilir.
class NewsItem {
  const NewsItem({
    required this.kind,
    required this.season,
    required this.week,
    this.params = const {},
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
    kind: NewsKind.values.byName(json['kind'] as String),
    season: json['season'] as int,
    week: json['week'] as int,
    params: Map<String, String>.from(
      (json['params'] as Map<String, dynamic>?) ?? const {},
    ),
  );

  final NewsKind kind;
  final int season;
  final int week;
  final Map<String, String> params;

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'season': season,
    'week': week,
    'params': params,
  };
}
