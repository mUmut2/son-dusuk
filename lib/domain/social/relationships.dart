/// Oyuncunun çevresiyle ilişkileri.
enum Relation { coach, teammates, fans, family, media }

/// Beş ilişkinin 0-100 değerleri. Değişmezdir.
class Relationships {
  const Relationships([Map<Relation, double>? values])
    : _values = values ?? const {};

  factory Relationships.fromJson(Map<String, dynamic> json) => Relationships({
    for (final r in Relation.values)
      if (json[r.name] != null) r: (json[r.name] as num).toDouble(),
  });

  final Map<Relation, double> _values;

  /// Hiçbir şey olmadığında her ilişkinin yöneldiği değer.
  static const Map<Relation, double> neutral = {
    Relation.coach: 50,
    Relation.teammates: 50,
    Relation.fans: 40,
    Relation.family: 70,
    Relation.media: 40,
  };

  double operator [](Relation r) => _values[r] ?? neutral[r]!;

  /// [deltas] eklenir, 0-100'e kırpılır.
  Relationships add(Map<Relation, double> deltas) => Relationships({
    for (final r in Relation.values)
      r: (this[r] + (deltas[r] ?? 0)).clamp(0.0, 100.0),
  });

  /// Zamanla nötr değere doğru yaklaşır ([rate]: haftalık pay).
  Relationships drift(double rate) => Relationships({
    for (final r in Relation.values)
      r: this[r] + (neutral[r]! - this[r]) * rate,
  });

  /// 0 (soğuk) .. 4 (çok yakın)
  static int levelOf(double value) {
    if (value < 20) return 0;
    if (value < 40) return 1;
    if (value < 60) return 2;
    if (value < 80) return 3;
    return 4;
  }

  Map<String, dynamic> toJson() => {
    for (final r in Relation.values) r.name: this[r],
  };
}
