import 'attributes.dart';
import 'position.dart';

/// Basit görünüm seçimi: paletlerdeki indeksler (renkler UI katmanında).
class Appearance {
  const Appearance({this.skinTone = 0, this.hairColor = 0, this.kitColor = 0});

  factory Appearance.fromJson(Map<String, dynamic> json) => Appearance(
    skinTone: json['skinTone'] as int? ?? 0,
    hairColor: json['hairColor'] as int? ?? 0,
    kitColor: json['kitColor'] as int? ?? 0,
  );

  final int skinTone;
  final int hairColor;
  final int kitColor;

  Map<String, dynamic> toJson() => {
    'skinTone': skinTone,
    'hairColor': hairColor,
    'kitColor': kitColor,
  };
}

/// Kullanıcının yönettiği oyuncu. Değişmezdir; değişiklikler [copyWith] ile.
class Player {
  const Player({
    required this.name,
    required this.birthplace,
    required this.position,
    required this.foot,
    required this.appearance,
    required this.age,
    required this.attributes,
    required this.potential,
    required this.injuryProneness,
    required this.professionalism,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    name: json['name'] as String,
    birthplace: json['birthplace'] as String,
    position: PlayerPosition.values.byName(json['position'] as String),
    foot: PreferredFoot.values.byName(json['foot'] as String),
    appearance: Appearance.fromJson(json['appearance'] as Map<String, dynamic>),
    age: json['age'] as int,
    attributes: Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
    potential: (json['potential'] as num).toDouble(),
    injuryProneness: (json['injuryProneness'] as num).toDouble(),
    professionalism: (json['professionalism'] as num).toDouble(),
  );

  final String name;
  final String birthplace;
  final PlayerPosition position;
  final PreferredFoot foot;
  final Appearance appearance;
  final int age;
  final Attributes attributes;

  /// GİZLİ: nitelik tavanını belirler (55-97).
  final double potential;

  /// GİZLİ: sakatlanma eğilimi (0-1, yüksek = daha riskli).
  final double injuryProneness;

  /// GİZLİ: antrenman verimini etkiler (0-1).
  final double professionalism;

  int get overall => attributes.overall(position);

  Player copyWith({int? age, Attributes? attributes}) => Player(
    name: name,
    birthplace: birthplace,
    position: position,
    foot: foot,
    appearance: appearance,
    age: age ?? this.age,
    attributes: attributes ?? this.attributes,
    potential: potential,
    injuryProneness: injuryProneness,
    professionalism: professionalism,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'birthplace': birthplace,
    'position': position.name,
    'foot': foot.name,
    'appearance': appearance.toJson(),
    'age': age,
    'attributes': attributes.toJson(),
    'potential': potential,
    'injuryProneness': injuryProneness,
    'professionalism': professionalism,
  };
}
