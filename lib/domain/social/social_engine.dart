import '../../core/game_random.dart';
import '../career/career_state.dart';
import '../career/week_report.dart';
import '../club/club_balance.dart';
import 'event_catalog.dart';
import 'event_models.dart';
import 'feed_balance.dart';
import 'feed_engine.dart';
import 'feed_models.dart';
import 'relationships.dart';
import 'social_balance.dart';

class SocialUpdate {
  const SocialUpdate(this.state, this.events);

  final CareerState state;
  final List<WeekEvent> events;
}

class ResolveResult {
  const ResolveResult({
    required this.state,
    required this.template,
    required this.choiceIndex,
    required this.effect,
    required this.backfired,
  });

  final CareerState state;
  final EventTemplate template;
  final int choiceIndex;

  /// Gerçekten uygulanan sonuç (ters tepmişse alternatif).
  final EventEffect effect;
  final bool backfired;
}

class OwnPostResult {
  const OwnPostResult(this.state, this.backfired);

  final CareerState state;

  /// Paylaşım ters tepti mi (tepki ve ilişkiler olumsuz).
  final bool backfired;
}

/// Haftalık oynanan maçın sosyal motoru ilgilendiren özeti.
class WeekSocialInput {
  const WeekSocialInput({
    this.rating,
    this.goals = 0,
    this.won = false,
    this.lost = false,
    this.scoreFor = 0,
    this.scoreAgainst = 0,
    this.opponent = '',
    this.benched = false,
  });

  final double? rating;
  final int goals;
  final bool won;
  final bool lost;
  final int scoreFor;
  final int scoreAgainst;
  final String opponent;
  final bool benched;

  bool get played => rating != null;
}

/// İlişkiler, olaylar ve haber akışı (saf Dart, seed'li).
abstract final class SocialEngine {
  // --- Oyuna etkiler ---

  /// Teknik direktör ilişkisinin maça çıkma olasılığına katkısı (±).
  static double coachSelectionBonus(CareerState s) =>
      (s.relations[Relation.coach] - 50) /
      50 *
      SocialBalance.coachSelectionRange;

  /// Medya ilişkisinin teklif sıklığına çarpanı.
  static double offerFactor(CareerState s) =>
      SocialBalance.mediaOfferLow +
      (SocialBalance.mediaOfferHigh - SocialBalance.mediaOfferLow) *
          (s.relations[Relation.media] / 100);

  /// Moralin yöneldiği taban (aile ve takım arkadaşlarıyla kayar).
  static double moraleBaseline(CareerState s, double baseline) =>
      baseline +
      s.spending.moraleBonus +
      (s.relations[Relation.family] - 50) * SocialBalance.familyMoraleShare +
      (s.relations[Relation.teammates] - 50) * SocialBalance.teamMoraleShare;

  // --- Haftalık akış ---

