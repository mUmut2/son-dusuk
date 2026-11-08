import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/career/retirement.dart';
import '../l10n_labels.dart';
import '../providers.dart';
import '../widgets/player_avatar.dart';

/// Kariyer özeti. Emekli olduktan sonra kariyerin son ekranıdır; emeklilikten
/// önce de "şimdiye kadar" görünümüyle açılabilir.
class CareerSummaryScreen extends ConsumerWidget {
  const CareerSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Menüye dönerken kariyer kapanır; geçiş animasyonunda boş kalabilir.
    final active = ref.watch(activeCareerProvider);
    final world = ref.watch(clubWorldProvider);
    if (active == null || world == null) return const Scaffold();
    final career = active.state;
    final player = career.player;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final retired = career.retired;

    final contract = career.contract;
    final summary = CareerSummary.of(
      career,
      tier: contract == null ? null : world.tierOf(contract.clubId),
    );

    final stats = <(String, String)>[
      (l10n.sumStat_matches, '${summary.matches}'),
      (l10n.sumStat_goals, '${summary.goals}'),
      (l10n.sumStat_assists, '${summary.assists}'),
      (
        l10n.sumStat_rating,
        summary.matches == 0 ? '-' : summary.averageRating.toStringAsFixed(2),
      ),
      (l10n.sumStat_seasons, '${summary.seasons}'),
      (l10n.sumStat_peak, '${summary.peakOverall}'),
      (l10n.sumStat_clubs, '${summary.clubs}'),
      (
        l10n.sumStat_bestLeague,
        summary.bestTier == 0 ? '-' : l10n.tierName(summary.bestTier),
      ),
      (l10n.sumStat_titles, '${summary.leagueTitles}'),
      (l10n.sumStat_caps, '${summary.caps}'),
      (l10n.sumStat_natTitles, '${summary.nationalTitles}'),
      (l10n.sumStat_achievements, '${summary.achievements}'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(retired ? l10n.summaryTitleRetired : l10n.summaryTitleLive),
        automaticallyImplyLeading: !retired,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
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
                              Text(l10n.positionName(player.position)),
                              Text(
                                retired
                                    ? l10n.summaryRetiredAt(player.age)
                                    : l10n.ageYears(player.age),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: scheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(l10n.summaryLegacy, style: textTheme.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                          l10n.legacyName(summary.rank),
                          style: textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.legacyBlurb(summary.rank),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < stats.length; i += 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(child: _StatBox(stat: stats[i])),
                        const SizedBox(width: 8),
                        Expanded(
                          child: i + 1 < stats.length
                              ? _StatBox(stat: stats[i + 1])
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: Text(l10n.summaryBalance),
                    trailing: Text(
                      l10n.money(career.finance.balance),
                      style: textTheme.titleMedium,
                    ),
                  ),
                ),
                if (career.history.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(l10n.summarySeasonsTitle, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  for (final r in career.history.reversed)
                    Card(
                      child: ListTile(
                        leading: r.champion
                            ? const Icon(Icons.emoji_events)
                            : const Icon(Icons.calendar_today),
                        title: Text(l10n.summarySeasonTitle(r.season, r.age)),
                        subtitle: Text(
                          [
                            l10n.summarySeasonSub(
                              r.clubId == null
                                  ? l10n.summaryNoClub
                                  : world.team(r.clubId!).name,
                              r.tier == 0 ? '-' : l10n.tierName(r.tier),
                            ),
                            l10n.summarySeasonStats(
                              r.matches,
                              r.goals,
                              r.assists,
                            ),
                            if (r.position > 0)
                              l10n.summaryPosition(r.position),
                          ].join('\n'),
                        ),
                        isThreeLine: r.position > 0,
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: Text(l10n.summaryOpenAchievements),
                  onPressed: () => context.push('/game/achievements'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: () {
                    if (retired) {
                      ref.read(activeCareerProvider.notifier).close();
                      context.go('/');
                    } else {
                      context.pop();
                    }
                  },
                  child: Text(retired ? l10n.summaryToMenu : l10n.summaryBack),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.stat});

  final (String, String) stat;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: '${stat.$1} ${stat.$2}',
      excludeSemantics: true,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stat.$2, style: textTheme.headlineSmall),
              Text(
                stat.$1,
                style: textTheme.labelMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
