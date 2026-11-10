import '../../app/l10n/app_localizations.dart';
import '../../domain/match/commentary.dart';
import '../../domain/match/match_simulator.dart';

/// Spiker satırlarının Türkçe metni. Her tür ARB'de tek bir `cm_<tür>`
/// anahtarıdır; cümle varyantları `|` ile ayrılır.
extension CommentaryTexts on AppLocalizations {
  String commentaryRaw(CommentaryKind kind) => switch (kind) {
    CommentaryKind.kickoff => cm_kickoff,
    CommentaryKind.halftime => cm_halftime,
    CommentaryKind.fulltimeWin => cm_fulltimeWin,
    CommentaryKind.fulltimeLoss => cm_fulltimeLoss,
    CommentaryKind.fulltimeDraw => cm_fulltimeDraw,
    CommentaryKind.midfield => cm_midfield,
    CommentaryKind.corner => cm_corner,
    CommentaryKind.foul => cm_foul,
    CommentaryKind.offside => cm_offside,
    CommentaryKind.wide => cm_wide,
    CommentaryKind.keeperSave => cm_keeperSave,
    CommentaryKind.crowd => cm_crowd,
    CommentaryKind.teamGoal => cm_teamGoal,
    CommentaryKind.oppGoal => cm_oppGoal,
    CommentaryKind.introShot => cm_introShot,
    CommentaryKind.introOneOnOne => cm_introOneOnOne,
    CommentaryKind.introHeader => cm_introHeader,
    CommentaryKind.introFreeKick => cm_introFreeKick,
    CommentaryKind.introPenalty => cm_introPenalty,
    CommentaryKind.introKeyPass => cm_introKeyPass,
    CommentaryKind.introDribble => cm_introDribble,
    CommentaryKind.introTackle => cm_introTackle,
    CommentaryKind.playerGoal => cm_playerGoal,
    CommentaryKind.playerAssist => cm_playerAssist,
    CommentaryKind.conceded => cm_conceded,
    CommentaryKind.missShot => cm_missShot,
    CommentaryKind.missPlay => cm_missPlay,
    CommentaryKind.tackleOk => cm_tackleOk,
  };

  /// Türün tüm cümleleri (yer tutucular çözülmemiş).
  List<String> commentaryVariants(CommentaryKind kind) =>
      commentaryRaw(kind).split('|');

  /// Satırın ekrandaki metni. `%team%` satırın takımı, `%other%` rakibi,
  /// `%player%` oyuncunun adıdır.
  String commentary(
    CommentaryLine line, {
    required String home,
    required String away,
    required String player,
  }) {
    final team = line.side == Side.home ? home : away;
    final other = line.side == Side.home ? away : home;
    final variants = commentaryVariants(line.kind);
    return variants[line.variant % variants.length]
        .replaceAll('%team%', team)
        .replaceAll('%other%', other)
        .replaceAll('%player%', player);
  }
}
