import 'dart:math' as math;

import '../../core/game_random.dart';
import '../club/club_engine.dart';
import '../club/finance.dart';
import '../player/player_development.dart';
import '../player/position.dart';
import 'career_state.dart';
import 'match_record.dart';
import 'player_status.dart';
import 'season_calendar.dart';
import 'week_balance.dart';
import 'week_report.dart';
import 'weekly_plan.dart';

enum MatchResultKind { win, draw, loss }

/// O hafta oynanan maçın oyuncuyu ilgilendiren özeti.
class WeekMatch {
  const WeekMatch({
    required this.rating,
    required this.goals,
    required this.assists,
    required this.result,
    this.scoreFor = 0,
    this.scoreAgainst = 0,
  });

  final double rating;
  final int goals;
  final int assists;
  final MatchResultKind result;

  /// Takımın attığı ve yediği goller (puan durumu için).
  final int scoreFor;
  final int scoreAgainst;
}

class WeekResult {
  const WeekResult({
    required this.state,
    required this.report,
    required this.before,
  });

  final CareerState state;
  final WeekReport report;

  /// Haftanın başındaki durum (özette "önce -> sonra" için).
  final PlayerStatus before;
}

/// Haftalık yaşam döngüsü (saf Dart, seed'li).
///
/// Zincir: düşük kondisyon -> sakatlık riski -> form düşüşü -> moral düşüşü.
abstract final class WeekEngine {
  /// Bu haftada oynanacak lig maçı var mı?
  static bool hasMatch(int week) =>
      SeasonCalendar.phaseOf(week) == SeasonPhase.regularSeason;

