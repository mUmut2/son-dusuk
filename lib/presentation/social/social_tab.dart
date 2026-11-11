import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/career/career_state.dart';
import '../../domain/social/event_catalog.dart';
import '../../domain/social/event_models.dart';
import '../../domain/social/relationships.dart';
import '../event_texts.dart';
import '../l10n_labels.dart';
import '../providers.dart';
import 'feed_widgets.dart';
import 'social_visuals.dart';

/// Sosyal sekmesi: "Gelişmeler" (cevap bekleyenler, ilişkiler, haberler) ve
/// "Akış" (sosyal ağ paylaşımları ve yorumlar).
class SocialTab extends ConsumerStatefulWidget {
  const SocialTab({super.key});

  @override
  ConsumerState<SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends ConsumerState<SocialTab> {
  bool _feed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.forum_outlined),
                  label: Text(l10n.feedSegmentEvents),
                ),
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.alternate_email),
                  label: Text(l10n.feedSegmentFeed),
                ),
              ],
              selected: {_feed},
              onSelectionChanged: (v) => setState(() => _feed = v.first),
            ),
          ),
        ),
        Expanded(child: _feed ? const FeedView() : const _EventsView()),
      ],
    );
  }
}

class _EventsView extends ConsumerWidget {
  const _EventsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)!.state;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.socialTitle, style: textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text(l10n.socialPending, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        if (career.pendingEvents.isEmpty)
          _EmptyState(
            icon: Icons.mark_email_read_outlined,
            text: l10n.socialNoPending,
          )
        else
          for (final p in career.pendingEvents)
            _PendingCard(event: p, career: career),
        const SizedBox(height: 24),
        Text(l10n.socialRelations, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (final r in Relation.values)
                  _RelationRow(relation: r, value: career.relations[r]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.socialNews, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        _NewsFeed(career: career),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.outline, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.event, required this.career});

  final PendingEvent event;
  final CareerState career;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final template = EventCatalog.byId(event.id);
    final texts = l10n.eventTexts(event.id, event.params);
    final weeksLeft = event.expiresAt - career.absoluteWeek + 1;
    final urgent = weeksLeft <= 1;

    return Card(
      color: scheme.primaryContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/game/event/${event.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: Icon(eventKindIcon(template.kind)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.eventKindName(template.kind),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      texts.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      urgent
                          ? l10n.eventExpiresLast
                          : l10n.eventExpires(weeksLeft),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: urgent
                            ? scheme.error
                            : scheme.onPrimaryContainer,
                        fontWeight: urgent ? FontWeight.w700 : null,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelationRow extends StatelessWidget {
  const _RelationRow({required this.relation, required this.value});

  final Relation relation;
  final double value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final color = relationColor(context, value);

    return Semantics(
      label:
          '${l10n.relationName(relation)}: ${l10n.relationLevel(value)}, '
          '${value.round()}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(relationIcon(relation), color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.relationName(relation),
                          style: textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        l10n.relationLevel(value),
                        style: textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: value / 100),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 8,
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.relationHint(relation),
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _NewsFeed extends ConsumerWidget {
  const _NewsFeed({required this.career});

  final CareerState career;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final world = ref.watch(clubWorldProvider)!;
    if (career.news.isEmpty) {
      return _EmptyState(icon: Icons.newspaper, text: l10n.socialNewsEmpty);
    }
    return Card(
      child: Column(
        children: [
          for (final n in career.news.take(12))
            ListTile(
              dense: true,
              leading: Icon(newsIcon(n.kind)),
              title: Text(l10n.newsText(n, (id) => world.team(id).name)),
              trailing: Text(
                l10n.seasonWeekShort(n.season, n.week),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
