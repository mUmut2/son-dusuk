// Haftalık hedef dengesi: `dart run tool/goal_stats.dart`
// ignore_for_file: avoid_print
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/season_calendar.dart';
import 'package:son_dusuk/domain/career/week_engine.dart';
import 'package:son_dusuk/domain/career/weekly_plan.dart';
import 'package:son_dusuk/domain/club/squad.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';

/// [hardChance] ağır antrenman, [postChance] paylaşım olasılığı (haftalık).
void profile(String name, double hardChance, double postChance) {
  const careers = 40;
  const seasons = 3;
  final done = List.filled(4, 0);
  var weeks = 0;
  var rewardSum = 0.0;
  var wageSum = 0.0;
  var bestStreakSum = 0;
  var milestones = 0;

  for (var c = 0; c < careers; c++) {
    final random = GameRandom(700 + c);
    final player = PlayerFactory.create(
      name: 'T',
      birthplace: 'Ankara',
      position: PlayerPosition.forward,
      foot: PreferredFoot.right,
      appearance: const Appearance(),
      random: random,
    );
    var s = CareerFactory.create(player, random);
    for (var i = 0; i < seasons * SeasonCalendar.weeksPerSeason; i++) {
      if (random.chance(postChance)) {
        s = s.copyWith(feed: s.feed.copyWith(lastOwnPostWeek: s.absoluteWeek));
      }
      final day = Squad.matchDay(s);
      final plan = WeeklyPlan(
        intensity: random.chance(hardChance)
            ? TrainingIntensity.hard
            : TrainingIntensity.normal,
      );
      final r = WeekEngine.advance(
        s,
        plan,
        day == MatchDay.play
            ? WeekMatch(
                rating: 4.5 + random.nextDouble() * 4.5,
                goals: random.chance(0.3) ? 1 + random.nextInt(2) : 0,
                assists: random.chance(0.2) ? 1 : 0,
                result: MatchResultKind
                    .values[random.nextInt(MatchResultKind.values.length)],
                scoreFor: 1,
                scoreAgainst: 1,
              )
            : null,
        random,
      );
      weeks++;
      done[r.state.goals.lastDone]++;
      rewardSum += r.state.goals.lastReward;
      wageSum += s.contract?.weeklyWage ?? 0;
      for (final e in r.report.events) {
        if (e.kind.name == 'goalStreak') milestones++;
      }
      s = r.state;
      if (s.retired) break;
    }
    bestStreakSum += s.goals.best;
  }
  print('$name:');
  for (var k = 0; k <= 3; k++) {
    print('  $k hedef: ${(done[k] / weeks * 100).toStringAsFixed(0)}% hafta');
  }
  print(
    '  ortalama en iyi seri: ${(bestStreakSum / careers).toStringAsFixed(1)}',
  );
  print('  seri ödülü/kariyer: ${(milestones / careers).toStringAsFixed(1)}');
  print(
    '  haftalık ödül / maaş: ${(rewardSum / wageSum * 100).toStringAsFixed(0)}%',
  );
}

void main() {
  profile('Pasif (ağır antrenman %10, paylaşım %10)', 0.1, 0.1);
  profile('Orta (ağır antrenman %40, paylaşım %40)', 0.4, 0.4);
  profile('Aktif (ağır antrenman %80, paylaşım %80)', 0.8, 0.8);
}
