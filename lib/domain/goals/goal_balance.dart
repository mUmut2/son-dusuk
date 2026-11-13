import '../social/event_models.dart';

/// Haftalık hedefler ve seri dengesi (tek yer).
abstract final class GoalBalance {
  /// Haftalık hedef sayısı.
  static const int perWeek = 3;

  /// Maç hedefi için eşik reyting.
  static const double ratingTarget = 7;

  /// Seri için haftada tamamlanması gereken en az hedef.
  static const int streakMin = 2;

  /// Her hedef: haftalık maaşın payı (en az [minPerGoal]) ve +moral.
  static const double moneyPerGoalWeeks = 0.05;
  static const int minPerGoal = 50;
  static const double moralePerGoal = 1;

  /// Hepsi tamamlanınca ek: maaş payı (en az [minAllDone]) ve taraftar.
  static const double allDoneWeeks = 0.15;
  static const int minAllDone = 100;
  static const double allDoneFans = 2;

  /// Seri dönüm noktaları (hafta) ve ödülü.
  static const List<int> milestones = [3, 6, 10, 15, 20, 30];
  static const double milestoneWeeks = 0.5;
  static const int minMilestone = 300;
  static const EventEffect milestoneEffect = EventEffect(
    media: 3,
    fans: 3,
    morale: 2,
  );
}
