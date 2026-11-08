import '../../core/game_random.dart';
import '../player/player.dart';
import 'critical_moment.dart';
import 'match_balance.dart';
import 'match_simulator.dart';
import 'moment_resolver.dart';

/// Oyuncunun katıldığı bir maç.
///
/// Akış: [MatchSession.start] arka plan golleri ve kritik anları üretir →
/// her an için [resolve] çağrılır (mini oyun ya da [autoPlay]) →
/// [result] nihai skoru verir. Oyuncunun anlarının referans (nitelik 50)
/// beklenen golü takım beklentisinden düşüldüğü için, otomatik oynayan
/// ortalama bir oyuncu maç sonuçlarını bozmaz; iyi oynayan fark yaratır.
class MatchSession {
  MatchSession._({
    required this.playerSide,
    required this.moments,
    required List<MatchGoal> backgroundGoals,
  }) : _goals = [...backgroundGoals];

  factory MatchSession.start({
    required double homeStrength,
    required double awayStrength,
    required Side playerSide,
    required Player player,
    required GameRandom random,
  }) {
    final moments = CriticalMomentGenerator.generate(player.position, random);

    var refFor = 0.0;
    var refAgainst = 0.0;
    for (final m in moments) {
      refFor += MatchBalance.goalChance[m.type]!;
      if (m.type == MomentType.tackle) {
        refAgainst +=
            (1 - MatchBalance.tackleSuccess) *
            MatchBalance.concedeOnFailedTackle;
      }
    }

    final playerIsHome = playerSide == Side.home;
    final goals = MatchSimulator.simulateGoals(
      homeStrength: homeStrength,
      awayStrength: awayStrength,
      random: random,
      homeReduction: playerIsHome ? refFor : refAgainst,
      awayReduction: playerIsHome ? refAgainst : refFor,
    );

    return MatchSession._(
      playerSide: playerSide,
      moments: moments,
      backgroundGoals: goals,
    );
  }

  final Side playerSide;
  final List<CriticalMoment> moments;
  final List<MatchGoal> _goals;
  final Map<CriticalMoment, MomentOutcome> _outcomes = {};

  Side get _opponentSide => playerSide == Side.home ? Side.away : Side.home;

  bool get isFinished => _outcomes.length == moments.length;

  /// Henüz çözülmemiş ilk an (yoksa null).
  CriticalMoment? get nextMoment {
    for (final m in moments) {
      if (!_outcomes.containsKey(m)) return m;
    }
    return null;
  }

  /// Oyuncunun kritik anlarından yenen gol sayısı.
  int get concededFromMoments =>
      _outcomes.values.where((o) => o.concededGoal).length;

  /// Bir anın sonucunu işler (her an yalnızca bir kez).
  void resolve(CriticalMoment moment, MomentOutcome outcome) {
    assert(moments.contains(moment), 'Bu an bu maça ait değil');
    assert(!_outcomes.containsKey(moment), 'An zaten çözüldü');
    _outcomes[moment] = outcome;
    if (outcome.playerGoal) {
      _goals.add(
        MatchGoal(minute: moment.minute, side: playerSide, byPlayer: true),
      );
    }
    if (outcome.playerAssist) {
      _goals.add(
        MatchGoal(
          minute: moment.minute,
          side: playerSide,
          assistedByPlayer: true,
        ),
      );
    }
    if (outcome.concededGoal) {
      _goals.add(MatchGoal(minute: moment.minute, side: _opponentSide));
    }
  }

  /// Çözülmemiş tüm anları oyuncu niteliklerine göre otomatik oynatır.
  void autoPlay(Player player, GameRandom random, {double performance = 1}) {
    for (final m in moments) {
      if (!_outcomes.containsKey(m)) {
        resolve(
          m,
          MomentResolver.autoResolve(
            m,
            player,
            random,
            performance: performance,
          ),
        );
      }
    }
  }

  MatchResult get result =>
      MatchResult(goals: [..._goals]..sort((a, b) => a.minute - b.minute));
}
