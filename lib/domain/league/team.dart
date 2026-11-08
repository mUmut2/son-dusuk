/// Kurgusal bir takım. [strength] 1-100 arası genel takım gücüdür.
class Team {
  const Team({required this.id, required this.name, required this.strength});

  final String id;
  final String name;
  final double strength;
}

/// Bir lig: [tier] 1 = en üst lig, 5 = amatör lig.
class League {
  const League({required this.tier, required this.teams});

  final int tier;
  final List<Team> teams;
}
