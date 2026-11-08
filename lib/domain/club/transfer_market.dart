import 'dart:math' as math;

import '../../core/game_random.dart';
import '../career/career_state.dart';
import '../career/season_calendar.dart';
import '../league/club_world.dart';
import '../league/league_factory.dart';
import '../league/team.dart';
import '../player/player.dart';
import 'agent.dart';
import 'club_balance.dart';
import 'contract.dart';
import 'finance.dart';
import '../social/event_models.dart';
import '../social/social_engine.dart';
import 'squad.dart';
import 'transfer_offer.dart';

enum NegotiationKind { accepted, counter, walkedAway }

class Negotiation {
  const Negotiation(this.kind, this.wage);

  final NegotiationKind kind;

  /// Kabulde anlaşılan, karşı teklifte önerilen maaş.
  final int wage;
}

/// Değerleme, teklif üretimi, pazarlık ve imza (saf Dart, seed'li).
abstract final class TransferMarket {
  /// Piyasa değeri (₺): yalnızca bilgi amaçlı; gösterge.
  static int marketValue(Player p) {
    final eff = Squad.effectiveOverall(p);
    final v =
        ClubBalance.valueBase *
        math.exp(
          ClubBalance.valueGrowth * (eff - ClubBalance.valueBaseOverall),
        ) *
        ClubBalance.ageValueFactor(p.age);
    return _round(v);
  }

  /// Bu oyuncu için bu kademede, bu rolde "adil" haftalık maaş.
  static double fairWage({
    required int tier,
    required Player player,
    required SquadRole role,
  }) {
    final eff = Squad.effectiveOverall(player);
    final tierStrength = ClubBalance.teamLevel(
      LeagueFactory.tierStrength[tier - 1],
    );
    return ClubBalance.tierWageBase[tier - 1] *
        math.pow(ClubBalance.wagePerOverall, eff - tierStrength) *
        ClubBalance.ageWageFactor(player.age) *
        ClubBalance.roleWage[role]!;
  }

  /// Haftalık oyuncu teklifi üretir (genelde 0, bazen 1 teklif).
  static List<TransferOffer> newOffers(
    CareerState s,
    ClubWorld world,
    GameRandom random,
  ) {
    final pending = s.offers.where((o) => o.kind == OfferKind.transfer);
    if (pending.length >= ClubBalance.maxPendingOffers) return const [];

    final free = s.isFreeAgent;
    if (!free && !SeasonCalendar.isTransferWindow(s.week)) return const [];

    final formFactor = (0.7 + 0.1 * (s.status.form - 6)).clamp(0.4, 1.5);
    final chance =
        ((free ? ClubBalance.freeAgentOfferChance : ClubBalance.offerChance) *
                (s.agent?.offerBoost ?? 1.0) *
                SocialEngine.offerFactor(s) *
                formFactor)
            .clamp(0.0, 0.95);
    if (!random.chance(chance)) return const [];

    final eff = Squad.effectiveOverall(s.player);
    final taken = {s.contract?.clubId, for (final o in s.offers) o.clubId};
    final candidates = <(Team, SquadRole)>[];
    for (final t in world.allTeams) {
      if (taken.contains(t.id)) continue;
      final level = ClubBalance.teamLevel(t.strength);
      if (level < eff - ClubBalance.candidateBelow ||
          level > eff + ClubBalance.candidateAbove) {
        continue;
      }
      final role = Squad.roleFor(s.player, t);
      if (role != null) candidates.add((t, role));
    }

    Team team;
    SquadRole role;
    if (candidates.isNotEmpty) {
      final pick = random.pick(candidates);
      team = pick.$1;
      role = pick.$2;
    } else if (free) {
      // Serbest oyuncu asla işsiz kalmasın: amatör ligden bir kulüp.
      team = random.pick(
        world.leagues.last.teams.where((t) => !taken.contains(t.id)).toList(),
      );
      role = Squad.roleOrProspect(s.player, team);
    } else {
      return const [];
    }

    final tier = world.tierOf(team.id);
    final fair = fairWage(tier: tier, player: s.player, role: role);
    final wage = _round(
      fair *
          (1 -
              ClubBalance.offerLow +
              random.nextDouble() *
                  (ClubBalance.offerLow + ClubBalance.offerHigh)),
    );
    final maxWage = math.max(
      _round(
        fair *
            (ClubBalance.maxWageBase +
                random.nextDouble() * ClubBalance.maxWageSpread +
                (s.agent?.negotiationBonus ?? 0)),
      ),
      (wage * 1.03).ceil(),
    );
    return [
      TransferOffer(
        kind: OfferKind.transfer,
        clubId: team.id,
        weeklyWage: wage,
        maxWage: maxWage,
        years: random.range(1, ClubBalance.maxYears),
        role: role,
        expiresAt: s.absoluteWeek + ClubBalance.offerLifetimeWeeks,
      ),
    ];
  }

