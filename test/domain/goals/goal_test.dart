import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/app/l10n/app_localizations.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/week_engine.dart';
import 'package:son_dusuk/domain/career/week_report.dart';
import 'package:son_dusuk/domain/career/weekly_plan.dart';
import 'package:son_dusuk/domain/club/squad.dart';
import 'package:son_dusuk/domain/goals/goal_balance.dart';
import 'package:son_dusuk/domain/goals/goal_engine.dart';
import 'package:son_dusuk/domain/goals/goal_models.dart';
import 'package:son_dusuk/domain/league/club_world.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/domain/social/feed_models.dart';
import 'package:son_dusuk/domain/social/relationships.dart';
import 'package:son_dusuk/domain/spending/spending_engine.dart';
import 'package:son_dusuk/domain/spending/spending_models.dart';
import 'package:son_dusuk/presentation/l10n_labels.dart';

CareerState newCareer({int week = 10}) => CareerFactory.create(
  PlayerFactory.create(
    name: 'Deniz',
    birthplace: 'Bursa',
    position: PlayerPosition.forward,
    foot: PreferredFoot.right,
    appearance: const Appearance(),
    random: GameRandom(1),
  ),
  GameRandom(1),
).copyWith(week: week);

/// Oyuncunun maçı olan bir hafta bulur.
CareerState matchWeek() {
  for (var w = 5; w <= 38; w++) {
    final s = newCareer(week: w);
    if (Squad.matchDay(s) == MatchDay.play) return s;
  }
  throw StateError('maçlı hafta yok');
}

const allDone = GoalInput(
  played: true,
  rating: 8,
  goals: 1,
  assists: 1,
  won: true,
  hardTraining: true,
);

