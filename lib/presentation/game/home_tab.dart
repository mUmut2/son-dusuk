import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/career/career_state.dart';
import '../../domain/club/squad.dart';
import '../../domain/national/national_balance.dart';
import '../../domain/national/national_engine.dart';
import '../equipment/equipment_screen.dart';
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
    final leagueName = clubId == null
        ? null
        : l10n.tierName(world!.tierOf(clubId));
    final nationalDay = NationalEngine.dayOf(career);

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
            subtitle: Text(switch (Squad.matchDay(career)) {
              MatchDay.injured => l10n.injuredNoMatch,
              MatchDay.benched => l10n.benchedThisWeek,
              MatchDay.play => l10n.matchThisWeek,
              MatchDay.none =>
                nationalDay != NationalDay.none
                    ? l10n.nationalDayText(
                        nationalDay,
                        opponent: NationalEngine.opponentOf(career)?.name ?? '',
                      )
                    : career.isFreeAgent
                    ? l10n.freeAgentNoMatch
                    : l10n.noMatchThisWeek,
            }),
          ),
        ),
        _NationalCard(career: career),
        const SizedBox(height: 12),
        const EquipmentCard(),
        if (career.pendingEvents.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.forum),
              title: Text(l10n.pendingEventsCard(career.pendingEvents.length)),
              subtitle: Text(l10n.pendingEventsHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/game/social'),
            ),
          ),
        ],
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

/// Milli takım durumu: çağrılma, sıradaki tur ya da yaklaşan turnuva.
class _NationalCard extends StatelessWidget {
  const _NationalCard({required this.career});

  final CareerState career;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final run = career.national.current;

    String? text;
    var icon = Icons.flag;
    if (run != null && run.season == career.season) {
      final name = l10n.tournamentName(run.kind);
      if (run.champion) {
        text = l10n.homeNationalChampion(name);
        icon = Icons.emoji_events;
      } else if (run.lost) {
        text = l10n.homeNationalOut(name);
      } else if (run.results.isEmpty && run.called) {
        text = l10n.homeNationalCalled(name);
      } else {
        final round = run.nextRound.clamp(0, NationalBalance.roundCount - 1);
        final opponent = NationalEngine.tournamentOf(
          career,
        )?.opponentOfHome(round)?.name;
        text = l10n.homeNationalRound(
          name,
          l10n.roundName(round),
          opponent ?? '?',
        );
      }
    } else if (NationalEngine.isTournamentSeason(career.season) &&
        career.week >= 30 &&
        career.week < NationalBalance.firstRoundWeek) {
      text = l10n.homeNationalNext(
        l10n.tournamentName(NationalEngine.kindOf(career.season)),
      );
    }
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(text),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/game/national'),
        ),
      ),
    );
  }
}
