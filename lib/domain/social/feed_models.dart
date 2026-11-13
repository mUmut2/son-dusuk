/// Sosyal ağ akışındaki bir paylaşımın konusu. Metinler ARB'de `sm_post_<ad>`.
enum FeedKind {
  win,
  loss,
  draw,
  scorer,
  hatTrick,
  star,
  flop,
  benched,
  injury,
  signed,
  interview,
  achievement,
  national,
  shopping,
  donation,
  betFined,
  horseWin,
  rumor,
  hype,
  fanArt,
  streak,
  // Oyuncunun kendi paylaşımları
  ownThanks,
  ownFunny,
  ownTraining,
  ownSpicy;

  /// Oyuncunun kendi paylaşımı mı?
  bool get isOwn => index >= FeedKind.ownThanks.index;
}

/// Paylaşımı yapan hesabın türü (görünüm ve ARB isim listesi için).
enum FeedSource { fan, journalist, teammate, club, meme, family, you }

/// Yorumun havası.
enum CommentTone { praise, joke, jeer, support }

class FeedComment {
  const FeedComment({
    required this.author,
    required this.tone,
    required this.variant,
    required this.likes,
  });

  factory FeedComment.fromJson(Map<String, dynamic> json) => FeedComment(
    author: json['a'] as int,
    tone: CommentTone.values.byName(json['t'] as String),
    variant: json['v'] as int,
    likes: json['l'] as int,
  );

  /// Yazar adı ARB listesinden `author % uzunluk` ile seçilir.
  final int author;
  final CommentTone tone;

  /// Cümle varyantı; arayüz `variant % varyantSayısı` ile seçer.
  final int variant;
  final int likes;

  Map<String, dynamic> toJson() => {
    'a': author,
    't': tone.name,
    'v': variant,
    'l': likes,
  };
}

class FeedPost {
  const FeedPost({
    required this.kind,
    required this.source,
    required this.author,
    required this.variant,
    required this.season,
    required this.week,
    required this.likes,
    this.comments = const [],
    this.params = const {},
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) => FeedPost(
    kind: FeedKind.values.byName(json['kind'] as String),
    source: FeedSource.values.byName(json['source'] as String),
    author: json['author'] as int,
    variant: json['variant'] as int,
    season: json['season'] as int,
    week: json['week'] as int,
    likes: json['likes'] as int,
    comments: [
      for (final c in (json['comments'] as List<dynamic>? ?? const []))
        FeedComment.fromJson(c as Map<String, dynamic>),
    ],
    params: Map<String, String>.from(
      (json['params'] as Map<String, dynamic>?) ?? const {},
    ),
  );

  final FeedKind kind;
  final FeedSource source;
  final int author;
  final int variant;
  final int season;
  final int week;
  final int likes;
  final List<FeedComment> comments;

  /// Metne gömülen değerler: rakip, skor, gol, kulüp, başarım...
  final Map<String, String> params;

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'source': source.name,
    'author': author,
    'variant': variant,
    'season': season,
    'week': week,
    'likes': likes,
    'comments': [for (final c in comments) c.toJson()],
    'params': params,
  };
}

/// Oyuncunun sosyal ağ hesabı: takipçi sayısı ve akış (en yeni başta).
class SocialFeed {
  const SocialFeed({
    this.posts = const [],
    this.followers = startFollowers,
    this.lastOwnPostWeek = 0,
  });

  factory SocialFeed.fromJson(Map<String, dynamic> json) => SocialFeed(
    posts: [
      for (final p in (json['posts'] as List<dynamic>? ?? const []))
        FeedPost.fromJson(p as Map<String, dynamic>),
    ],
    followers: json['followers'] as int? ?? startFollowers,
    lastOwnPostWeek: json['lastOwnPostWeek'] as int? ?? 0,
  );

  static const int startFollowers = 150;

  final List<FeedPost> posts;
  final int followers;

  /// Oyuncunun en son paylaşım yaptığı mutlak hafta (haftada en çok 1).
  final int lastOwnPostWeek;

  SocialFeed copyWith({
    List<FeedPost>? posts,
    int? followers,
    int? lastOwnPostWeek,
  }) => SocialFeed(
    posts: posts ?? this.posts,
    followers: followers ?? this.followers,
    lastOwnPostWeek: lastOwnPostWeek ?? this.lastOwnPostWeek,
  );

  Map<String, dynamic> toJson() => {
    'posts': [for (final p in posts) p.toJson()],
    'followers': followers,
    'lastOwnPostWeek': lastOwnPostWeek,
  };
}