  /// [prev]: haftanın başı, [next]: kulüp güncellemesinden sonraki durum.
  static SocialUpdate afterWeek(
    CareerState prev,
    CareerState next,
    WeekSocialInput input,
    GameRandom random,
  ) {
    var s = next;
    final events = <WeekEvent>[];

    // 1) İlişkiler: maç sonucu, performans, sakatlık, zamanla nötrleşme.
    final deltas = <Relation, double>{};
    void add(Relation r, double d) => deltas[r] = (deltas[r] ?? 0) + d;
    if (input.played) {
      if (input.won) {
        SocialBalance.winDelta.forEach(add);
      } else if (input.lost) {
        SocialBalance.lossDelta.forEach(add);
      }
      add(
        Relation.fans,
        SocialBalance.fanPerGoal *
            input.goals.clamp(0, SocialBalance.fanGoalCap),
      );
      final r = input.rating!;
      if (r >= SocialBalance.notableRatingHigh) {
        add(Relation.coach, SocialBalance.greatRatingCoach);
        add(Relation.media, SocialBalance.greatRatingMedia);
      } else if (r <= SocialBalance.notableRatingLow) {
        add(Relation.coach, SocialBalance.poorRatingCoach);
        add(Relation.media, SocialBalance.poorRatingMedia);
      }
    }
    if (prev.status.isInjured) {
      add(Relation.family, SocialBalance.injuredFamily);
    }
    s = s.copyWith(
      relations: s.relations.drift(SocialBalance.driftRate).add(deltas),
    );

    // 2) Haber akışı
    var news = s.news;
    if (input.played) {
      news = _addNews(
        news,
        NewsItem(
          kind: NewsKind.match,
          season: prev.season,
          week: prev.week,
          params: {
            'opponent': input.opponent,
            'score': '${input.scoreFor}-${input.scoreAgainst}',
            'goals': '${input.goals}',
          },
        ),
      );
    }
    if (!prev.status.isInjured && s.status.isInjured) {
      news = _addNews(
        news,
        NewsItem(
          kind: NewsKind.injury,
          season: prev.season,
          week: prev.week,
          params: {
            'type': s.status.injury!.type.name,
            'weeks': '${s.status.injury!.weeksLeft}',
          },
        ),
      );
    }
    s = s.copyWith(news: news);

    // 2b) Sosyal ağ akışı: paylaşımlar, yorumlar, takipçiler
    s = FeedEngine.afterWeek(
      prev,
      s,
      FeedWeekInput(
        rating: input.rating,
        goals: input.goals,
        won: input.won,
        lost: input.lost,
        scoreFor: input.scoreFor,
        scoreAgainst: input.scoreAgainst,
        opponent: input.opponent,
        benched: input.benched,
      ),
      random,
    );

    // 3) Süresi dolan olaylar (cevapsız): "yok say" sonucu uygulanır.
    final now = s.absoluteWeek;
    final live = <PendingEvent>[];
    for (final p in s.pendingEvents) {
      if (p.expiresAt >= now) {
        live.add(p);
      } else {
        s = applyEffect(s, EventCatalog.byId(p.id).ignore);
      }
    }
    s = s.copyWith(pendingEvents: live);

    // 4) Yeni olay
    final created = _roll(s, input, random);
    if (created != null) {
      s = s.copyWith(
        pendingEvents: [...s.pendingEvents, created],
        eventSeen: {...s.eventSeen, created.id: now},
      );
      events.add(WeekEvent(WeekEventKind.newEvent, eventId: created.id));
    }
    return SocialUpdate(s, events);
  }

  static PendingEvent? _roll(
    CareerState s,
    WeekSocialInput input,
    GameRandom random,
  ) {
    if (s.pendingEvents.length >= SocialBalance.pendingCap) return null;
    final now = s.absoluteWeek;
    final ctx = EventContext(
      state: s,
      rating: input.rating,
      goals: input.goals,
      won: input.won,
      lost: input.lost,
      benched: input.benched,
    );

    List<EventTemplate> candidates(bool press) => [
      for (final t in EventCatalog.all)
        if ((t.kind == EventKind.press) == press &&
            !s.pendingEvents.any((p) => p.id == t.id) &&
            (s.eventSeen[t.id] == null ||
                now - s.eventSeen[t.id]! >= t.cooldownWeeks) &&
            t.when(ctx))
          t,
    ];

    EventTemplate? pick(List<EventTemplate> list) {
      if (list.isEmpty) return null;
      var roll = random.nextDouble() * list.fold(0.0, (a, t) => a + t.weight);
      for (final t in list) {
        roll -= t.weight;
        if (roll <= 0) return t;
      }
      return list.last;
    }

    EventTemplate? chosen;
    if (input.played || input.benched) {
      final notable =
          input.played &&
          (input.rating! >= SocialBalance.notableRatingHigh ||
              input.rating! <= SocialBalance.notableRatingLow ||
              input.goals >= SocialBalance.notableGoals);
      final chance = notable
          ? SocialBalance.pressChanceNotable
          : SocialBalance.pressChance;
      if (random.chance(chance)) chosen = pick(candidates(true));
    }
    if (chosen == null && random.chance(SocialBalance.randomChance)) {
      chosen = pick(candidates(false));
    }
    if (chosen == null) return null;

    final life = chosen.kind == EventKind.press
        ? SocialBalance.pressLifetimeWeeks
        : SocialBalance.eventLifetimeWeeks;
    return PendingEvent(
      id: chosen.id,
      createdAt: now,
      expiresAt: now + life,
      params: {
        'opponent': input.opponent,
        'score': '${input.scoreFor}-${input.scoreAgainst}',
      },
    );
  }

