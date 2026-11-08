import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../data/save_repository.dart';
import '../l10n_labels.dart';
import '../providers.dart';
import '../widgets/player_avatar.dart';

/// Açılış ekranı: 3 kayıt slotu.
class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final slots = ref.watch(saveSlotsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.simulatorTitle,
            icon: const Icon(Icons.leaderboard),
            onPressed: () => context.push('/simulator'),
          ),
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.tagline,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                for (final info in slots) _SlotCard(info: info),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlotCard extends ConsumerWidget {
  const _SlotCard({required this.info});

  final SlotInfo info;

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    switch (info.status) {
      case SlotStatus.empty:
        await context.push('/create/${info.slot}');
      case SlotStatus.ok:
        ref.read(activeCareerProvider.notifier).open(info.slot, info.career!);
        context.go('/game');
      case SlotStatus.corrupt:
        await _confirmDelete(context, ref);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final message = info.career == null
        ? l10n.deleteCorruptConfirm
        : l10n.deleteSaveConfirm(info.career!.player.name);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSave),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(saveSlotsProvider.notifier).delete(info.slot);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = info.career;
    final player = career?.player;

    final String subtitle;
    switch (info.status) {
      case SlotStatus.empty:
        subtitle = l10n.slotEmpty;
      case SlotStatus.corrupt:
        subtitle = l10n.slotCorrupt;
      case SlotStatus.ok:
        subtitle = career!.retired
            ? l10n.slotRetired(
                player!.age,
                career.history.fold<int>(
                  player.overall,
                  (a, r) => r.overall > a ? r.overall : a,
                ),
              )
            : l10n.slotSummary(
                player!.age,
                l10n.positionName(player.position),
                player.overall,
              );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onTap(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (player != null)
                PlayerAvatar(appearance: player.appearance, size: 56)
              else
                const SizedBox.square(
                  dimension: 56,
                  child: Icon(Icons.add_circle_outline, size: 40),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player?.name ?? l10n.slotTitle(info.slot + 1),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                    if (career != null)
                      Text(l10n.seasonWeek(career.season, career.week)),
                  ],
                ),
              ),
              if (info.status != SlotStatus.empty)
                IconButton(
                  tooltip: l10n.deleteSave,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, ref),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
