import '../app/l10n/app_localizations.dart';
import '../domain/career/difficulty.dart';
import '../domain/career/player_status.dart';
import '../domain/career/season_calendar.dart';
import '../domain/career/week_report.dart';
import '../domain/career/weekly_plan.dart';
import '../domain/club/contract.dart';
import '../domain/club/finance.dart';
import '../domain/player/attribute.dart';
import '../domain/social/event_models.dart';
import '../domain/social/relationships.dart';
import 'event_texts.dart';
import '../domain/player/position.dart';

/// Enum -> yerelleştirilmiş metin eşlemeleri (tek yerde).
extension L10nLabels on AppLocalizations {
  String positionName(PlayerPosition p) => switch (p) {
    PlayerPosition.forward => position_forward,
    PlayerPosition.winger => position_winger,
    PlayerPosition.attackingMid => position_attackingMid,
    PlayerPosition.centralMid => position_centralMid,
    PlayerPosition.defender => position_defender,
  };

  String footName(PreferredFoot f) => switch (f) {
    PreferredFoot.left => foot_left,
    PreferredFoot.right => foot_right,
    PreferredFoot.both => foot_both,
  };

  String attributeName(Attribute a) => switch (a) {
    Attribute.shooting => attr_shooting,
    Attribute.finesse => attr_finesse,
    Attribute.passing => attr_passing,
    Attribute.vision => attr_vision,
    Attribute.dribbling => attr_dribbling,
    Attribute.pace => attr_pace,
    Attribute.agility => attr_agility,
    Attribute.strength => attr_strength,
    Attribute.stamina => attr_stamina,
    Attribute.defending => attr_defending,
    Attribute.ballControl => attr_ballControl,
    Attribute.heading => attr_heading,
    Attribute.setPieces => attr_setPieces,
    Attribute.composure => attr_composure,
    Attribute.charisma => attr_charisma,
  };

  String kindName(AttributeKind k) => switch (k) {
    AttributeKind.physical => kind_physical,
    AttributeKind.technical => kind_technical,
    AttributeKind.mental => kind_mental,
  };

  String difficultyName(Difficulty d) => switch (d) {
    Difficulty.easy => difficulty_easy,
    Difficulty.normal => difficulty_normal,
    Difficulty.hard => difficulty_hard,
  };

  String injuryTypeName(InjuryType t) => switch (t) {
    InjuryType.muscle => injury_muscle,
    InjuryType.ligament => injury_ligament,
    InjuryType.fracture => injury_fracture,
  };

  String focusName(TrainingFocus f) => switch (f) {
    TrainingFocus.shooting => focus_shooting,
    TrainingFocus.physical => focus_physical,
    TrainingFocus.technical => focus_technical,
    TrainingFocus.tactical => focus_tactical,
    TrainingFocus.rest => focus_rest,
  };

  String intensityName(TrainingIntensity i) => switch (i) {
    TrainingIntensity.light => intensity_light,
    TrainingIntensity.normal => intensity_normal,
    TrainingIntensity.hard => intensity_hard,
  };

  String socialName(SocialActivity s) => switch (s) {
    SocialActivity.none => social_none,
    SocialActivity.family => social_family,
    SocialActivity.friends => social_friends,
    SocialActivity.hobby => social_hobby,
  };

  String statName(StatKind k) => switch (k) {
    StatKind.condition => statCondition,
    StatKind.form => statForm,
    StatKind.morale => statMorale,
  };

  String phaseName(int week) => switch (SeasonCalendar.phaseOf(week)) {
    SeasonPhase.preseason => phase_preseason,
    SeasonPhase.regularSeason => phase_regularSeason(
      SeasonCalendar.leagueRoundOf(week)!,
    ),
    SeasonPhase.offseason => phase_offseason,
  };

  String reasonName(WeekReason r) => switch (r) {
    WeekReason.recovery => reason_recovery,
    WeekReason.trainingLight => reason_trainingLight,
    WeekReason.trainingNormal => reason_trainingNormal,
    WeekReason.trainingHard => reason_trainingHard,
    WeekReason.restFocus => reason_restFocus,
    WeekReason.match => reason_match,
    WeekReason.socialFamily => reason_socialFamily,
    WeekReason.socialFriends => reason_socialFriends,
    WeekReason.socialHobby => reason_socialHobby,
    WeekReason.matchWin => reason_matchWin,
    WeekReason.matchLoss => reason_matchLoss,
    WeekReason.greatPerformance => reason_greatPerformance,
    WeekReason.poorPerformance => reason_poorPerformance,
    WeekReason.injured => reason_injured,
    WeekReason.injuryOnset => reason_injuryOnset,
    WeekReason.healed => reason_healed,
    WeekReason.exhausted => reason_exhausted,
    WeekReason.formFromRatings => reason_formFromRatings,
    WeekReason.earlyReturn => reason_earlyReturn,
    WeekReason.drift => reason_drift,
    WeekReason.lifestyle => reason_lifestyle,
    WeekReason.debt => reason_debt,
  };

