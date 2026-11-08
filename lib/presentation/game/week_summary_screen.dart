import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/career/week_report.dart';
import '../l10n_labels.dart';
import '../providers.dart';

/// Hafta sonu özeti: ne değişti, neden değişti.
class WeekSummaryScreen extends ConsumerWidget {
  const WeekSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final result = ref.watch(lastWeekProvider);
    if (result == null) {
      // Doğrudan açılırsa ana sayfaya dön.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/game');
      });
      return const Scaffold();
    }

    final report = result.report;
    final before = result.before;
    final after = result.state.status;
    final textTheme = Theme.of(context).textTheme;

    final statValues = {
      StatKind.condition: (before.condition, after.condition),
      StatKind.form: (before.form, after.form),
      StatKind.morale: (before.morale, after.morale),
    };

    String fmt(StatKind k, double v) =>
        k == StatKind.form ? v.toStringAsFixed(1) : '${v.round()}';

    String signed(double v) =>
        '${v >= 0 ? '+' : ''}${v.toStringAsFixed(v.abs() < 10 ? 1 : 0)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.weekSummaryTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        l10n.summaryWeekOf(report.season, report.week),
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      for (final event in report.events)
                        Card(
                          child: ListTile(
                            leading: Icon(switch (event.kind) {
                              WeekEventKind.healed => Icons.check_circle,
                              WeekEventKind.newSeason => Icons.celebration,
                              WeekEventKind.trainingBlocked =>
                                Icons.do_not_disturb_on,
                              _ => Icons.healing,
                            }),
                            title: Text(l10n.eventText(event)),
                          ),
                        ),
                      Text(l10n.changesTitle, style: textTheme.titleMedium),
                      for (final kind in StatKind.values) ...[
                        const SizedBox(height: 12),
                        Text(
                          l10n.statLine(
                            l10n.statName(kind),
                            fmt(kind, statValues[kind]!.$1),
                            fmt(kind, statValues[kind]!.$2),
                          ),
                          style: textTheme.titleSmall,
                        ),
                        for (final c in report.statChanges.where(
                          (c) => c.stat == kind,
                        ))
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 48,
                                  child: Text(
                                    signed(c.delta),
                                    style: TextStyle(
                                      color: c.delta < 0
                                          ? Theme.of(context).colorScheme.error
                                          : null,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(l10n.reasonName(c.reason)),
                                ),
                              ],
                            ),
                          ),
                      ],
                      if (report.attributeGains.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          l10n.attributeGainsTitle,
                          style: textTheme.titleMedium,
                        ),
                        for (final g in report.attributeGains)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 56,
                                  child: Text(
                                    '+${g.delta.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(l10n.attributeName(g.attribute)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: () => context.go('/game'),
                    child: Text(l10n.continueButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
