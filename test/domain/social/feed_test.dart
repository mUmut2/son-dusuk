import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/app/l10n/app_localizations.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/domain/social/event_models.dart';
import 'package:son_dusuk/domain/social/feed_balance.dart';
import 'package:son_dusuk/domain/social/feed_engine.dart';
import 'package:son_dusuk/domain/social/feed_models.dart';
import 'package:son_dusuk/domain/social/relationships.dart';
import 'package:son_dusuk/domain/social/social_engine.dart';
import 'package:son_dusuk/presentation/social/feed_texts.dart';

CareerState newCareer({int week = 10}) => CareerFactory.create(
  PlayerFactory.create(
    name: 'Deniz',
    birthplace: 'Bursa',
    position: PlayerPosition.forward,
    foot: PreferredFoot.right,
    appearance: const Appearance(),
    random: GameRandom(1),
  ),
  GameRandom(1),
).copyWith(week: week);

const winWeek = FeedWeekInput(
  rating: 7,
  goals: 1,
  won: true,
  scoreFor: 2,
  scoreAgainst: 1,
  opponent: 'Rakip SK',
);

void main() {
  group('akış modeli', () {
    test('JSON gidiş-dönüş', () {
      final s = FeedEngine.afterWeek(
        newCareer(),
        newCareer(),
        winWeek,
        GameRandom(3),
      );
      expect(s.feed.posts, isNotEmpty);
      final back = SocialFeed.fromJson(
        jsonDecode(jsonEncode(s.feed.toJson())) as Map<String, dynamic>,
      );
      expect(back.followers, s.feed.followers);
      expect(back.posts.length, s.feed.posts.length);
      expect(back.posts.first.kind, s.feed.posts.first.kind);
      expect(
        back.posts.first.comments.length,
        s.feed.posts.first.comments.length,
      );
    });

    test('eski kayıt (feed alanı yok) boş akışla açılır', () {
      final json = newCareer().toJson()..remove('feed');
      final loaded = CareerState.fromJson(json);
      expect(loaded.feed.posts, isEmpty);
      expect(loaded.feed.followers, SocialFeed.startFollowers);
    });
  });

  group('haftalık akış', () {
    test('aynı seed aynı akışı üretir', () {
      final a = FeedEngine.afterWeek(
        newCareer(),
        newCareer(),
        winWeek,
        GameRandom(7),
      );
      final b = FeedEngine.afterWeek(
        newCareer(),
        newCareer(),
        winWeek,
        GameRandom(7),
      );
      expect(jsonEncode(a.feed.toJson()), jsonEncode(b.feed.toJson()));
    });

    test('maç türüne göre ana paylaşım seçilir', () {
      FeedKind mainOf(FeedWeekInput i) => FeedEngine.afterWeek(
        newCareer(),
        newCareer(),
        i,
        GameRandom(1),
      ).feed.posts.first.kind;

      expect(
        mainOf(
          const FeedWeekInput(rating: 9, goals: 3, won: true, scoreFor: 3),
        ),
        FeedKind.hatTrick,
      );
      expect(
        mainOf(const FeedWeekInput(rating: 8, goals: 0, won: true)),
        FeedKind.star,
      );
      expect(mainOf(const FeedWeekInput(rating: 4, lost: true)), FeedKind.flop);
      expect(
        mainOf(const FeedWeekInput(rating: 6.5, goals: 1, won: true)),
        FeedKind.scorer,
      );
      expect(mainOf(const FeedWeekInput(rating: 6.5, won: true)), FeedKind.win);
      expect(
        mainOf(const FeedWeekInput(rating: 6.5, lost: true)),
        FeedKind.loss,
      );
      expect(mainOf(const FeedWeekInput(rating: 6.5)), FeedKind.draw);
      expect(
        mainOf(const FeedWeekInput(benched: true, opponent: 'X')),
        FeedKind.benched,
      );
    });

    test('maçsız sessiz haftada en çok bir gündem paylaşımı gelir', () {
      const quiet = {FeedKind.rumor, FeedKind.hype, FeedKind.fanArt};
      var withPost = 0;
      for (var seed = 0; seed < 100; seed++) {
        final s = FeedEngine.afterWeek(
          newCareer(),
          newCareer(),
          const FeedWeekInput(),
          GameRandom(seed),
        );
        expect(s.feed.posts.length, lessThanOrEqualTo(1));
        for (final p in s.feed.posts) {
          expect(quiet, contains(p.kind));
        }
        withPost += s.feed.posts.length;
      }
      // Olasılık yaklaşık %70: hem çoğu hafta hem de bazı haftalar boş.
      expect(withPost, greaterThan(50));
      expect(withPost, lessThan(95));
    });

    test('akış sınırı aşılmaz ve en yeni başta', () {
      var s = newCareer();
      final random = GameRandom(2);
      for (var i = 0; i < 60; i++) {
        s = FeedEngine.afterWeek(s, s, winWeek, random);
      }
      expect(s.feed.posts.length, lessThanOrEqualTo(FeedBalance.postCap));
    });

    test('yorum ve beğeni sınırlar içinde, konu doğru', () {
      var s = newCareer();
      final random = GameRandom(5);
      for (var i = 0; i < 40; i++) {
        s = FeedEngine.afterWeek(s, s, winWeek, random);
      }
      for (final p in s.feed.posts) {
        expect(p.likes, greaterThanOrEqualTo(FeedBalance.minLikes));
        expect(p.comments.length, lessThanOrEqualTo(FeedBalance.maxComments));
        for (final c in p.comments) {
          expect(c.likes, greaterThanOrEqualTo(0));
        }
      }
    });

    test('galibiyetler takipçiyi büyütür, yenilgiler daha az büyütür', () {
      int run(FeedWeekInput i) {
        var s = newCareer();
        final random = GameRandom(9);
        for (var k = 0; k < 30; k++) {
          s = FeedEngine.afterWeek(s, s, i, random);
        }
        return s.feed.followers;
      }

      final good = run(
        const FeedWeekInput(rating: 8, goals: 2, won: true, scoreFor: 3),
      );
      final bad = run(const FeedWeekInput(rating: 4, lost: true));
      expect(good, greaterThan(SocialFeed.startFollowers));
      expect(good, greaterThan(bad));
      expect(bad, lessThan(good));
    });

    test('takipçi tavanı aşılmaz', () {
      var s = newCareer().copyWith(
        feed: const SocialFeed(followers: FeedBalance.maxFollowers),
      );
      final random = GameRandom(1);
      for (var i = 0; i < 20; i++) {
        s = FeedEngine.afterWeek(s, s, winWeek, random);
      }
      expect(s.feed.followers, lessThanOrEqualTo(FeedBalance.maxFollowers));
    });

    test('yeni haberler (imza, başarım) paylaşıma dönüşür', () {
      final prev = newCareer();
      final next = prev.copyWith(
        news: SocialEngine.addNews(
          SocialEngine.addNews(
            prev.news,
            const NewsItem(
              kind: NewsKind.signed,
              season: 1,
              week: 10,
              params: {'club': 'x'},
            ),
          ),
          const NewsItem(
            kind: NewsKind.achievement,
            season: 1,
            week: 10,
            params: {'id': 'firstGoal'},
          ),
        ),
      );
      final s = FeedEngine.afterWeek(
        prev,
        next,
        const FeedWeekInput(),
        GameRandom(4),
      );
      final kinds = s.feed.posts.map((p) => p.kind).toSet();
      expect(kinds, containsAll([FeedKind.signed, FeedKind.achievement]));
    });

    test('taraftar ilişkisi yorumların havasını değiştirir', () {
      double jeerShare(double fans) {
        var jeer = 0;
        var total = 0;
        final random = GameRandom(11);
        var s = newCareer().copyWith(
          relations: const Relationships().add({Relation.fans: fans - 50}),
          feed: const SocialFeed(followers: 5000),
        );
        for (var i = 0; i < 60; i++) {
          s = FeedEngine.afterWeek(
            s,
            s,
            const FeedWeekInput(rating: 6.5, goals: 1, won: true),
            random,
          );
        }
        for (final p in s.feed.posts) {
          for (final c in p.comments) {
            total++;
            if (c.tone == CommentTone.jeer) jeer++;
          }
        }
        return jeer / total;
      }

      expect(jeerShare(10), greaterThan(jeerShare(95)));
    });
  });

  group('röportaj yankısı', () {
    test('cevaplanan röportaj akışa gazete paylaşımı ekler', () {
      final s = newCareer();
      final p = PendingEvent(
        id: 'pressWin',
        createdAt: s.absoluteWeek,
        expiresAt: s.absoluteWeek + 2,
      );
      final r = SocialEngine.resolve(
        s.copyWith(pendingEvents: [p]),
        p,
        0,
        GameRandom(1),
      );
      final post = r.state.feed.posts.first;
      expect(post.kind, FeedKind.interview);
      expect(post.params['id'], 'pressWin');
      expect(post.params['choice'], '0');
    });

    test('röportaj dışı olaylar akışa yazmaz', () {
      final s = newCareer();
      final p = PendingEvent(
        id: 'familyDinner',
        createdAt: s.absoluteWeek,
        expiresAt: s.absoluteWeek + 5,
      );
      final r = SocialEngine.resolve(
        s.copyWith(pendingEvents: [p]),
        p,
        0,
        GameRandom(1),
      );
      expect(r.state.feed.posts, isEmpty);
    });
  });

  group('oyuncunun kendi paylaşımı', () {
    test('haftada bir kez; ertesi hafta tekrar açılır', () {
      final s = newCareer();
      final first = SocialEngine.postToFeed(
        s,
        FeedKind.ownThanks,
        GameRandom(1),
      );
      expect(first, isNotNull);
      expect(first!.state.feed.posts.first.kind, FeedKind.ownThanks);
      expect(first.state.feed.posts.first.source, FeedSource.you);
      expect(FeedEngine.canPostOwn(first.state), isFalse);
      expect(
        SocialEngine.postToFeed(first.state, FeedKind.ownFunny, GameRandom(1)),
        isNull,
      );
      final nextWeek = first.state.copyWith(week: first.state.week + 1);
      expect(FeedEngine.canPostOwn(nextWeek), isTrue);
    });

    test('oyuncu dışı türler reddedilir', () {
      expect(
        SocialEngine.postToFeed(newCareer(), FeedKind.win, GameRandom(1)),
        isNull,
      );
    });

    test('güvenli paylaşım ters tepmez, riskli bazen ters tepti', () {
      var spicyBackfires = 0;
      for (var seed = 0; seed < 200; seed++) {
        final thanks = SocialEngine.postToFeed(
          newCareer(),
          FeedKind.ownThanks,
          GameRandom(seed),
        )!;
        expect(thanks.backfired, isFalse);
        final spicy = SocialEngine.postToFeed(
          newCareer(),
          FeedKind.ownSpicy,
          GameRandom(seed),
        )!;
        if (spicy.backfired) spicyBackfires++;
      }
      expect(spicyBackfires, greaterThan(30));
      expect(spicyBackfires, lessThan(120));
    });

    test('ters tepme ilişkileri düşürür, başarı yükseltir', () {
      CareerState? ok;
      CareerState? bad;
      for (var seed = 0; seed < 100 && (ok == null || bad == null); seed++) {
        final r = SocialEngine.postToFeed(
          newCareer(),
          FeedKind.ownSpicy,
          GameRandom(seed),
        )!;
        if (r.backfired) {
          bad ??= r.state;
        } else {
          ok ??= r.state;
        }
      }
      final base = newCareer();
      expect(
        ok!.relations[Relation.media],
        greaterThan(base.relations[Relation.media]),
      );
      expect(
        bad!.relations[Relation.coach],
        lessThan(base.relations[Relation.coach]),
      );
      expect(bad.feed.posts.first.params['backfired'], '1');
      expect(ok.feed.followers, greaterThan(base.feed.followers));
      expect(bad.feed.followers, lessThan(base.feed.followers));
    });
  });

  group('metinler', () {
    test(
      'her paylaşım türü ve yorum havası için yeterli varyant var',
      () async {
        final l10n = await AppLocalizations.delegate.load(const Locale('tr'));
        for (final k in FeedKind.values) {
          final raw = switch (k) {
            FeedKind.win => l10n.sm_post_win,
            FeedKind.loss => l10n.sm_post_loss,
            FeedKind.draw => l10n.sm_post_draw,
            FeedKind.scorer => l10n.sm_post_scorer,
            FeedKind.hatTrick => l10n.sm_post_hatTrick,
            FeedKind.star => l10n.sm_post_star,
            FeedKind.flop => l10n.sm_post_flop,
            FeedKind.benched => l10n.sm_post_benched,
            FeedKind.injury => l10n.sm_post_injury,
            FeedKind.signed => l10n.sm_post_signed,
            FeedKind.interview => l10n.sm_post_interview,
            FeedKind.achievement => l10n.sm_post_achievement,
            FeedKind.national => l10n.sm_post_national,
            FeedKind.shopping => l10n.sm_post_shopping,
            FeedKind.donation => l10n.sm_post_donation,
            FeedKind.betFined => l10n.sm_post_betFined,
            FeedKind.horseWin => l10n.sm_post_horseWin,
            FeedKind.rumor => l10n.sm_post_rumor,
            FeedKind.hype => l10n.sm_post_hype,
            FeedKind.fanArt => l10n.sm_post_fanArt,
            FeedKind.streak => l10n.sm_post_streak,
            FeedKind.ownThanks => l10n.sm_post_ownThanks,
            FeedKind.ownFunny => l10n.sm_post_ownFunny,
            FeedKind.ownTraining => l10n.sm_post_ownTraining,
            FeedKind.ownSpicy => l10n.sm_post_ownSpicy,
          };
          expect(
            raw.split('|').length,
            greaterThanOrEqualTo(3),
            reason: k.name,
          );
          for (final v in raw.split('|')) {
            expect(v.trim(), isNotEmpty, reason: k.name);
            expect(v.contains('. dakika'), isFalse, reason: k.name);
          }
        }
        for (final raw in [
          l10n.sm_comment_praise,
          l10n.sm_comment_joke,
          l10n.sm_comment_jeer,
          l10n.sm_comment_support,
        ]) {
          expect(raw.split('|').length, greaterThanOrEqualTo(8));
        }
        for (final s in FeedSource.values) {
          expect(l10n.feedSourceName(s), isNotEmpty);
        }
      },
    );

    test('hiçbir paylaşım çözümlenmemiş yer tutucu bırakmaz', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('tr'));
      const params = {
        'opponent': 'Rakip SK',
        'score': '2-1',
        'goals': '2',
        'type': 'muscle',
        'weeks': '3',
        'club': 'x',
        'id': 'firstGoal',
        'kind': 'world',
        'choice': '0',
        'item': 'car',
        'horse': '3',
        'streak': '5',
      };
      for (final k in FeedKind.values) {
        final p = k == FeedKind.interview
            ? const {'id': 'pressWin', 'choice': '1'}
            : params;
        for (var v = 0; v < 6; v++) {
          final text = l10n.feedPostText(
            FeedPost(
              kind: k,
              source: FeedSource.fan,
              author: v,
              variant: v,
              season: 1,
              week: 1,
              likes: 1,
              params: p,
            ),
            playerName: 'Deniz',
            clubName: (_) => 'Kulüp A',
          );
          expect(text, isNotEmpty, reason: '${k.name}/$v');
          expect(text.contains('%'), isFalse, reason: '${k.name}/$v: $text');
        }
      }
      for (final t in CommentTone.values) {
        for (var v = 0; v < 12; v++) {
          final text = l10n.feedCommentText(
            FeedComment(author: v, tone: t, variant: v, likes: 0),
            'Deniz',
          );
          expect(text.contains('%'), isFalse);
        }
      }
    });

    test('takipçi sayısı kısa yazılır', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('tr'));
      expect(l10n.feedCount(950), '950');
      expect(l10n.feedCount(1200), '1,2 B');
      expect(l10n.feedCount(20000), '20 B');
      expect(l10n.feedCount(3400000), '3,4 Mn');
    });
  });
}
