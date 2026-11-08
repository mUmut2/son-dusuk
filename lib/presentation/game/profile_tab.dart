import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/player/attribute.dart';
import '../l10n_labels.dart';
import '../providers.dart';

/// Profil: görünür nitelikler (gizli nitelikler gösterilmez).
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final player = ref.watch(activeCareerProvider)!.state.player;
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
