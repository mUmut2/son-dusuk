import '../../app/l10n/app_localizations.dart';
import '../../domain/achievements/achievements.dart';
import '../../domain/career/player_status.dart';
import '../../domain/national/national_career.dart';
import '../../domain/social/feed_models.dart';
import '../../domain/spending/spending_models.dart';
import '../event_texts.dart';
import '../l10n_labels.dart';

String _pick(String raw, int variant) {
  final list = raw.split('|');
  return list[variant % list.length];
}

/// Sosyal ağ akışı metinleri: ARB'deki `|` ile ayrılmış varyantlardan seçilir.
extension FeedTexts on AppLocalizations {
  String _postRaw(FeedKind k) => switch (k) {
    FeedKind.win => sm_post_win,
    FeedKind.loss => sm_post_loss,
    FeedKind.draw => sm_post_draw,
    FeedKind.scorer => sm_post_scorer,
    FeedKind.hatTrick => sm_post_hatTrick,
    FeedKind.star => sm_post_star,
    FeedKind.flop => sm_post_flop,
    FeedKind.benched => sm_post_benched,
    FeedKind.injury => sm_post_injury,
    FeedKind.signed => sm_post_signed,
    FeedKind.interview => sm_post_interview,
    FeedKind.achievement => sm_post_achievement,
    FeedKind.national => sm_post_national,
    FeedKind.shopping => sm_post_shopping,
    FeedKind.donation => sm_post_donation,
    FeedKind.betFined => sm_post_betFined,
    FeedKind.ownThanks => sm_post_ownThanks,
    FeedKind.ownFunny => sm_post_ownFunny,
    FeedKind.ownTraining => sm_post_ownTraining,
    FeedKind.ownSpicy => sm_post_ownSpicy,
  };

  String _namesRaw(FeedSource s) => switch (s) {
    FeedSource.fan => sm_names_fan,
    FeedSource.journalist => sm_names_journalist,
    FeedSource.teammate => sm_names_teammate,
    FeedSource.club => sm_names_club,
    FeedSource.meme => sm_names_meme,
    FeedSource.family => sm_names_family,
    FeedSource.you => sm_name_you,
  };

  String _commentRaw(CommentTone t) => switch (t) {
    CommentTone.praise => sm_comment_praise,
    CommentTone.joke => sm_comment_joke,
    CommentTone.jeer => sm_comment_jeer,
    CommentTone.support => sm_comment_support,
  };

  String feedSourceName(FeedSource s) => switch (s) {
    FeedSource.fan => feedSource_fan,
    FeedSource.journalist => feedSource_journalist,
    FeedSource.teammate => feedSource_teammate,
    FeedSource.club => feedSource_club,
    FeedSource.meme => feedSource_meme,
    FeedSource.family => feedSource_family,
    FeedSource.you => feedSource_you,
  };

  String feedOwnTitle(FeedKind k) => switch (k) {
    FeedKind.ownThanks => feedOwnTitle_ownThanks,
    FeedKind.ownFunny => feedOwnTitle_ownFunny,
    FeedKind.ownTraining => feedOwnTitle_ownTraining,
    _ => feedOwnTitle_ownSpicy,
  };

  String feedOwnDesc(FeedKind k) => switch (k) {
    FeedKind.ownThanks => feedOwnDesc_ownThanks,
    FeedKind.ownFunny => feedOwnDesc_ownFunny,
    FeedKind.ownTraining => feedOwnDesc_ownTraining,
    _ => feedOwnDesc_ownSpicy,
  };

  /// Gönderi sahibinin görünen adı.
  String feedAuthorName(FeedPost p) {
    if (p.source == FeedSource.you) return sm_name_you;
    final list = _namesRaw(p.source).split('|');
    return list[p.author % list.length];
  }

  String feedCommenterName(FeedComment c) {
    final list = sm_names_commenter.split('|');
    return list[c.author % list.length];
  }

  String feedCommentText(FeedComment c, String playerName) =>
      _pick(_commentRaw(c.tone), c.variant).replaceAll('%player%', playerName);

  /// Gönderi metni; [clubName] kulüp kimliğini ada çevirir.
  String feedPostText(
    FeedPost p, {
    required String playerName,
    required String Function(String id) clubName,
  }) {
    final q = p.params;
    var text = _pick(_postRaw(p.kind), p.variant)
        .replaceAll('%player%', playerName)
        .replaceAll('%opponent%', q['opponent'] ?? '')
        .replaceAll('%score%', q['score'] ?? '')
        .replaceAll('%goals%', q['goals'] ?? '');

    if (text.contains('%')) {
      text = switch (p.kind) {
        FeedKind.injury =>
          text
              .replaceAll(
                '%type%',
                injuryTypeName(
                  InjuryType.values.byName(q['type'] ?? InjuryType.muscle.name),
                ),
              )
              .replaceAll('%weeks%', q['weeks'] ?? ''),
        FeedKind.signed => text.replaceAll('%club%', clubName(q['club'] ?? '')),
        FeedKind.achievement => text.replaceAll(
          '%ach%',
          achievementTitle(
            Achievement.values.byName(q['id'] ?? Achievement.firstMatch.name),
          ),
        ),
        FeedKind.national => text.replaceAll(
          '%tournament%',
          tournamentName(
            TournamentKind.values.byName(
              q['kind'] ?? TournamentKind.world.name,
            ),
          ),
        ),
        FeedKind.interview => text.replaceAll('%headline%', _headline(p)),
        FeedKind.shopping => text.replaceAll(
          '%item%',
          propertyName(
            Property.values.byName(q['item'] ?? Property.watch.name),
          ),
        ),
        _ => text,
      };
    }
    return text;
  }

  String _headline(FeedPost p) {
    if (p.params['backfired'] == '1') return interviewBackfireHeadline;
    final choice = int.tryParse(p.params['choice'] ?? '') ?? 0;
    final heads = eventTexts(p.params['id'] ?? '', const {}).headlines;
    return choice < heads.length ? heads[choice] : '';
  }

  /// 1.234 -> "1,2 B", 3.400.000 -> "3,4 Mn".
  String feedCount(int n) {
    String short(double v, String unit) {
      final s = v.toStringAsFixed(1).replaceAll('.', ',');
      return '${s.endsWith(',0') ? s.substring(0, s.length - 2) : s} $unit';
    }

    if (n >= 1000000) return short(n / 1000000, feedCountMillion);
    if (n >= 1000) return short(n / 1000, feedCountThousand);
    return '$n';
  }
}
