import '../../core/game_random.dart';
import '../../core/seed_mix.dart';
import '../career/career_state.dart';
import '../career/week_report.dart';
import '../league/club_world.dart';
import '../social/event_models.dart';
import '../social/relationships.dart';
import '../social/social_engine.dart';
import 'nation.dart';
import 'national_balance.dart';
import 'national_career.dart';
import 'tournament.dart';

/// Bu hafta oyuncunun milli takım durumu.
enum NationalDay {
  /// Turnuva yok ya da bu hafta tur yok.
  none,

  /// Turnuva sürüyor ama oyuncu kadroda değil.
  notCalled,

  /// Ülke elendi.
  eliminated,

  /// Kadroda ama sakat.
  injured,

  /// Kadroda ama yedek.
  benched,

  /// İlk 11'de: maçı oynar.
  play,
}

/// Oyuncunun oynadığı turnuva maçının özeti.
class NationalPlay {
  const NationalPlay({
    required this.goals,
    required this.scoreFor,
    required this.scoreAgainst,
    this.pensFor,
    this.pensAgainst,
  });

  final int goals;
  final int scoreFor;
  final int scoreAgainst;
  final int? pensFor;
  final int? pensAgainst;
}

class NationalUpdate {
  const NationalUpdate({
    required this.state,
    required this.events,
    this.bonus = 0,
    this.opponent,
  });

  final CareerState state;
  final List<WeekEvent> events;

  /// Haftanın milli takım primi (₺; bakiyeye zaten eklendi).
  final int bonus;

  /// Bu hafta turnuva maçı varsa rakip ülkenin adı.
  final String? opponent;
}

/// Milli takım: çağrılma, turnuva haftaları, ödüller (saf Dart, seed'li).
abstract final class NationalEngine {
  // --- Takvim ---

  static bool isTournamentSeason(int season) =>
      season % NationalBalance.tournamentEvery == 0;

  /// Dörtte bir sezonda dünya kupası, aradakilerde kıtalar kupası.
  static TournamentKind kindOf(int season) =>
      season % (NationalBalance.tournamentEvery * 2) == 0
      ? TournamentKind.world
      : TournamentKind.continental;

  /// Hafta -> tur numarası (0-3); turnuva haftası değilse null.
  static int? roundOfWeek(int week) {
    final r = week - NationalBalance.firstRoundWeek;
    return r >= 0 && r < NationalBalance.roundCount ? r : null;
  }

  // --- Çağrılma ---

  /// Çağrılma puanı: genel güç + lig kademesi + form.
  static double callUpScore(CareerState s, int? tier) {
    final bonus = NationalBalance.tierBonus[(tier ?? 5) - 1];
    return s.player.overall +
        bonus +
        s.status.formBonus * NationalBalance.formShare;
  }

  /// Kadro rolü; çağrılmazsa null.
  static NationalRole? roleFor(CareerState s, int? tier) {
    if (s.player.age < NationalBalance.minAge) return null;
    final score = callUpScore(s, tier);
    if (score >= NationalBalance.starterScore) return NationalRole.starter;
    if (score >= NationalBalance.rotationScore) return NationalRole.rotation;
    if (score >= NationalBalance.callUpScore) return NationalRole.reserve;
    return null;
  }

  static double playChance(NationalRole role) => switch (role) {
    NationalRole.reserve => NationalBalance.reserveChance,
    NationalRole.rotation => NationalBalance.rotationChance,
    NationalRole.starter => NationalBalance.starterChance,
  };

  /// Bu haftaki durum. Seed'li ve kararlı: aynı hafta hep aynı sonuç.
  static NationalDay dayOf(CareerState s) {
    final run = s.national.current;
    final round = roundOfWeek(s.week);
    if (run == null || round == null || run.season != s.season) {
      return NationalDay.none;
    }
    if (run.lost) return NationalDay.eliminated;
    if (run.finished || run.nextRound != round) return NationalDay.none;
    if (!run.called) return NationalDay.notCalled;
    if (s.status.isInjured) return NationalDay.injured;
    final random = GameRandom(mixSeed([s.worldSeed, s.season, s.week, 88]));
    return random.chance(playChance(run.role))
        ? NationalDay.play
        : NationalDay.benched;
  }

