import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/domain/career/season_calendar.dart';

void main() {
  test('evreler ve lig turları', () {
    expect(SeasonCalendar.weeksPerSeason, 42);
    expect(SeasonCalendar.phaseOf(1), SeasonPhase.preseason);
    expect(SeasonCalendar.phaseOf(4), SeasonPhase.preseason);
    expect(SeasonCalendar.phaseOf(5), SeasonPhase.regularSeason);
    expect(SeasonCalendar.phaseOf(38), SeasonPhase.regularSeason);
    expect(SeasonCalendar.phaseOf(39), SeasonPhase.offseason);

    expect(SeasonCalendar.leagueRoundOf(5), 1);
    expect(SeasonCalendar.leagueRoundOf(38), 34);
    expect(SeasonCalendar.leagueRoundOf(2), isNull);
  });

  test('her lig turu tam bir haftaya denk gelir', () {
    final rounds = [
      for (var w = 1; w <= SeasonCalendar.weeksPerSeason; w++)
        SeasonCalendar.leagueRoundOf(w),
    ].whereType<int>().toList();
    expect(rounds, [for (var r = 1; r <= 34; r++) r]);
  });

  test('transfer pencereleri', () {
    expect(SeasonCalendar.isTransferWindow(1), isTrue);
    expect(SeasonCalendar.isTransferWindow(10), isFalse);
    expect(SeasonCalendar.isTransferWindow(23), isTrue);
    expect(SeasonCalendar.isTransferWindow(30), isFalse);
  });

  test('geçersiz hafta hata verir', () {
    expect(() => SeasonCalendar.phaseOf(0), throwsRangeError);
    expect(() => SeasonCalendar.phaseOf(43), throwsRangeError);
  });
}
