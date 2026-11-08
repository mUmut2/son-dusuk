import 'attribute.dart';

/// Yaşa göre yıllık beklenen nitelik değişimi (puan/yıl, sınırsız halde).
///
/// 16-21: hızlı gelişim, 22-28: zirve, 29+: fiziksel düşüş.
/// Zihinsel nitelikler (Vizyon, Sakinlik, Karizma) geç yaşa kadar korunur.
abstract final class AgeCurve {
  static const int startAge = 16;
  static const int maxCareerAge = 40;

  static double annualDelta(int age, AttributeKind kind) {
    return switch (kind) {
      AttributeKind.physical => _physical(age),
      AttributeKind.technical => _technical(age),
      AttributeKind.mental => _mental(age),
    };
  }

  static double _physical(int age) {
    if (age <= 17) return 4.5;
    return switch (age) {
      18 => 4.0,
      19 => 3.5,
      20 => 3.0,
      21 => 2.2,
      22 => 1.2,
      >= 23 && <= 26 => 0.3,
      27 || 28 => 0.0,
      29 => -1.0,
      30 => -1.5,
      31 => -2.0,
      _ => -2.5,
    };
  }

  static double _technical(int age) {
    if (age <= 17) return 4.0;
    return switch (age) {
      18 => 3.8,
      19 => 3.4,
      20 => 3.0,
      21 => 2.5,
      22 => 1.8,
      23 || 24 => 1.0,
      >= 25 && <= 28 => 0.4,
      >= 29 && <= 31 => 0.0,
      _ => -0.5,
    };
  }

  static double _mental(int age) {
    if (age <= 21) return 3.2;
    if (age <= 24) return 1.8;
    if (age <= 28) return 1.0;
    if (age <= 33) return 0.5;
    return 0.0;
  }
}
