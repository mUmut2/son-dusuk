import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/career/season_calendar.dart';
import '../../domain/club/squad.dart';
import '../../domain/national/national_engine.dart';
import '../../domain/career/weekly_plan.dart';
import '../equipment/equipment_screen.dart';
import '../l10n_labels.dart';
import '../providers.dart';
import '../widgets/status_meters.dart';

/// Haftalık plan: antrenman odağı, yoğunluk, sosyal hayat.
class TrainingTab extends ConsumerWidget {
  const TrainingTab({super.key});

  Future<void> _confirmEarlyReturn(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.earlyReturn),
        content: Text(l10n.earlyReturnBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.earlyReturnConfirm),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(activeCareerProvider.notifier).returnEarly();
    }
  }

  Future<void> _play(BuildContext context, WidgetRef ref, bool match) async {
    if (match) {
      await context.push('/game/match');
      return;
    }
    await ref.read(activeCareerProvider.notifier).playWeek(null);
    if (!context.mounted) return;
    context.go('/game/week');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)!.state;
    final plan = ref.watch(weeklyPlanProvider);
    final planNotifier = ref.read(weeklyPlanProvider.notifier);
    final status = career.status;
    final injured = status.isInjured;
    final matchDay = Squad.matchDay(career);
    final nationalDay = NationalEngine.dayOf(career);
    final nationalMatch = nationalDay == NationalDay.play;
    final matchWeek = matchDay == MatchDay.play || nationalMatch;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.trainingTitle, style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '${l10n.weekHeader(career.season, career.week)} · '
          '${l10n.phaseName(career.week)}',
        ),
        if (SeasonCalendar.isTransferWindow(career.week))
          Text(l10n.transferWindowOpen, style: textTheme.bodySmall),
        const SizedBox(height: 12),
        if (injured) ...[
          InjuryBanner(injury: status.injury!),
          Text(l10n.injuredNoTraining, style: textTheme.bodySmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            icon: const Icon(Icons.warning_amber),
            label: Text(l10n.earlyReturn),
            onPressed: () => _confirmEarlyReturn(context, ref),
          ),
          const SizedBox(height: 12),
        ],
        StatusMeters(status: status),
        const SizedBox(height: 16),
        _Section(
          title: l10n.focusLabel,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in TrainingFocus.values)
                ChoiceChip(
                  label: Text(l10n.focusName(f)),
                  selected: (injured ? TrainingFocus.rest : plan.focus) == f,
                  onSelected: injured ? null : (_) => planNotifier.setFocus(f),
                ),
            ],
          ),
        ),
        _Section(
          title: l10n.intensityLabel,
          child: SegmentedButton<TrainingIntensity>(
            segments: [
              for (final i in TrainingIntensity.values)
                ButtonSegment(value: i, label: Text(l10n.intensityName(i))),
            ],
            selected: {plan.intensity},
            onSelectionChanged: injured
                ? null
                : (s) => planNotifier.setIntensity(s.first),
          ),
        ),
        _Section(
          title: l10n.socialLabel,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in SocialActivity.values)
                ChoiceChip(
                  label: Text(l10n.socialName(s)),
                  selected: plan.social == s,
                  onSelected: (_) => planNotifier.setSocial(s),
                ),
            ],
          ),
        ),
        if (matchDay == MatchDay.benched)
          Text(l10n.benchedThisWeek, style: textTheme.bodySmall),
        if (nationalDay != NationalDay.none)
          Text(
            l10n.nationalDayText(
              nationalDay,
              opponent: NationalEngine.opponentOf(career)?.name ?? '',
            ),
            style: textTheme.bodySmall,
          ),
        if (career.isFreeAgent)
          Text(l10n.freeAgentNoMatch, style: textTheme.bodySmall),
        Text(l10n.trainingHint, style: textTheme.bodySmall),
        const SizedBox(height: 16),
        const EquipmentCard(),
        const SizedBox(height: 16),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: () => _play(context, ref, matchWeek),
          child: Text(
            nationalMatch
                ? l10n.playWeekNationalMatch
                : matchWeek
                ? l10n.playWeekMatch
                : l10n.playWeekNoMatch,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
