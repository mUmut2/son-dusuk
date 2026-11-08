import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/achievements/achievements.dart';
import '../../domain/career/season_calendar.dart';
import '../l10n_labels.dart';
import '../providers.dart';

/// Başarım listesi: kategoriye göre, açılanlar renkli, kilitliler soluk.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)!.state;
    final textTheme = Theme.of(context).textTheme;
    final total = Achievement.values.length;
    final done = career.achievements.length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.achievementsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Text(
                      l10n.achievementsProgress(done, total),
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Semantics(
                        label: l10n.achievementsProgress(done, total),
                        excludeSemantics: true,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : done / total,
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                for (final category in AchievementCategory.values) ...[
                  const SizedBox(height: 20),
                  Text(
                    l10n.achievementCategoryName(category),
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  for (final a in Achievement.values.where(
                    (a) => a.category == category,
                  ))
                    _AchievementTile(
                      achievement: a,
                      unlockedAt: career.achievements[a.name],
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement, required this.unlockedAt});

  final Achievement achievement;

  /// Açıldığı mutlak hafta; kilitliyse null.
  final int? unlockedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final unlocked = unlockedAt != null;
    final title = l10n.achievementTitle(achievement);
    final desc = l10n.achievementDesc(achievement);

    String? when;
    if (unlockedAt != null) {
      final w = unlockedAt! - 1;
      when = l10n.seasonWeek(
        w ~/ SeasonCalendar.weeksPerSeason + 1,
        w % SeasonCalendar.weeksPerSeason + 1,
      );
    }

    return Semantics(
      label: '$title. $desc. ${unlocked ? when : l10n.achLocked}',
      excludeSemantics: true,
      child: Card(
        color: unlocked ? scheme.primaryContainer : null,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: unlocked
                ? scheme.primary
                : scheme.surfaceContainerHighest,
            foregroundColor: unlocked
                ? scheme.onPrimary
                : scheme.onSurfaceVariant,
            child: Icon(unlocked ? achievementIcon(achievement) : Icons.lock),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: unlocked ? null : scheme.onSurfaceVariant,
            ),
          ),
          subtitle: Text(desc),
          trailing: when == null
              ? null
              : Text(when, style: Theme.of(context).textTheme.labelSmall),
        ),
      ),
    );
  }
}

/// Her başarım için bir simge.
IconData achievementIcon(Achievement a) => switch (a) {
  Achievement.firstMatch => Icons.sports,
  Achievement.firstGoal => Icons.sports_soccer,
  Achievement.firstAssist => Icons.handshake,
  Achievement.goals10 => Icons.looks_one,
  Achievement.goals50 => Icons.local_fire_department,
  Achievement.goals150 => Icons.whatshot,
  Achievement.goals400 => Icons.bolt,
  Achievement.matches50 => Icons.event_available,
  Achievement.matches250 => Icons.directions_run,
  Achievement.matches500 => Icons.shield,
  Achievement.hatTrick => Icons.filter_3,
  Achievement.starPerformance => Icons.star,
  Achievement.seasons10 => Icons.calendar_month,
  Achievement.veteran => Icons.military_tech,
  Achievement.firstTransfer => Icons.swap_horiz,
  Achievement.topLeague => Icons.stadium,
  Achievement.leagueChampion => Icons.emoji_events,
  Achievement.topLeagueChampion => Icons.workspace_premium,
  Achievement.loyal => Icons.favorite,
  Achievement.agentTop => Icons.contact_phone,
  Achievement.nationalDebut => Icons.flag,
  Achievement.nationalGoal => Icons.flag_circle,
  Achievement.nationalFinal => Icons.sports_score,
  Achievement.continentalChampion => Icons.public,
  Achievement.worldChampion => Icons.emoji_events,
  Achievement.overall70 => Icons.trending_up,
  Achievement.overall80 => Icons.rocket_launch,
  Achievement.overall90 => Icons.auto_awesome,
  Achievement.fanIdol => Icons.groups,
  Achievement.comfortable => Icons.savings,
  Achievement.millionaire => Icons.diamond,
  Achievement.tycoon => Icons.account_balance,
};
