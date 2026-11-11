// Sosyal ağ akışı dengesi: `dart run tool/feed_stats.dart`
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
import 'package:son_dusuk/domain/social/feed_models.dart';

void main() {
  const careers = 40;
  const seasons = 10;
  final followersBySeason = List.filled(seasons, 0.0);
  final kinds = <FeedKind, int>{};
  final tones = <CommentTone, int>{};
  var posts = 0;
  var comments = 0;

  for (var c = 0; c < careers; c++) {
    final random = GameRandom(900 + c);
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
      final day = Squad.matchDay(s);
      final r = WeekEngine.advance(
        s,
        const WeeklyPlan(),
        day == MatchDay.play
            ? WeekMatch(
                rating: 4.5 + random.nextDouble() * 4.5,
                goals: random.chance(0.3) ? 1 + random.nextInt(2) : 0,
                assists: 0,
                result: MatchResultKind
                    .values[random.nextInt(MatchResultKind.values.length)],
                scoreFor: 1,
                scoreAgainst: 1,
              )
            : null,
        random,
      );
      s = r.state;
      if ((i + 1) % SeasonCalendar.weeksPerSeason == 0) {
        followersBySeason[i ~/ SeasonCalendar.weeksPerSeason] +=
            s.feed.followers;
      }
      if (s.retired) break;
    }
    for (final p in s.feed.posts) {
      posts++;
      kinds[p.kind] = (kinds[p.kind] ?? 0) + 1;
      for (final cm in p.comments) {
        comments++;
        tones[cm.tone] = (tones[cm.tone] ?? 0) + 1;
      }
    }
  }

  print('Sezon sonu ortalama takipçi (emekli olanlar dahil sayılır):');
  for (var i = 0; i < seasons; i++) {
    print('  ${i + 1}. sezon: ${(followersBySeason[i] / careers).round()}');
  }
  print('Son 40 paylaşımdaki tür dağılımı:');
  for (final e in (kinds.entries.toList()..sort((a, b) => b.value - a.value))) {
    print('  ${e.key.name}: ${(e.value / posts * 100).toStringAsFixed(0)}%');
  }
  print('Yorum havası:');
  for (final e in tones.entries) {
    print('  ${e.key.name}: ${(e.value / comments * 100).toStringAsFixed(0)}%');
  }
  print(
    'Paylaşım başına ortalama yorum: ${(comments / posts).toStringAsFixed(1)}',
  );
}
