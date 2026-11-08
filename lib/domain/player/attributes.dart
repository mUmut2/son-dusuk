import 'attribute.dart';
import 'position.dart';

/// Oyuncunun 15 niteliğini tutan değişmez nesne. Değerler içeride ondalıklı
/// saklanır (yıllık küçük gelişimler kaybolmasın), dışarıya tam sayı verilir.
class Attributes {
  Attributes(Map<Attribute, double> values)
    : _values = Map.unmodifiable({
        for (final a in Attribute.values)
          a: (values[a] ?? minValue).clamp(minValue, maxValue).toDouble(),
      });

  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes({
      for (final a in Attribute.values)
        if (json[a.name] is num) a: (json[a.name] as num).toDouble(),
    });
  }

  static const double minValue = 1;
  static const double maxValue = 99;

  final Map<Attribute, double> _values;

  /// Gösterim için yuvarlanmış değer (1-99).
  int operator [](Attribute attribute) => _values[attribute]!.round();

  /// Ondalıklı ham değer.
  double raw(Attribute attribute) => _values[attribute]!;

  Attributes copyWith(Map<Attribute, double> changes) =>
      Attributes({..._values, ...changes});

  /// Her niteliğe [transform] uygulayıp yeni nesne üretir.
  Attributes map(double Function(Attribute attribute, double value) transform) {
    return Attributes({
      for (final entry in _values.entries)
        entry.key: transform(entry.key, entry.value),
    });
  }

  /// Mevkiye göre ağırlıklı "genel güç" (1-99).
  int overall(PlayerPosition position) {
    var weighted = 0.0;
    var total = 0.0;
    for (final entry in _values.entries) {
      final w = PositionProfile.weight(position, entry.key);
      weighted += entry.value * w;
      total += w;
    }
    return (weighted / total).round();
  }

  Map<String, dynamic> toJson() => {
    for (final entry in _values.entries) entry.key.name: entry.value,
  };
}
