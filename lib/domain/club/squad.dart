import '../../core/game_random.dart';
import '../../core/seed_mix.dart';
import '../career/career_state.dart';
import '../career/season_calendar.dart';
import '../league/team.dart';
import '../player/player.dart';
import 'club_balance.dart';
import 'contract.dart';

/// Kadro mantığı: kulüplerin gördüğü güç, rol ve maça çıkma.
abstract final class Squad {
  /// Kulüplerin gördüğü güç: genç oyuncuda potansiyelin bir kısmı eklenir.
  static double effectiveOverall(Player p) {
    final overall = p.overall.toDouble();
    if (p.age <= ClubBalance.potentialMaxAge && p.potential > overall) {
      return overall + (p.potential - overall) * ClubBalance.potentialShare;
    }
    return overall;
  }

  /// Oyuncunun [team]'deki rolü; çok gerideyse (genç değilse) null.
  static SquadRole? roleFor(Player p, Team team) {
    final diff = effectiveOverall(p) - ClubBalance.teamLevel(team.strength);
    if (diff >= ClubBalance.starMargin) return SquadRole.star;
    if (diff >= ClubBalance.starterMargin) return SquadRole.starter;
    if (diff >= ClubBalance.rotationMargin) return SquadRole.rotation;
    if (p.age <= ClubBalance.youthMaxAge &&
        diff >= ClubBalance.youthProspectMargin) {
      return SquadRole.prospect;
    }
    return null;
  }

  /// Rol hesaplanamayacak kadar gerideyse yedek sayılır.
  static SquadRole roleOrProspect(Player p, Team team) =>
      roleFor(p, team) ?? SquadRole.prospect;

  /// Bu hafta ilk 11'de mi? Seed'li ve kararlı: aynı hafta hep aynı sonuç.
  static bool isSelected(CareerState s) {
    final c = s.contract;
    if (c == null) return false;
    final chance = ClubBalance.rolePlayChance[c.role]!;
    final random = GameRandom(mixSeed([s.worldSeed, s.season, s.week, 99]));
    return random.chance(chance);
  }

  /// Bu hafta oyuncunun oynayacağı lig maçı var mı, yoksa neden yok?
  static MatchDay matchDay(CareerState s) {
    if (SeasonCalendar.phaseOf(s.week) != SeasonPhase.regularSeason) {
      return MatchDay.none;
    }
    if (s.contract == null) return MatchDay.none;
    if (s.status.isInjured) return MatchDay.injured;
    return isSelected(s) ? MatchDay.play : MatchDay.benched;
  }
}

enum MatchDay { none, injured, benched, play }
