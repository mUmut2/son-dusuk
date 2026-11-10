import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/club/club_balance.dart';
import '../../domain/club/equipment.dart';
import '../../game/sound_service.dart';
import '../l10n_labels.dart';
import '../providers.dart';

IconData equipmentIcon(EquipmentSlot s) => switch (s) {
  EquipmentSlot.boots => Icons.sports_soccer,
  EquipmentSlot.trainingKit => Icons.fitness_center,
  EquipmentSlot.recoveryKit => Icons.spa,
  EquipmentSlot.shinGuards => Icons.shield,
};

Color _accent(EquipmentSlot s) => switch (s) {
  EquipmentSlot.boots => const Color(0xFFEF6C00),
  EquipmentSlot.trainingKit => const Color(0xFF1E88E5),
  EquipmentSlot.recoveryKit => const Color(0xFF00897B),
  EquipmentSlot.shinGuards => const Color(0xFF8E24AA),
};

/// Ana sayfa ve antrenman sekmesinden mağazaya giden kısa kart.
class EquipmentCard extends ConsumerWidget {
  const EquipmentCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)?.state;
    if (career == null) return const SizedBox.shrink();
    final owned = EquipmentSlot.values.fold<int>(
      0,
      (sum, s) => sum + career.equipment.level(s),
    );
    final total = EquipmentSlot.values.length * ClubBalance.equipmentMaxLevel;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.storefront),
        title: Text(l10n.equipmentTitle),
        subtitle: Text(
          owned == 0
              ? l10n.equipmentCardNone
              : l10n.equipmentCardOwned('$owned', '$total'),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/game/equipment'),
      ),
    );
  }
}

/// Ekipman mağazası: krampon, antrenman/toparlanma seti, tekmelik.
class EquipmentScreen extends ConsumerWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)?.state;
    if (career == null) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final equipment = career.equipment;
    final balance = career.finance.balance;
    final slots = EquipmentSlot.values;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.equipmentTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: scheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 32,
                          color: scheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.financeBalance,
                                style: textTheme.labelMedium?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                l10n.money(balance),
                                style: textTheme.headlineSmall?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(l10n.equipmentIntro, style: textTheme.bodySmall),
                const SizedBox(height: 16),
                Text(l10n.equipmentBonusTitle, style: textTheme.titleSmall),
                const SizedBox(height: 8),
                _BonusSummary(equipment: equipment),
                const SizedBox(height: 20),
                for (var i = 0; i < slots.length; i += 2) ...[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final slot in slots.skip(i).take(2)) ...[
                          if (slot != slots[i]) const SizedBox(width: 12),
                          Expanded(
                            child: _SlotTile(
                              slot: slot,
                              equipment: equipment,
                              balance: balance,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sahip olunan ekipmanların toplam etkisi, kısa etiketlerle.
class _BonusSummary extends StatelessWidget {
  const _BonusSummary({required this.equipment});

  final Equipment equipment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final owned = [
      for (final s in EquipmentSlot.values)
        if (equipment.level(s) > 0) s,
    ];
    if (owned.isEmpty) {
      return Text(
        l10n.equipmentBonusNone,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in owned)
          Chip(
            avatar: Icon(equipmentIcon(s), size: 18, color: _accent(s)),
            label: Text(l10n.equipmentBonusShort(s, equipment.level(s))),
          ),
      ],
    );
  }
}

class _SlotTile extends ConsumerWidget {
  const _SlotTile({
    required this.slot,
    required this.equipment,
    required this.balance,
  });

  final EquipmentSlot slot;
  final Equipment equipment;
  final int balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = _accent(slot);
    final level = equipment.level(slot);
    final price = equipment.nextPrice(slot);
    final title = level == 0
        ? l10n.equipmentSlotName(slot)
        : l10n.equipmentItemName(slot, level);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: accent.withValues(alpha: 0.18),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: accent,
                  child: Icon(
                    equipmentIcon(slot),
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _Pips(level: level, color: accent),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleSmall),
                  Text(
                    level == 0
                        ? l10n.equipmentEmpty
                        : l10n.equipmentLevel(
                            '$level',
                            '${ClubBalance.equipmentMaxLevel}',
                          ),
                    style: textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  if (level > 0)
                    Text(
                      l10n.equipmentEffect(slot, level),
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (price != null) ...[
                    if (level > 0) const SizedBox(height: 6),
                    Text(
                      l10n.equipmentNext(
                        l10n.equipmentItemName(slot, level + 1),
                      ),
                      style: textTheme.labelMedium,
                    ),
                    Text(
                      l10n.equipmentEffect(slot, level + 1),
                      style: textTheme.bodySmall,
                    ),
                  ],
                  const Spacer(),
                  const SizedBox(height: 10),
                  if (price != null)
                    _BuyButton(
                      slot: slot,
                      level: level,
                      price: price,
                      balance: balance,
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified, size: 18, color: accent),
                        const SizedBox(width: 6),
                        Text(l10n.equipmentMaxed, style: textTheme.labelLarge),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuyButton extends ConsumerWidget {
  const _BuyButton({
    required this.slot,
    required this.level,
    required this.price,
    required this.balance,
  });

  final EquipmentSlot slot;
  final int level;
  final int price;
  final int balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final affordable = balance >= price;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: affordable
              ? () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final name = l10n.equipmentItemName(slot, level + 1);
                  await ref
                      .read(activeCareerProvider.notifier)
                      .buyEquipment(slot);
                  ref.playSfx(Sfx.buy);
                  messenger
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(l10n.equipmentBought(name))),
                    );
                }
              : null,
          child: Text(l10n.equipmentBuy(l10n.money(price))),
        ),
        if (!affordable)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.equipmentShort(l10n.money(price - balance)),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }
}

/// Seviye göstergesi: dolu/boş yıldızlar.
class _Pips extends StatelessWidget {
  const _Pips({required this.level, required this.color});

  final int level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= ClubBalance.equipmentMaxLevel; i++)
          Icon(
            i <= level ? Icons.star : Icons.star_border,
            size: 20,
            color: i <= level ? color : color.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
