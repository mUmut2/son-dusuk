import '../../core/game_random.dart';
import '../career/career_state.dart';
import 'event_models.dart';
import 'feed_balance.dart';
import 'feed_models.dart';
import 'relationships.dart';
import 'social_balance.dart';

/// Hafta içinde oynanan maçın akışı ilgilendiren özeti.
class FeedWeekInput {
  const FeedWeekInput({
    this.rating,
    this.goals = 0,
    this.won = false,
    this.lost = false,
    this.scoreFor = 0,
    this.scoreAgainst = 0,
    this.opponent = '',
    this.benched = false,
  });

  final double? rating;
  final int goals;
  final bool won;
  final bool lost;
  final int scoreFor;
  final int scoreAgainst;
  final String opponent;
  final bool benched;

  bool get played => rating != null;
}

/// Sosyal ağ akışı: paylaşımlar, yorumlar, takipçiler (saf Dart, seed'li).
abstract final class FeedEngine {
  static const Map<FeedKind, List<FeedSource>> _sources = {
    FeedKind.win: [FeedSource.fan, FeedSource.meme, FeedSource.club],
    FeedKind.loss: [FeedSource.fan, FeedSource.meme],
    FeedKind.draw: [FeedSource.fan, FeedSource.club],
    FeedKind.scorer: [FeedSource.fan, FeedSource.meme, FeedSource.journalist],
    FeedKind.hatTrick: [FeedSource.journalist, FeedSource.fan, FeedSource.meme],
    FeedKind.star: [FeedSource.journalist, FeedSource.fan],
    FeedKind.flop: [FeedSource.fan, FeedSource.meme],
    FeedKind.benched: [FeedSource.fan, FeedSource.journalist],
    FeedKind.injury: [FeedSource.club, FeedSource.teammate, FeedSource.family],
    FeedKind.signed: [FeedSource.club, FeedSource.journalist],
    FeedKind.interview: [FeedSource.journalist],
    FeedKind.achievement: [FeedSource.club, FeedSource.fan],
    FeedKind.national: [FeedSource.journalist, FeedSource.club],
    FeedKind.shopping: [FeedSource.meme, FeedSource.fan, FeedSource.journalist],
    FeedKind.donation: [FeedSource.fan, FeedSource.club, FeedSource.journalist],
    FeedKind.betFined: [FeedSource.journalist, FeedSource.fan, FeedSource.club],
    FeedKind.horseWin: [FeedSource.meme, FeedSource.fan, FeedSource.journalist],
  };

  /// Bu hafta oyuncu paylaşım yapabilir mi (haftada bir).
  static bool canPostOwn(CareerState s) =>
      !s.retired && s.feed.lastOwnPostWeek != s.absoluteWeek;

  // --- Haftalık akış ---

  /// [prev]: haftanın başı, [next]: haber ve ilişkiler işlendikten sonraki durum.
  static CareerState afterWeek(
    CareerState prev,
    CareerState next,
    FeedWeekInput input,
    GameRandom random,
  ) {
    final fans = next.relations[Relation.fans];
    final followers = next.feed.followers;
    final posts = <FeedPost>[];
    var growth = FeedBalance.growthBase;

    FeedPost make(FeedKind kind, Map<String, String> params) => _post(
      kind: kind,
      source: random.pick(_sources[kind]!),
      season: prev.season,
      week: prev.week,
      followers: followers,
      fans: fans,
      params: params,
      random: random,
    );

    if (input.played) {
      final params = {
        'opponent': input.opponent,
        'score': '${input.scoreFor}-${input.scoreAgainst}',
        'goals': '${input.goals}',
      };
      final result = input.won
          ? FeedKind.win
          : input.lost
          ? FeedKind.loss
          : FeedKind.draw;
      final rating = input.rating!;
      final FeedKind main;
      if (input.goals >= 3) {
        main = FeedKind.hatTrick;
      } else if (rating >= SocialBalance.notableRatingHigh) {
        main = FeedKind.star;
      } else if (rating <= SocialBalance.notableRatingLow) {
        main = FeedKind.flop;
      } else if (input.goals >= 1) {
        main = FeedKind.scorer;
      } else {
        main = result;
      }
      posts.add(make(main, params));
      if (main != result && random.chance(FeedBalance.extraPostChance)) {
        posts.add(make(result, params));
      }

      if (input.won) growth += FeedBalance.growthWin;
      if (input.lost) growth += FeedBalance.growthLoss;
      growth +=
          FeedBalance.growthPerGoal *
          input.goals.clamp(0, FeedBalance.growthGoalCap);
      if (main == FeedKind.star || main == FeedKind.hatTrick) {
        growth += FeedBalance.growthStar;
      }
      if (main == FeedKind.flop) growth += FeedBalance.growthFlop;
    } else if (input.benched) {
      posts.add(make(FeedKind.benched, {'opponent': input.opponent}));
    }

    // Bu hafta eklenen haberler (imza, sakatlık, başarım, milli takım).
    for (final n in _freshNews(prev, next)) {
      switch (n.kind) {
        case NewsKind.signed:
          posts.add(make(FeedKind.signed, n.params));
          growth += FeedBalance.growthSigned;
        case NewsKind.injury:
          posts.add(make(FeedKind.injury, n.params));
        case NewsKind.achievement:
          posts.add(make(FeedKind.achievement, n.params));
          growth += FeedBalance.growthAchievement;
        case NewsKind.national:
          posts.add(make(FeedKind.national, n.params));
          growth += FeedBalance.growthNational;
        case NewsKind.match:
        case NewsKind.event:
        case NewsKind.retired:
        case NewsKind.betting:
          break;
      }
    }

    return _commit(next, posts, growth, random);
  }