  /// Devam eden turnuvanın eşleşme tablosu (yoksa null).
  static Tournament? tournamentOf(CareerState s) {
    final run = s.national.current;
    if (run == null) return null;
    return Tournament(
      world: NationalWorld(s.worldSeed),
      season: run.season,
      homeResults: run.results,
    );
  }

  /// Bu haftaki turnuva rakibi (maç yoksa null).
  static Nation? opponentOf(CareerState s) {
    final run = s.national.current;
    final round = roundOfWeek(s.week);
    if (run == null || round == null || run.season != s.season) return null;
    if (!run.alive || run.nextRound != round) return null;
    return tournamentOf(s)?.opponentOfHome(round);
  }

  // --- Haftalık akış ---

  /// [prev]: haftanın başı, [next]: kulüp güncellemesinden sonraki durum,
  /// [play]: oyuncu bu hafta turnuva maçı oynadıysa özeti.
  static NationalUpdate afterWeek({
    required CareerState prev,
    required CareerState next,
    NationalPlay? play,
  }) {
    var s = next;
    var nat = s.national;
    final events = <WeekEvent>[];
    var bonus = 0;
    var morale = 0.0;
    final rel = <Relation, double>{};
    String? opponentName;

    final season = prev.season;
    final week = prev.week;
    final round = roundOfWeek(week);
    var run = nat.current;
    final wage = (s.contract?.weeklyWage ?? 0) < NationalBalance.wageFloor
        ? NationalBalance.wageFloor
        : s.contract!.weeklyWage;

    // 1) Bu haftanın turnuva maçı
    if (run != null &&
        round != null &&
        run.season == season &&
        run.alive &&
        run.nextRound == round) {
      final world = NationalWorld(s.worldSeed);
      final bracket = Tournament(
        world: world,
        season: season,
        homeResults: run.results,
      );
      final opponent = bracket.opponentOfHome(round)!;
      final home = bracket.nation(NationalWorld.homeId);
      opponentName = opponent.name;

      final playing = play != null && run.called;
      final NationalMatchRecord rec;
      if (playing) {
        var pf = play.pensFor;
        var pa = play.pensAgainst;
        if (play.scoreFor == play.scoreAgainst && pf == null) {
          (pf, pa) = Shootout.decide(
            home.strength,
            opponent.strength,
            GameRandom(mixSeed([s.worldSeed, season, round, 56])),
          );
        }
        rec = NationalMatchRecord(
          round: round,
          opponentId: opponent.id,
          scoreFor: play.scoreFor,
          scoreAgainst: play.scoreAgainst,
          pensFor: play.scoreFor == play.scoreAgainst ? pf : null,
          pensAgainst: play.scoreFor == play.scoreAgainst ? pa : null,
          played: true,
          playerGoals: play.goals,
        );
        nat = nat.copyWith(caps: nat.caps + 1, goals: nat.goals + play.goals);
        bonus += (wage * NationalBalance.appearanceFee).round();
      } else {
        rec = bracket.simulateHome(
          round,
          GameRandom(mixSeed([s.worldSeed, season, round, 55])),
        );
      }
      run = run.copyWith(results: [...run.results, rec]);
      events.add(
        WeekEvent(
          WeekEventKind.nationalMatch,
          detail: opponent.name,
          detail2: _scoreText(rec),
          weeks: round,
        ),
      );

      // 2) Turnuva bitti mi?
      if (run.finished) {
        final stage = run.stage!;
        nat = nat.copyWith(
          past: [
            ...nat.past,
            TournamentRecord(
              season: season,
              kind: run.kind,
              called: run.called,
              stage: stage,
              appearances: run.appearances,
              goals: run.goals,
            ),
          ],
        );
        if (run.called) {
          bonus += (wage * _prizeWeeks(stage)).round();
          morale += _stageMorale(stage);
          rel.addAll(_stageRelations(stage));
          events.add(
            WeekEvent(
              switch (stage) {
                TournamentStage.champion => WeekEventKind.nationalChampion,
                TournamentStage.runnerUp => WeekEventKind.nationalRunnerUp,
                _ => WeekEventKind.nationalOut,
              },
              detail: run.kind.name,
              detail2: stage.name,
            ),
          );
        }
        s = s.copyWith(
          news: SocialEngine.addNews(
            s.news,
            NewsItem(
              kind: NewsKind.national,
              season: season,
              week: week,
              params: {
                'kind': run.kind.name,
                'stage': stage.name,
                'called': '${run.called}',
              },
            ),
          ),
        );
      }
      nat = nat.copyWith(current: run);
    }

    // 3) Turnuva öncesi: kadro açıklanır (38. haftadan 39'a geçerken)
    if (next.season == prev.season &&
        prev.week == NationalBalance.firstRoundWeek - 1 &&
        isTournamentSeason(next.season)) {
      final tier = s.contract == null
          ? null
          : ClubWorld(s.worldSeed).tierOf(s.contract!.clubId);
      final role = roleFor(s, tier);
      final kind = kindOf(next.season);
      nat = nat.copyWith(
        current: TournamentRun(
          season: next.season,
          kind: kind,
          called: role != null,
          role: role ?? NationalRole.reserve,
        ),
      );
      if (role != null) {
        morale += NationalBalance.callUpMorale;
        rel[Relation.media] =
            (rel[Relation.media] ?? 0) + NationalBalance.callUpMedia;
        rel[Relation.family] =
            (rel[Relation.family] ?? 0) + NationalBalance.callUpFamily;
      }
      events.add(
        WeekEvent(
          role != null
              ? WeekEventKind.nationalCalled
              : WeekEventKind.nationalOmitted,
          detail: kind.name,
          detail2: role?.name,
        ),
      );
    }

    // 4) Sezon geçti: bitmiş turnuva kartı kalkar (kalıcı özet `past`'ta)
    if (next.season > prev.season) {
      nat = nat.copyWith(clearCurrent: true);
    }

    s = s.copyWith(
      national: nat,
      status: morale == 0
          ? null
          : s.status.copyWith(morale: s.status.morale + morale),
      relations: rel.isEmpty ? null : s.relations.add(rel),
      finance: bonus == 0
          ? null
          : s.finance.copyWith(balance: s.finance.balance + bonus),
    );
    return NationalUpdate(
      state: s,
      events: events,
      bonus: bonus,
      opponent: opponentName,
    );
  }