void main() {
  group('haftanın hedefleri', () {
    test('üç farklı hedef, kararlı, sıralı', () {
      final s = matchWeek();
      final a = GoalEngine.forWeek(s);
      final b = GoalEngine.forWeek(s);
      expect(a, b);
      expect(a.length, GoalBalance.perWeek);
      expect(a.toSet().length, a.length);
      expect([...a]..sort((x, y) => x.index - y.index), a);
    });

    test('maçsız haftada yalnızca maçtan bağımsız hedefler çıkar', () {
      final s = newCareer(week: 40);
      expect(Squad.matchDay(s), isNot(MatchDay.play));
      expect(GoalEngine.forWeek(s), [
        GoalKind.trainHard,
        GoalKind.postFeed,
        GoalKind.noBetting,
      ]);
    });

    test('farklı haftalarda farklı hedefler çıkar', () {
      final seen = <String>{};
      for (var w = 5; w <= 38; w++) {
        seen.add(GoalEngine.forWeek(newCareer(week: w)).join(','));
      }
      expect(seen.length, greaterThan(5));
    });
  });

  group('hedef sonuçları', () {
    test('her hedef kendi koşuluyla sağlanır', () {
      final s = newCareer();
      expect(GoalEngine.isMet(GoalKind.scoreGoal, s, allDone), isTrue);
      expect(
        GoalEngine.isMet(
          GoalKind.scoreGoal,
          s,
          const GoalInput(played: true, rating: 8),
        ),
        isFalse,
      );
      expect(GoalEngine.isMet(GoalKind.assist, s, allDone), isTrue);
      expect(GoalEngine.isMet(GoalKind.rating7, s, allDone), isTrue);
      expect(
        GoalEngine.isMet(
          GoalKind.rating7,
          s,
          const GoalInput(played: true, rating: 6.9),
        ),
        isFalse,
      );
      expect(GoalEngine.isMet(GoalKind.winMatch, s, allDone), isTrue);
      expect(
        GoalEngine.isMet(GoalKind.winMatch, s, const GoalInput()),
        isFalse,
      );
      expect(GoalEngine.isMet(GoalKind.trainHard, s, allDone), isTrue);
      expect(
        GoalEngine.isMet(GoalKind.trainHard, s, const GoalInput()),
        isFalse,
      );
      expect(
        GoalEngine.isMet(GoalKind.noBetting, s, const GoalInput()),
        isTrue,
      );
      expect(
        GoalEngine.isMet(
          GoalKind.noBetting,
          s.copyWith(spending: const Spending(weekStaked: 100)),
          const GoalInput(),
        ),
        isFalse,
      );
      expect(
        GoalEngine.isMet(GoalKind.postFeed, s, const GoalInput()),
        isFalse,
      );
      expect(
        GoalEngine.isMet(
          GoalKind.postFeed,
          s.copyWith(feed: s.feed.copyWith(lastOwnPostWeek: s.absoluteWeek)),
          const GoalInput(),
        ),
        isTrue,
      );
    });

    test('haftanın ortasındaki durum: paylaşım, bahis ve antrenman', () {
      final s = newCareer();
      GoalStatus st(GoalKind k, CareerState c, TrainingIntensity i) =>
          GoalEngine.statusNow(k, c, intensity: i);
      expect(
        st(GoalKind.postFeed, s, TrainingIntensity.normal),
        GoalStatus.pending,
      );
      final posted = s.copyWith(
        feed: s.feed.copyWith(lastOwnPostWeek: s.absoluteWeek),
      );
      expect(
        st(GoalKind.postFeed, posted, TrainingIntensity.normal),
        GoalStatus.done,
      );
      expect(
        st(GoalKind.trainHard, s, TrainingIntensity.hard),
        GoalStatus.done,
      );
      expect(
        st(GoalKind.trainHard, s, TrainingIntensity.light),
        GoalStatus.pending,
      );
      final bet = s.copyWith(spending: const Spending(weekStaked: 50));
      expect(
        st(GoalKind.noBetting, bet, TrainingIntensity.normal),
        GoalStatus.failed,
      );
      expect(
        st(GoalKind.scoreGoal, s, TrainingIntensity.normal),
        GoalStatus.pending,
      );
    });

    test('bahis tutarı izlenir ve hafta bitince sıfırlanır', () {
      final s = newCareer(week: 10);
      final w = ClubWorld(s.worldSeed);
      final next = SpendingEngine.placeBet(s, w, 0, BetPick.home, 100)!;
      expect(next.spending.weekStaked, 100);
      final after = SpendingEngine.afterWeek(
        next,
        next.copyWith(week: 11),
        GameRandom(1),
      ).state;
      expect(after.spending.weekStaked, 0);
    });
  });

  group('ödül ve seri', () {
    test('hepsi tamamlanınca hedef başına ödül + bonus + moral + taraftar', () {
      final s = matchWeek();
      final goals = GoalEngine.forWeek(s);
      // Seçilen üç hedefi de sağlayan girdi.
      final posted = s.copyWith(
        feed: s.feed.copyWith(lastOwnPostWeek: s.absoluteWeek),
      );
      final u = GoalEngine.afterWeek(posted, posted, allDone, GameRandom(1));
      final expected =
          goals.length * GoalEngine.rewardPerGoal(posted) +
          GoalEngine.allDoneBonus(posted);
      expect(u.state.goals.lastDone, 3);
      expect(u.state.goals.lastReward, expected);
      expect(u.state.finance.balance, posted.finance.balance + expected);
      expect(
        u.state.relations[Relation.fans],
        greaterThan(posted.relations[Relation.fans]),
      );
      expect(u.state.goals.streak, 1);
      final report = u.events.firstWhere(
        (e) => e.kind == WeekEventKind.goalsReport,
      );
      expect(report.detail, '3');
      expect(report.weeks, 1);
    });

    test('hiçbiri tamamlanmazsa ödül ve seri sıfır', () {
      final s = newCareer(week: 40).copyWith(
        goals: const Goals(streak: 4, best: 4),
        spending: const Spending(weekStaked: 100),
      );
      final u = GoalEngine.afterWeek(s, s, const GoalInput(), GameRandom(1));
      expect(u.state.goals.lastDone, 0);
      expect(u.state.goals.lastReward, 0);
      expect(u.state.goals.streak, 0);
      expect(u.state.goals.best, 4);
      expect(u.state.finance.balance, s.finance.balance);
    });

    test('haftada en az 2 hedef seriyi korur, 1 hedef bozar', () {
      // Hafta 40: trainHard, postFeed, noBetting.
      var s = newCareer(week: 40);
      final two = GoalEngine.afterWeek(
        s,
        s,
        const GoalInput(hardTraining: true),
        GameRandom(1),
      );
      expect(two.state.goals.lastDone, 2);
      expect(two.state.goals.streak, 1);
      s = s.copyWith(spending: const Spending(weekStaked: 10));
      final one = GoalEngine.afterWeek(
        s,
        s,
        const GoalInput(hardTraining: true),
        GameRandom(1),
      );
      expect(one.state.goals.lastDone, 1);
      expect(one.state.goals.streak, 0);
    });

    test('dönüm noktasında ek ödül, akışta paylaşım ve olay gelir', () {
      var s = newCareer(
        week: 40,
      ).copyWith(goals: const Goals(streak: 2, best: 2));
      final plain = GoalEngine.afterWeek(
        s,
        s,
        const GoalInput(hardTraining: true),
        GameRandom(1),
      );
      expect(plain.state.goals.streak, 3);
      expect(
        plain.events.map((e) => e.kind),
        contains(WeekEventKind.goalStreak),
      );
      expect(plain.state.feed.posts.first.kind, FeedKind.streak);
      expect(plain.state.feed.posts.first.params['streak'], '3');
      expect(
        plain.state.goals.lastReward,
        greaterThan(2 * GoalEngine.rewardPerGoal(s)),
      );

      // 4. hafta dönüm noktası değil.
      s = plain.state.copyWith(week: 40);
      final again = GoalEngine.afterWeek(
        s,
        s,
        const GoalInput(hardTraining: true),
        GameRandom(1),
      );
      expect(again.state.goals.streak, 4);
      expect(
        again.events.map((e) => e.kind),
        isNot(contains(WeekEventKind.goalStreak)),
      );
    });

    test('emekli kariyerde değerlendirme yapılmaz', () {
      final s = newCareer().copyWith(retired: true);
      final u = GoalEngine.afterWeek(s, s, allDone, GameRandom(1));
      expect(u.events, isEmpty);
      expect(u.state.goals.totalDone, 0);
    });

    test('ödül maaşla ölçeklenir, alt sınırı vardır', () {
      final s = newCareer();
      expect(
        GoalEngine.rewardPerGoal(s),
        greaterThanOrEqualTo(GoalBalance.minPerGoal),
      );
      expect(
        GoalEngine.allDoneBonus(s),
        greaterThanOrEqualTo(GoalBalance.minAllDone),
      );
      expect(
        GoalEngine.milestoneReward(s),
        greaterThanOrEqualTo(GoalBalance.minMilestone),
      );
    });
  });

  group('hafta motoru ve kayıt', () {
    test('hafta sonunda hedef raporu çıkar ve ödül bakiyeye eklenir', () {
      final s = newCareer(
        week: 40,
      ).copyWith(feed: newCareer().feed.copyWith(lastOwnPostWeek: 0));
      final posted = s.copyWith(
        feed: s.feed.copyWith(lastOwnPostWeek: s.absoluteWeek),
      );
      final r = WeekEngine.advance(
        posted,
        const WeeklyPlan(intensity: TrainingIntensity.hard),
        null,
        GameRandom(3),
      );
      final report = r.report.events.firstWhere(
        (e) => e.kind == WeekEventKind.goalsReport,
      );
      expect(report.detail, '3');
      expect(r.state.goals.streak, 1);
      expect(
        r.state.finance.balance,
        posted.finance.balance + r.report.money.net + r.state.goals.lastReward,
      );
    });

    test('JSON gidiş-dönüş ve eski kayıt varsayılanı', () {
      final s = newCareer().copyWith(
        goals: const Goals(streak: 3, best: 5, totalDone: 12, lastDone: 2),
      );
      final back = CareerState.fromJson(
        jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>,
      );
      expect(back.goals.streak, 3);
      expect(back.goals.best, 5);
      expect(back.goals.totalDone, 12);
      final old = newCareer().toJson()..remove('goals');
      expect(CareerState.fromJson(old).goals.streak, 0);
    });
  });

  group('metinler', () {
    test('hedef adları ve olay metinleri tam', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('tr'));
      for (final k in GoalKind.values) {
        expect(l10n.goalName(k), isNotEmpty);
      }
      final t = l10n.eventText(
        const WeekEvent(
          WeekEventKind.goalsReport,
          weeks: 2,
          detail: '2',
          detail2: '500',
        ),
        clubName: '',
        eventTitle: '',
      );
      expect(t, contains('2/3'));
      expect(t.contains('{'), isFalse);
      final m = l10n.eventText(
        const WeekEvent(WeekEventKind.goalStreak, weeks: 6),
        clubName: '',
        eventTitle: '',
      );
      expect(m, contains('6'));
    });
  });
}