  /// Oyuncunun bir davranışına (alışveriş, bağış, ceza) hesaplardan tepki.
  static CareerState react(
    CareerState s,
    FeedKind kind,
    Map<String, String> params,
    GameRandom random, {
    double growth = 0,
  }) {
    final post = _post(
      kind: kind,
      source: random.pick(_sources[kind]!),
      season: s.season,
      week: s.week,
      followers: s.feed.followers,
      fans: s.relations[Relation.fans],
      params: params,
      random: random,
      backfired: kind == FeedKind.betFined,
    );
    return _commit(s, [post], growth, random);
  }

  /// Cevaplanan röportajın gazetedeki yankısı.
  static CareerState interviewPost(
    CareerState s,
    String eventId,
    int choice,
    bool backfired,
    GameRandom random,
  ) {
    final post = _post(
      kind: FeedKind.interview,
      source: FeedSource.journalist,
      season: s.season,
      week: s.week,
      followers: s.feed.followers,
      fans: s.relations[Relation.fans],
      params: {
        'id': eventId,
        'choice': '$choice',
        if (backfired) 'backfired': '1',
      },
      random: random,
      backfired: backfired,
    );
    return _commit(
      s,
      [post],
      backfired ? FeedBalance.growthFlop : FeedBalance.growthInterview,
      random,
    );
  }

  /// Oyuncunun kendi paylaşımı: akışa girer, takipçi ve ilişkiler değişir.
  /// [effectApplied] paylaşımın ilişki/moral etkisi uygulanmış durumdur.
  static CareerState ownPost(
    CareerState effectApplied,
    FeedKind kind,
    bool backfired,
    GameRandom random,
  ) {
    assert(kind.isOwn, 'ownPost yalnızca kendi paylaşım türleriyle çağrılır');
    final rule = FeedBalance.ownRules[kind]!;
    final post = _post(
      kind: kind,
      source: FeedSource.you,
      season: effectApplied.season,
      week: effectApplied.week,
      followers: effectApplied.feed.followers,
      fans: effectApplied.relations[Relation.fans],
      params: {if (backfired) 'backfired': '1'},
      random: random,
      backfired: backfired,
    );
    final committed = _commit(
      effectApplied,
      [post],
      backfired ? -rule.altFollowerLoss : rule.followerGain,
      random,
    );
    return committed.copyWith(
      feed: committed.feed.copyWith(
        lastOwnPostWeek: effectApplied.absoluteWeek,
      ),
    );
  }

  // --- İç yardımcılar ---

  /// [next] haberlerinden bu haftanın yeni eklenenleri (yeniden eskiye).
  static List<NewsItem> _freshNews(CareerState prev, CareerState next) {
    final fresh = <NewsItem>[];
    for (final n in next.news) {
      if (prev.news.isNotEmpty && identical(n, prev.news.first)) break;
      fresh.add(n);
    }
    return fresh;
  }

  static CareerState _commit(
    CareerState s,
    List<FeedPost> posts,
    double growth,
    GameRandom random,
  ) {
    final followers = s.feed.followers;
    final room = 1 - followers / FeedBalance.maxFollowers;
    var delta = followers * growth * room;
    if (growth > 0 && delta < 1) delta = 1;
    final next = (followers + delta).round().clamp(0, FeedBalance.maxFollowers);
    return s.copyWith(
      feed: s.feed.copyWith(
        followers: next,
        posts: [...posts, ...s.feed.posts].take(FeedBalance.postCap).toList(),
      ),
    );
  }

  static FeedPost _post({
    required FeedKind kind,
    required FeedSource source,
    required int season,
    required int week,
    required int followers,
    required double fans,
    required Map<String, String> params,
    required GameRandom random,
    bool backfired = false,
  }) {
    final fanFactor = 0.7 + 0.6 * fans / 100;
    final likes =
        (followers *
                FeedBalance.likeRate *
                (0.5 + random.nextDouble()) *
                FeedBalance.likeWeight[kind]! *
                fanFactor)
            .round();
    final safeLikes = likes < FeedBalance.minLikes
        ? FeedBalance.minLikes + random.nextInt(3)
        : likes;
    final count = followers < FeedBalance.smallAccountFollowers
        ? random.range(0, 2)
        : random.range(1, FeedBalance.maxComments);
    return FeedPost(
      kind: kind,
      source: source,
      author: random.nextInt(1000),
      variant: random.nextInt(1000),
      season: season,
      week: week,
      likes: safeLikes,
      params: params,
      comments: [
        for (var i = 0; i < count; i++)
          FeedComment(
            author: random.nextInt(1000),
            tone: _tone(kind, fans, backfired, random),
            variant: random.nextInt(1000),
            likes: random.range(0, (safeLikes ~/ 3).clamp(1, 1 << 30)),
          ),
      ],
    );
  }

  static CommentTone _tone(
    FeedKind kind,
    double fans,
    bool backfired,
    GameRandom random,
  ) {
    final mix = backfired
        ? const [0.05, 0.1, 0.8, 0.05]
        : [...FeedBalance.toneMix[kind]!];
    if (!backfired) {
      final shift = (fans - 50) / 50 * FeedBalance.fanMoodShift;
      mix[0] = (mix[0] + shift).clamp(0.0, 1.0);
      mix[2] = (mix[2] - shift).clamp(0.0, 1.0);
    }
    final total = mix.fold(0.0, (a, b) => a + b);
    var roll = random.nextDouble() * total;
    for (var i = 0; i < mix.length; i++) {
      roll -= mix[i];
      if (roll <= 0) return CommentTone.values[i];
    }
    return CommentTone.praise;
  }
}
