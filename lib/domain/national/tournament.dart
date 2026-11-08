import '../../core/game_random.dart';
import '../../core/seed_mix.dart';
import '../match/match_simulator.dart';
import 'nation.dart';
import 'national_balance.dart';
import 'national_career.dart';

/// Penaltı atışları (eleme maçı berabere bitince).
abstract final class Shootout {
  /// (a, b) penaltı skoru; kazanan her zaman daha çok golü olandır.
  static (int, int) decide(
    double strengthA,
    double strengthB,
    GameRandom random,
  ) {
    final p = (0.5 + (strengthA - strengthB) * NationalBalance.shootoutSlope)
        .clamp(0.35, 0.65);
    final aWins = random.chance(p);
    final winner = random.range(3, 5);
    final loser = winner - random.range(1, 2);
    return aWins ? (winner, loser) : (loser, winner);
  }
}

/// Eşleşme tablosundaki bir maç. Taraflar belli değilse ([a]/[b] null) ya da
/// henüz oynanmadıysa ([goalsA] null) bekleyen maçtır.
class BracketMatch {
  const BracketMatch({
    required this.round,
    required this.index,
    this.a,
    this.b,
    this.goalsA,
    this.goalsB,
    this.pensA,
    this.pensB,
  });

  final int round;
  final int index;
  final Nation? a;
  final Nation? b;
  final int? goalsA;
  final int? goalsB;
  final int? pensA;
  final int? pensB;

  bool get decided => goalsA != null && goalsB != null;

  bool involves(String nationId) => a?.id == nationId || b?.id == nationId;

  Nation? get winner {
    if (!decided) return null;
    if (goalsA != goalsB) return goalsA! > goalsB! ? a : b;
    return (pensA ?? 0) > (pensB ?? 0) ? a : b;
  }
}

/// 16 ülkeli tek maçlık eleme turnuvası: Son 16, Çeyrek, Yarı, Final.
///
/// Kura ve oyuncunun ülkesi dışındaki maçlar seed'e bağlıdır (her açılışta
/// aynı); oyuncunun ülkesinin maçlarında [homeResults] gerçek sonuçlardır.
class Tournament {
  Tournament({
    required this.world,
    required this.season,
    this.homeResults = const [],
  }) {
    nations = world.nations(season);
    rounds = _build();
  }

  final NationalWorld world;
  final int season;
  final List<NationalMatchRecord> homeResults;

  late final List<Nation> nations;
  late final List<List<BracketMatch>> rounds;

  Nation nation(String id) => nations.firstWhere((n) => n.id == id);

  /// [round] turunda oyuncunun ülkesinin maçı (yoksa null).
  BracketMatch? homeMatch(int round) {
    for (final m in rounds[round]) {
      if (m.involves(NationalWorld.homeId)) return m;
    }
    return null;
  }

  /// [round] turundaki rakip (ülke elendiyse ya da taraflar belli değilse null).
  Nation? opponentOfHome(int round) {
    final m = homeMatch(round);
    if (m == null || m.a == null || m.b == null) return null;
    return m.a!.id == NationalWorld.homeId ? m.b : m.a;
  }

  /// Oyuncu oynamadığında ülkenin [round] maçını simüle eder.
  NationalMatchRecord simulateHome(int round, GameRandom random) {
    final opponent = opponentOfHome(round)!;
    final home = nation(NationalWorld.homeId);
    final goals = MatchSimulator.simulateGoals(
      homeStrength: home.strength,
      awayStrength: opponent.strength,
      random: random,
      neutral: true,
    );
    final own = goals.where((g) => g.side == Side.home).length;
    final other = goals.length - own;
    int? pensFor;
    int? pensAgainst;
    if (own == other) {
      (pensFor, pensAgainst) = Shootout.decide(
        home.strength,
        opponent.strength,
        random,
      );
    }
    return NationalMatchRecord(
      round: round,
      opponentId: opponent.id,
      scoreFor: own,
      scoreAgainst: other,
      pensFor: pensFor,
      pensAgainst: pensAgainst,
    );
  }

  List<List<BracketMatch>> _build() {
    final draw = [...nations];
    final random = GameRandom(mixSeed([world.worldSeed, season, 77]));
    for (var i = draw.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final tmp = draw[i];
      draw[i] = draw[j];
      draw[j] = tmp;
    }

    final built = <List<BracketMatch>>[];
    for (var round = 0; round < NationalBalance.roundCount; round++) {
      final count = nations.length >> (round + 1);
      final matches = <BracketMatch>[];
      for (var i = 0; i < count; i++) {
        final a = round == 0 ? draw[2 * i] : built[round - 1][2 * i].winner;
        final b = round == 0
            ? draw[2 * i + 1]
            : built[round - 1][2 * i + 1].winner;
        matches.add(_play(round, i, a, b));
      }
      built.add(matches);
    }
    return built;
  }

  BracketMatch _play(int round, int index, Nation? a, Nation? b) {
    if (a == null || b == null) {
      return BracketMatch(round: round, index: index, a: a, b: b);
    }
    if (a.id == NationalWorld.homeId || b.id == NationalWorld.homeId) {
      NationalMatchRecord? rec;
      for (final r in homeResults) {
        if (r.round == round) rec = r;
      }
      if (rec == null) {
        return BracketMatch(round: round, index: index, a: a, b: b);
      }
      final homeIsA = a.id == NationalWorld.homeId;
      return BracketMatch(
        round: round,
        index: index,
        a: a,
        b: b,
        goalsA: homeIsA ? rec.scoreFor : rec.scoreAgainst,
        goalsB: homeIsA ? rec.scoreAgainst : rec.scoreFor,
        pensA: homeIsA ? rec.pensFor : rec.pensAgainst,
        pensB: homeIsA ? rec.pensAgainst : rec.pensFor,
      );
    }
    final random = GameRandom(
      mixSeed([world.worldSeed, season, round, index, 5]),
    );
    final goals = MatchSimulator.simulateGoals(
      homeStrength: a.strength,
      awayStrength: b.strength,
      random: random,
      neutral: true,
    );
    final ga = goals.where((g) => g.side == Side.home).length;
    final gb = goals.length - ga;
    int? pa;
    int? pb;
    if (ga == gb) (pa, pb) = Shootout.decide(a.strength, b.strength, random);
    return BracketMatch(
      round: round,
      index: index,
      a: a,
      b: b,
      goalsA: ga,
      goalsB: gb,
      pensA: pa,
      pensB: pb,
    );
  }
}
