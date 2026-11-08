import 'package:flutter/material.dart';

import '../../app/l10n/app_localizations.dart';
import '../../core/game_random.dart';
import '../../domain/league/league_factory.dart';
import '../../domain/league/season_simulator.dart';
import '../../domain/league/team.dart';

/// Faz 2 doğrulama ekranı: bir ligin sezonunu simüle edip tabloyu gösterir.
class SeasonSimulatorScreen extends StatefulWidget {
  const SeasonSimulatorScreen({super.key});

  @override
  State<SeasonSimulatorScreen> createState() => _SeasonSimulatorScreenState();
}

class _SeasonSimulatorScreenState extends State<SeasonSimulatorScreen> {
  final _seedController = TextEditingController();
  int _tier = 1;
  String? _seedError;
  League? _league;
  SeasonResult? _result;

  @override
  void dispose() {
    _seedController.dispose();
    super.dispose();
  }

  String _tierName(AppLocalizations l10n, int tier) => switch (tier) {
    1 => l10n.leagueTier1,
    2 => l10n.leagueTier2,
    3 => l10n.leagueTier3,
    4 => l10n.leagueTier4,
    _ => l10n.leagueTier5,
  };

  void _simulate(AppLocalizations l10n) {
    final text = _seedController.text.trim();
    int? seed;
    if (text.isNotEmpty) {
      seed = int.tryParse(text);
      if (seed == null) {
        setState(() => _seedError = l10n.simulatorSeedInvalid);
        return;
      }
    }
    final random = GameRandom(seed);
    final pyramid = LeagueFactory.createPyramid(random);
    final league = pyramid[_tier - 1];
    setState(() {
      _seedError = null;
      _league = league;
      _result = SeasonSimulator.simulate(league, random);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = _result;
    final league = _league;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.simulatorTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.simulatorHint),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _tier,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var t = 1; t <= LeagueFactory.tierCount; t++)
                      DropdownMenuItem(
                        value: t,
                        child: Text(_tierName(l10n, t)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _tier = v ?? _tier),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _seedController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.simulatorSeed,
                    errorText: _seedError,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () => _simulate(l10n),
                  child: Text(l10n.simulateSeason),
                ),
                if (result != null && league != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.simulatorStats(
                      result.matchCount,
                      result.goalsPerMatch.toStringAsFixed(2),
                      (result.homeWinRate * 100).toStringAsFixed(0),
                      (result.drawRate * 100).toStringAsFixed(0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StandingsTable(league: league, result: result),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StandingsTable extends StatelessWidget {
  const _StandingsTable({required this.league, required this.result});

  final League league;
  final SeasonResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final names = {for (final t in league.teams) t.id: t.name};
    final rows = result.standings.sorted;

    DataColumn col(String label, {bool numeric = true}) =>
        DataColumn(label: Text(label), numeric: numeric);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 14,
        headingRowHeight: 40,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 40,
        columns: [
          col('#'),
          col(l10n.colTeam, numeric: false),
          col(l10n.colPlayed),
          col(l10n.colWon),
          col(l10n.colDrawn),
          col(l10n.colLost),
          col(l10n.colGoalsFor),
          col(l10n.colGoalsAgainst),
          col(l10n.colGoalDiff),
          col(l10n.colPoints),
        ],
        rows: [
          for (var i = 0; i < rows.length; i++)
            DataRow(
              cells: [
                DataCell(Text('${i + 1}')),
                DataCell(Text(names[rows[i].teamId]!)),
                DataCell(Text('${rows[i].played}')),
                DataCell(Text('${rows[i].won}')),
                DataCell(Text('${rows[i].drawn}')),
                DataCell(Text('${rows[i].lost}')),
                DataCell(Text('${rows[i].goalsFor}')),
                DataCell(Text('${rows[i].goalsAgainst}')),
                DataCell(Text('${rows[i].goalDifference}')),
                DataCell(
                  Text(
                    '${rows[i].points}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
