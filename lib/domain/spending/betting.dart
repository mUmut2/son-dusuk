import 'dart:math' as math;

import '../../core/game_random.dart';
import '../../core/seed_mix.dart';
import '../career/career_state.dart';
import '../career/season_calendar.dart';
import '../league/club_world.dart';
import '../league/team.dart';
import '../match/match_simulator.dart';
import 'spending_balance.dart';
import 'spending_models.dart';

/// Kuponun bir maçı ve oranları.
class BetMatch {
  const BetMatch({
    required this.homeId,
    required this.awayId,
    required this.oddsHome,
    required this.oddsDraw,
    required this.oddsAway,
  });

  final String homeId;
  final String awayId;
  final double oddsHome;
  final double oddsDraw;
  final double oddsAway;

  double odds(BetPick p) => switch (p) {
    BetPick.home => oddsHome,
    BetPick.draw => oddsDraw,
    BetPick.away => oddsAway,
  };
}

/// Kurgusal bahis kuponu, oranlar ve sonuçlandırma (saf Dart, seed'li).
abstract final class Betting {
  /// Bu haftanın kuponu: oyuncunun ligindeki, kendi takımı hariç maçlar.
  /// Lig haftası değilse veya kulüpsüzse boş. Aynı hafta hep aynı kupon.
  static List<BetMatch> coupon(CareerState s, ClubWorld world) {
    final round = SeasonCalendar.leagueRoundOf(s.week);
    final contract = s.contract;
    if (round == null || contract == null) return const [];
    final tier = world.tierOf(contract.clubId);
    final candidates = [
      for (final f in world.fixtures(tier)[round - 1])
        if (f.homeId != contract.clubId && f.awayId != contract.clubId) f,
    ];
    final random = GameRandom(mixSeed([s.worldSeed, s.season, round, 61]));
    for (var i = candidates.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final t = candidates[i];
      candidates[i] = candidates[j];
      candidates[j] = t;
    }
    return [
      for (final f in candidates.take(SpendingBalance.couponSize))
        _match(world.team(f.homeId), world.team(f.awayId)),
    ];
  }

  static BetMatch _match(Team home, Team away) {
    final p = probabilities(home.strength, away.strength);
    return BetMatch(
      homeId: home.id,
      awayId: away.id,
      oddsHome: _odds(p.home),
      oddsDraw: _odds(p.draw),
      oddsAway: _odds(p.away),
    );
  }

  /// Poisson gol beklentisinden ev/beraberlik/deplasman olasılıkları.
  static ({double home, double draw, double away}) probabilities(
    double homeStrength,
    double awayStrength,
  ) {
    final xg = MatchSimulator.expectedGoals(
      homeStrength: homeStrength,
      awayStrength: awayStrength,
    );
    const maxGoals = 9;
    double poisson(double lambda, int k) {
      var f = 1.0;
      for (var i = 2; i <= k; i++) {
        f *= i;
      }
      return math.exp(-lambda) * math.pow(lambda, k) / f;
    }

    var home = 0.0;
    var draw = 0.0;
    var away = 0.0;
    for (var h = 0; h <= maxGoals; h++) {
      for (var a = 0; a <= maxGoals; a++) {
        final p = poisson(xg.home, h) * poisson(xg.away, a);
        if (h > a) {
          home += p;
        } else if (h == a) {
          draw += p;
        } else {
          away += p;
        }
      }
    }
    final total = home + draw + away;
    return (home: home / total, draw: draw / total, away: away / total);
  }

  /// Adil orandan büro payı düşülür, 0.05'e yuvarlanır.
  static double _odds(double p) {
    final raw = (1 / p) * (1 - SpendingBalance.houseMargin);
    final clamped = raw.clamp(SpendingBalance.minOdds, SpendingBalance.maxOdds);
    return (clamped * 20).round() / 20;
  }

  /// Bahis tutarı seçenekleri (bakiyeye göre, yinelenenler tekilleştirilir).
  static List<int> stakeOptions(int balance) {
    final out = <int>[];
    for (final share in SpendingBalance.stakeShares) {
      var v = (balance * share).round();
      if (v < SpendingBalance.minStake) v = SpendingBalance.minStake;
      if (v >= 100) v = (v / 10).round() * 10;
      if (!out.contains(v)) out.add(v);
    }
    return out;
  }

  /// Bahsin konu olduğu maçın (seed'li) sonucu: aynı bahis hep aynı sonuç.
  static MatchResult resultOf(PlacedBet bet, int worldSeed, ClubWorld world) {
    final key = bet.homeId.codeUnits.fold<int>(
      bet.awayId.codeUnits.fold<int>(3, (a, c) => (a * 31 + c) % 1000003),
      (a, c) => (a * 31 + c) % 1000003,
    );
    return MatchSimulator.simulate(
      homeStrength: world.team(bet.homeId).strength,
      awayStrength: world.team(bet.awayId).strength,
      random: GameRandom(mixSeed([worldSeed, bet.season, bet.week, key, 62])),
    );
  }

  static BetPick pickOf(int homeGoals, int awayGoals) => homeGoals > awayGoals
      ? BetPick.home
      : homeGoals == awayGoals
      ? BetPick.draw
      : BetPick.away;

  /// Bahsi sonuçlandırır; kazanırsa geri ödeme = tutar x oran.
  static SettledBet settle(PlacedBet bet, int worldSeed, ClubWorld world) {
    final r = resultOf(bet, worldSeed, world);
    final won = pickOf(r.homeGoals, r.awayGoals) == bet.pick;
    return SettledBet(
      homeId: bet.homeId,
      awayId: bet.awayId,
      pick: bet.pick,
      homeGoals: r.homeGoals,
      awayGoals: r.awayGoals,
      stake: bet.stake,
      payout: won ? (bet.stake * bet.odds).round() : 0,
      season: bet.season,
      week: bet.week,
    );
  }
}
