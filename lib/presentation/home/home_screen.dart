import 'package:flutter/material.dart';

import '../../app/l10n/app_localizations.dart';

/// Faz 0 yer tutucu ana ekranı. Faz 1'de oyuncu kartı ve navigasyon gelecek.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sports_soccer,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(l10n.appTitle, style: textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text(l10n.tagline, style: textTheme.titleMedium),
                const SizedBox(height: 24),
                Text(l10n.phaseZeroNotice, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
