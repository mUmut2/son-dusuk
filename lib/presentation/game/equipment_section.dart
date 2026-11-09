import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/club/club_balance.dart';
import '../../domain/club/equipment.dart';
import '../l10n_labels.dart';
import '../providers.dart';

/// Ekipman mağazası: krampon, antrenman/toparlanma seti, tekmelik.
class EquipmentSection extends ConsumerWidget {
  const EquipmentSection({super.key});

  static IconData icon(EquipmentSlot s) => switch (s) {
    EquipmentSlot.boots => Icons.sports_soccer,
    EquipmentSlot.trainingKit => Icons.fitness_center,
    EquipmentSlot.recoveryKit => Icons.spa,
    EquipmentSlot.shinGuards => Icons.shield,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)?.state;
    if (career == null) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.equipmentTitle, style: textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(l10n.equipmentIntro, style: textTheme.bodySmall),
        const SizedBox(height: 8),
        for (final slot in EquipmentSlot.values)
          _EquipmentCard(
            slot: slot,
            equipment: career.equipment,
            balance: career.finance.balance,
          ),
      ],
    );
  }
}

class _EquipmentCard extends ConsumerWidget {
  const _EquipmentCard({
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
    final level = equipment.level(slot);
    final price = equipment.nextPrice(slot);
    final title = level == 0
        ? l10n.equipmentSlotName(slot)
        : l10n.equipmentItemName(slot, level);
    final effect = level == 0 ? null : l10n.equipmentEffect(slot, level);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(EquipmentSection.icon(slot), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleSmall),
                      Text(
                        l10n.equipmentLevel(
                          '$level',
                          '${ClubBalance.equipmentMaxLevel}',
                        ),
                        style: textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: level / ClubBalance.equipmentMaxLevel,
            ),
            const SizedBox(height: 6),
            if (effect != null) Text(effect, style: textTheme.bodySmall),
            if (price != null) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.equipmentNext(l10n.equipmentItemName(slot, level + 1))} — '
                '${l10n.equipmentEffect(slot, level + 1)}',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(l10n.equipmentBuy(l10n.money(price))),
                  onPressed: balance < price
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final name = l10n.equipmentItemName(slot, level + 1);
                          await ref
                              .read(activeCareerProvider.notifier)
                              .buyEquipment(slot);
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.equipmentBought(name))),
                          );
                        },
                ),
              ),
            ] else
              Align(
                alignment: Alignment.centerRight,
                child: Text(l10n.equipmentMaxed, style: textTheme.labelLarge),
              ),
          ],
        ),
      ),
    );
  }
}
