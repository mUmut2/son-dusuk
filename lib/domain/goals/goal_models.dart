/// Haftalık hedef türleri. Metinler ARB'de `goal_<ad>`.
enum GoalKind {
  // Maç hedefleri (yalnızca maçı olan haftalarda çıkar)
  scoreGoal,
  assist,
  rating7,
  winMatch,
  // Maçtan bağımsız hedefler
  trainHard,
  postFeed,
  noBetting;

  bool get isMatch => index <= GoalKind.winMatch.index;
}

/// Bir hedefin o anki durumu.
enum GoalStatus { pending, done, failed }

/// Hedef serisi ve toplamlar (kayda yazılır). Haftanın hedefleri kayıtta
/// tutulmaz; her hafta seed'den yeniden üretilir.
class Goals {
  const Goals({
    this.streak = 0,
    this.best = 0,
    this.totalDone = 0,
    this.lastWeek = 0,
    this.lastDone = 0,
    this.lastReward = 0,
  });

  factory Goals.fromJson(Map<String, dynamic> json) => Goals(
    streak: json['streak'] as int? ?? 0,
    best: json['best'] as int? ?? 0,
    totalDone: json['totalDone'] as int? ?? 0,
    lastWeek: json['lastWeek'] as int? ?? 0,
    lastDone: json['lastDone'] as int? ?? 0,
    lastReward: json['lastReward'] as int? ?? 0,
  );

  /// Üst üste hedef tamamlanan hafta sayısı (haftada en az [GoalBalance.streakMin]).
  final int streak;
  final int best;
  final int totalDone;

  /// En son değerlendirilen mutlak hafta, tamamlanan hedef sayısı ve ödülü.
  final int lastWeek;
  final int lastDone;
  final int lastReward;

  Goals copyWith({
    int? streak,
    int? best,
    int? totalDone,
    int? lastWeek,
    int? lastDone,
    int? lastReward,
  }) => Goals(
    streak: streak ?? this.streak,
    best: best ?? this.best,
    totalDone: totalDone ?? this.totalDone,
    lastWeek: lastWeek ?? this.lastWeek,
    lastDone: lastDone ?? this.lastDone,
    lastReward: lastReward ?? this.lastReward,
  );

  Map<String, dynamic> toJson() => {
    'streak': streak,
    'best': best,
    'totalDone': totalDone,
    'lastWeek': lastWeek,
    'lastDone': lastDone,
    'lastReward': lastReward,
  };
}
