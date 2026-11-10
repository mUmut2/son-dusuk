import 'package:flutter/material.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/match/commentary.dart';

/// Spikerin canlı anlatım paneli. [lines] eskiden yeniye sıralıdır; en yeni
/// satır en üstte görünür ve daktilo gibi yazılır.
class CommentaryFeed extends StatelessWidget {
  const CommentaryFeed({
    required this.lines,
    required this.textOf,
    this.live = false,
    super.key,
  });

  final List<CommentaryLine> lines;
  final String Function(CommentaryLine line) textOf;

  /// Maç akarken "CANLI" rozeti gösterilir.
  final bool live;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final newestFirst = lines.reversed.toList();

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: scheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.mic, size: 18, color: scheme.onPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.commentaryTitle,
                    style: textTheme.titleSmall?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (live)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.commentaryLive,
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: newestFirst.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.commentaryEmpty,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: newestFirst.length,
                    itemBuilder: (context, i) {
                      final line = newestFirst[i];
                      return Opacity(
                        opacity: (1 - i * 0.12).clamp(0.5, 1.0),
                        child: _Entry(
                          key: ObjectKey(line),
                          line: line,
                          text: textOf(line),
                          animate: i == 0,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.line,
    required this.text,
    required this.animate,
    super.key,
  });

  final CommentaryLine line;
  final String text;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final goal = line.kind.isGoal;
    final style = textTheme.bodyMedium?.copyWith(
      height: 1.35,
      fontWeight: goal ? FontWeight.w700 : null,
      color: goal ? scheme.onTertiaryContainer : null,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: goal ? scheme.tertiaryContainer : scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: goal ? scheme.tertiary : scheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${line.minute}'",
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: goal ? scheme.onTertiary : scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (goal) ...[
            Icon(Icons.sports_soccer, size: 18, color: scheme.tertiary),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: animate
                ? _Typewriter(text: text, style: style)
                : Text(text, style: style),
          ),
        ],
      ),
    );
  }
}

/// Metni harf harf yazar. Yerleşim sabit kalsın diye tam metin görünmez
/// biçimde yer ayırır.
class _Typewriter extends StatelessWidget {
  const _Typewriter({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: text.length),
      duration: Duration(milliseconds: 18 * text.length),
      builder: (context, count, _) => Text.rich(
        TextSpan(
          style: style,
          children: [
            TextSpan(text: text.substring(0, count)),
            TextSpan(
              text: text.substring(count),
              style: const TextStyle(color: Color(0x00000000)),
            ),
          ],
        ),
      ),
    );
  }
}