  /// Sakat oyuncu ilerlemek için bu haftayı oynamak zorunda değildir:
  /// maç yok, antrenman dinlenmeye çevrilir.
  static WeekResult advance(
    CareerState state,
    WeeklyPlan plan,
    WeekMatch? match,
    GameRandom random,
  ) {
    final before = state.status;
    final injuredAtStart = before.isInjured;
    final m = injuredAtStart ? null : match;

    final focus = injuredAtStart ? TrainingFocus.rest : plan.focus;
    final intensity = plan.intensity;
    final training = focus != TrainingFocus.rest;

    final changes = <StatChange>[];
    final gains = <AttributeGain>[];
    final events = <WeekEvent>[];

    if (injuredAtStart && plan.focus != TrainingFocus.rest) {
      events.add(const WeekEvent(WeekEventKind.trainingBlocked));
    }
    if (m == null &&
        !injuredAtStart &&
        state.contract != null &&
        hasMatch(state.week)) {
      events.add(const WeekEvent(WeekEventKind.benched));
    }

    // --- Antrenman: odaktaki nitelikler ---
    var player = state.player;
    if (training) {
      var attrs = player.attributes;
      final gainBase =
          WeekBalance.trainingGainBase *
          WeekBalance.intensityGain[intensity]! *
          (0.6 + 0.8 * player.professionalism) *
          WeekBalance.ageGainMultiplier(player.age);
      for (final a in WeeklyPlan.attributesFor(focus)) {
        final value = attrs.raw(a);
        final ceiling = PositionProfile.ceiling(
          player.position,
          a,
          player.potential,
        );
        final headroom = ((ceiling - value) / 10).clamp(0.0, 1.0);
        final gain = gainBase * headroom;
        if (gain > 0) {
          attrs = attrs.copyWith({a: value + gain});
          gains.add(AttributeGain(a, gain));
        }
      }
      player = player.copyWith(attributes: attrs);
    }

    // --- Kondisyon ---
    void cond(double d, WeekReason why) {
      if (d != 0) changes.add(StatChange(StatKind.condition, d, why));
    }

    cond(WeekBalance.weeklyRecovery, WeekReason.recovery);
    if (!training) {
      cond(WeekBalance.restRecovery, WeekReason.restFocus);
    } else {
      cond(WeekBalance.trainingCondition[intensity]!, switch (intensity) {
        TrainingIntensity.light => WeekReason.trainingLight,
        TrainingIntensity.normal => WeekReason.trainingNormal,
        TrainingIntensity.hard => WeekReason.trainingHard,
      });
    }
    if (m != null) cond(WeekBalance.matchCondition, WeekReason.match);
    cond(WeekBalance.socialCondition[plan.social]!, _socialReason(plan.social));

    final conditionDelta = changes.fold(0.0, (s, c) => s + c.delta);
    final newCondition = (before.condition + conditionDelta).clamp(0.0, 100.0);

    // --- Sakatlık ---
    Injury? injury = before.injury;
    var injuryOnset = false;
    var healed = false;
    if (injuredAtStart) {
      var left = injury!.weeksLeft - 1;
      if (left > 0 && random.chance(WeekBalance.restHealChance)) left--;
      if (left <= 0) {
        injury = null;
        healed = true;
        events.add(const WeekEvent(WeekEventKind.healed));
      } else {
        injury = injury.copyWith(weeksLeft: left);
      }
    } else {
      final lowCondition =
          ((WeekBalance.lowConditionThreshold - newCondition) /
                  WeekBalance.lowConditionThreshold)
              .clamp(0.0, 1.0) *
          WeekBalance.lowConditionRisk;
      final risk =
          WeekBalance.injuryBase +
          WeekBalance.injuryProneGain * player.injuryProneness +
          lowCondition +
          (m != null ? WeekBalance.matchRisk : 0) +
          (training ? WeekBalance.intensityRisk[intensity]! : 0) +
          before.relapseRisk;
      if (random.chance(risk)) {
        final type = _pickInjuryType(random);
        final range = WeekBalance.injuryWeeks[type]!;
        var weeks = random.range(range.$1, range.$2);
        final relapse = before.relapseRisk > 0.1;
        if (relapse) {
          weeks = (weeks * WeekBalance.relapseDurationMultiplier).ceil();
        }
        injury = Injury(
          type: type,
          weeksLeft: weeks,
          totalWeeks: weeks,
          isRelapse: relapse,
        );
        injuryOnset = true;
        events.add(
          WeekEvent(
            relapse ? WeekEventKind.relapse : WeekEventKind.injured,
            injuryType: type,
            weeks: weeks,
          ),
        );
      }
    }

    // --- Form: son 5 maçın reyting ortalaması (0-10) ---
    final ratings = [...before.recentRatings];
    var newForm = before.form;
    if (m != null) {
      ratings
        ..add(m.rating)
        ..removeRange(
          0,
          math.max(0, ratings.length - WeekBalance.ratingWindow),
        );
      newForm = (ratings.reduce((a, b) => a + b) / ratings.length).clamp(
        0.0,
        10.0,
      );
      changes.add(
        StatChange(
          StatKind.form,
          newForm - before.form,
          WeekReason.formFromRatings,
        ),
      );
    }

    // --- Moral ---
    void morale(double d, WeekReason why) {
      if (d != 0) changes.add(StatChange(StatKind.morale, d, why));
    }

    if (m != null) {
      switch (m.result) {
        case MatchResultKind.win:
          morale(WeekBalance.moraleWin, WeekReason.matchWin);
        case MatchResultKind.loss:
          morale(WeekBalance.moraleLoss, WeekReason.matchLoss);
        case MatchResultKind.draw:
          break;
      }
      if (m.rating >= 7.5) {
        morale(WeekBalance.moraleGreatRating, WeekReason.greatPerformance);
      } else if (m.rating <= 5) {
        morale(WeekBalance.moralePoorRating, WeekReason.poorPerformance);
      }
    }
    if (injuredAtStart && !healed) {
      morale(WeekBalance.moraleInjuredWeek, WeekReason.injured);
    }
    if (injuryOnset) {
      morale(WeekBalance.moraleInjuryOnset, WeekReason.injuryOnset);
    }
    if (healed) morale(WeekBalance.moraleHealed, WeekReason.healed);
    if (newCondition < 30) {
      morale(WeekBalance.moraleExhausted, WeekReason.exhausted);
    }
    if (training && intensity == TrainingIntensity.hard) {
      morale(WeekBalance.moraleHardTraining, WeekReason.trainingHard);
    }
    morale(WeekBalance.socialMorale[plan.social]!, _socialReason(plan.social));
    final (lifeMorale, inDebt) = Economy.moraleEffect(state.finance);
    morale(lifeMorale, inDebt ? WeekReason.debt : WeekReason.lifestyle);
    morale(
      (WeekBalance.moraleBaseline - before.morale) * WeekBalance.moraleDrift,
      WeekReason.drift,
    );
    final moraleDelta = changes
        .where((c) => c.stat == StatKind.morale)
        .fold(0.0, (s, c) => s + c.delta);

    var relapseRisk = before.relapseRisk * WeekBalance.relapseRiskDecay;
    if (relapseRisk < 0.02) relapseRisk = 0;

    final after = PlayerStatus(
      condition: newCondition,
      form: newForm,
      morale: (before.morale + moraleDelta).clamp(0.0, 100.0),
      injury: injury,
      relapseRisk: relapseRisk,
      recentRatings: ratings,
    );

    // --- Takvim: hafta ilerler, sezon sonunda yaşlanma ---
    final reportSeason = state.season;
    final reportWeek = state.week;
    var season = state.season;
    var week = state.week + 1;
    if (week > SeasonCalendar.weeksPerSeason) {
      week = 1;
      season += 1;
      player = PlayerDevelopment.advanceYear(player, random);
      events.add(WeekEvent(WeekEventKind.newSeason, age: player.age));
    }

    // --- Para: maaş, prim, menajer komisyonu, yaşam gideri ---
    final money = Economy.weekly(
      contract: state.contract,
      agent: state.agent,
      lifestyle: state.finance.lifestyle,
      won: m?.result == MatchResultKind.win,
      goals: m?.goals ?? 0,
    );

    // --- Skor kaydı (puan durumu için) ---
    final round = SeasonCalendar.leagueRoundOf(reportWeek);
    final results = [
      ...state.results,
      if (m != null && state.contract != null && round != null)
        MatchRecord(
          round: round,
          clubId: state.contract!.clubId,
          scoreFor: m.scoreFor,
          scoreAgainst: m.scoreAgainst,
        ),
    ];

    final advanced = state.copyWith(
      player: player,
      season: season,
      week: week,
      status: after,
      stats: m == null
          ? state.stats
          : state.stats.addMatch(
              goals: m.goals,
              assists: m.assists,
              rating: m.rating,
            ),
      finance: state.finance.copyWith(
        balance: state.finance.balance + money.net,
      ),
      results: results,
    );

    // --- Kulüp: sezon geçişi, teklifler, yenileme ---
    final club = ClubEngine.process(
      advanced,
      newSeason: season > state.season,
      random: random,
    );
    events.addAll(club.events);

    return WeekResult(
      state: club.state,
      before: before,
      report: WeekReport(
        season: reportSeason,
        week: reportWeek,
        statChanges: changes,
        attributeGains: gains,
        events: events,
        playedMatch: m != null,
        money: money,
      ),
    );
  }

  /// Riskli erken dönüş: sakatlık biter ama tekrar sakatlanma riski yüksektir.
  static CareerState returnEarly(CareerState state) {
    if (!state.status.isInjured) return state;
    return state.copyWith(
      status: state.status.copyWith(
        clearInjury: true,
        relapseRisk: WeekBalance.earlyReturnRelapseRisk,
        condition: state.status.condition + WeekBalance.earlyReturnCondition,
      ),
    );
  }

  static InjuryType _pickInjuryType(GameRandom random) {
    final weights = WeekBalance.injuryTypeWeight;
    var roll = random.nextDouble() * weights.values.fold(0.0, (a, b) => a + b);
    for (final e in weights.entries) {
      roll -= e.value;
      if (roll <= 0) return e.key;
    }
    return weights.keys.last;
  }

  static WeekReason _socialReason(SocialActivity s) => switch (s) {
    SocialActivity.family => WeekReason.socialFamily,
    SocialActivity.friends => WeekReason.socialFriends,
    SocialActivity.hobby => WeekReason.socialHobby,
    SocialActivity.none => WeekReason.recovery,
  };
}
