import '../club/finance.dart';
import '../player/attribute.dart';
import 'player_status.dart';

enum StatKind { condition, form, morale }

/// Bir değişimin NEDENİ (haftalık özette "ne değişti, neden" için).
enum WeekReason {
  recovery,
  trainingLight,
  trainingNormal,
  trainingHard,
  restFocus,
  match,
  socialFamily,
  socialFriends,
  socialHobby,
  matchWin,
  matchLoss,
  greatPerformance,
  poorPerformance,
  injured,
  injuryOnset,
  healed,
  exhausted,
  formFromRatings,
  earlyReturn,
  drift,
  lifestyle,
  debt,
}

class StatChange {
  const StatChange(this.stat, this.delta, this.reason);

  final StatKind stat;
  final double delta;
  final WeekReason reason;
}

class AttributeGain {
  const AttributeGain(this.attribute, this.delta);

  final Attribute attribute;
  final double delta;
}

enum WeekEventKind {
  injured,
  relapse,
  healed,
  newSeason,
  trainingBlocked,
  benched,
  offerReceived,
  renewalOffered,
  contractExpired,
  newEvent,
  nationalCalled,
  nationalOmitted,
  nationalMatch,
  nationalOut,
  nationalRunnerUp,
  nationalChampion,
  achievement,
  retired,
  betSettled,
  betWarning,
  betFined,
  betSuspended,
  suspended,
  goalsReport,
  goalStreak,
}

class WeekEvent {
  const WeekEvent(
    this.kind, {
    this.injuryType,
    this.weeks,
    this.age,
    this.clubId,
    this.eventId,
    this.detail,
    this.detail2,
  });

  final WeekEventKind kind;
  final InjuryType? injuryType;
  final int? weeks;
  final int? age;

  /// Teklif/sözleşme olaylarında ilgili kulüp.
  final String? clubId;

  /// `newEvent` olayında yeni gelen olayın şablon kimliği.
  final String? eventId;

  /// Milli takım / başarım olaylarının serbest alanları (anlamı olaya göre):
  /// nationalCalled: detail = turnuva türü, detail2 = kadro rolü.
  /// nationalMatch: detail = rakip adı, detail2 = skor ("2-1" ya da "1-1|4-3"),
  /// weeks = tur numarası. nationalOut/RunnerUp/Champion: detail = turnuva türü,
  /// detail2 = aşama. achievement: detail = başarım adı.
  final String? detail;
  final String? detail2;
}

/// Bir haftanın özeti: ne değişti ve neden.
class WeekReport {
  const WeekReport({
    required this.season,
    required this.week,
    required this.statChanges,
    required this.attributeGains,
    required this.events,
    this.playedMatch = false,
    this.money = const WeekMoney([]),
  });

  /// Bu raporun ait olduğu (oynanan) sezon ve hafta.
  final int season;
  final int week;
  final List<StatChange> statChanges;
  final List<AttributeGain> attributeGains;
  final List<WeekEvent> events;
  final bool playedMatch;

  /// Haftanın gelir-giderleri.
  final WeekMoney money;

  double totalDelta(StatKind kind) => statChanges
      .where((c) => c.stat == kind)
      .fold(0.0, (sum, c) => sum + c.delta);
}
