import 'package:flutter/material.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/career/player_status.dart';

/// Kondisyon, form ve moral çubukları + sakatlık bilgisi.
class StatusMeters extends StatelessWidget {
  const StatusMeters({required this.status, super.key});

  final PlayerStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Meter(
          label: l10n.statCondition,
          value: status.condition / 100,
          text: '${status.condition.round()}',
          color: status.condition < 40 ? scheme.error : scheme.primary,
        ),
        _Meter(
          label: l10n.statForm,
          value: (status.form + 10) / 20,
          text: (status.form >= 0 ? '+' : '') + status.form.toStringAsFixed(1),
          color: status.form < -3 ? scheme.error : scheme.primary,
        ),
        _Meter(
          label: l10n.statMorale,
          value: status.morale / 100,
          text: '${status.morale.round()}',
          color: status.morale < 30 ? scheme.error : scheme.primary,
        ),
      ],
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({
    required this.label,
    required this.value,
    required this.text,
    required this.color,
  });

  final String label;
  final double value;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $text',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 92, child: Text(label)),
            Expanded(
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 8,
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: 48, child: Text(text, textAlign: TextAlign.end)),
          ],
        ),
      ),
    );
  }
}

/// Sakatsa kırmızı bilgi şeridi.
class InjuryBanner extends StatelessWidget {
  const InjuryBanner({required this.injury, super.key});

  final Injury injury;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final type = switch (injury.type) {
      InjuryType.muscle => l10n.injury_muscle,
      InjuryType.ligament => l10n.injury_ligament,
      InjuryType.fracture => l10n.injury_fracture,
    };
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.healing, color: scheme.onErrorContainer),
        title: Text(
          l10n.injuryBanner(type, injury.weeksLeft),
          style: TextStyle(color: scheme.onErrorContainer),
        ),
      ),
    );
  }
}
