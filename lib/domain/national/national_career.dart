import 'national_balance.dart';

enum TournamentKind { continental, world }

/// Turnuvada ulaşılan son aşama (elenen için elendiği tur).
enum TournamentStage { roundOf16, quarterFinal, semiFinal, runnerUp, champion }

/// Milli takım kadrosundaki yer (çağrılma puanına göre).
enum NationalRole { reserve, rotation, starter }

/// Ülkenin bir turnuva maçı (oyuncu oynadıysa [played]).
class NationalMatchRecord {
  const NationalMatchRecord({
    required this.round,
    required this.opponentId,
    required this.scoreFor,
    required this.scoreAgainst,
    this.pensFor,
    this.pensAgainst,
    this.played = false,
    this.playerGoals = 0,
  });

  factory NationalMatchRecord.fromJson(Map<String, dynamic> json) =>
      NationalMatchRecord(
        round: json['round'] as int,
        opponentId: json['opponentId'] as String,
        scoreFor: json['scoreFor'] as int,
        scoreAgainst: json['scoreAgainst'] as int,
        pensFor: json['pensFor'] as int?,
        pensAgainst: json['pensAgainst'] as int?,
        played: json['played'] as bool? ?? false,
        playerGoals: json['playerGoals'] as int? ?? 0,
      );

  /// 0 = Son 16 .. 3 = Final.
  final int round;
  final String opponentId;
  final int scoreFor;
  final int scoreAgainst;

  /// Beraberlikte penaltı atışları skoru.
  final int? pensFor;
  final int? pensAgainst;

  /// Oyuncu bu maçta oynadı mı?
  final bool played;
  final int playerGoals;

  bool get won => scoreFor != scoreAgainst
      ? scoreFor > scoreAgainst
      : (pensFor ?? 0) > (pensAgainst ?? 0);

  Map<String, dynamic> toJson() => {
    'round': round,
    'opponentId': opponentId,
    'scoreFor': scoreFor,
    'scoreAgainst': scoreAgainst,
    'pensFor': pensFor,
    'pensAgainst': pensAgainst,
    'played': played,
    'playerGoals': playerGoals,
  };
}

/// Devam eden (ya da bu sezon biten) turnuva.
class TournamentRun {
  const TournamentRun({
    required this.season,
    required this.kind,
    required this.called,
    this.role = NationalRole.reserve,
    this.results = const [],
  });

  factory TournamentRun.fromJson(Map<String, dynamic> json) => TournamentRun(
    season: json['season'] as int,
    kind: TournamentKind.values.byName(json['kind'] as String),
    called: json['called'] as bool? ?? false,
    role: NationalRole.values.byName(
      json['role'] as String? ?? NationalRole.reserve.name,
    ),
    results: [
      for (final r in (json['results'] as List<dynamic>? ?? const []))
        NationalMatchRecord.fromJson(r as Map<String, dynamic>),
    ],
  );

  final int season;
  final TournamentKind kind;

  /// Oyuncu milli takım kadrosuna çağrıldı mı?
  final bool called;
  final NationalRole role;

  /// Ülkenin şimdiye kadarki maçları (tur sırasıyla).
  final List<NationalMatchRecord> results;

  bool get champion =>
      results.length == NationalBalance.roundCount && results.last.won;
  bool get lost => results.isNotEmpty && !results.last.won;
  bool get finished => lost || champion;
  bool get alive => !finished;

  /// Sıradaki turun numarası (0-3).
  int get nextRound => results.length;

  int get appearances => results.where((r) => r.played).length;
  int get goals => results.fold(0, (s, r) => s + r.playerGoals);

  /// Biten turnuvanın sonucu; sürüyorsa null.
  TournamentStage? get stage {
    if (champion) return TournamentStage.champion;
    if (!lost) return null;
    return switch (results.length - 1) {
      0 => TournamentStage.roundOf16,
      1 => TournamentStage.quarterFinal,
      2 => TournamentStage.semiFinal,
      _ => TournamentStage.runnerUp,
    };
  }

  TournamentRun copyWith({List<NationalMatchRecord>? results}) => TournamentRun(
    season: season,
    kind: kind,
    called: called,
    role: role,
    results: results ?? this.results,
  );

  Map<String, dynamic> toJson() => {
    'season': season,
    'kind': kind.name,
    'called': called,
    'role': role.name,
    'results': [for (final r in results) r.toJson()],
  };
}

/// Biten bir turnuvanın kalıcı özeti.
class TournamentRecord {
  const TournamentRecord({
    required this.season,
    required this.kind,
    required this.called,
    required this.stage,
    this.appearances = 0,
    this.goals = 0,
  });

  factory TournamentRecord.fromJson(Map<String, dynamic> json) =>
      TournamentRecord(
        season: json['season'] as int,
        kind: TournamentKind.values.byName(json['kind'] as String),
        called: json['called'] as bool? ?? false,
        stage: TournamentStage.values.byName(json['stage'] as String),
        appearances: json['appearances'] as int? ?? 0,
        goals: json['goals'] as int? ?? 0,
      );

  final int season;
  final TournamentKind kind;
  final bool called;
  final TournamentStage stage;
  final int appearances;
  final int goals;

  /// Kadrodayken kazanılan şampiyonluk.
  bool get isTitle => called && stage == TournamentStage.champion;

  Map<String, dynamic> toJson() => {
    'season': season,
    'kind': kind.name,
    'called': called,
    'stage': stage.name,
    'appearances': appearances,
    'goals': goals,
  };
}

/// Oyuncunun milli takım kariyeri.
class NationalCareer {
  const NationalCareer({
    this.caps = 0,
    this.goals = 0,
    this.current,
    this.past = const [],
  });

  factory NationalCareer.fromJson(Map<String, dynamic> json) => NationalCareer(
    caps: json['caps'] as int? ?? 0,
    goals: json['goals'] as int? ?? 0,
    current: json['current'] == null
        ? null
        : TournamentRun.fromJson(json['current'] as Map<String, dynamic>),
    past: [
      for (final r in (json['past'] as List<dynamic>? ?? const []))
        TournamentRecord.fromJson(r as Map<String, dynamic>),
    ],
  );

  /// Milli maç sayısı ve golleri.
  final int caps;
  final int goals;
  final TournamentRun? current;
  final List<TournamentRecord> past;

  int get titles => past.where((r) => r.isTitle).length;
  int get tournamentsPlayed => past.where((r) => r.called).length;

  NationalCareer copyWith({
    int? caps,
    int? goals,
    TournamentRun? current,
    bool clearCurrent = false,
    List<TournamentRecord>? past,
  }) => NationalCareer(
    caps: caps ?? this.caps,
    goals: goals ?? this.goals,
    current: clearCurrent ? null : (current ?? this.current),
    past: past ?? this.past,
  );

  Map<String, dynamic> toJson() => {
    'caps': caps,
    'goals': goals,
    'current': current?.toJson(),
    'past': [for (final r in past) r.toJson()],
  };
}
