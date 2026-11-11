import '../../core/game_random.dart';
import '../career/career_state.dart';
import '../career/week_report.dart';
import '../league/club_world.dart';
import '../social/event_models.dart';
import '../social/feed_engine.dart';
import '../social/feed_models.dart';
import '../social/social_engine.dart';
import 'betting.dart';
import 'spending_balance.dart';
import 'spending_models.dart';

class SpendingUpdate {
  const SpendingUpdate(this.state, this.events);

  final CareerState state;
  final List<WeekEvent> events;
}

/// Mülk, bağış, bahis, alışkanlık ve ceza kuralları (saf Dart, seed'li).
abstract final class SpendingEngine {
  static int _wage(CareerState s) => s.contract?.weeklyWage ?? 0;

  static CareerState _pay(CareerState s, int amount) => s.copyWith(
    finance: s.finance.copyWith(balance: s.finance.balance - amount),
  );

  // --- Mülkler ---

  static bool canBuy(CareerState s, Property p) =>
      !s.spending.owns(p) &&
      s.finance.balance >= SpendingBalance.propertyPrice[p]!;

  /// Mülkü satın alır; alamıyorsa (var ya da para yok) null.
  static CareerState? buyProperty(
    CareerState s,
    Property p,
    GameRandom random,
  ) {
    if (!canBuy(s, p)) return null;
    var next = _pay(s, SpendingBalance.propertyPrice[p]!);
    next = SocialEngine.applyEffect(next, SpendingBalance.propertyEffect[p]!);
    next = next.copyWith(
      spending: next.spending.copyWith(
        properties: [...next.spending.properties, p],
      ),
    );
    return FeedEngine.react(
      next,
      FeedKind.shopping,
      {'item': p.name},
      random,
      growth: 0.02,
    );
  }

  // --- Bağış / hediye ---

  static int donationCost(CareerState s, Donation d) {
    final byWage = (_wage(s) * SpendingBalance.donationWeeks[d]!).round();
    final min = SpendingBalance.donationMin[d]!;
    return byWage < min ? min : byWage;
  }

  static bool donationReady(CareerState s) =>
      s.spending.lastDonationWeek == 0 ||
      s.absoluteWeek - s.spending.lastDonationWeek >=
          SpendingBalance.donationGapWeeks;

  static bool canDonate(CareerState s, Donation d) =>
      donationReady(s) && s.finance.balance >= donationCost(s, d);

  static CareerState? donate(CareerState s, Donation d, GameRandom random) {
    if (!canDonate(s, d)) return null;
    var next = _pay(s, donationCost(s, d));
    next = SocialEngine.applyEffect(next, SpendingBalance.donationEffect[d]!);
    next = next.copyWith(
      spending: next.spending.copyWith(lastDonationWeek: s.absoluteWeek),
    );
    return d == Donation.charity
        ? FeedEngine.react(
            next,
            FeedKind.donation,
            const {},
            random,
            growth: 0.015,
          )
        : next;
  }

  // --- Bahis ---

  /// Kuponun [matchIndex]. maçına [pick] için [stake] kadar bahis yapar.
  /// Geçersizse (maç yok, aynı maça bahis var, yetersiz bakiye) null.
  static CareerState? placeBet(
    CareerState s,
    ClubWorld world,
    int matchIndex,
    BetPick pick,
    int stake,
  ) {
    final coupon = Betting.coupon(s, world);
    if (matchIndex < 0 || matchIndex >= coupon.length) return null;
    if (stake < SpendingBalance.minStake || stake > s.finance.balance) {
      return null;
    }
    final m = coupon[matchIndex];
    final sp = s.spending;
    if (sp.bets.any((b) => b.homeId == m.homeId && b.awayId == m.awayId)) {
      return null;
    }
    final share = (stake / s.finance.balance).clamp(0.0, 1.0);
    var habit =
        sp.habit +
        SpendingBalance.habitPerBet +
        share * SpendingBalance.habitPerStakeShare;
    if (sp.settled.isNotEmpty && !sp.settled.first.won) {
      habit += SpendingBalance.habitChase;
    }
    final next = _pay(s, stake);
    return next.copyWith(
      spending: sp.copyWith(
        bets: [
          ...sp.bets,
          PlacedBet(
            homeId: m.homeId,
            awayId: m.awayId,
            pick: pick,
            stake: stake,
            odds: m.odds(pick),
            season: s.season,
            week: s.week,
          ),
        ],
        habit: habit.clamp(0.0, SpendingBalance.habitMax),
        totalStaked: sp.totalStaked + stake,
      ),
    );
  }

