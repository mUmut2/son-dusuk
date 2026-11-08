// ignore_for_file: avoid_print
// Kulüp/ekonomi dengesi: `dart run tool/club_stats.dart`
//
// Basit bir politikayla (her pencerede en iyi teklifi al, normal antrenman)
// çok sayıda kariyer oynatır ve kademe, para, teklif sıklığını yazdırır.
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/season_calendar.dart';
import 'package:son_dusuk/domain/career/week_engine.dart';
import 'package:son_dusuk/domain/career/week_report.dart';
import 'package:son_dusuk/domain/career/weekly_plan.dart';
import 'package:son_dusuk/domain/club/squad.dart';
import 'package:son_dusuk/domain/club/transfer_market.dart';
import 'package:son_dusuk/domain/league/club_world.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';

void main() {
  const careers = 60;
  const seasons = 14; // 16 yaş -> 30 yaş
  final tierAtAge = <int, List<int>>{};
  final balanceAtAge = <int, List<int>>{};
  final overallAtAge = <int, List<int>>{};
  var offersPerSeason = 0;
  var transfers = 0;
  var freeAgentSeasons = 0;
  var benchedWeeks = 0;
  var leagueWeeks = 0;

  for (var c = 0; c < careers; c++) {
    final random = GameRandom(1000 + c);
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

    for (var season = 1; season <= seasons; season++) {
      for (var w = 1; w <= SeasonCalendar.weeksPerSeason; w++) {
        // En iyi teklifi (en yüksek kademe, sonra maaş) al; menajer yok.
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
            if (pick.kind.name == 'transfer') transfers++;
          }
        }

        final day = Squad.matchDay(s);
        if (SeasonCalendar.phaseOf(s.week) == SeasonPhase.regularSeason &&
            s.contract != null) {
          leagueWeeks++;
          if (day == MatchDay.benched) benchedWeeks++;
        }
        final r = WeekEngine.advance(
          s,
          const WeeklyPlan(focus: TrainingFocus.technical),
          day == MatchDay.play
              ? const WeekMatch(
                  rating: 6.5,
                  goals: 0,
                  assists: 0,
                  result: MatchResultKind.draw,
                  scoreFor: 1,
                  scoreAgainst: 1,
                )
              : null,
          random,
        );
        offersPerSeason += r.report.events
            .where((e) => e.kind == WeekEventKind.offerReceived)
            .length;
        s = r.state;
      }
      if (s.contract == null) freeAgentSeasons++;
      final tier = s.contract == null ? 6 : world.tierOf(s.contract!.clubId);
      (tierAtAge[s.player.age] ??= []).add(tier);
      (balanceAtAge[s.player.age] ??= []).add(s.finance.balance);
      (overallAtAge[s.player.age] ??= []).add(s.player.overall);
    }
  }

  String avg(List<num> v) =>
      (v.fold<double>(0, (a, b) => a + b) / v.length).toStringAsFixed(1);

  print('Kariyer: $careers, sezon: $seasons');
  print('Sezon başına teklif: ${(offersPerSeason / (careers * seasons)).toStringAsFixed(2)}');
  print('Kariyer başına transfer: ${(transfers / careers).toStringAsFixed(2)}');
  print('Serbest biten sezon oranı: ${(freeAgentSeasons / (careers * seasons) * 100).toStringAsFixed(1)}%');
  print('Yedek kalma oranı: ${(benchedWeeks / leagueWeeks * 100).toStringAsFixed(1)}%');
  final at27 = tierAtAge[27] ?? [];
  for (var t = 1; t <= 6; t++) {
    final pct = at27.where((x) => x == t).length / at27.length * 100;
    print('27 yaşında kademe $t: ${pct.toStringAsFixed(0)}%');
  }
  print('Yaş | ort. kademe | ort. bakiye | ort. güç');
  for (final age in tierAtAge.keys.toList()..sort()) {
    print('$age | ${avg(tierAtAge[age]!)} | ${avg(balanceAtAge[age]!)} | ${avg(overallAtAge[age]!)}');
  }
}
