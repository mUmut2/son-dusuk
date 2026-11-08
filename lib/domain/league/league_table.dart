import '../../core/game_random.dart';
import '../../core/seed_mix.dart';
import '../career/match_record.dart';
import '../match/match_simulator.dart';
import 'club_world.dart';
import 'standings.dart';

/// Sezon içi puan durumu. Oyuncunun kulübü dışındaki maçlar seed'li olarak
/// (her açılışta aynı sonuçla) simüle edilir; oyuncunun oynadığı maçlarda
/// gerçek skor kullanılır.
abstract final class LeagueTable {
  /// [throughRound]: bu tur dahil (0 = henüz maç yok).
  static Standings compute({
    required ClubWorld world,
    required int tier,
    required int season,
    required int throughRound,
    required List<MatchRecord> playerResults,
  }) {
    final league = world.leagues[tier - 1];
    final standings = Standings([for (final t in league.teams) t.id]);
    final rounds = world.fixtures(tier);
    final last = throughRound.clamp(0, rounds.length);

    for (var r = 0; r < last; r++) {
      final fixtures = rounds[r];
      for (var i = 0; i < fixtures.length; i++) {
        final f = fixtures[i];
        MatchRecord? played;
        for (final rec in playerResults) {
          if (rec.round == r + 1 &&
              (rec.clubId == f.homeId || rec.clubId == f.awayId)) {
            played = rec;
          }
        }
        if (played != null) {
          final home = played.clubId == f.homeId;
          standings.record(
            f.homeId,
            f.awayId,
            home ? played.scoreFor : played.scoreAgainst,
            home ? played.scoreAgainst : played.scoreFor,
          );
          continue;
        }
        final result = MatchSimulator.simulate(
          homeStrength: world.team(f.homeId).strength,
          awayStrength: world.team(f.awayId).strength,
          random: GameRandom(mixSeed([world.seed, season, tier, r, i])),
        );
        standings.record(f.homeId, f.awayId, result.homeGoals, result.awayGoals);
      }
    }
    return standings;
  }
}
