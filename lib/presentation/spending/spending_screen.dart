import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/career/career_state.dart';
import '../../domain/league/club_world.dart';
import '../../domain/spending/betting.dart';
import '../../domain/spending/spending_balance.dart';
import '../../domain/spending/spending_engine.dart';
import '../../domain/spending/spending_models.dart';
import '../../game/sound_service.dart';
import '../l10n_labels.dart';
import '../providers.dart';

IconData propertyIcon(Property p) => switch (p) {
  Property.watch => Icons.watch,
  Property.car => Icons.directions_car,
  Property.flat => Icons.apartment,
  Property.villa => Icons.villa,
  Property.yacht => Icons.directions_boat,
};

Color habitColor(double habit) => switch (L10nLabels.habitLevel(habit)) {
  0 => const Color(0xFF43A047),
  1 => const Color(0xFFF9A825),
  2 => const Color(0xFFEF6C00),
  _ => const Color(0xFFD32F2F),
};

String _odds(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

/// Ana sayfadan harcama ve şans köşesine giden kısa kart.
class SpendingCard extends ConsumerWidget {
  const SpendingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)?.state;
    if (career == null) return const SizedBox.shrink();
    final sp = career.spending;
    return Card(
      child: ListTile(
        leading: Icon(
          sp.suspended ? Icons.gavel : Icons.shopping_bag_outlined,
          color: sp.suspended ? Theme.of(context).colorScheme.error : null,
        ),
        title: Text(l10n.spendTitle),
        subtitle: Text(
          sp.properties.isEmpty && sp.habit < SpendingBalance.warnAt
              ? l10n.spendCardHint
              : l10n.spendCardOwned(
                  '${sp.properties.length}',
                  l10n.habitLevelName(sp.habit),
                ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/game/spending'),
      ),
    );
  }
}

/// Harcama: mülkler, bağışlar ve kurgusal "şans köşesi" (bahis).
class SpendingScreen extends ConsumerStatefulWidget {
  const SpendingScreen({super.key});

  @override
  ConsumerState<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends ConsumerState<SpendingScreen> {
  int _stakeIndex = 0;

  void _say(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)?.state;
    final world = ref.watch(clubWorldProvider);
    if (career == null || world == null) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.spendTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _BalanceCard(balance: career.finance.balance),
                const SizedBox(height: 12),
                Text(l10n.spendIntro, style: textTheme.bodySmall),
                const SizedBox(height: 20),
                Text(l10n.spendPropertiesTitle, style: textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final p in Property.values) _propertyTile(career, p),
                const SizedBox(height: 20),
                Text(l10n.spendDonationsTitle, style: textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final d in Donation.values) _donationTile(career, d),
                const SizedBox(height: 20),
                Text(l10n.betTitle, style: textTheme.titleMedium),
                const SizedBox(height: 8),
                _RaceCard(career: career),
                const SizedBox(height: 8),
                _HabitCard(spending: career.spending),
                const SizedBox(height: 8),
                Text(
                  l10n.betRules,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                ..._coupon(career, world),
                const SizedBox(height: 16),
                Text(l10n.betResultsTitle, style: textTheme.titleSmall),
                const SizedBox(height: 8),
                _Results(spending: career.spending, world: world),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _propertyTile(CareerState career, Property p) {
    final l10n = AppLocalizations.of(context);
    final owned = career.spending.owns(p);
    final price = SpendingBalance.propertyPrice[p]!;
    return Card(
      child: ListTile(
        leading: Icon(propertyIcon(p), size: 32),
        title: Text(l10n.propertyName(p)),
        subtitle: Text('${l10n.propertyDesc(p)}\n${l10n.money(price)}'),
        isThreeLine: true,
        trailing: owned
            ? Chip(label: Text(l10n.spendOwned))
            : FilledButton(
                onPressed: SpendingEngine.canBuy(career, p)
                    ? () async {
                        final ok = await ref
                            .read(activeCareerProvider.notifier)
                            .buyProperty(p);
                        if (!mounted || !ok) return;
                        ref.playSfx(Sfx.buy);
                        _say(l10n.spendBought);
                      }
                    : null,
                child: Text(l10n.spendBuy),
              ),
      ),
    );
  }

  Widget _donationTile(CareerState career, Donation d) {
    final l10n = AppLocalizations.of(context);
    final ready = SpendingEngine.donationReady(career);
    return Card(
      child: ListTile(
        leading: Icon(
          d == Donation.charity
              ? Icons.volunteer_activism
              : Icons.card_giftcard,
          size: 32,
        ),
        title: Text(l10n.donationName(d)),
        subtitle: Text(
          '${ready ? l10n.donationDesc(d) : l10n.spendDonationWait}\n'
          '${l10n.money(SpendingEngine.donationCost(career, d))}',
        ),
        isThreeLine: true,
        trailing: FilledButton(
          onPressed: SpendingEngine.canDonate(career, d)
              ? () async {
                  final ok = await ref
                      .read(activeCareerProvider.notifier)
                      .donate(d);
                  if (!mounted || !ok) return;
                  ref.playSfx(Sfx.good);
                  _say(l10n.spendDonated);
                }
              : null,
          child: Text(l10n.spendDonate),
        ),
      ),
    );
  }

  List<Widget> _coupon(CareerState career, ClubWorld world) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final coupon = Betting.coupon(career, world);
    if (coupon.isEmpty) {
      return [Text(l10n.betNoCoupon, style: textTheme.bodyMedium)];
    }
    final stakes = Betting.stakeOptions(career.finance.balance);
    final index = _stakeIndex.clamp(0, stakes.length - 1);
    final stake = stakes[index];
    return [
      Text(l10n.betCouponTitle, style: textTheme.titleSmall),
      const SizedBox(height: 8),
      Text(l10n.betStakeLabel, style: textTheme.labelMedium),
      const SizedBox(height: 4),
      SegmentedButton<int>(
        showSelectedIcon: false,
        segments: [
          for (var i = 0; i < stakes.length; i++)
            ButtonSegment(value: i, label: Text(l10n.money(stakes[i]))),
        ],
        selected: {index},
        onSelectionChanged: (v) => setState(() => _stakeIndex = v.first),
      ),
      const SizedBox(height: 8),
      for (var i = 0; i < coupon.length; i++)
        _CouponCard(
          match: coupon[i],
          world: world,
          bet: _betOn(career, coupon[i]),
          canPay: career.finance.balance >= stake,
          onPick: (pick) async {
            final ok = await ref
                .read(activeCareerProvider.notifier)
                .placeBet(i, pick, stake);
            if (!mounted || !ok) return;
            _say(l10n.betPlaced(_odds(coupon[i].odds(pick))));
          },
        ),
    ];
  }

  PlacedBet? _betOn(CareerState career, BetMatch m) {
    for (final b in career.spending.bets) {
      if (b.homeId == m.homeId && b.awayId == m.awayId) return b;
    }
    return null;
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 32,
              color: scheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.financeBalance,
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    l10n.money(balance),
                    style: textTheme.headlineSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
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

class _RaceCard extends StatelessWidget {
  const _RaceCard({required this.career});

  final CareerState career;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ready = SpendingEngine.raceReady(career);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.emoji_events, size: 32),
        title: Text(l10n.raceTitle),
        subtitle: Text(ready ? l10n.raceCardHint : l10n.raceCardDone),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/game/race'),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({required this.spending});

  final Spending spending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final color = habitColor(spending.habit);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.habitTitle, style: textTheme.titleSmall),
                ),
                Text(
                  l10n.habitLevelName(spending.habit),
                  style: textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: spending.habit / SpendingBalance.habitMax,
              minHeight: 10,
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Text(l10n.habitHint(spending.habit), style: textTheme.bodySmall),
            if (spending.suspended) ...[
              const SizedBox(height: 6),
              Text(
                l10n.habitSuspended(spending.suspendedWeeks),
                style: textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (spending.totalStaked > 0) ...[
              const SizedBox(height: 6),
              Text(
                l10n.habitStats(
                  l10n.money(spending.totalStaked),
                  l10n.money(spending.totalWon),
                  l10n.money(spending.totalFines),
                ),
                style: textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.match,
    required this.world,
    required this.bet,
    required this.canPay,
    required this.onPick,
  });

  final BetMatch match;
  final ClubWorld world;
  final PlacedBet? bet;
  final bool canPay;
  final void Function(BetPick pick) onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${world.team(match.homeId).name} - '
              '${world.team(match.awayId).name}',
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (bet != null) ...[
              Text(l10n.betAlready, style: textTheme.labelMedium),
              Text(
                l10n.betBetLine(
                  l10n.betPickName(bet!.pick),
                  l10n.money(bet!.stake),
                  _odds(bet!.odds),
                ),
                style: textTheme.bodyMedium,
              ),
            ] else
              Row(
                children: [
                  for (final p in BetPick.values) ...[
                    if (p != BetPick.home) const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: canPay ? () => onPick(p) : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.betPickName(p),
                              style: textTheme.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _odds(match.odds(p)),
                              style: textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.spending, required this.world});

  final Spending spending;
  final ClubWorld world;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    if (spending.settled.isEmpty) {
      return Text(l10n.betNoResults, style: textTheme.bodyMedium);
    }
    return Card(
      child: Column(
        children: [
          for (final b in spending.settled)
            ListTile(
              dense: true,
              leading: Icon(
                b.won ? Icons.check_circle : Icons.cancel,
                color: b.won ? const Color(0xFF43A047) : scheme.error,
              ),
              title: Text(
                '${world.team(b.homeId).name} ${b.homeGoals}-${b.awayGoals} '
                '${world.team(b.awayId).name}',
              ),
              subtitle: Text(
                l10n.betResultLine(
                  l10n.betPickName(b.pick),
                  l10n.money(b.stake),
                  l10n.money(b.payout),
                ),
              ),
              trailing: Text(b.won ? l10n.betWon : l10n.betLost),
            ),
        ],
      ),
    );
  }
}
