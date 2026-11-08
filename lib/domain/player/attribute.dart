/// Niteliğin yaş eğrisindeki davranışını belirleyen grup.
enum AttributeKind { physical, technical, mental }

/// Oyuncu nitelikleri (1-99).
enum Attribute {
  shooting(AttributeKind.technical), // Şut
  finesse(AttributeKind.technical), // Plase
  passing(AttributeKind.technical), // Pas
  vision(AttributeKind.mental), // Vizyon
  dribbling(AttributeKind.technical), // Dribling
  pace(AttributeKind.physical), // Hız
  agility(AttributeKind.physical), // Çabukluk
  strength(AttributeKind.physical), // Güç
  stamina(AttributeKind.physical), // Dayanıklılık
  defending(AttributeKind.technical), // Defans
  ballControl(AttributeKind.technical), // Top Kontrolü
  heading(AttributeKind.technical), // Kafa Vuruşu
  setPieces(AttributeKind.technical), // Duran Top
  composure(AttributeKind.mental), // Sakinlik
  charisma(AttributeKind.mental); // Karizma

  const Attribute(this.kind);

  final AttributeKind kind;
}
