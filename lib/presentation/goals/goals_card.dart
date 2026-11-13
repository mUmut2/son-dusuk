import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/goals/goal_balance.dart';
import '../../domain/goals/goal_engine.dart';
import '../../domain/goals/goal_models.dart';
import '../l10n_labels.dart';
import '../providers.dart';

IconData goalIcon(GoalKind k) => switch (k) {
  GoalKind.scoreGoal => Icons.sports_soccer,
  GoalKind.assist => Icons.handshake,
  GoalKind.rating7 => Icons.star,
  GoalKind.winMatch => Icons.emoji_events,
  GoalKind.trainHard => Icons.fitness_center,
  GoalKind.postFeed => Icons.alternate_email,
  GoalKind.noBetting => Icons.block,
};

/// Ana sayfadaki haftalık hedefler ve seri kartı.
class GoalsCard extends ConsumerWidget {
  const GoalsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)?.state;
    if (career == null || career.retired) return const SizedBox.shrink();
    final intensity = ref.watch(weeklyPlanProvider).intensity;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final goals = GoalEngine.forWeek(career);
    final g = career.goals;
    final lastWeekEvaluated =
        g.lastWeek == career.absoluteWeek - 1 && g.lastWeek > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag_circle),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.goalsTitle,
                        style: textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                if (g.streak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Color(0xFFEF6C00),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            l10n.goalsStreak(g.streak),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelLarge?.copyWith(
                              color: scheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (final k in goals)
              _GoalRow(
                kind: k,
                status: GoalEngine.statusNow(k, career, intensity: intensity),
              ),
            const SizedBox(height: 8),
            Text(
              l10n.goalsReward(
                l10n.money(GoalEngine.rewardPerGoal(career)),
                l10n.money(GoalEngine.allDoneBonus(career)),
              ),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            Text(
              l10n.goalsHint,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (lastWeekEvaluated) ...[
              const SizedBox(height: 4),
              Text(
                l10n.goalsLastWeek(
                  '${g.lastDone}',
                  '${GoalBalance.perWeek}',
                  l10n.money(g.lastReward),
                ),
                style: textTheme.labelMedium,
              ),
            ],
            if (g.best > 0)
              Text(l10n.goalsBest(g.best), style: textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.kind, required this.status});

  final GoalKind kind;
  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (icon, color, label) = switch (status) {
      GoalStatus.done => (
        Icons.check_circle,
        const Color(0xFF43A047),
        l10n.goalDone,
      ),
      GoalStatus.failed => (Icons.cancel, scheme.error, l10n.goalFailed),
      GoalStatus.pending => (
        Icons.radio_button_unchecked,
        scheme.outline,
        l10n.goalPending,
      ),
    };
    return Semantics(
      label: '${l10n.goalName(kind)}: $label',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Icon(goalIcon(kind), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.goalName(kind),
                style: status == GoalStatus.done
                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
