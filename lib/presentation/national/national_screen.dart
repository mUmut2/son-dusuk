import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/national/nation.dart';
import '../../domain/national/national_balance.dart';
import '../../domain/national/national_career.dart';
import '../../domain/national/national_engine.dart';
import '../../domain/national/tournament.dart';
import '../l10n_labels.dart';
import '../providers.dart';

/// Milli takım: kadro durumu, turnuva eşleşmeleri ve geçmiş turnuvalar.
class NationalScreen extends ConsumerWidget {
  const NationalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)!.state;
    final nat = career.national;
    final run = nat.current;
    final bracket = NationalEngine.tournamentOf(career);
    final textTheme = Theme.of(context).textTheme;

    final history = [
      for (final r in nat.past.reversed)
        if (r.season != run?.season) r,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.nationalTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.flag, size: 32),
                    title: Text(
                      NationalWorld.homeName,
                      style: textTheme.titleLarge,
                    ),
                    subtitle: Text(l10n.nationalCapsGoals(nat.caps, nat.goals)),
                  ),
                ),
                const SizedBox(height: 12),
                if (run != null && bracket != null) ...[
                  _RunCard(run: run),
                  const SizedBox(height: 16),
                  Text(l10n.nationalBracketTitle, style: textTheme.titleMedium),
                  for (var r = 0; r < bracket.rounds.length; r++) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.nationalRoundHeader(
                        l10n.roundName(r),
                        NationalBalance.firstRoundWeek + r,
                      ),
                      style: textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    for (final m in bracket.rounds[r])
                      _MatchRow(
                        match: m,
                        youPlayed:
                            m.involves(NationalWorld.homeId) &&
                            run.results.any((x) => x.round == r && x.played),
                      ),
                  ],
                ] else
                  _NextCard(season: career.season, week: career.week),
                if (nat.past.isEmpty && run == null) ...[
                  const SizedBox(height: 12),
                  Text(l10n.nationalEmpty, style: textTheme.bodyMedium),
                ],
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(l10n.nationalHistoryTitle, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  for (final r in history) _HistoryTile(record: r),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RunCard extends StatelessWidget {
  const _RunCard({required this.run});

  final TournamentRun run;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = run.champion
        ? l10n.nationalStatusChampion
        : run.lost
        ? l10n.nationalStatusEliminated
        : run.called
        ? l10n.nationalStatusCalled(l10n.nationalRoleName(run.role))
        : l10n.nationalStatusOmitted;
    final good = run.champion || (run.called && !run.lost);
    return Card(
      color: run.champion ? scheme.tertiaryContainer : scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              run.champion ? Icons.emoji_events : Icons.sports_soccer,
              size: 36,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.nationalHistoryLine(
                      l10n.tournamentName(run.kind),
                      run.season,
                    ),
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: good ? null : scheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.season, required this.week});

  final int season;
  final int week;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final upcoming =
        NationalEngine.isTournamentSeason(season) &&
            week < NationalBalance.firstRoundWeek
        ? season
        : (NationalEngine.isTournamentSeason(season) ? season + 2 : season + 1);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(
          l10n.nationalNextTournament(
            l10n.tournamentName(NationalEngine.kindOf(upcoming)),
            upcoming,
          ),
        ),
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match, required this.youPlayed});

  final BracketMatch match;
  final bool youPlayed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final mine = match.involves(NationalWorld.homeId);
    final winner = match.winner;

    TextStyle side(Nation? n) => TextStyle(
      fontWeight:
          n != null && (n.id == winner?.id || n.id == NationalWorld.homeId)
          ? FontWeight.w700
          : FontWeight.w400,
    );

    final score = match.decided ? '${match.goalsA} - ${match.goalsB}' : '-';
    final pens = match.pensA == null
        ? null
        : l10n.nationalPens('${match.pensA}-${match.pensB}');

    return Semantics(
      label:
          '${match.a?.name ?? '?'} $score ${match.b?.name ?? '?'}'
          '${pens == null ? '' : ' $pens'}',
      excludeSemantics: true,
      child: Card(
        color: mine ? scheme.primaryContainer : null,
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      match.a?.name ?? '?',
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: side(match.a),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: Text(
                      score,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.b?.name ?? '?',
                      overflow: TextOverflow.ellipsis,
                      style: side(match.b),
                    ),
                  ),
                ],
              ),
              if (pens != null || youPlayed)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    [?pens, if (youPlayed) l10n.nationalYouPlayed].join(' · '),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record});

  final TournamentRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = l10n.stageResult(record.stage);
    return Card(
      child: ListTile(
        leading: Icon(record.isTitle ? Icons.emoji_events : Icons.flag),
        title: Text(
          l10n.nationalHistoryLine(
            l10n.tournamentName(record.kind),
            record.season,
          ),
        ),
        subtitle: Text(
          record.called
              ? l10n.nationalHistorySub(
                  result,
                  record.appearances,
                  record.goals,
                )
              : l10n.nationalHistoryNotCalled(result),
        ),
      ),
    );
  }
}
