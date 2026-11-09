import '../player/player.dart';
import 'club_balance.dart';

/// Satın alınabilir ekipman türleri. Her birinin 3 seviyesi vardır.
enum EquipmentSlot {
  /// Maçta şut/dribling/çabukluk gibi niteliklere artı verir.
  boots,

  /// Haftalık antrenman kazancını artırır.
  trainingKit,

  /// Haftalık kondisyon toparlanmasını artırır.
  recoveryKit,

  /// Sakatlanma riskini azaltır.
  shinGuards,
}

/// Oyuncunun sahip olduğu ekipmanlar (slot -> seviye 0-3). Saf Dart, immutable.
class Equipment {
  const Equipment([this.levels = const {}]);

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment({
    for (final s in EquipmentSlot.values)
      if (json[s.name] is int)
        s.name: (json[s.name] as int).clamp(0, ClubBalance.equipmentMaxLevel),
  });

  final Map<String, int> levels;

  int level(EquipmentSlot s) => levels[s.name] ?? 0;

  bool isMaxed(EquipmentSlot s) => level(s) >= ClubBalance.equipmentMaxLevel;

  /// Bir sonraki seviyenin fiyatı; son seviyedeyse null.
  int? nextPrice(EquipmentSlot s) =>
      isMaxed(s) ? null : ClubBalance.equipmentPrice[s]![level(s)];

  Equipment upgrade(EquipmentSlot s) =>
      Equipment({...levels, s.name: level(s) + 1});

  /// Maçlarda nitelik artısı (krampon).
  int get bootsBonus =>
      ClubBalance.bootsBonusPerLevel * level(EquipmentSlot.boots);

  /// Antrenman kazancı çarpanı (1.0 = ekipmansız).
  double get trainingMultiplier =>
      1 + ClubBalance.trainingKitPerLevel * level(EquipmentSlot.trainingKit);

  /// Haftalık ek kondisyon toparlanması.
  double get recoveryBonus =>
      ClubBalance.recoveryKitPerLevel * level(EquipmentSlot.recoveryKit);

  /// Sakatlık riski çarpanı (1.0 = ekipmansız, daha düşük = daha az risk).
  double get injuryMultiplier =>
      1 - ClubBalance.shinGuardsPerLevel * level(EquipmentSlot.shinGuards);

  /// Maç/mini oyunlar için kramponun nitelik artısını uygulanmış oyuncu.
  /// Kayda yazılmaz; yalnızca o anki oynanışta kullanılır.
  Player applyToPlayer(Player p) {
    final bonus = bootsBonus;
    if (bonus == 0) return p;
    return p.copyWith(
      attributes: p.attributes.copyWith({
        for (final a in ClubBalance.bootsAttributes)
          a: p.attributes.raw(a) + bonus,
      }),
    );
  }

  Map<String, dynamic> toJson() => levels;
}
