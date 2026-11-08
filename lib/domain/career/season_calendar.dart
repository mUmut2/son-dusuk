enum SeasonPhase { preseason, regularSeason, offseason }

/// Sezon takvimi: hafta numarasından (1..[weeksPerSeason]) evre ve lig turu.
///
/// 1-4 hazırlık, 5-38 lig turları (34 tur), 39-42 sezon arası.
/// Kupa ve milli takım araları sonraki fazlarda eklenir.
abstract final class SeasonCalendar {
  static const int preseasonWeeks = 4;
  static const int leagueRounds = 34;
  static const int offseasonWeeks = 4;
  static const int weeksPerSeason =
      preseasonWeeks + leagueRounds + offseasonWeeks;

  /// Yaz transfer penceresi: hazırlık + ilk lig haftaları. Kış: 22-24.
  static const int summerWindowEnd = 6;
  static const int winterWindowStart = 22;
  static const int winterWindowEnd = 24;

  static SeasonPhase phaseOf(int week) {
    _check(week);
    if (week <= preseasonWeeks) return SeasonPhase.preseason;
    if (week <= preseasonWeeks + leagueRounds) return SeasonPhase.regularSeason;
    return SeasonPhase.offseason;
  }

  /// Lig turu numarası (1-34); lig haftası değilse null.
  static int? leagueRoundOf(int week) =>
      phaseOf(week) == SeasonPhase.regularSeason ? week - preseasonWeeks : null;

  /// [week] başında tamamlanmış lig turu sayısı (0-34).
  static int roundsPlayed(int week) {
    _check(week);
    return (week - preseasonWeeks - 1).clamp(0, leagueRounds);
  }

  static bool isTransferWindow(int week) {
    _check(week);
    return week <= summerWindowEnd ||
        (week >= winterWindowStart && week <= winterWindowEnd);
  }

  static void _check(int week) {
    if (week < 1 || week > weeksPerSeason) {
      throw RangeError.range(week, 1, weeksPerSeason, 'week');
    }
  }
}
