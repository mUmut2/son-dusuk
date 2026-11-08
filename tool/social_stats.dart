// Sosyal sistem dengesi: `dart run tool/social_stats.dart`
// ignore_for_file: avoid_print
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/season_calendar.dart';
import 'package:son_dusuk/domain/career/week_engine.dart';
import 'package:son_dusuk/domain/career/week_report.dart';
import 'package:son_dusuk/domain/career/weekly_plan.dart';
import 'package:son_dusuk/domain/club/squad.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/domain/social/event_catalog.dart';
import 'package:son_dusuk/domain/social/event_models.dart';
import 'package:son_dusuk/domain/social/relationships.dart';
import 'package:son_dusuk/domain/social/social_engine.dart';

void main() {
  const careers = 60;
  const seasons = 3;
  final byId = <String, int>{};
  var events = 0;
  var press = 0;
  var matches = 0;
  var expired = 0;
  final rel = {for (final r in Relation.values) r: 0.0};

  for (var c = 0; c < careers; c++) {
    final random = GameRandom(500 + c);
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
      // Oyuncu her olaya rastgele bir seçenekle cevap verir.
      for (final p in [...s.pendingEvents]) {
        final t = EventCatalog.byId(p.id);
        s = SocialEngine.resolve(
          s,
          p,
          random.nextInt(t.choices.length),
          random,
        ).state;
      }
      final day = Squad.matchDay(s);
      final r = WeekEngine.advance(
        s,
        const WeeklyPlan(),
        day == MatchDay.play
            ? WeekMatch(
                rating: 5 + random.nextDouble() * 4,
                goals: random.chance(0.25) ? 1 + random.nextInt(2) : 0,
                assists: 0,
                result: MatchResultKind
                    .values[random.nextInt(MatchResultKind.values.length)],
                scoreFor: 1,
                scoreAgainst: 1,
              )
            : null,
        random,
      );
      if (day == MatchDay.play) matches++;
      for (final e in r.report.events) {
        if (e.kind == WeekEventKind.newEvent) {
          events++;
          byId[e.eventId!] = (byId[e.eventId!] ?? 0) + 1;
          if (EventCatalog.byId(e.eventId!).kind == EventKind.press) press++;
        }
      }
      s = r.state;
    }
    expired += s.pendingEvents.length;
    for (final k in Relation.values) {
      rel[k] = rel[k]! + s.relations[k];
    }
  }

  final seasonsTotal = careers * seasons;
  print('Sezon başına olay: ${(events / seasonsTotal).toStringAsFixed(1)}');
  print(
    'Basın sorusu / oynanan maç: ${(press / matches * 100).toStringAsFixed(0)}%',
  );
  print('Bitişte bekleyen (toplam): $expired');
  print('Ortalama ilişki (rastgele cevaplarla):');
  for (final k in Relation.values) {
    print('  ${k.name}: ${(rel[k]! / careers).toStringAsFixed(0)}');
  }
  final sorted = byId.entries.toList()..sort((a, b) => b.value - a.value);
  for (final e in sorted) {
    print('  ${e.key}: ${(e.value / seasonsTotal).toStringAsFixed(2)}/sezon');
  }
}
