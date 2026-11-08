// ignore_for_file: avoid_print
// Milli takım / başarım / miras dengesi: `dart run tool/national_stats.dart`
//
// Basit bir politikayla (en iyi teklifi al, teknik antrenman, maçları hızlı
// simülasyonla oyna) kariyerleri emekliliğe kadar oynatır; çağrılma, turnuva
// sonuçları, başarımlar ve miras dağılımını yazdırır.
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/achievements/achievements.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/retirement.dart';
import 'package:son_dusuk/domain/career/season_calendar.dart';
import 'package:son_dusuk/domain/career/week_engine.dart';
import 'package:son_dusuk/domain/career/weekly_plan.dart';
import 'package:son_dusuk/domain/club/squad.dart';
import 'package:son_dusuk/domain/club/transfer_market.dart';
import 'package:son_dusuk/domain/league/club_world.dart';
import 'package:son_dusuk/domain/match/match_session.dart';
import 'package:son_dusuk/domain/match/match_simulator.dart';
import 'package:son_dusuk/domain/match/player_rating.dart';
import 'package:son_dusuk/domain/national/national_career.dart';
import 'package:son_dusuk/domain/national/national_engine.dart';
import 'package:son_dusuk/domain/national/tournament.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';

WeekMatch playQuick({
  required CareerState s,
  required double ownStrength,
  required double otherStrength,
  required bool neutral,
  required GameRandom random,
  bool playerHome = true,
  bool knockout = false,
}) {
  final session = MatchSession.start(
    homeStrength: playerHome ? ownStrength : otherStrength,
    awayStrength: playerHome ? otherStrength : ownStrength,
    playerSide: playerHome ? Side.home : Side.away,
    player: s.player,
    random: random,
    neutral: neutral,
  )..autoPlay(s.player, random, performance: s.status.performanceMultiplier);
  final result = session.result;
  final goals = result.goals;
  int? pf;
  int? pa;
  if (knockout && result.homeGoals == result.awayGoals) {
    (pf, pa) = Shootout.decide(ownStrength, otherStrength, random);
  }
  final own = playerHome ? result.homeGoals : result.awayGoals;
  final other = result.totalGoals - own;
  return WeekMatch(
    rating: PlayerRating.compute(session),
    goals: goals.where((g) => g.byPlayer).length,
    assists: goals.where((g) => g.assistedByPlayer).length,
    scoreFor: own,
    scoreAgainst: other,
    pensFor: pf,
    pensAgainst: pa,
    result: own > other || (own == other && (pf ?? 0) > (pa ?? 0))
        ? MatchResultKind.win
        : own < other
        ? MatchResultKind.loss
        : own == other && pf == null
        ? MatchResultKind.draw
        : MatchResultKind.loss,
  );
}

