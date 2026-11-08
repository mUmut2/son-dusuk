import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/club/squad.dart';
import '../l10n_labels.dart';
import '../providers.dart';
import '../widgets/player_avatar.dart';
import '../widgets/status_meters.dart';

/// Ana sayfa: oyuncu kartı ve sıradaki maç yer tutucusu.
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)!.state;
    final player = career.player;
    final textTheme = Theme.of(context).textTheme;
    final world = ref.watch(clubWorldProvider);
    final clubId = career.contract?.clubId;
    final clubName = clubId == null ? null : world!.team(clubId).name;
    final leagueName = clubId == null ? null : l10n.tierName(world!.tierOf(clubId));

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
                      if (clubName != null)
                        Text(l10n.homeClubLine(clubName, leagueName!)),
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
        const SizedBox(height: 12),
        if (career.status.isInjured)
          InjuryBanner(injury: career.status.injury!),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StatusMeters(status: career.status),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: Text('${l10n.thisWeek}: ${l10n.phaseName(career.week)}'),
            subtitle: Text(
              switch (Squad.matchDay(career)) {
                MatchDay.injured => l10n.injuredNoMatch,
                MatchDay.benched => l10n.benchedThisWeek,
                MatchDay.play => l10n.matchThisWeek,
                MatchDay.none =>
                  career.isFreeAgent
                      ? l10n.freeAgentNoMatch
                      : l10n.noMatchThisWeek,
              },
            ),
          ),
        ),
        if (career.offers.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text(l10n.offersWaiting(career.offers.length)),
              onTap: () => context.go('/game/club'),
            ),
          ),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          icon: const Icon(Icons.event_available),
          label: Text(l10n.goTraining),
          onPressed: () => context.go('/game/training'),
        ),
      ],
    );
  }
}
