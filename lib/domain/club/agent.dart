import 'club_balance.dart';

/// Oyuncunun menajeri. [level] 1-3; yüksek seviye daha iyi teklif ve pazarlık,
/// ama daha yüksek komisyon demektir. Adlar tamamen kurgusaldır.
class Agent {
  const Agent({required this.name, required this.level});

  factory Agent.fromJson(Map<String, dynamic> json) =>
      Agent(name: json['name'] as String, level: json['level'] as int);

  final String name;
  final int level;

  double get commission => ClubBalance.agentCommission[level]!;
  double get negotiationBonus => ClubBalance.agentNegotiation[level]!;
  double get offerBoost => ClubBalance.agentOfferBoost[level]!;

  Map<String, dynamic> toJson() => {'name': name, 'level': level};
}

abstract final class AgentPool {
  static const List<String> _names = [
    'Selim Karaca',
    'Haluk Erdem',
    'Nevzat Çiftçi',
    'Orhan Yalçın',
    'Fikret Baysal',
    'Metin Soylu',
    'Cengiz Aydoğan',
    'Rıza Tunçel',
    'Ergin Kalkan',
    'Taner Özdağ',
    'Burhan Sezgin',
    'Mahir Doğan',
  ];

  static const List<int> levels = [1, 2, 3];

  /// Her seviye için dünyaya özgü, kararlı bir aday.
  static Agent candidate(int worldSeed, int level) => Agent(
    name: _names[(worldSeed.abs() + level * 5) % _names.length],
    level: level,
  );

  static bool canHire(int level, int overall) =>
      overall >= ClubBalance.agentMinOverall[level]!;
}
