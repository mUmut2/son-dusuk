import '../../core/game_random.dart';
import 'commentary_balance.dart';
import 'critical_moment.dart';
import 'match_simulator.dart';
import 'moment_resolver.dart';

/// Spiker satırı türleri. [variants]: ARB'de `cm_<tür>` anahtarında `|` ile
/// ayrılmış kaç farklı cümle olduğu (`test/domain/match/commentary_test.dart`
/// bunu denetler). Metinlerde `%team%` (satırın takımı), `%other%` (rakibi) ve
/// `%player%` (oyuncunun adı) yer tutucuları kullanılır.
enum CommentaryKind {
  // Maç akışı
  kickoff(3),
  halftime(3),
  fulltimeWin(3),
  fulltimeLoss(3),
  fulltimeDraw(3),

  // Ara anlatım
  midfield(4),
  corner(3),
  foul(3),
  offside(3),
  wide(3),
  keeperSave(3),
  crowd(3),

  // Arka plandaki goller (oyuncunun dışındakiler)
  teamGoal(4),
  oppGoal(4),

  // Oyuncunun kritik anlarının girişi
  introShot(3),
  introOneOnOne(3),
  introHeader(3),
  introFreeKick(3),
  introPenalty(3),
  introKeyPass(3),
  introDribble(3),
  introTackle(3),

  // Oyuncunun kritik anlarının sonucu
  playerGoal(4),
  playerAssist(3),
  conceded(3),
  missShot(3),
  missPlay(3),
  tackleOk(3);

  const CommentaryKind(this.variants);

  final int variants;

  /// Ekranda vurgulanan (gol içeren) satırlar.
  bool get isGoal =>
      this == teamGoal ||
      this == oppGoal ||
      this == playerGoal ||
      this == playerAssist ||
      this == conceded;
}

/// Ekrana yazılacak tek bir spiker satırı. Metin arayüzde ARB'den üretilir.
class CommentaryLine {
  const CommentaryLine({
    required this.minute,
    required this.kind,
    required this.variant,
    required this.side,
  });

  final int minute;
  final CommentaryKind kind;

  /// Türün hangi cümlesi (0..variants-1).
  final int variant;

  /// Satırın konusu olan takım (`%team%`).
  final Side side;
}

/// Maç boyunca spiker satırlarını üretir (saf Dart, `GameRandom` ile).
abstract final class MatchCommentator {
  static const List<CommentaryKind> _fillers = [
    CommentaryKind.midfield,
    CommentaryKind.corner,
    CommentaryKind.foul,
    CommentaryKind.offside,
    CommentaryKind.wide,
    CommentaryKind.keeperSave,
    CommentaryKind.crowd,
  ];

  static CommentaryLine _line(
    int minute,
    CommentaryKind kind,
    Side side,
    GameRandom random,
  ) => CommentaryLine(
    minute: minute,
    kind: kind,
    variant: random.nextInt(kind.variants),
    side: side,
  );

  static Side _other(Side s) => s == Side.home ? Side.away : Side.home;

  /// ([from], [to]] dakikaları arasında akan maçın anlatımı.
  ///
  /// [goals]: o ana kadar bilinen tüm goller. Oyuncunun kendi gol/asistleri ve
  /// kritik anlardan gelen goller burada anlatılmaz (onlar an sonucunda
  /// anlatılır); yalnızca arka plan golleri satıra dönüşür.
  /// [kickoff]: maç başı satırını ekler. [fullTime]: bitiş satırını ekler
  /// (tüm anlar çözülmüş olmalı).
  static List<CommentaryLine> segment({
    required int from,
    required int to,
    required List<MatchGoal> goals,
    required Side playerSide,
    required GameRandom random,
    bool kickoff = false,
    bool fullTime = false,
  }) {
    final lines = <CommentaryLine>[];
    if (kickoff) {
      lines.add(_line(0, CommentaryKind.kickoff, playerSide, random));
    }

    final goalMinutes = <int>{};
    for (final g in goals) {
      if (g.minute <= from || g.minute > to) continue;
      if (g.byPlayer || g.assistedByPlayer) continue;
      goalMinutes.add(g.minute);
      lines.add(
        _line(
          g.minute,
          g.side == playerSide
              ? CommentaryKind.teamGoal
              : CommentaryKind.oppGoal,
          g.side,
          random,
        ),
      );
    }

    if (from < 45 && to >= 45) {
      lines.add(_line(45, CommentaryKind.halftime, playerSide, random));
    }

    // Ara anlatım: arada bir, gol dakikalarıyla çakışmadan.
    var t =
        from +
        random.range(
          CommentaryBalance.fillerGapMin,
          CommentaryBalance.fillerGapMax,
        );
    CommentaryKind? previous;
    while (t < to) {
      if (!goalMinutes.contains(t) && t != 45) {
        var kind = random.pick(_fillers);
        if (kind == previous) kind = random.pick(_fillers);
        previous = kind;
        lines.add(
          _line(t, kind, random.chance(0.5) ? Side.home : Side.away, random),
        );
      }
      t += random.range(
        CommentaryBalance.fillerGapMin,
        CommentaryBalance.fillerGapMax,
      );
    }

    if (fullTime) {
      final own = goals.where((g) => g.side == playerSide).length;
      final other = goals.length - own;
      final kind = own > other
          ? CommentaryKind.fulltimeWin
          : own < other
          ? CommentaryKind.fulltimeLoss
          : CommentaryKind.fulltimeDraw;
      lines.add(
        _line(CommentaryBalance.matchMinutes, kind, playerSide, random),
      );
    }

    // Dakikaya göre sırala (eşitlikte eklenme sırası korunur).
    final indexed = [for (var i = 0; i < lines.length; i++) (i, lines[i])]
      ..sort((a, b) {
        final c = a.$2.minute - b.$2.minute;
        return c != 0 ? c : a.$1 - b.$1;
      });
    return [for (final e in indexed) e.$2];
  }

  /// Oyuncunun kritik anının girişi ("Top %player% önünde!").
  static CommentaryLine momentIntro(
    CriticalMoment m,
    Side playerSide,
    GameRandom random,
  ) => _line(
    m.minute,
    switch (m.type) {
      MomentType.shot => CommentaryKind.introShot,
      MomentType.oneOnOne => CommentaryKind.introOneOnOne,
      MomentType.header => CommentaryKind.introHeader,
      MomentType.freeKick => CommentaryKind.introFreeKick,
      MomentType.penalty => CommentaryKind.introPenalty,
      MomentType.keyPass => CommentaryKind.introKeyPass,
      MomentType.dribble => CommentaryKind.introDribble,
      MomentType.tackle => CommentaryKind.introTackle,
    },
    playerSide,
    random,
  );

  /// Oyuncunun kritik anının sonucu.
  static CommentaryLine momentResult(
    CriticalMoment m,
    MomentOutcome o,
    Side playerSide,
    GameRandom random,
  ) {
    final kind = o.playerGoal
        ? CommentaryKind.playerGoal
        : o.playerAssist
        ? CommentaryKind.playerAssist
        : o.concededGoal
        ? CommentaryKind.conceded
        : switch (m.type) {
            MomentType.tackle => CommentaryKind.tackleOk,
            MomentType.keyPass || MomentType.dribble => CommentaryKind.missPlay,
            _ => CommentaryKind.missShot,
          };
    // Yenilen golde "takım" rakiptir; yer tutucular buna göre çözülür.
    return _line(
      m.minute,
      kind,
      kind == CommentaryKind.conceded ? _other(playerSide) : playerSide,
      random,
    );
  }
}
