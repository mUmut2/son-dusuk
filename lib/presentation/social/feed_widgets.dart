import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/career/career_state.dart';
import '../../domain/social/feed_engine.dart';
import '../../domain/social/feed_models.dart';
import '../providers.dart';
import 'feed_texts.dart';

Color feedSourceColor(FeedSource s) => switch (s) {
  FeedSource.fan => const Color(0xFFF57C00),
  FeedSource.journalist => const Color(0xFF546E7A),
  FeedSource.teammate => const Color(0xFF00897B),
  FeedSource.club => const Color(0xFF3949AB),
  FeedSource.meme => const Color(0xFF8E24AA),
  FeedSource.family => const Color(0xFFD81B60),
  FeedSource.you => const Color(0xFF2E7D32),
};

IconData feedSourceIcon(FeedSource s) => switch (s) {
  FeedSource.fan => Icons.person,
  FeedSource.journalist => Icons.newspaper,
  FeedSource.teammate => Icons.sports_soccer,
  FeedSource.club => Icons.shield,
  FeedSource.meme => Icons.emoji_emotions,
  FeedSource.family => Icons.favorite,
  FeedSource.you => Icons.star,
};

IconData feedOwnIcon(FeedKind k) => switch (k) {
  FeedKind.ownThanks => Icons.volunteer_activism,
  FeedKind.ownFunny => Icons.emoji_emotions,
  FeedKind.ownTraining => Icons.fitness_center,
  _ => Icons.local_fire_department,
};

/// Sosyal ağ akışı: hesap başlığı + paylaşımlar.
class FeedView extends ConsumerWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)!.state;
    final feed = career.feed;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _AccountHeader(career: career),
        const SizedBox(height: 12),
        if (feed.posts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.feedEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final p in feed.posts) PostCard(post: p, career: career),
      ],
    );
  }
}

class _AccountHeader extends ConsumerWidget {
  const _AccountHeader({required this.career});

  final CareerState career;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canPost = FeedEngine.canPostOwn(career);

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  child: Text(
                    career.player.name.isEmpty
                        ? '?'
                        : career.player.name.characters.first.toUpperCase(),
                    style: textTheme.titleLarge?.copyWith(
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        career.player.name,
                        style: textTheme.titleMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.feedYourAccount,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _Stat(
                  value: l10n.feedCount(career.feed.followers),
                  label: l10n.feedFollowers,
                ),
                _Stat(
                  value: '${career.feed.posts.length}',
                  label: l10n.feedPostCount,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canPost ? () => _openSheet(context, ref) : null,
                icon: const Icon(Icons.edit),
                label: Text(
                  canPost ? l10n.feedPostButton : l10n.feedPostedThisWeek,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final kind = await showModalBottomSheet<FeedKind>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                l10n.feedSheetTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final k in FeedKind.values.where((k) => k.isOwn))
                    ListTile(
                      leading: Icon(feedOwnIcon(k)),
                      title: Text(l10n.feedOwnTitle(k)),
                      subtitle: Text(l10n.feedOwnDesc(k)),
                      onTap: () => Navigator.of(context).pop(k),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (kind == null) return;
    final result = await ref
        .read(activeCareerProvider.notifier)
        .postToFeed(kind);
    if (result == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.backfired ? l10n.feedPostBackfired : l10n.feedPostDone,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

/// Tek paylaşım: yazar, metin, beğeni ve açılır yorumlar.
class PostCard extends ConsumerStatefulWidget {
  const PostCard({required this.post, required this.career, super.key});

  final FeedPost post;
  final CareerState career;

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final world = ref.watch(clubWorldProvider);
    final p = widget.post;
    final name = widget.career.player.name;
    final color = feedSourceColor(p.source);
    final text = l10n.feedPostText(
      p,
      playerName: name,
      clubName: (id) => world == null ? '' : world.team(id).name,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  child: Icon(feedSourceIcon(p.source), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.feedAuthorName(p),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.feedSourceName(p.source),
                        style: textTheme.labelSmall?.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
                Text(
                  l10n.seasonWeekShort(p.season, p.week),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(text, style: textTheme.bodyLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 20,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, size: 18, color: scheme.error),
                    const SizedBox(width: 4),
                    Text(l10n.feedCount(p.likes), style: textTheme.labelLarge),
                  ],
                ),
                if (p.comments.isNotEmpty)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _open = !_open),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${p.comments.length}',
                            style: textTheme.labelLarge,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _open
                                ? l10n.feedHideComments
                                : l10n.feedShowComments,
                            style: textTheme.labelMedium?.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (_open) ...[
              const Divider(height: 16),
              for (final c in p.comments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 16,
                        color: scheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${l10n.feedCommenterName(c)}  ',
                                style: textTheme.labelLarge,
                              ),
                              TextSpan(
                                text: l10n.feedCommentText(c, name),
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.favorite_border,
                        size: 14,
                        color: scheme.outline,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${c.likes}',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
