import '../career/career_state.dart';
import '../career/week_report.dart';
import '../national/national_career.dart';
import '../social/event_models.dart';
import '../social/relationships.dart';
import '../social/social_engine.dart';

enum AchievementCategory { career, club, national, growth, wealth }

/// Başarımlar. Metinler ARB'de `ach_<ad>_title` / `ach_<ad>_desc` anahtarlarıyla.
enum Achievement {
  // Kariyer
  firstMatch(AchievementCategory.career),
  firstGoal(AchievementCategory.career),
  firstAssist(AchievementCategory.career),
  goals10(AchievementCategory.career),
  goals50(AchievementCategory.career),
  goals150(AchievementCategory.career),
  goals400(AchievementCategory.career),
  matches50(AchievementCategory.career),
  matches250(AchievementCategory.career),
  matches500(AchievementCategory.career),
  hatTrick(AchievementCategory.career),
  starPerformance(AchievementCategory.career),
  seasons10(AchievementCategory.career),
  veteran(AchievementCategory.career),
  // Kulüp
  firstTransfer(AchievementCategory.club),
  topLeague(AchievementCategory.club),
  leagueChampion(AchievementCategory.club),
  topLeagueChampion(AchievementCategory.club),
  loyal(AchievementCategory.club),
  agentTop(AchievementCategory.club),
  // Milli takım
  nationalDebut(AchievementCategory.national),
  nationalGoal(AchievementCategory.national),
  nationalFinal(AchievementCategory.national),
  continentalChampion(AchievementCategory.national),
  worldChampion(AchievementCategory.national),
  // Gelişim
  overall70(AchievementCategory.growth),
  overall80(AchievementCategory.growth),
  overall90(AchievementCategory.growth),
  fanIdol(AchievementCategory.growth),
  // Para
  comfortable(AchievementCategory.wealth),
  millionaire(AchievementCategory.wealth),
  tycoon(AchievementCategory.wealth);

  const Achievement(this.category);

  final AchievementCategory category;
}

class AchievementUpdate {
  const AchievementUpdate(this.state, this.unlocked);

  final CareerState state;

  /// Bu çağrıda yeni açılanlar.
  final List<Achievement> unlocked;

  List<WeekEvent> get events => [
    for (final a in unlocked)
      WeekEvent(WeekEventKind.achievement, detail: a.name),
  ];
}

/// Başarım koşulları ve kilit açma (saf Dart).
abstract final class AchievementEngine {
  static const int comfortableBalance = 100000;
  static const int millionaireBalance = 1000000;
  static const int tycoonBalance = 25000000;

  /// Açık olanları [CareerState.achievements]'a yazar.
  ///
  /// [tier]: oyuncunun şu anki kulübünün lig kademesi (kulübü yoksa null).
  /// [matchGoals] / [matchRating]: bu hafta oynanan maçın özeti (yoksa null).
  static AchievementUpdate sync(
    CareerState s, {
    int? tier,
    int? matchGoals,
    double? matchRating,
  }) {
    final opened = <Achievement>[];
    for (final a in Achievement.values) {
      if (s.achievements.containsKey(a.name)) continue;
      if (isMet(
        a,
        s,
        tier: tier,
        matchGoals: matchGoals,
        matchRating: matchRating,
      )) {
        opened.add(a);
      }
    }
    if (opened.isEmpty) return AchievementUpdate(s, const []);

    var news = s.news;
    for (final a in opened) {
      news = SocialEngine.addNews(
        news,
        NewsItem(
          kind: NewsKind.achievement,
          season: s.season,
          week: s.week,
          params: {'id': a.name},
        ),
      );
    }
    return AchievementUpdate(
      s.copyWith(
        achievements: {
          ...s.achievements,
          for (final a in opened) a.name: s.absoluteWeek,
        },
        news: news,
      ),
      opened,
    );
  }

  static bool isMet(
    Achievement a,
    CareerState s, {
    int? tier,
    int? matchGoals,
    double? matchRating,
  }) {
    final stats = s.stats;
    final nat = s.national;
    return switch (a) {
      Achievement.firstMatch => stats.matches >= 1,
      Achievement.firstGoal => stats.goals >= 1,
      Achievement.firstAssist => stats.assists >= 1,
      Achievement.goals10 => stats.goals >= 10,
      Achievement.goals50 => stats.goals >= 50,
      Achievement.goals150 => stats.goals >= 150,
      Achievement.goals400 => stats.goals >= 400,
      Achievement.matches50 => stats.matches >= 50,
      Achievement.matches250 => stats.matches >= 250,
      Achievement.matches500 => stats.matches >= 500,
      Achievement.hatTrick => (matchGoals ?? 0) >= 3,
      Achievement.starPerformance => (matchRating ?? 0) >= 9.8,
      Achievement.seasons10 => s.history.length >= 10,
      Achievement.veteran => s.player.age >= 35,
      Achievement.firstTransfer => stats.transfers >= 1,
      Achievement.topLeague => tier == 1,
      Achievement.leagueChampion => s.history.any((r) => r.champion),
      Achievement.topLeagueChampion => s.history.any(
        (r) => r.champion && r.tier == 1,
      ),
      Achievement.loyal => _loyal(s),
      Achievement.agentTop => s.agent?.level == 3,
      Achievement.nationalDebut => nat.caps >= 1,
      Achievement.nationalGoal => nat.goals >= 1,
      Achievement.nationalFinal => nat.past.any(
        (r) =>
            r.called &&
            (r.stage == TournamentStage.runnerUp ||
                r.stage == TournamentStage.champion),
      ),
      Achievement.continentalChampion => nat.past.any(
        (r) => r.isTitle && r.kind == TournamentKind.continental,
      ),
      Achievement.worldChampion => nat.past.any(
        (r) => r.isTitle && r.kind == TournamentKind.world,
      ),
      Achievement.overall70 => s.player.overall >= 70,
      Achievement.overall80 => s.player.overall >= 80,
      Achievement.overall90 => s.player.overall >= 90,
      Achievement.fanIdol => s.relations[Relation.fans] >= 80,
      Achievement.comfortable => s.finance.balance >= comfortableBalance,
      Achievement.millionaire => s.finance.balance >= millionaireBalance,
      Achievement.tycoon => s.finance.balance >= tycoonBalance,
    };
  }

  /// Aynı kulüpte arka arkaya 10 sezon.
  static bool _loyal(CareerState s) {
    const seasons = 10;
    if (s.history.length < seasons) return false;
    final last = s.history.sublist(s.history.length - seasons);
    final club = last.first.clubId;
    return club != null && last.every((r) => r.clubId == club);
  }
}