  // --- Haftalık akış ---

  /// Hafta ilerleyince: bahisleri sonuçlandırır, alışkanlığı ve cezaları işler.
  /// [prev] haftanın başı, [next] diğer sistemlerden sonraki durum.
  static SpendingUpdate afterWeek(
    CareerState prev,
    CareerState next,
    GameRandom random,
  ) {
    var s = next;
    final events = <WeekEvent>[];
    var sp = s.spending;

    // 1) Bahisleri sonuçlandır.
    if (sp.bets.isNotEmpty) {
      final world = ClubWorld(s.worldSeed);
      final results = [
        for (final b in sp.bets) Betting.settle(b, s.worldSeed, world),
      ];
      final payout = results.fold(0, (a, r) => a + r.payout);
      final staked = results.fold(0, (a, r) => a + r.stake);
      sp = sp.copyWith(
        bets: const [],
        settled: [
          ...results.reversed,
          ...sp.settled,
        ].take(SpendingBalance.settledCap).toList(),
        totalWon: sp.totalWon + payout,
      );
      s = s.copyWith(
        finance: s.finance.copyWith(balance: s.finance.balance + payout),
      );
      events.add(
        WeekEvent(WeekEventKind.betSettled, detail: '${payout - staked}'),
      );
    }
    sp = sp.copyWith(
      habit: (sp.habit - SpendingBalance.habitDecay).clamp(
        0.0,
        SpendingBalance.habitMax,
      ),
    );

    // 2) Kadro dışı süresi.
    if (sp.suspendedWeeks > 0) {
      sp = sp.copyWith(suspendedWeeks: sp.suspendedWeeks - 1);
    }

    // 3) Ceza basamakları (en yüksek geçerli olan).
    var stage = sp.penaltyStage;
    if (sp.habit < SpendingBalance.relaxBelow) stage = 0;
    s = s.copyWith(spending: sp.copyWith(penaltyStage: stage));
    sp = s.spending;
    final wage = _wage(prev);

    int fineOf(double multiplier) {
      final f = (wage * SpendingBalance.fineWeeks * multiplier).round();
      return f < SpendingBalance.minFine ? SpendingBalance.minFine : f;
    }

    void news(String kind) {
      s = s.copyWith(
        news: SocialEngine.addNews(
          s.news,
          NewsItem(
            kind: NewsKind.betting,
            season: prev.season,
            week: prev.week,
            params: {'stage': kind},
          ),
        ),
      );
    }

    if (sp.habit >= SpendingBalance.banAt && stage < 3) {
      final fine = fineOf(SpendingBalance.banFineMultiplier);
      s = SocialEngine.applyEffect(_pay(s, fine), SpendingBalance.banEffect);
      s = s.copyWith(
        spending: sp.copyWith(
          penaltyStage: 1,
          habit: SpendingBalance.habitAfterHelp,
          suspendedWeeks: SpendingBalance.banWeeks,
          totalFines: sp.totalFines + fine,
        ),
      );
      news('suspended');
      s = FeedEngine.react(
        s,
        FeedKind.betFined,
        const {},
        random,
        growth: -0.03,
      );
      events.add(
        WeekEvent(WeekEventKind.betSuspended, weeks: SpendingBalance.banWeeks),
      );
    } else if (sp.habit >= SpendingBalance.fineAt && stage < 2) {
      final fine = fineOf(1);
      s = SocialEngine.applyEffect(_pay(s, fine), SpendingBalance.fineEffect);
      s = s.copyWith(
        spending: sp.copyWith(
          penaltyStage: 2,
          totalFines: sp.totalFines + fine,
        ),
      );
      news('fined');
      s = FeedEngine.react(
        s,
        FeedKind.betFined,
        const {},
        random,
        growth: -0.015,
      );
      events.add(WeekEvent(WeekEventKind.betFined, detail: '$fine'));
    } else if (sp.habit >= SpendingBalance.warnAt && stage < 1) {
      s = SocialEngine.applyEffect(s, SpendingBalance.warnEffect);
      s = s.copyWith(spending: sp.copyWith(penaltyStage: 1));
      news('warned');
      events.add(const WeekEvent(WeekEventKind.betWarning));
    }
    return SpendingUpdate(s, events);
  }
}
