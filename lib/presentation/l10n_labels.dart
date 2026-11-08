import '../app/l10n/app_localizations.dart';
import '../domain/career/difficulty.dart';
import '../domain/career/player_status.dart';
import '../domain/career/season_calendar.dart';
import '../domain/career/week_report.dart';
import '../domain/career/weekly_plan.dart';
import '../domain/player/attribute.dart';
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
  };

  String eventText(WeekEvent e) => switch (e.kind) {
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
  };
}