  /// [clubName]: teklif/sözleşme olaylarında kulüp adı.
  String eventText(
    WeekEvent e, {
    String clubName = '',
    String eventTitle = '',
  }) => switch (e.kind) {
    WeekEventKind.injured => eventInjured(
      injuryTypeName(e.injuryType!),
      e.weeks!,
    ),
    WeekEventKind.relapse => eventRelapse(
      injuryTypeName(e.injuryType!),
      e.weeks!,
    ),
    WeekEventKind.healed => eventHealed,
    WeekEventKind.newSeason => eventNewSeason(e.age!),
    WeekEventKind.trainingBlocked => eventTrainingBlocked,
    WeekEventKind.benched => eventBenched,
    WeekEventKind.offerReceived => eventOfferReceived(clubName),
    WeekEventKind.renewalOffered => eventRenewalOffered(clubName),
    WeekEventKind.contractExpired => eventContractExpired(clubName),
    WeekEventKind.newEvent => eventNewEvent(eventTitle),
  };

  String relationName(Relation r) => switch (r) {
    Relation.coach => rel_coach,
    Relation.teammates => rel_teammates,
    Relation.fans => rel_fans,
    Relation.family => rel_family,
    Relation.media => rel_media,
  };

  String relationHint(Relation r) => switch (r) {
    Relation.coach => relHint_coach,
    Relation.teammates => relHint_teammates,
    Relation.fans => relHint_fans,
    Relation.family => relHint_family,
    Relation.media => relHint_media,
  };

  String relationLevel(double value) => switch (Relationships.levelOf(value)) {
    0 => relLevel_0,
    1 => relLevel_1,
    2 => relLevel_2,
    3 => relLevel_3,
    _ => relLevel_4,
  };

  String eventKindName(EventKind k) => switch (k) {
    EventKind.press => eventKind_press,
    EventKind.personal => eventKind_personal,
    EventKind.career => eventKind_career,
    EventKind.money => eventKind_money,
  };

  /// Haber akışı satırı. [clubName]: kulüp kimliğinden ada çevirici.
  String newsText(NewsItem n, String Function(String id) clubName) =>
      switch (n.kind) {
        NewsKind.match =>
          (n.params['goals'] ?? '0') == '0'
              ? newsMatch(n.params['opponent'] ?? '', n.params['score'] ?? '')
              : newsMatchGoals(
                  n.params['opponent'] ?? '',
                  n.params['score'] ?? '',
                  n.params['goals'] ?? '',
                ),
        NewsKind.signed => newsSigned(clubName(n.params['club'] ?? '')),
        NewsKind.injury => newsInjury(
          injuryTypeName(
            InjuryType.values.byName(n.params['type'] ?? 'muscle'),
          ),
          n.params['weeks'] ?? '',
        ),
        NewsKind.event => () {
          final t = eventTexts(n.params['id'] ?? '', const {});
          final i = int.tryParse(n.params['choice'] ?? '') ?? 0;
          return newsEvent(t.title, t.choices[i]);
        }(),
      };

  String roleName(SquadRole r) => switch (r) {
    SquadRole.prospect => role_prospect,
    SquadRole.rotation => role_rotation,
    SquadRole.starter => role_starter,
    SquadRole.star => role_star,
  };

  String lifestyleName(Lifestyle l) => switch (l) {
    Lifestyle.modest => lifestyle_modest,
    Lifestyle.comfortable => lifestyle_comfortable,
    Lifestyle.lavish => lifestyle_lavish,
  };

  String moneyKindName(MoneyKind k) => switch (k) {
    MoneyKind.wage => money_wage,
    MoneyKind.winBonus => money_winBonus,
    MoneyKind.goalBonus => money_goalBonus,
    MoneyKind.agentFee => money_agentFee,
    MoneyKind.living => money_living,
  };

  String agentLevelName(int level) => switch (level) {
    1 => agentLevel_1,
    2 => agentLevel_2,
    _ => agentLevel_3,
  };

  String tierName(int tier) => switch (tier) {
    1 => leagueTier1,
    2 => leagueTier2,
    3 => leagueTier3,
    4 => leagueTier4,
    _ => leagueTier5,
  };

  /// 1234567 -> "1.234.567 ₺" (eksi değerlerde "-").
  String money(int value) => moneyAmount(_grouped(value));

  String moneyWeek(int value) => moneyPerWeek(_grouped(value));

  static String _grouped(int value) {
    final digits = value.abs().toString();
    final buf = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}
