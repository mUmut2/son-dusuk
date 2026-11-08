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
  formFades,
  earlyReturn,
  drift,
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

enum WeekEventKind { injured, relapse, healed, newSeason, trainingBlocked }

class WeekEvent {
  const WeekEvent(this.kind, {this.injuryType, this.weeks, this.age});

  final WeekEventKind kind;
  final InjuryType? injuryType;
  final int? weeks;
  final int? age;
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
  });

  /// Bu raporun ait olduğu (oynanan) sezon ve hafta.
  final int season;
  final int week;
  final List<StatChange> statChanges;
  final List<AttributeGain> attributeGains;
  final List<WeekEvent> events;
  final bool playedMatch;

  double totalDelta(StatKind kind) => statChanges
      .where((c) => c.stat == kind)
      .fold(0.0, (sum, c) => sum + c.delta);
}
