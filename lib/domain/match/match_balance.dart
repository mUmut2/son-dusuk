import '../player/attribute.dart';
import '../player/position.dart';
import 'critical_moment.dart';

/// Maç simülasyonu ve kritik anlar için TÜM denge parametreleri burada.
abstract final class MatchBalance {
  // --- Takım simülasyonu ---

  /// Eşit güçte iki takımın ev/deplasman çarpanından önceki gol beklentisi.
  /// (1.33 * 1.1 + 1.33 / 1.1 ≈ 2.67 gol/maç)
  static const double baseGoals = 1.33;
  static const double homeAdvantage = 1.1;

  /// Güç farkının (puan) gol beklentisine etkisi: exp(slope * fark).
  static const double strengthSlope = 0.018;
  static const double minGoalExpectation = 0.25;
  static const int matchMinutes = 90;

  // --- Kritik anlar ---

  static const int momentCountMin = 5;
  static const int momentCountMax = 8;

  /// Referans (nitelik 50) koşulunda anın gol (veya asist) olasılığı.
  static const Map<MomentType, double> goalChance = {
    MomentType.shot: 0.30, // şut mini oyunu: 'net pozisyon'
    MomentType.oneOnOne: 0.32,
    MomentType.header: 0.15,
    MomentType.freeKick: 0.25,
    MomentType.penalty: 0.76,
    MomentType.keyPass: 0.06, // asist
    MomentType.dribble: 0.035, // asist
    MomentType.tackle: 0.0,
  };

  /// Müdahalenin referans başarı olasılığı ve başarısızlıkta yenilen gol olasılığı.
  static const double tackleSuccess = 0.65;
  static const double concedeOnFailedTackle = 0.12;

  /// Nitelik çarpanı: 50 -> 1.0, 99 -> ~1.49, 20 -> 0.7.
  static double attributeFactor(double attribute) => 0.5 + attribute / 100;

  /// Her an türü için belirleyici nitelikler (ortalaması alınır).
  static const Map<MomentType, List<Attribute>> momentAttributes = {
    MomentType.shot: [
      Attribute.shooting,
      Attribute.finesse,
      Attribute.composure,
    ],
    MomentType.oneOnOne: [Attribute.shooting, Attribute.composure],
    MomentType.header: [Attribute.heading, Attribute.strength],
    MomentType.freeKick: [Attribute.setPieces, Attribute.finesse],
    MomentType.penalty: [Attribute.shooting, Attribute.composure],
    MomentType.keyPass: [Attribute.passing, Attribute.vision],
    MomentType.dribble: [
      Attribute.dribbling,
      Attribute.agility,
      Attribute.ballControl,
    ],
    MomentType.tackle: [Attribute.defending, Attribute.strength],
  };

  /// Mevkiye göre kritik an türü ağırlıkları (toplamın 1 olması şart değil).
  static const Map<PlayerPosition, Map<MomentType, double>> momentWeights = {
    PlayerPosition.forward: {
      MomentType.shot: 0.10,
      MomentType.oneOnOne: 0.06,
      MomentType.header: 0.08,
      MomentType.freeKick: 0.02,
      MomentType.penalty: 0.02,
      MomentType.keyPass: 0.20,
      MomentType.dribble: 0.44,
      MomentType.tackle: 0.08,
    },
    PlayerPosition.winger: {
      MomentType.shot: 0.08,
      MomentType.oneOnOne: 0.04,
      MomentType.header: 0.03,
      MomentType.freeKick: 0.03,
      MomentType.penalty: 0.01,
      MomentType.keyPass: 0.30,
      MomentType.dribble: 0.43,
      MomentType.tackle: 0.08,
    },
    PlayerPosition.attackingMid: {
      MomentType.shot: 0.08,
      MomentType.oneOnOne: 0.03,
      MomentType.header: 0.02,
      MomentType.freeKick: 0.05,
      MomentType.penalty: 0.01,
      MomentType.keyPass: 0.40,
      MomentType.dribble: 0.31,
      MomentType.tackle: 0.10,
    },
    PlayerPosition.centralMid: {
      MomentType.shot: 0.04,
      MomentType.oneOnOne: 0.01,
      MomentType.header: 0.04,
      MomentType.freeKick: 0.03,
      MomentType.penalty: 0.01,
      MomentType.keyPass: 0.40,
      MomentType.dribble: 0.15,
      MomentType.tackle: 0.32,
    },
    PlayerPosition.defender: {
      MomentType.shot: 0.01,
      MomentType.oneOnOne: 0.00,
      MomentType.header: 0.10,
      MomentType.freeKick: 0.01,
      MomentType.penalty: 0.01,
      MomentType.keyPass: 0.22,
      MomentType.dribble: 0.10,
      MomentType.tackle: 0.55,
    },
  };
}
