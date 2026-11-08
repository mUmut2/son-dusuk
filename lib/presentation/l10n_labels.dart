import '../app/l10n/app_localizations.dart';
import '../domain/achievements/achievements.dart';
import '../domain/career/difficulty.dart';
import '../domain/career/retirement.dart';
import '../domain/career/player_status.dart';
import '../domain/career/season_calendar.dart';
import '../domain/career/week_report.dart';
import '../domain/career/weekly_plan.dart';
import '../domain/club/contract.dart';
import '../domain/club/finance.dart';
import '../domain/national/nation.dart';
import '../domain/national/national_engine.dart';
import '../domain/national/national_career.dart';
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
    WeekEventKind.nationalCalled => eventNationalCalled(
      tournamentName(TournamentKind.values.byName(e.detail!)),
      nationalRoleName(NationalRole.values.byName(e.detail2!)),
    ),
    WeekEventKind.nationalOmitted => eventNationalOmitted(
      tournamentName(TournamentKind.values.byName(e.detail!)),
    ),
    WeekEventKind.nationalMatch => _nationalMatchText(e),
    WeekEventKind.nationalOut => eventNationalOut(
      tournamentName(TournamentKind.values.byName(e.detail!)),
      stageResult(TournamentStage.values.byName(e.detail2!)),
    ),
    WeekEventKind.nationalRunnerUp => eventNationalRunnerUp(
      tournamentName(TournamentKind.values.byName(e.detail!)),
    ),
    WeekEventKind.nationalChampion => eventNationalChampion(
      tournamentName(TournamentKind.values.byName(e.detail!)),
    ),
    WeekEventKind.achievement => eventAchievement(
      achievementTitle(Achievement.values.byName(e.detail!)),
    ),
    WeekEventKind.retired => eventRetired,
  };

  String _nationalMatchText(WeekEvent e) {
    final parts = (e.detail2 ?? '').split('|');
    final round = roundName(e.weeks ?? 0);
    return parts.length > 1
        ? eventNationalMatchPens(
            round,
            NationalWorld.homeName,
            parts[0],
            e.detail ?? '',
            nationalPens(parts[1]),
          )
        : eventNationalMatch(
            round,
            NationalWorld.homeName,
            parts[0],
            e.detail ?? '',
          );
  }

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
  String newsText(
    NewsItem n,
    String Function(String id) clubName,
  ) => switch (n.kind) {
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
      injuryTypeName(InjuryType.values.byName(n.params['type'] ?? 'muscle')),
      n.params['weeks'] ?? '',
    ),
    NewsKind.national => newsNational(
      tournamentName(TournamentKind.values.byName(n.params['kind'] ?? 'world')),
      stageResult(
        TournamentStage.values.byName(
          n.params['stage'] ?? TournamentStage.roundOf16.name,
        ),
      ),
    ),
    NewsKind.achievement => newsAchievement(
      achievementTitle(
        Achievement.values.byName(n.params['id'] ?? 'firstMatch'),
      ),
    ),
    NewsKind.retired => newsRetired(n.params['age'] ?? ''),
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
    MoneyKind.nationalBonus => money_nationalBonus,
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

  String nationalDayText(NationalDay d, {String opponent = ''}) => switch (d) {
    NationalDay.none => '',
    NationalDay.notCalled => nationalNotCalledThisWeek,
    NationalDay.eliminated => nationalEliminatedThisWeek,
    NationalDay.injured => nationalInjuredThisWeek,
    NationalDay.benched => nationalBenchedThisWeek,
    NationalDay.play => nationalMatchThisWeek(opponent),
  };

  String tournamentName(TournamentKind k) => switch (k) {
    TournamentKind.continental => tournament_continental,
    TournamentKind.world => tournament_world,
  };

  String roundName(int round) => switch (round) {
    0 => round_0,
    1 => round_1,
    2 => round_2,
    _ => round_3,
  };

  String stageResult(TournamentStage s) => switch (s) {
    TournamentStage.roundOf16 => stageResult_roundOf16,
    TournamentStage.quarterFinal => stageResult_quarterFinal,
    TournamentStage.semiFinal => stageResult_semiFinal,
    TournamentStage.runnerUp => stageResult_runnerUp,
    TournamentStage.champion => stageResult_champion,
  };

  String nationalRoleName(NationalRole r) => switch (r) {
    NationalRole.starter => natRole_starter,
    NationalRole.rotation => natRole_rotation,
    NationalRole.reserve => natRole_reserve,
  };

  String legacyName(LegacyRank r) => switch (r) {
    LegacyRank.amateur => legacy_amateur,
    LegacyRank.local => legacy_local,
    LegacyRank.pro => legacy_pro,
    LegacyRank.star => legacy_star,
    LegacyRank.legend => legacy_legend,
  };

  String legacyBlurb(LegacyRank r) => switch (r) {
    LegacyRank.amateur => legacyBlurb_amateur,
    LegacyRank.local => legacyBlurb_local,
    LegacyRank.pro => legacyBlurb_pro,
    LegacyRank.star => legacyBlurb_star,
    LegacyRank.legend => legacyBlurb_legend,
  };

  String achievementCategoryName(AchievementCategory c) => switch (c) {
    AchievementCategory.career => achCategory_career,
    AchievementCategory.club => achCategory_club,
    AchievementCategory.national => achCategory_national,
    AchievementCategory.growth => achCategory_growth,
    AchievementCategory.wealth => achCategory_wealth,
  };

  String achievementTitle(Achievement a) => switch (a) {
    Achievement.firstMatch => ach_firstMatch_title,
    Achievement.firstGoal => ach_firstGoal_title,
    Achievement.firstAssist => ach_firstAssist_title,
    Achievement.goals10 => ach_goals10_title,
    Achievement.goals50 => ach_goals50_title,
    Achievement.goals150 => ach_goals150_title,
    Achievement.goals400 => ach_goals400_title,
    Achievement.matches50 => ach_matches50_title,
    Achievement.matches250 => ach_matches250_title,
    Achievement.matches500 => ach_matches500_title,
    Achievement.hatTrick => ach_hatTrick_title,
    Achievement.starPerformance => ach_starPerformance_title,
    Achievement.seasons10 => ach_seasons10_title,
    Achievement.veteran => ach_veteran_title,
    Achievement.firstTransfer => ach_firstTransfer_title,
    Achievement.topLeague => ach_topLeague_title,
    Achievement.leagueChampion => ach_leagueChampion_title,
    Achievement.topLeagueChampion => ach_topLeagueChampion_title,
    Achievement.loyal => ach_loyal_title,
    Achievement.agentTop => ach_agentTop_title,
    Achievement.nationalDebut => ach_nationalDebut_title,
    Achievement.nationalGoal => ach_nationalGoal_title,
    Achievement.nationalFinal => ach_nationalFinal_title,
    Achievement.continentalChampion => ach_continentalChampion_title,
    Achievement.worldChampion => ach_worldChampion_title,
    Achievement.overall70 => ach_overall70_title,
    Achievement.overall80 => ach_overall80_title,
    Achievement.overall90 => ach_overall90_title,
    Achievement.fanIdol => ach_fanIdol_title,
    Achievement.comfortable => ach_comfortable_title,
    Achievement.millionaire => ach_millionaire_title,
    Achievement.tycoon => ach_tycoon_title,
  };

  String achievementDesc(Achievement a) => switch (a) {
    Achievement.firstMatch => ach_firstMatch_desc,
    Achievement.firstGoal => ach_firstGoal_desc,
    Achievement.firstAssist => ach_firstAssist_desc,
    Achievement.goals10 => ach_goals10_desc,
    Achievement.goals50 => ach_goals50_desc,
    Achievement.goals150 => ach_goals150_desc,
    Achievement.goals400 => ach_goals400_desc,
    Achievement.matches50 => ach_matches50_desc,
    Achievement.matches250 => ach_matches250_desc,
    Achievement.matches500 => ach_matches500_desc,
    Achievement.hatTrick => ach_hatTrick_desc,
    Achievement.starPerformance => ach_starPerformance_desc,
    Achievement.seasons10 => ach_seasons10_desc,
    Achievement.veteran => ach_veteran_desc,
    Achievement.firstTransfer => ach_firstTransfer_desc,
    Achievement.topLeague => ach_topLeague_desc,
    Achievement.leagueChampion => ach_leagueChampion_desc,
    Achievement.topLeagueChampion => ach_topLeagueChampion_desc,
    Achievement.loyal => ach_loyal_desc,
    Achievement.agentTop => ach_agentTop_desc,
    Achievement.nationalDebut => ach_nationalDebut_desc,
    Achievement.nationalGoal => ach_nationalGoal_desc,
    Achievement.nationalFinal => ach_nationalFinal_desc,
    Achievement.continentalChampion => ach_continentalChampion_desc,
    Achievement.worldChampion => ach_worldChampion_desc,
    Achievement.overall70 => ach_overall70_desc,
    Achievement.overall80 => ach_overall80_desc,
    Achievement.overall90 => ach_overall90_desc,
    Achievement.fanIdol => ach_fanIdol_desc,
    Achievement.comfortable => ach_comfortable_desc,
    Achievement.millionaire => ach_millionaire_desc,
    Achievement.tycoon => ach_tycoon_desc,
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
