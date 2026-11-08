import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../l10n_labels.dart';
import '../providers.dart';
import '../widgets/player_avatar.dart';

/// Ana sayfa: oyuncu kartı ve sıradaki maç yer tutucusu.
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)!.state;
    final player = career.player;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                PlayerAvatar(appearance: player.appearance, size: 72),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(player.name, style: textTheme.titleLarge),
                      Text(
                        '${l10n.positionName(player.position)} · '
                        '${l10n.ageYears(player.age)}',
                      ),
                      Text(l10n.seasonWeek(career.season, career.week)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('${player.overall}', style: textTheme.displaySmall),
                    Text(l10n.overallLabel, style: textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: Text(l10n.nextMatch),
            subtitle: Text(l10n.nextMatchPlaceholder),
          ),
        ),
      ],
    );
  }
}
