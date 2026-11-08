import '../achievements/achievements.dart';
import '../league/club_world.dart';
import '../national/national_career.dart';
import '../social/event_models.dart';
import '../social/social_engine.dart';
import 'career_state.dart';
import 'legacy_balance.dart';
import 'season_record.dart';

/// Kariyerin genel değerlendirmesi (miras sıralaması).
enum LegacyRank { amateur, local, pro, star, legend }

/// Kariyer özeti ekranının rakamları.
class CareerSummary {
  const CareerSummary({
    required this.matches,
    required this.goals,
    required this.assists,
    required this.averageRating,
    required this.seasons,
    required this.clubs,
    required this.leagueTitles,
    required this.topLeagueTitles,
    required this.bestTier,
    required this.peakOverall,
    required this.caps,
    required this.nationalGoals,
    required this.nationalTitles,
    required this.nationalFinals,
    required this.achievements,
    required this.score,
    required this.rank,
  });

  final int matches;
  final int goals;
  final int assists;
  final double averageRating;
  final int seasons;
  final int clubs;
  final int leagueTitles;
  final int topLeagueTitles;

  /// Ulaşılan en üst lig kademesi (1 = en üst); hiç kulüp yoksa 0.
  final int bestTier;
  final int peakOverall;
  final int caps;
  final int nationalGoals;
  final int nationalTitles;
  final int nationalFinals;
  final int achievements;
  final double score;
  final LegacyRank rank;

  /// [tier]: oyuncunun şu anki kulübünün lig kademesi (yoksa null).
  static CareerSummary of(CareerState s, {int? tier}) {
    final history = s.history;
    final tiers = [
      for (final r in history)
        if (r.tier > 0) r.tier,
      ?tier,
    ];
    final bestTier = tiers.isEmpty ? 0 : tiers.reduce((a, b) => a < b ? a : b);
    final clubs = {
      for (final r in history)
        if (r.clubId != null) r.clubId!,
      if (s.contract != null) s.contract!.clubId,
    };
    final peak = [
      s.player.overall,
      for (final r in history) r.overall,
    ].reduce((a, b) => a > b ? a : b);
    final titles = history.where((r) => r.champion).length;
    final topTitles = history.where((r) => r.champion && r.tier == 1).length;
    final nat = s.national;
    final finals = nat.past
        .where(
          (r) =>
              r.called &&
              (r.stage == TournamentStage.runnerUp ||
                  r.stage == TournamentStage.champion),
        )
        .length;

    var score =
        s.stats.goals * LegacyBalance.perGoal +
        s.stats.assists * LegacyBalance.perAssist +
        s.stats.matches * LegacyBalance.perMatch +
        nat.caps * LegacyBalance.perCap +
        nat.goals * LegacyBalance.perNationalGoal +
        topTitles * LegacyBalance.topLeagueTitle +
        (titles - topTitles) * LegacyBalance.otherTitle +
        nat.titles * LegacyBalance.nationalTitle +
        finals * LegacyBalance.nationalFinal +
        (peak - 60).clamp(0, 99) * LegacyBalance.perPeakPoint +
        s.achievements.length * LegacyBalance.perAchievement;
    if (bestTier > 0) {
      score += (5 - bestTier) * LegacyBalance.perTierStep;
    }

    var rank = LegacyRank.amateur;
    for (var i = 0; i < LegacyRank.values.length; i++) {
      if (score >= LegacyBalance.rankThresholds[i]) rank = LegacyRank.values[i];
    }

    return CareerSummary(
      matches: s.stats.matches,
      goals: s.stats.goals,
      assists: s.stats.assists,
      averageRating: s.stats.averageRating,
      seasons: history.length,
      clubs: clubs.length,
      leagueTitles: titles,
      topLeagueTitles: topTitles,
      bestTier: bestTier,
      peakOverall: peak,
      caps: nat.caps,
      nationalGoals: nat.goals,
      nationalTitles: nat.titles,
      nationalFinals: finals,
      achievements: s.achievements.length,
      score: score,
      rank: rank,
    );
  }
}

/// Emeklilik (saf Dart).
abstract final class Retirement {
  static bool canRetire(CareerState s) =>
      !s.retired && s.player.age >= LegacyBalance.voluntaryAge;

  static bool mustRetire(CareerState s) =>
      !s.retired && s.player.age >= LegacyBalance.forcedAge;

  /// Kariyeri bitirir: yarım kalan sezon geçmişe yazılır, son başarımlar açılır.
  static CareerState retire(CareerState s) {
    if (s.retired) return s;
    final world = ClubWorld(s.worldSeed);
    final clubId = s.contract?.clubId;
    final tier = clubId == null ? 0 : world.tierOf(clubId);

    var next = s;
    if (s.seasonStats.matches > 0) {
      next = next.copyWith(
        history: [
          ...next.history,
          SeasonRecord(
            season: s.season,
            age: s.player.age,
            overall: s.player.overall,
            clubId: clubId,
            tier: tier,
            matches: s.seasonStats.matches,
            goals: s.seasonStats.goals,
            assists: s.seasonStats.assists,
            averageRating: s.seasonStats.averageRating,
          ),
        ],
      );
    }
    next = next.copyWith(
      retired: true,
      offers: const [],
      pendingEvents: const [],
      news: SocialEngine.addNews(
        next.news,
        NewsItem(
          kind: NewsKind.retired,
          season: s.season,
          week: s.week,
          params: {'age': '${s.player.age}'},
        ),
      ),
    );
    return AchievementEngine.sync(next, tier: tier == 0 ? null : tier).state;
  }
}
