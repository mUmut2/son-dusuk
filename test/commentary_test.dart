import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/app/l10n/app_localizations.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/match/commentary.dart';
import 'package:son_dusuk/domain/match/critical_moment.dart';
import 'package:son_dusuk/domain/match/match_simulator.dart';
import 'package:son_dusuk/domain/match/moment_resolver.dart';
import 'package:son_dusuk/presentation/match/commentary_texts.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('tr'));

  group('Spiker metinleri', () {
    test('her türün ARB cümle sayısı enum ile aynı ve hiçbiri boş değil', () {
      for (final kind in CommentaryKind.values) {
        final variants = l10n.commentaryVariants(kind);
        expect(variants.length, kind.variants, reason: kind.name);
        for (final v in variants) {
          expect(v.trim(), isNotEmpty, reason: kind.name);
        }
      }
    });

    test('yer tutucular çözülür ve ekranda yüzde işareti kalmaz', () {
      for (final kind in CommentaryKind.values) {
        for (var v = 0; v < kind.variants; v++) {
          final text = l10n.commentary(
            CommentaryLine(minute: 10, kind: kind, variant: v, side: Side.home),
            home: 'Kartallar',
            away: 'Aslanlar',
            player: 'Deniz',
          );
          expect(text.contains('%'), isFalse, reason: '${kind.name}/$v: $text');
        }
      }
    });

    test('rakip adı satırın karşı takımına yazılır', () {
      var found = false;
      for (var v = 0; v < CommentaryKind.fulltimeLoss.variants; v++) {
        final text = l10n.commentary(
          CommentaryLine(
            minute: 90,
            kind: CommentaryKind.fulltimeLoss,
            variant: v,
            side: Side.away,
          ),
          home: 'Kartallar',
          away: 'Aslanlar',
          player: 'Deniz',
        );
        // Oyuncunun takımı (away) = %team%, kazanan (home) = %other%.
        if (text.contains('Kartallar')) found = true;
      }
      expect(found, isTrue);
    });

    test('anlatımda ". dakika" geçmez (maç ekranı bu ifadeyi sayar)', () {
      for (final kind in CommentaryKind.values) {
        for (final v in l10n.commentaryVariants(kind)) {
          expect(v.contains('. dakika'), isFalse, reason: kind.name);
        }
      }
    });
  });

  group('MatchCommentator', () {
    List<CommentaryLine> seg({
      int from = 0,
      int to = 90,
      List<MatchGoal> goals = const [],
      bool kickoff = false,
      bool fullTime = false,
      int seed = 1,
    }) => MatchCommentator.segment(
      from: from,
      to: to,
      goals: goals,
      playerSide: Side.home,
      random: GameRandom(seed),
      kickoff: kickoff,
      fullTime: fullTime,
    );

    test('satırlar dakikaya göre sıralı ve aralığın içinde', () {
      for (var seed = 0; seed < 50; seed++) {
        final lines = seg(from: 10, to: 70, seed: seed);
        for (var i = 1; i < lines.length; i++) {
          expect(lines[i].minute, greaterThanOrEqualTo(lines[i - 1].minute));
        }
        for (final l in lines) {
          expect(l.minute, inInclusiveRange(10, 70));
          expect(l.variant, inInclusiveRange(0, l.kind.variants - 1));
        }
      }
    });

    test('maç başı ve bitiş satırları, devre arası', () {
      final lines = seg(kickoff: true, fullTime: true);
      expect(lines.first.kind, CommentaryKind.kickoff);
      expect(lines.last.kind, CommentaryKind.fulltimeDraw);
      expect(
        lines.where((l) => l.kind == CommentaryKind.halftime),
        hasLength(1),
      );
      // Devre arası yalnızca 45. dakikayı kapsayan aralıkta olur.
      expect(
        seg(from: 50, to: 80).any((l) => l.kind == CommentaryKind.halftime),
        isFalse,
      );
    });

    test('bitiş satırı skora göre galibiyet/yenilgi/beraberlik seçer', () {
      CommentaryKind end(List<MatchGoal> goals) =>
          seg(goals: goals, fullTime: true).last.kind;
      const home = MatchGoal(minute: 20, side: Side.home);
      const away = MatchGoal(minute: 30, side: Side.away);
      expect(end([home]), CommentaryKind.fulltimeWin);
      expect(end([away]), CommentaryKind.fulltimeLoss);
      expect(end([home, away]), CommentaryKind.fulltimeDraw);
    });

    test('arka plan golleri anlatılır, oyuncunun golleri anlatılmaz', () {
      final lines = seg(
        goals: const [
          MatchGoal(minute: 20, side: Side.home),
          MatchGoal(minute: 30, side: Side.away),
          MatchGoal(minute: 40, side: Side.home, byPlayer: true),
          MatchGoal(minute: 50, side: Side.home, assistedByPlayer: true),
        ],
      );
      final goalLines = lines.where((l) => l.kind.isGoal).toList();
      expect(goalLines.map((l) => (l.minute, l.kind)), [
        (20, CommentaryKind.teamGoal),
        (30, CommentaryKind.oppGoal),
      ]);
    });

    test('aralığın dışındaki goller anlatılmaz', () {
      final lines = seg(
        from: 20,
        to: 60,
        goals: const [
          MatchGoal(minute: 20, side: Side.home), // önceki anın dakikası
          MatchGoal(minute: 61, side: Side.away),
          MatchGoal(minute: 35, side: Side.home),
        ],
      );
      expect(lines.where((l) => l.kind.isGoal).map((l) => l.minute), [35]);
    });

    test('aynı seed aynı anlatımı verir', () {
      final a = seg(seed: 7, kickoff: true, fullTime: true);
      final b = seg(seed: 7, kickoff: true, fullTime: true);
      expect(
        [for (final l in a) (l.minute, l.kind, l.variant, l.side)],
        [for (final l in b) (l.minute, l.kind, l.variant, l.side)],
      );
    });

    test('ara anlatım gol dakikasıyla çakışmaz', () {
      for (var seed = 0; seed < 100; seed++) {
        final lines = seg(
          goals: const [MatchGoal(minute: 33, side: Side.away)],
          seed: seed,
        );
        expect(lines.where((l) => l.minute == 33), hasLength(1));
      }
    });

    test('an girişi ve sonucu türe ve sonuca göre seçilir', () {
      const m = CriticalMoment(minute: 30, type: MomentType.penalty);
      final intro = MatchCommentator.momentIntro(m, Side.home, GameRandom(1));
      expect(intro.kind, CommentaryKind.introPenalty);

      CommentaryKind result(MomentType t, MomentOutcome o) =>
          MatchCommentator.momentResult(
            CriticalMoment(minute: 30, type: t),
            o,
            Side.home,
            GameRandom(1),
          ).kind;
      expect(
        result(MomentType.shot, MomentOutcome.goal),
        CommentaryKind.playerGoal,
      );
      expect(
        result(MomentType.keyPass, MomentOutcome.assist),
        CommentaryKind.playerAssist,
      );
      expect(
        result(MomentType.tackle, MomentOutcome.conceded),
        CommentaryKind.conceded,
      );
      expect(
        result(MomentType.tackle, MomentOutcome.none),
        CommentaryKind.tackleOk,
      );
      expect(
        result(MomentType.shot, MomentOutcome.none),
        CommentaryKind.missShot,
      );
      expect(
        result(MomentType.dribble, MomentOutcome.none),
        CommentaryKind.missPlay,
      );
    });

    test('yenilen golde satırın takımı rakiptir', () {
      final line = MatchCommentator.momentResult(
        const CriticalMoment(minute: 30, type: MomentType.tackle),
        MomentOutcome.conceded,
        Side.home,
        GameRandom(1),
      );
      expect(line.side, Side.away);
    });
  });
}
