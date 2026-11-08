import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/career/difficulty.dart';
import '../l10n_labels.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAllSaves),
        content: Text(l10n.deleteAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (!(ok ?? false)) return;
    await ref.read(saveSlotsProvider.notifier).deleteAll();
    messenger.showSnackBar(SnackBar(content: Text(l10n.allSavesDeleted)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: Text(l10n.soundLabel),
                  value: settings.soundOn,
                  onChanged: notifier.setSound,
                ),
                SwitchListTile(
                  title: Text(l10n.vibrationLabel),
                  value: settings.vibrationOn,
                  onChanged: notifier.setVibration,
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(l10n.difficultyLabel),
                  subtitle: Text(l10n.difficultyHint),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SegmentedButton<Difficulty>(
                    segments: [
                      for (final d in Difficulty.values)
                        ButtonSegment(
                          value: d,
                          label: Text(l10n.difficultyName(d)),
                        ),
                    ],
                    selected: {settings.difficulty},
                    onSelectionChanged: (s) => notifier.setDifficulty(s.first),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(l10n.languageLabel),
                  trailing: Text(l10n.languageTurkish),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(l10n.deleteAllSaves),
                  onTap: () => _deleteAll(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