  /// Sözleşmesi son sezonundaki oyuncuya mevcut kulübün yenileme teklifi.
  static TransferOffer? renewalOffer(
    CareerState s,
    ClubWorld world,
    GameRandom random,
  ) {
    final c = s.contract;
    if (c == null || c.endSeason != s.season) return null;
    if (s.week < ClubBalance.renewalWeekFrom) return null;
    if (s.offers.any((o) => o.kind == OfferKind.renewal)) return null;
    if (!random.chance(ClubBalance.renewalChance[c.role]!)) return null;

    final team = world.team(c.clubId);
    final role = Squad.roleOrProspect(s.player, team);
    final fair = fairWage(
      tier: world.tierOf(c.clubId),
      player: s.player,
      role: role,
    );
    final wage = _round(
      fair * (1 - ClubBalance.offerLow + random.nextDouble() * 0.15),
    );
    final maxWage = math.max(
      _round(
        fair *
            (ClubBalance.maxWageBase +
                random.nextDouble() * ClubBalance.maxWageSpread +
                (s.agent?.negotiationBonus ?? 0)),
      ),
      (wage * 1.03).ceil(),
    );
    return TransferOffer(
      kind: OfferKind.renewal,
      clubId: c.clubId,
      weeklyWage: wage,
      maxWage: maxWage,
      years: random.range(1, ClubBalance.renewalMaxYears),
      role: role,
      // Sezon sonuna kadar geçerli.
      expiresAt: (s.season) * SeasonCalendar.weeksPerSeason,
    );
  }

  /// Oyuncu [askedWage] ister. Pazarlık tek turdur.
  static Negotiation negotiate(TransferOffer offer, int askedWage) {
    if (askedWage <= offer.weeklyWage) {
      return Negotiation(NegotiationKind.accepted, offer.weeklyWage);
    }
    if (askedWage <= offer.maxWage) {
      return Negotiation(NegotiationKind.accepted, askedWage);
    }
    if (askedWage <= offer.maxWage * ClubBalance.walkAwayFactor) {
      return Negotiation(NegotiationKind.counter, offer.maxWage);
    }
    return Negotiation(NegotiationKind.walkedAway, 0);
  }

  /// İmza parası (menajer komisyonu düşülmüş net tutar).
  static int signingBonus(int wage, Agent? agent) {
    final gross = wage * ClubBalance.signingBonusWeeks;
    return (gross * (1 - (agent?.commission ?? 0))).round();
  }

  /// Teklifi [wage] maaşıyla imzalar: sözleşme, para, teklif listesi güncellenir.
  static CareerState sign(CareerState s, TransferOffer offer, int wage) {
    final current = s.contract;
    final int endSeason;
    if (offer.kind == OfferKind.renewal && current != null) {
      endSeason = current.endSeason + offer.years;
    } else {
      final start =
          s.week > SeasonCalendar.preseasonWeeks + SeasonCalendar.leagueRounds
          ? s.season + 1
          : s.season;
      endSeason = start + offer.years - 1;
    }
    final contract = Contract(
      clubId: offer.clubId,
      weeklyWage: wage,
      endSeason: endSeason,
      role: offer.role,
    );
    return s.copyWith(
      contract: contract,
      stats: offer.kind == OfferKind.transfer ? s.stats.addTransfer() : null,
      finance: s.finance.copyWith(
        balance: s.finance.balance + signingBonus(wage, s.agent),
      ),
      offers: const [],
      news: SocialEngine.addNews(
        s.news,
        NewsItem(
          kind: NewsKind.signed,
          season: s.season,
          week: s.week,
          params: {'club': offer.clubId},
        ),
      ),
      // Kulüp değiştiyse bu sezonki skorlar eski kulübe aittir; tabloda
      // kulüp kimliğiyle ayrıştırıldığı için silmeye gerek yok.
    );
  }

  static int _round(double v) {
    final step = v < 5000 ? 10 : (v < 50000 ? 100 : 500);
    return math.max(step, (v / step).round() * step);
  }
}

/// Menajer ve yaşam tarzı işlemleri.
abstract final class ClubActions {
  static CareerState hireAgent(CareerState s, int level) {
    if (!AgentPool.canHire(level, s.player.overall)) return s;
    return s.copyWith(agent: AgentPool.candidate(s.worldSeed, level));
  }

  static CareerState fireAgent(CareerState s) => s.copyWith(clearAgent: true);

  static CareerState setLifestyle(CareerState s, Lifestyle l) =>
      s.copyWith(finance: s.finance.copyWith(lifestyle: l));

  static CareerState declineOffer(CareerState s, TransferOffer offer) =>
      s.copyWith(
        offers: [
          for (final o in s.offers)
            if (o != offer) o,
        ],
      );

  static CareerState markNegotiated(CareerState s, TransferOffer offer) =>
      s.copyWith(
        offers: [
          for (final o in s.offers)
            o == offer ? o.copyWith(negotiated: true) : o,
        ],
      );
}
