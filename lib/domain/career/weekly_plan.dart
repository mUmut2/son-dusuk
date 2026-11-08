import '../player/attribute.dart';

enum TrainingFocus { shooting, physical, technical, tactical, rest }

enum TrainingIntensity { light, normal, hard }

enum SocialActivity { none, family, friends, hobby }

/// Oyuncunun o hafta için verdiği kararlar.
class WeeklyPlan {
  const WeeklyPlan({
    this.focus = TrainingFocus.technical,
    this.intensity = TrainingIntensity.normal,
    this.social = SocialActivity.none,
  });

  final TrainingFocus focus;
  final TrainingIntensity intensity;
  final SocialActivity social;

  WeeklyPlan copyWith({
    TrainingFocus? focus,
    TrainingIntensity? intensity,
    SocialActivity? social,
  }) => WeeklyPlan(
    focus: focus ?? this.focus,
    intensity: intensity ?? this.intensity,
    social: social ?? this.social,
  );

  /// Odaklanılan antrenmanın geliştirdiği nitelikler.
  static List<Attribute> attributesFor(TrainingFocus focus) => switch (focus) {
    TrainingFocus.shooting => [
      Attribute.shooting,
      Attribute.finesse,
      Attribute.setPieces,
    ],
    TrainingFocus.physical => [
      Attribute.pace,
      Attribute.agility,
      Attribute.strength,
      Attribute.stamina,
    ],
    TrainingFocus.technical => [
      Attribute.dribbling,
      Attribute.ballControl,
      Attribute.passing,
      Attribute.heading,
    ],
    TrainingFocus.tactical => [
      Attribute.vision,
      Attribute.defending,
      Attribute.composure,
      Attribute.passing,
    ],
    TrainingFocus.rest => const [],
  };
}
