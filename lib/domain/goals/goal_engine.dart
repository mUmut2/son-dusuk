import '../../core/game_random.dart';
import '../../core/seed_mix.dart';
import '../career/career_state.dart';
import '../career/week_report.dart';
import '../career/weekly_plan.dart';
import '../club/squad.dart';
import '../social/event_models.dart';
import '../social/feed_engine.dart';
import '../social/feed_models.dart';
import '../social/social_engine.dart';
import 'goal_balance.dart';
import 'goal_models.dart';

/// Hafta sonunda hedeflerin değerlendirilmesi için maç ve plan özeti.
class GoalInput {
  const GoalInput({
    this.played = false,
    this.rating = 0,
    this.goals = 0,
    this.assists = 0,
    this.won = false,
    this.hardTraining = false,
  });

  final bool played;
  final double rating;
  final int goals;
  final int assists;
  final bool won;

  /// Bu hafta ağır tempoda antrenman yapıldı.
  final bool hardTraining;
}

class GoalUpdate {
  const GoalUpdate(this.state, this.events);

  final CareerState state;
  final List<WeekEvent> events;
}

/// Haftalık hedefler, seri ve ödüller (saf Dart, seed'li).
abstract final class GoalEngine {
  /// Bu haftanın hedefleri: aynı hafta hep aynı. Maçı olmayan haftada yalnızca
  /// maçtan bağımsız hedefler çıkar.
  static List<GoalKind> forWeek(CareerState s) {
    final random = GameRandom(mixSeed([s.worldSeed, s.season, s.week, 80]));
    final hasMatch = Squad.matchDay(s) == MatchDay.play;
    final pool = [
      for (final k in GoalKind.values)
        if (hasMatch || !k.isMatch) k,
    ];
    for (var i = pool.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final t = pool[i];
      pool[i] = pool[j];
      pool[j] = t;
    }
    return pool.take(GoalBalance.perWeek).toList()
      ..sort((a, b) => a.index.compareTo(b.index));
  }

  /// Hedefin hafta sonundaki sonucu.
  static bool isMet(GoalKind k, CareerState s, GoalInput i) => switch (k) {
    GoalKind.scoreGoal => i.played && i.goals >= 1,
    GoalKind.assist => i.played && i.assists >= 1,
    GoalKind.rating7 => i.played && i.rating >= GoalBalance.ratingTarget,
    GoalKind.winMatch => i.played && i.won,
    GoalKind.trainHard => i.hardTraining,
    GoalKind.postFeed => s.feed.lastOwnPostWeek == s.absoluteWeek,
    GoalKind.noBetting => s.spending.weekStaked == 0,
  };

  /// Haftanın ortasında gösterilen durum: bitenler, kaçırılanlar, bekleyenler.
  static GoalStatus statusNow(
    GoalKind k,
    CareerState s, {
    required TrainingIntensity intensity,
  }) => switch (k) {
    GoalKind.postFeed =>
      s.feed.lastOwnPostWeek == s.absoluteWeek
          ? GoalStatus.done
          : GoalStatus.pending,
    GoalKind.noBetting =>
      s.spending.weekStaked == 0 ? GoalStatus.pending : GoalStatus.failed,
    GoalKind.trainHard =>
      intensity == TrainingIntensity.hard
          ? GoalStatus.done
          : GoalStatus.pending,
    _ => GoalStatus.pending,
  };

  static int _wage(CareerState s) => s.contract?.weeklyWage ?? 0;

  static int _atLeast(double value, int min) {
    final v = value.round();
    return v < min ? min : v;
  }

  /// Hedef başına ödül (para).
  static int rewardPerGoal(CareerState s) => _atLeast(
    _wage(s) * GoalBalance.moneyPerGoalWeeks,
    GoalBalance.minPerGoal,
  );

  static int allDoneBonus(CareerState s) =>
      _atLeast(_wage(s) * GoalBalance.allDoneWeeks, GoalBalance.minAllDone);

  static int milestoneReward(CareerState s) =>
      _atLeast(_wage(s) * GoalBalance.milestoneWeeks, GoalBalance.minMilestone);

  /// Haftanın hedeflerini değerlendirir, ödülü verir, seriyi günceller.
  /// [prev] haftanın başı (hedeflerin üretildiği durum), [next] sonraki durum.
  static GoalUpdate afterWeek(
    CareerState prev,
    CareerState next,
    GoalInput input,
    GameRandom random,
  ) {
    if (prev.retired) return GoalUpdate(next, const []);
    final goals = forWeek(prev);
    final done = goals.where((k) => isMet(k, prev, input)).length;

    var s = next;
    var reward = done * rewardPerGoal(prev);
    final all = done == goals.length;
    if (all) reward += allDoneBonus(prev);

    final old = s.goals;
    final streak = done >= GoalBalance.streakMin ? old.streak + 1 : 0;
    final milestone =
        streak > old.streak && GoalBalance.milestones.contains(streak);
    if (milestone) reward += milestoneReward(prev);

    s = SocialEngine.applyEffect(
      s,
      EventEffect(
        morale: GoalBalance.moralePerGoal * done,
        fans: all ? GoalBalance.allDoneFans : 0,
        money: reward,
      ),
    );
    if (milestone) {
      s = SocialEngine.applyEffect(s, GoalBalance.milestoneEffect);
      s = FeedEngine.react(
        s,
        FeedKind.streak,
        {'streak': '$streak'},
        random,
        growth: 0.02,
      );
    }
    s = s.copyWith(
      goals: old.copyWith(
        streak: streak,
        best: streak > old.best ? streak : old.best,
        totalDone: old.totalDone + done,
        lastWeek: prev.absoluteWeek,
        lastDone: done,
        lastReward: reward,
      ),
    );
    return GoalUpdate(s, [
      WeekEvent(
        WeekEventKind.goalsReport,
        weeks: streak,
        detail: '$done',
        detail2: '$reward',
      ),
      if (milestone) WeekEvent(WeekEventKind.goalStreak, weeks: streak),
    ]);
  }
}
