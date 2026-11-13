import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/spending/betting.dart';
import '../../domain/spending/horse_racing.dart';
import '../../domain/spending/spending_balance.dart';
import '../../domain/spending/spending_engine.dart';
import '../../game/horse_painter.dart';
import '../../game/sound_service.dart';
import '../l10n_labels.dart';
import '../providers.dart';

const _coats = [
  Color(0xFF8D5A3B),
  Color(0xFF3E2723),
  Color(0xFFBCAAA4),
  Color(0xFFD9A441),
  Color(0xFF616161),
  Color(0xFFA1887F),
];
const _silks = [
  Color(0xFFE53935),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFF9A825),
  Color(0xFF8E24AA),
  Color(0xFFFB8C00),
];

String _odds(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

/// At yarışı: at seç, bahis yap (ya da bahissiz izle), yarışı seyret.
class HorseRaceScreen extends ConsumerStatefulWidget {
  const HorseRaceScreen({super.key});

  @override
  ConsumerState<HorseRaceScreen> createState() => _HorseRaceScreenState();
}

class _HorseRaceScreenState extends ConsumerState<HorseRaceScreen>
    with SingleTickerProviderStateMixin {
  static const _raceDuration = Duration(seconds: 9);

  AnimationController? _anim;
  RaceCard? _card;
  int _cardWeek = -1;
  int? _horse;
  RaceBet _kind = RaceBet.win;
  int _stakeIndex = 0;
  RaceOutcome? _outcome;
  int _chosenHorse = 0;
  int _chosenStake = 0;
  bool _finished = false;

  @override
  void dispose() {
    _anim?.dispose();
    super.dispose();
  }

  Future<void> _start(RaceCard card, List<int> stakes) async {
    final horse = _horse;
    if (horse == null) return;
    final stake = stakes[_stakeIndex.clamp(0, stakes.length - 1)];
    final outcome = await ref
        .read(activeCareerProvider.notifier)
        .runRace(horse: horse, kind: _kind, stake: stake, card: card);
    if (!mounted || outcome == null) return;
    final anim = AnimationController(vsync: this, duration: _raceDuration);
    anim.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _finished = true);
        if (_chosenStake > 0) {
          ref.playSfx(outcome.payout > 0 ? Sfx.goal : Sfx.bad);
        }
      }
    });
    setState(() {
      _outcome = outcome;
      _chosenHorse = horse;
      _chosenStake = stake;
      _anim = anim;
    });
    unawaited(anim.forward());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)?.state;
    if (career == null) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;

    final running = _outcome != null && !_finished;
    final ready = _outcome == null && SpendingEngine.raceReady(career);

    if (_cardWeek != career.absoluteWeek && _outcome == null) {
      _card = HorseRacing.card(career);
      _cardWeek = career.absoluteWeek;
    }
    final card = _outcome?.card ?? _card!;
    final stakes = [0, ...Betting.stakeOptions(career.finance.balance)];
    final stakeIndex = _stakeIndex.clamp(0, stakes.length - 1);
    final canPay = career.finance.balance >= stakes[stakeIndex];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.raceTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_outcome == null) ...[
                  Text(l10n.raceIntro, style: textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    l10n.raceRules,
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_outcome != null)
                  _Track(
                    animation: _anim!,
                    result: _outcome!.result,
                    card: card,
                    chosen: _chosenHorse,
                  ),
                if (_finished) ...[
                  const SizedBox(height: 12),
                  _ResultCard(
                    outcome: _outcome!,
                    chosen: _chosenHorse,
                    stake: _chosenStake,
                    kind: _kind,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.pop(),
                    child: Text(l10n.raceAgainNextWeek),
                  ),
                ],
                if (!ready && _outcome == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(l10n.raceDone, style: textTheme.titleSmall),
                  ),
                if (_outcome == null) ...[
                  Text(l10n.raceHorsesTitle, style: textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (var i = 0; i < card.horses.length; i++)
                    _HorseTile(
                      index: i,
                      card: card,
                      selected: _horse == i,
                      enabled: ready && !running,
                      onTap: () => setState(() => _horse = i),
                    ),
                  if (ready) ...[
                    const SizedBox(height: 12),
                    Text(l10n.raceBetKind, style: textTheme.labelMedium),
                    const SizedBox(height: 4),
                    SegmentedButton<RaceBet>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: RaceBet.win,
                          label: Text(l10n.raceBet_win),
                        ),
                        ButtonSegment(
                          value: RaceBet.place,
                          label: Text(l10n.raceBet_place),
                        ),
                      ],
                      selected: {_kind},
                      onSelectionChanged: (v) =>
                          setState(() => _kind = v.first),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.raceStakeLabel, style: textTheme.labelMedium),
                    const SizedBox(height: 4),
                    SegmentedButton<int>(
                      showSelectedIcon: false,
                      segments: [
                        for (var i = 0; i < stakes.length; i++)
                          ButtonSegment(
                            value: i,
                            label: Text(
                              i == 0
                                  ? l10n.raceWatchOnly
                                  : l10n.money(stakes[i]),
                            ),
                          ),
                      ],
                      selected: {stakeIndex},
                      onSelectionChanged: (v) =>
                          setState(() => _stakeIndex = v.first),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: const Icon(Icons.flag),
                      onPressed: _horse != null && canPay
                          ? () => _start(card, stakes)
                          : null,
                      label: Text(
                        _horse == null ? l10n.racePickFirst : l10n.raceStart,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HorseTile extends StatelessWidget {
  const _HorseTile({
    required this.index,
    required this.card,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final int index;
  final RaceCard card;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final horse = card.horses[index];
    final stars =
        1 +
        ((horse.rating - SpendingBalance.horseRatingMin) /
                (SpendingBalance.horseRatingMax -
                    SpendingBalance.horseRatingMin) *
                4)
            .round();
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        enabled: enabled,
        onTap: enabled ? onTap : null,
        leading: CircleAvatar(
          backgroundColor: _silks[index],
          foregroundColor: Colors.white,
          child: Text('${index + 1}'),
        ),
        title: Text(l10n.horseName(horse.nameIndex)),
        subtitle: Text(
          '${l10n.raceForm}: ${'★' * stars}${'☆' * (5 - stars)}\n'
          '${l10n.raceOddsLine(_odds(card.winOdds[index]), _odds(card.placeOdds[index]))}',
        ),
        isThreeLine: true,
        trailing: selected ? const Icon(Icons.check_circle) : null,
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({
    required this.animation,
    required this.result,
    required this.card,
    required this.chosen,
  });

  final Animation<double> animation;
  final RaceResult result;
  final RaceCard card;
  final int chosen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final positions = _positionsAt(result, animation.value);
        var leader = 0;
        for (var i = 1; i < positions.length; i++) {
          if (positions[i] > positions[leader]) leader = i;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.raceLeader(l10n.horseName(card.horses[leader].nameIndex)),
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1.35,
                child: CustomPaint(
                  painter: _TrackPainter(
                    positions: positions,
                    chosen: chosen,
                    phase: animation.value * 90,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// [t] (0..1) anındaki konumlar: kareler arası doğrusal ara değer.
List<double> _positionsAt(RaceResult r, double t) {
  final frames = r.positions;
  if (frames.isEmpty) return List.filled(SpendingBalance.horseCount, 0);
  final f = t.clamp(0.0, 1.0) * (frames.length - 1);
  final a = f.floor();
  final b = (a + 1).clamp(0, frames.length - 1);
  final k = f - a;
  return [
    for (var i = 0; i < frames[a].length; i++)
      frames[a][i] + (frames[b][i] - frames[a][i]) * k,
  ];
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    required this.positions,
    required this.chosen,
    required this.phase,
  });

  final List<double> positions;
  final int chosen;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final lanes = positions.length;
    final laneH = size.height / lanes;
    const startX = 34.0;
    final endX = size.width - 40;
    for (var i = 0; i < lanes; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * laneH, size.width, laneH),
        Paint()
          ..color = i.isEven
              ? const Color(0xFF7CB342)
              : const Color(0xFF689F38),
      );
    }
    // Bitiş çizgisi (damalı)
    const cell = 6.0;
    for (var y = 0.0, row = 0; y < size.height; y += cell, row++) {
      for (var c = 0; c < 2; c++) {
        canvas.drawRect(
          Rect.fromLTWH(endX + c * cell, y, cell, cell),
          Paint()
            ..color = (row + c).isEven
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF212121),
        );
      }
    }
    final unit = laneH * 0.3;
    for (var i = 0; i < lanes; i++) {
      final x = startX + (endX - startX - unit * 2.2) * positions[i];
      final y = i * laneH + laneH * 0.62;
      if (i == chosen) {
        canvas.drawRect(
          Rect.fromLTWH(0, i * laneH, size.width, laneH),
          Paint()..color = const Color(0x22FFFFFF),
        );
      }
      paintHorse(
        canvas,
        x,
        y,
        unit,
        _coats[i % _coats.length],
        _silks[i % _silks.length],
        phase + i,
      );
      final badge = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.drawCircle(
        Offset(12, i * laneH + laneH / 2),
        9,
        Paint()..color = _silks[i % _silks.length],
      );
      badge.paint(
        canvas,
        Offset(12 - badge.width / 2, i * laneH + laneH / 2 - badge.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.phase != phase || old.positions != positions;
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.outcome,
    required this.chosen,
    required this.stake,
    required this.kind,
  });

  final RaceOutcome outcome;
  final int chosen;
  final int stake;
  final RaceBet kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final order = outcome.result.order;
    final String message;
    if (stake > 0) {
      message = outcome.payout > 0
          ? l10n.raceWon(l10n.money(outcome.payout))
          : l10n.raceLost;
    } else {
      message = outcome.hit ? l10n.raceWatchedHit : l10n.raceWatchedMiss;
    }
    final good = stake > 0 ? outcome.payout > 0 : outcome.hit;
    return Card(
      color: good ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: textTheme.titleMedium),
            const SizedBox(height: 10),
            Text(l10n.raceResultTitle, style: textTheme.labelMedium),
            const SizedBox(height: 4),
            for (var i = 0; i < order.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text('${i + 1}.')),
                    CircleAvatar(radius: 9, backgroundColor: _silks[order[i]]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.horseName(outcome.card.horses[order[i]].nameIndex),
                        style: order[i] == chosen
                            ? textTheme.titleSmall
                            : textTheme.bodyMedium,
                      ),
                    ),
                    if (order[i] == chosen) Text(l10n.raceYourHorse),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
