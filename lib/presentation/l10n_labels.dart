import '../app/l10n/app_localizations.dart';
import '../domain/career/difficulty.dart';
import '../domain/player/attribute.dart';
import '../domain/player/position.dart';

/// Enum -> yerelleştirilmiş metin eşlemeleri (tek yerde).
extension L10nLabels on AppLocalizations {
  String positionName(PlayerPosition p) => switch (p) {
    PlayerPosition.forward => position_forward,
    PlayerPosition.winger => position_winger,
    PlayerPosition.attackingMid => position_attackingMid,
    PlayerPosition.centralMid => position_centralMid,
    PlayerPosition.defender => position_defender,
  };

  String footName(PreferredFoot f) => switch (f) {
    PreferredFoot.left => foot_left,
    PreferredFoot.right => foot_right,
    PreferredFoot.both => foot_both,
  };

  String attributeName(Attribute a) => switch (a) {
    Attribute.shooting => attr_shooting,
    Attribute.finesse => attr_finesse,
    Attribute.passing => attr_passing,
    Attribute.vision => attr_vision,
    Attribute.dribbling => attr_dribbling,
    Attribute.pace => attr_pace,
    Attribute.agility => attr_agility,
    Attribute.strength => attr_strength,
    Attribute.stamina => attr_stamina,
    Attribute.defending => attr_defending,
    Attribute.ballControl => attr_ballControl,
    Attribute.heading => attr_heading,
    Attribute.setPieces => attr_setPieces,
    Attribute.composure => attr_composure,
    Attribute.charisma => attr_charisma,
  };

  String kindName(AttributeKind k) => switch (k) {
    AttributeKind.physical => kind_physical,
    AttributeKind.technical => kind_technical,
    AttributeKind.mental => kind_mental,
  };

  String difficultyName(Difficulty d) => switch (d) {
    Difficulty.easy => difficulty_easy,
    Difficulty.normal => difficulty_normal,
    Difficulty.hard => difficulty_hard,
  };
}
