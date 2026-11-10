import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/social/event_catalog.dart';
import '../../domain/social/event_models.dart';
import '../../domain/social/relationships.dart';
import '../../domain/social/social_engine.dart';
import '../event_texts.dart';
import '../l10n_labels.dart';
import '../providers.dart';
import 'interview_widgets.dart';
import 'social_visuals.dart';

/// Tek bir olay: soru -> seçenekler -> sonuç. [eventId] bekleyen olayın kimliği.
class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({required this.eventId, super.key});

  final String eventId;

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  ResolveResult? _result;
  PendingEvent? _event;
  bool _busy = false;

  Future<void> _choose(int index) async {
    final event = _event;
    if (event == null || _busy) return;
    setState(() => _busy = true);
    unawaited(HapticFeedback.selectionClick());
    final result = await ref
        .read(activeCareerProvider.notifier)
        .resolveEvent(event, index);
    if (!mounted) return;
    if (result?.backfired ?? false) unawaited(HapticFeedback.heavyImpact());
    setState(() {
      _result = result;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)!.state;

    // Cevap verildikten sonra olay listeden düşer; ilk bulunan örneği sakla.
    _event ??= () {
      for (final e in career.pendingEvents) {
        if (e.id == widget.eventId) return e;
      }
      return null;
    }();

    final event = _event;
    if (event == null) {
      // Olay yok (süresi dolmuş ya da zaten cevaplanmış).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/game/social');
      });
      return const Scaffold();
    }

    final template = EventCatalog.byId(event.id);
    final texts = l10n.eventTexts(event.id, event.params);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eventKindName(template.kind)),
        automaticallyImplyLeading: _result == null,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _result == null
                  ? _Question(
                      key: const ValueKey('question'),
                      template: template,
                      texts: texts,
                      busy: _busy,
                      onChoose: _choose,
                    )
                  : _Outcome(
                      key: const ValueKey('outcome'),
                      result: _result!,
                      texts: texts,
                      press: template.kind == EventKind.press,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.template,
    required this.texts,
    required this.busy,
    required this.onChoose,
    super.key,
  });

  final EventTemplate template;
  final EventTexts texts;
  final bool busy;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final press = template.kind == EventKind.press;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (press)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const ReporterAvatar(size: 80),
                  Text(l10n.interviewReporter, style: textTheme.labelSmall),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SpeechBubble(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        texts.title,
                        style: textTheme.titleMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        texts.body,
                        style: textTheme.bodyLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  child: Icon(eventKindIcon(template.kind), size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  texts.title,
                  style: textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  texts.body,
                  style: textTheme.bodyLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Text(
          press ? l10n.interviewPickHint : l10n.eventChooseHint,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < template.choices.length; i++)
          _ChoiceCard(
            label: press ? '“${texts.choices[i]}”' : texts.choices[i],
            choice: template.choices[i],
            enabled: !busy,
            onTap: () => onChoose(i),
          ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.label,
    required this.choice,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final EventChoice choice;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final affected = <Relation>{
      ...choice.effect.relationsAffected,
      ...?choice.alt?.relationsAffected,
    };
    final touchesMoney =
        choice.effect.touchesMoney || (choice.alt?.touchesMoney ?? false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (choice.tone != null) ...[
                ToneChip(tone: choice.tone!),
                const SizedBox(height: 8),
              ],
              Text(label, style: textTheme.titleMedium),
              if (affected.isNotEmpty || touchesMoney || choice.risky) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final r in Relation.values)
                      if (affected.contains(r))
                        _Tag(
                          icon: relationIcon(r),
                          label: l10n.relationName(r),
                        ),
                    if (touchesMoney)
                      _Tag(
                        icon: Icons.payments_outlined,
                        label: l10n.effectMoney,
                      ),
                    if (choice.risky)
                      _Tag(
                        icon: Icons.casino_outlined,
                        label: l10n.eventRiskyTag,
                        color: scheme.error,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: c.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c),
          ),
        ],
      ),
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.result,
    required this.texts,
    required this.press,
    super.key,
  });

  final ResolveResult result;
  final EventTexts texts;

  /// Röportajsa sonuç gazete manşeti olarak gösterilir.
  final bool press;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final i = result.choiceIndex;
    final backfired = result.backfired;
    final story = backfired
        ? (texts.backfires[i] ?? texts.results[i])
        : texts.results[i];
    final e = result.effect;

    final lines = <_EffectLine>[
      if (e.morale != 0) _EffectLine(l10n.statMorale, e.morale),
      if (e.condition != 0) _EffectLine(l10n.statCondition, e.condition),
      for (final r in Relation.values)
        if (e.relations[r] != 0)
          _EffectLine(l10n.relationName(r), e.relations[r]!),
      if (e.touchesMoney)
        _EffectLine(
          l10n.effectMoney,
          SocialEngine.moneyOf(
            // Para tutarını gösterirken güncel maaşı kullan.
            result.state,
            e,
          ).toDouble(),
          text: l10n.money(SocialEngine.moneyOf(result.state, e)),
        ),
      if (e.healWeeks != 0)
        _EffectLine(
          l10n.effectHeal,
          e.healWeeks.toDouble(),
          text: l10n.effectHealValue(e.healWeeks),
        ),
      if (e.relapseRisk != 0)
        _EffectLine(
          l10n.effectRelapse,
          -e.relapseRisk,
          text: '+%${(e.relapseRisk * 100).round()}',
        ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        if (press && texts.headlines.length > i) ...[
          NewspaperCard(
            headline: texts.headlines[i],
            story: story,
            backfired: backfired,
          ),
        ] else ...[
          Icon(
            backfired
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            size: 64,
            color: backfired ? scheme.error : scheme.primary,
          ),
          const SizedBox(height: 12),
          if (backfired)
            Text(
              l10n.eventBackfired,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Text(
              l10n.eventResult,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
          const SizedBox(height: 12),
          Text(
            story,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
        ],
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: lines),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: () => context.go('/game/social'),
          child: Text(l10n.eventDone),
        ),
      ],
    );
  }
}

class _EffectLine extends StatelessWidget {
  const _EffectLine(this.label, this.delta, {this.text});

  final String label;
  final double delta;

  /// Verilirse işaretli sayı yerine bu gösterilir.
  final String? text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final good = delta > 0;
    final color = good ? scheme.primary : scheme.error;
    final shown = text ?? '${delta > 0 ? '+' : ''}${delta.round()}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            good ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            shown,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