  static String _scoreText(NationalMatchRecord r) {
    final score = '${r.scoreFor}-${r.scoreAgainst}';
    return r.pensFor == null ? score : '$score|${r.pensFor}-${r.pensAgainst}';
  }

  static double _prizeWeeks(TournamentStage s) => switch (s) {
    TournamentStage.champion => NationalBalance.prizeChampion,
    TournamentStage.runnerUp => NationalBalance.prizeRunnerUp,
    TournamentStage.semiFinal => NationalBalance.prizeSemi,
    TournamentStage.quarterFinal => NationalBalance.prizeQuarter,
    TournamentStage.roundOf16 => 0,
  };

  static double _stageMorale(TournamentStage s) => switch (s) {
    TournamentStage.champion => NationalBalance.championMorale,
    TournamentStage.runnerUp => NationalBalance.runnerUpMorale,
    TournamentStage.semiFinal => NationalBalance.semiMorale,
    TournamentStage.quarterFinal => 0,
    TournamentStage.roundOf16 => NationalBalance.earlyExitMorale,
  };

  static Map<Relation, double> _stageRelations(TournamentStage s) =>
      switch (s) {
        TournamentStage.champion => {
          Relation.fans: 10,
          Relation.media: 8,
          Relation.family: 4,
          Relation.teammates: 4,
        },
        TournamentStage.runnerUp => {Relation.fans: 5, Relation.media: 4},
        TournamentStage.semiFinal => {Relation.fans: 3, Relation.media: 2},
        _ => const {},
      };
}
