import 'agent.dart';
import 'club_balance.dart';
import 'contract.dart';

enum Lifestyle { modest, comfortable, lavish }

/// Oyuncunun parası ve yaşam tarzı.
class Finance {
  const Finance({
    this.balance = ClubBalance.startingBalance,
    this.lifestyle = Lifestyle.modest,
  });

  factory Finance.fromJson(Map<String, dynamic> json) => Finance(
    balance: json['balance'] as int? ?? ClubBalance.startingBalance,
    lifestyle: Lifestyle.values.byName(
      json['lifestyle'] as String? ?? Lifestyle.modest.name,
    ),
  );

  final int balance;
  final Lifestyle lifestyle;

  bool get inDebt => balance < 0;

  Finance copyWith({int? balance, Lifestyle? lifestyle}) => Finance(
    balance: balance ?? this.balance,
    lifestyle: lifestyle ?? this.lifestyle,
  );

  Map<String, dynamic> toJson() => {
    'balance': balance,
    'lifestyle': lifestyle.name,
  };
}

enum MoneyKind { wage, winBonus, goalBonus, agentFee, living, nationalBonus }

class MoneyLine {
  const MoneyLine(this.kind, this.amount);

  final MoneyKind kind;

  /// Gelir pozitif, gider negatif.
  final int amount;
}

class WeekMoney {
  const WeekMoney(this.lines);

  final List<MoneyLine> lines;

  int get net => lines.fold(0, (s, l) => s + l.amount);
}

/// Haftalık gelir-gider hesabı (saf Dart).
abstract final class Economy {
  /// [won] ve [goals] yalnızca bu hafta maç oynandıysa anlamlıdır.
  static WeekMoney weekly({
    required Contract? contract,
    required Agent? agent,
    required Lifestyle lifestyle,
    bool won = false,
    int goals = 0,
  }) {
    final lines = <MoneyLine>[];
    var income = 0;
    if (contract != null) {
      lines.add(MoneyLine(MoneyKind.wage, contract.weeklyWage));
      income += contract.weeklyWage;
      if (won) {
        final b = (contract.weeklyWage * ClubBalance.winBonusShare).round();
        lines.add(MoneyLine(MoneyKind.winBonus, b));
        income += b;
      }
      if (goals > 0) {
        final b = (contract.weeklyWage * ClubBalance.goalBonusShare * goals)
            .round();
        lines.add(MoneyLine(MoneyKind.goalBonus, b));
        income += b;
      }
    }
    if (agent != null && income > 0) {
      lines.add(
        MoneyLine(MoneyKind.agentFee, -(income * agent.commission).round()),
      );
    }
    lines.add(
      MoneyLine(MoneyKind.living, -ClubBalance.lifestyleCost[lifestyle]!),
    );
    return WeekMoney(lines);
  }

  /// Yaşam tarzı ve borcun haftalık moral etkisi: (delta, borç mu).
  static (double, bool) moraleEffect(Finance f) {
    if (f.inDebt) return (ClubBalance.debtMorale, true);
    return (ClubBalance.lifestyleMorale[f.lifestyle]!, false);
  }
}