  // --- Çözüm ---

  /// Olaya [choiceIndex]. seçenekle cevap verir.
  static ResolveResult resolve(
    CareerState s,
    PendingEvent p,
    int choiceIndex,
    GameRandom random,
  ) {
    final template = EventCatalog.byId(p.id);
    final choice = template.choices[choiceIndex];
    final backfired = choice.risky && random.chance(choice.altChance);
    final effect = backfired ? choice.alt! : choice.effect;

    var next = applyEffect(s, effect);
    next = next.copyWith(
      pendingEvents: [
        for (final e in next.pendingEvents)
          if (e != p) e,
      ],
      news: _addNews(
        next.news,
        NewsItem(
          kind: NewsKind.event,
          season: s.season,
          week: s.week,
          params: {'id': p.id, 'choice': '$choiceIndex'},
        ),
      ),
    );
    if (template.kind == EventKind.press) {
      next = FeedEngine.interviewPost(
        next,
        p.id,
        choiceIndex,
        backfired,
        random,
      );
    }
    return ResolveResult(
      state: next,
      template: template,
      choiceIndex: choiceIndex,
      effect: effect,
      backfired: backfired,
    );
  }

  /// Oyuncu kendi hesabından [kind] türünde paylaşım yapar (haftada bir).
  /// Yapamıyorsa null döner.
  static OwnPostResult? postToFeed(
    CareerState s,
    FeedKind kind,
    GameRandom random,
  ) {
    final rule = FeedBalance.ownRules[kind];
    if (rule == null || !FeedEngine.canPostOwn(s)) return null;
    final backfired = rule.alt != null && random.chance(rule.altChance);
    final applied = applyEffect(s, backfired ? rule.alt! : rule.effect);
    return OwnPostResult(
      FeedEngine.ownPost(applied, kind, backfired, random),
      backfired,
    );
  }

  /// Bir sonucu duruma uygular (moral, kondisyon, sakatlık, para, ilişkiler).
  static CareerState applyEffect(CareerState s, EventEffect e) {
    var status = s.status.copyWith(
      morale: s.status.morale + e.morale,
      condition: s.status.condition + e.condition,
      relapseRisk: s.status.relapseRisk + e.relapseRisk,
    );
    if (e.healWeeks != 0 && status.isInjured) {
      final left = status.injury!.weeksLeft - e.healWeeks;
      status = status.copyWith(
        injury: status.injury!.copyWith(weeksLeft: left < 1 ? 1 : left),
      );
    }
    final wage = s.contract?.weeklyWage ?? 0;
    final money =
        e.money +
        (e.moneyWeeks *
                (wage < SocialBalance.minWageForMoney
                    ? SocialBalance.minWageForMoney
                    : wage))
            .round();
    return s.copyWith(
      status: status,
      finance: s.finance.copyWith(balance: s.finance.balance + money),
      relations: s.relations.add(e.relations),
    );
  }

  /// Seçenek ipucu için gerçek para tutarı (arayüz göstermek isterse).
  static int moneyOf(CareerState s, EventEffect e) {
    final wage = s.contract?.weeklyWage ?? ClubBalance.startingBalance;
    return e.money +
        (e.moneyWeeks *
                (wage < SocialBalance.minWageForMoney
                    ? SocialBalance.minWageForMoney
                    : wage))
            .round();
  }

  /// Dışarıdan (ör. imza) haber eklemek için.
  static List<NewsItem> addNews(List<NewsItem> news, NewsItem item) =>
      _addNews(news, item);

  static List<NewsItem> _addNews(List<NewsItem> news, NewsItem item) =>
      [item, ...news].take(SocialBalance.newsCap).toList();
}