void main() {
  const careers = 60;
  var calledCareers = 0;
  var tournamentsTotal = 0;
  var calledTournaments = 0;
  final stages = <TournamentStage, int>{};
  final calledByAge = <int, List<bool>>{};
  var capsTotal = 0;
  var natGoalsTotal = 0;
  var titles = 0;
  final ranks = <LegacyRank, int>{};
  final unlockCount = <Achievement, int>{};
  var scoreSum = 0.0;
  var seasonsSum = 0;
  var retireAgeSum = 0;
  var leagueTitles = 0;
  var topTitles = 0;
  final finalScores = <double>[];
  final scoreAt30 = <double>[];
  final scoreAt34 = <double>[];
  var goalsSum = 0;
  var matchesSum = 0;
  final balances = <int>[];

  for (var c = 0; c < careers; c++) {
    final random = GameRandom(2000 + c);
    final player = PlayerFactory.create(
      name: 'T',
      birthplace: 'Ankara',
      position: PlayerPosition.forward,
      foot: PreferredFoot.right,
      appearance: const Appearance(),
      random: random,
    );
    var s = CareerFactory.create(player, random);
    final world = ClubWorld(s.worldSeed);

    var guard = 0;
    while (!s.retired && guard++ < 40 * SeasonCalendar.weeksPerSeason) {
      if (s.offers.isNotEmpty) {
        final best = [...s.offers]
          ..sort((a, b) {
            final byTier = world
                .tierOf(a.clubId)
                .compareTo(world.tierOf(b.clubId));
            return byTier != 0 ? byTier : b.weeklyWage.compareTo(a.weeklyWage);
          });
        final pick = best.first;
        final curTier = s.contract == null
            ? 6
            : world.tierOf(s.contract!.clubId);
        if (world.tierOf(pick.clubId) <= curTier ||
            s.contract == null ||
            pick.kind.name == 'renewal') {
          s = TransferMarket.sign(s, pick, pick.weeklyWage);
        }
      }

      WeekMatch? match;
      final nat = NationalEngine.dayOf(s);
      if (nat == NationalDay.play) {
        final bracket = NationalEngine.tournamentOf(s)!;
        final round = NationalEngine.roundOfWeek(s.week)!;
        final home = bracket.nation('n_home');
        final opp = bracket.opponentOfHome(round)!;
        match = playQuick(
          s: s,
          ownStrength: home.strength,
          otherStrength: opp.strength,
          neutral: true,
          random: random,
          knockout: true,
        );
      } else if (Squad.matchDay(s) == MatchDay.play) {
        final round = SeasonCalendar.leagueRoundOf(s.week)!;
        final fx = world.fixtureFor(s.contract!.clubId, round);
        final own = world.team(s.contract!.clubId).strength;
        match = playQuick(
          s: s,
          ownStrength: own,
          otherStrength: fx.opponent.strength,
          neutral: false,
          playerHome: fx.home,
          random: random,
        );
      }

      final before = s;
      if (s.week == 1 && s.player.age == 30) {
        scoreAt30.add(CareerSummary.of(s).score);
      }
      if (s.week == 1 && s.player.age == 34) {
        scoreAt34.add(CareerSummary.of(s).score);
      }
      s = WeekEngine.advance(
        s,
        const WeeklyPlan(focus: TrainingFocus.technical),
        match,
        random,
      ).state;

      // Turnuva bittiğinde sonuçları topla.
      if (s.national.past.length > before.national.past.length) {
        final r = s.national.past.last;
        tournamentsTotal++;
        stages[r.stage] = (stages[r.stage] ?? 0) + 1;
        if (r.called) calledTournaments++;
        (calledByAge[before.player.age] ??= []).add(r.called);
      }
    }

    final summary = CareerSummary.of(s);
    if (s.national.tournamentsPlayed > 0) calledCareers++;
    capsTotal += s.national.caps;
    natGoalsTotal += s.national.goals;
    titles += s.national.titles;
    ranks[summary.rank] = (ranks[summary.rank] ?? 0) + 1;
    scoreSum += summary.score;
    finalScores.add(summary.score);
    goalsSum += s.stats.goals;
    matchesSum += s.stats.matches;
    balances.add(s.finance.balance);
    seasonsSum += s.history.length;
    retireAgeSum += s.player.age;
    leagueTitles += summary.leagueTitles;
    topTitles += summary.topLeagueTitles;
    for (final key in s.achievements.keys) {
      final a = Achievement.values.byName(key);
      unlockCount[a] = (unlockCount[a] ?? 0) + 1;
    }
  }

  String pct(num a, num b) =>
      b == 0 ? '-' : '${(a / b * 100).toStringAsFixed(0)}%';

  print('Kariyer: $careers (emekliliğe kadar)');
  print('Ort. emeklilik yaşı: ${(retireAgeSum / careers).toStringAsFixed(1)}');
  print('Ort. kayıtlı sezon: ${(seasonsSum / careers).toStringAsFixed(1)}');
  print(
    'Milli takıma en az bir kez çağrılan kariyer: ${pct(calledCareers, careers)}',
  );
  print(
    'Turnuva başına çağrılma: ${pct(calledTournaments, tournamentsTotal)} '
    '($calledTournaments / $tournamentsTotal)',
  );
  print(
    'Kariyer başına milli maç: ${(capsTotal / careers).toStringAsFixed(1)}',
  );
  print(
    'Kariyer başına milli gol: ${(natGoalsTotal / careers).toStringAsFixed(1)}',
  );
  print(
    'Turnuva kupası (kadroda): ${(titles / careers).toStringAsFixed(2)} / kariyer, '
    'çağrılan turnuvaların ${pct(titles, calledTournaments)}',
  );
  print('Ülke sonuçları (tüm turnuvalar):');
  for (final st in TournamentStage.values) {
    print('  ${st.name}: ${pct(stages[st] ?? 0, tournamentsTotal)}');
  }
  print('Çağrılma yaşa göre:');
  for (final age in calledByAge.keys.toList()..sort()) {
    final v = calledByAge[age]!;
    print('  $age: ${pct(v.where((x) => x).length, v.length)} (${v.length})');
  }
  print(
    'Lig şampiyonluğu / kariyer: ${(leagueTitles / careers).toStringAsFixed(2)} '
    '(üst lig ${(topTitles / careers).toStringAsFixed(2)})',
  );
  String quant(List<num> v) {
    final x = [...v]..sort();
    num q(double f) => x[((x.length - 1) * f).round()];
    return 'min ${q(0).round()} · p25 ${q(0.25).round()} · p50 ${q(0.5).round()} '
        '· p75 ${q(0.75).round()} · p90 ${q(0.9).round()} · max ${q(1).round()}';
  }

  print(
    'Kariyer başına gol: ${(goalsSum / careers).toStringAsFixed(0)}, '
    'maç: ${(matchesSum / careers).toStringAsFixed(0)}',
  );
  print('Son bakiye: ${quant(balances)}');
  print('Miras puanı ort.: ${(scoreSum / careers).toStringAsFixed(0)}');
  print('Miras (emeklilik): ${quant(finalScores)}');
  print('Miras (30 yaş): ${quant(scoreAt30)}');
  print('Miras (34 yaş): ${quant(scoreAt34)}');
  for (final r in LegacyRank.values) {
    print('  ${r.name}: ${pct(ranks[r] ?? 0, careers)}');
  }
  print('Başarım açılma oranı:');
  for (final a in Achievement.values) {
    print('  ${a.name}: ${pct(unlockCount[a] ?? 0, careers)}');
  }
}
