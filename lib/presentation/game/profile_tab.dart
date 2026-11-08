import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/achievements/achievements.dart';
import '../../domain/career/legacy_balance.dart';
import '../../domain/career/retirement.dart';
import '../../domain/player/attribute.dart';
import '../l10n_labels.dart';
import '../providers.dart';

/// Profil: görünür nitelikler (gizli nitelikler gösterilmez).
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  Future<void> _confirmRetire(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.retireTitle),
        content: Text(l10n.retireBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.retireConfirm),
          ),
        ],
      ),
    );
    if (!(ok ?? false)) return;
    await ref.read(activeCareerProvider.notifier).retire();
    if (!context.mounted) return;
    context.go('/game/summary');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Menüye dönerken kariyer kapanır; geçiş animasyonunda boş kalabilir.
    final active = ref.watch(activeCareerProvider);
    if (active == null) return const SizedBox.shrink();
    final career = active.state;
    final player = career.player;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(player.name, style: textTheme.headlineSmall),
        Text(
          '${l10n.positionName(player.position)} · '
          '${l10n.footLabel}: ${l10n.footName(player.foot)}',
        ),
        Text(l10n.birthplaceValue(player.birthplace)),
        const SizedBox(height: 16),
        Text(l10n.profileCareerSection, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.flag),
            title: Text(l10n.profileNationalCard),
            subtitle: Text(
              l10n.profileNationalSub(
                career.national.caps,
                career.national.goals,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/game/national'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.emoji_events),
            title: Text(l10n.profileAchievementsCard),
            subtitle: Text(
              l10n.profileAchievementsSub(
                career.achievements.length,
                Achievement.values.length,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/game/achievements'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.assessment),
            title: Text(l10n.profileSummaryCard),
            subtitle: Text(l10n.profileSummarySub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/game/summary'),
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.attributesTitle, style: textTheme.titleMedium),
        for (final kind in AttributeKind.values) ...[
          const SizedBox(height: 12),
          Text(l10n.kindName(kind), style: textTheme.titleSmall),
          for (final a in Attribute.values.where((a) => a.kind == kind))
            _AttributeRow(
              label: l10n.attributeName(a),
              value: player.attributes[a],
            ),
        ],
        const SizedBox(height: 24),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          icon: const Icon(Icons.sports_score),
          label: Text(l10n.retireButton),
          onPressed: Retirement.canRetire(career)
              ? () => _confirmRetire(context, ref)
              : null,
        ),
        if (!Retirement.canRetire(career))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.retireAgeHint(LegacyBalance.voluntaryAge),
              style: textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          icon: const Icon(Icons.logout),
          label: Text(l10n.backToMenu),
          onPressed: () {
            ref.read(activeCareerProvider.notifier).close();
            context.go('/');
          },
        ),
      ],
    );
  }
}

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 120, child: Text(label)),
            Expanded(
              child: LinearProgressIndicator(
                value: value / 99,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text('$value', textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }
}
