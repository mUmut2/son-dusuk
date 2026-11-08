import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/career/career_state.dart';
import '../../domain/career/season_calendar.dart';
import '../../domain/club/agent.dart';
import '../../domain/club/club_balance.dart';
import '../../domain/club/finance.dart';
import '../../domain/club/transfer_market.dart';
import '../../domain/club/transfer_offer.dart';
import '../../domain/league/club_world.dart';
import '../../domain/league/league_table.dart';
import '../l10n_labels.dart';
import '../providers.dart';

/// Kulüp sekmesi: sözleşme, teklifler, menajer, finans ve lig tablosu.
class ClubTab extends ConsumerWidget {
  const ClubTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final career = ref.watch(activeCareerProvider)!.state;
    final world = ref.watch(clubWorldProvider)!;
    final textTheme = Theme.of(context).textTheme;
    final contract = career.contract;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.navClub, style: textTheme.headlineSmall),
        const SizedBox(height: 12),
        if (contract == null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_off_outlined),
              title: Text(l10n.clubFreeAgentTitle),
              subtitle: Text(l10n.clubFreeAgentBody),
            ),
          )
        else
          _ContractCard(career: career, world: world),
        _Section(
          title: l10n.offersTitle,
          child: _Offers(career: career, world: world),
        ),
        _Section(
          title: l10n.agentTitle,
          child: _AgentSection(career: career),
        ),
        _Section(
          title: l10n.financeTitle,
          child: _FinanceSection(career: career),
        ),
        if (contract != null)
          _Section(
            title: l10n.tableTitle,
            child: _LeagueTableView(career: career, world: world),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class _ContractCard extends StatelessWidget {
  const _ContractCard({required this.career, required this.world});

  final CareerState career;
  final ClubWorld world;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final c = career.contract!;
    final team = world.team(c.clubId);
    final tier = world.tierOf(c.clubId);
    final rounds = SeasonCalendar.roundsPlayed(career.week);
    final standings = LeagueTable.compute(
      world: world,
      tier: tier,
      season: career.season,
      throughRound: rounds,
      playerResults: career.results,
    );
    final sorted = standings.sorted;
    final pos = sorted.indexWhere((r) => r.teamId == c.clubId) + 1;
    final points = standings.row(c.clubId).points;

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: textTheme.titleSmall),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(team.name, style: textTheme.titleLarge),
            Text(
              rounds == 0
                  ? l10n.clubLeagueLineNoMatch(l10n.tierName(tier))
                  : l10n.clubLeagueLine(l10n.tierName(tier), pos, points),
            ),
            const Divider(height: 24),
            Text(l10n.contractTitle, style: textTheme.titleSmall),
            const SizedBox(height: 4),
            row(l10n.contractWage, l10n.moneyWeek(c.weeklyWage)),
            row(l10n.contractRole, l10n.roleName(c.role)),
            row(l10n.contractEnds, l10n.contractEndsValue(c.endSeason)),
            row(
              l10n.marketValue,
              l10n.money(TransferMarket.marketValue(career.player)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Offers extends ConsumerWidget {
  const _Offers({required this.career, required this.world});

  final CareerState career;
  final ClubWorld world;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    if (career.offers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.offersNone),
          const SizedBox(height: 4),
          Text(l10n.offersWindowHint, style: textTheme.bodySmall),
        ],
      );
    }
    return Column(
      children: [
        for (final offer in career.offers)
          _OfferCard(offer: offer, career: career, world: world),
      ],
    );
  }
}

class _OfferCard extends ConsumerWidget {
  const _OfferCard({
    required this.offer,
    required this.career,
    required this.world,
  });

  final TransferOffer offer;
  final CareerState career;
  final ClubWorld world;

  Future<void> _sign(
    BuildContext context,
    WidgetRef ref,
    int wage,
    String clubName,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(activeCareerProvider.notifier).acceptOffer(offer, wage);
    messenger.showSnackBar(SnackBar(content: Text(l10n.offerSigned(clubName))));
  }

  Future<void> _negotiate(
    BuildContext context,
    WidgetRef ref,
    String clubName,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(activeCareerProvider.notifier);
    final asked = await showDialog<int>(
      context: context,
      builder: (context) => _NegotiateDialog(offer: offer),
    );
    if (asked == null || !context.mounted) return;

    final result = TransferMarket.negotiate(offer, asked);
    switch (result.kind) {
      case NegotiationKind.accepted:
        await _sign(context, ref, result.wage, clubName);
      case NegotiationKind.walkedAway:
        await notifier.declineOffer(offer);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.negotiateWalked(clubName))),
        );
      case NegotiationKind.counter:
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.negotiateTitle),
            content: Text(
              l10n.negotiateCounter(clubName, l10n.moneyWeek(result.wage)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.negotiateSignAt),
              ),
            ],
          ),
        );
        if (!context.mounted) return;
        if (ok ?? false) {
          await _sign(context, ref, result.wage, clubName);
        } else {
          await notifier.markNegotiated(offer);
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final clubName = world.team(offer.clubId).name;
    final weeksLeft = (offer.expiresAt - career.absoluteWeek + 1).clamp(0, 99);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer.kind == OfferKind.renewal
                  ? l10n.offerRenewalTitle(clubName)
                  : l10n.offerTransferTitle(clubName),
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.offerTerms(
                l10n.tierName(world.tierOf(offer.clubId)),
                offer.years,
                l10n.roleName(offer.role),
              ),
            ),
            Text(
              l10n.moneyWeek(offer.weeklyWage),
              style: textTheme.titleMedium,
            ),
            Text(l10n.offerExpires(weeksLeft), style: textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () =>
                      _sign(context, ref, offer.weeklyWage, clubName),
                  child: Text(l10n.offerAccept),
                ),
                if (!offer.negotiated)
                  OutlinedButton(
                    onPressed: () => _negotiate(context, ref, clubName),
                    child: Text(l10n.offerNegotiate),
                  ),
                TextButton(
                  onPressed: () => ref
                      .read(activeCareerProvider.notifier)
                      .declineOffer(offer),
                  child: Text(l10n.offerDecline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NegotiateDialog extends StatefulWidget {
  const _NegotiateDialog({required this.offer});

  final TransferOffer offer;

  @override
  State<_NegotiateDialog> createState() => _NegotiateDialogState();
}

class _NegotiateDialogState extends State<_NegotiateDialog> {
  static const int _steps = 16;
  int _step = 0;

  int get _wage {
    final base = widget.offer.weeklyWage;
    final raw = base * (1 + ClubBalance.maxAsk * _step / _steps);
    final rounded = (raw / 10).round() * 10;
    return rounded < base ? base : rounded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.negotiateTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.negotiateAsk),
          Text(
            l10n.moneyWeek(_wage),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Slider(
            value: _step.toDouble(),
            max: _steps.toDouble(),
            divisions: _steps,
            onChanged: (v) => setState(() => _step = v.round()),
          ),
          Text(
            l10n.negotiateHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _wage),
          child: Text(l10n.negotiateSubmit),
        ),
      ],
    );
  }
}

class _AgentSection extends ConsumerWidget {
  const _AgentSection({required this.career});

  final CareerState career;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(activeCareerProvider.notifier);
    final agent = career.agent;

    if (agent != null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.handshake_outlined),
          title: Text(l10n.agentLevelName(agent.level)),
          subtitle: Text(
            l10n.agentInfo(agent.name, (agent.commission * 100).round()),
          ),
          trailing: TextButton(
            onPressed: notifier.fireAgent,
            child: Text(l10n.agentFire),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.agentNone, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        for (final level in AgentPool.levels)
          Card(
            child: ListTile(
              title: Text(l10n.agentLevelName(level)),
              subtitle: Text(
                AgentPool.canHire(level, career.player.overall)
                    ? l10n.agentInfo(
                        AgentPool.candidate(career.worldSeed, level).name,
                        (ClubBalance.agentCommission[level]! * 100).round(),
                      )
                    : l10n.agentLocked(ClubBalance.agentMinOverall[level]!),
              ),
              trailing: FilledButton(
                onPressed: AgentPool.canHire(level, career.player.overall)
                    ? () => notifier.hireAgent(level)
                    : null,
                child: Text(l10n.agentHire),
              ),
            ),
          ),
      ],
    );
  }
}

class _FinanceSection extends ConsumerWidget {
  const _FinanceSection({required this.career});

  final CareerState career;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final finance = career.finance;
    final weekly = Economy.weekly(
      contract: career.contract,
      agent: career.agent,
      lifestyle: finance.lifestyle,
    );
    final income = weekly.lines
        .where((l) => l.amount > 0)
        .fold(0, (s, l) => s + l.amount);
    final cost = -weekly.lines
        .where((l) => l.amount < 0)
        .fold(0, (s, l) => s + l.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.financeBalance, style: textTheme.labelMedium),
                Text(
                  l10n.money(finance.balance),
                  style: textTheme.headlineSmall?.copyWith(
                    color: finance.inDebt
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.financeWeekly(l10n.money(income), l10n.money(cost)),
                  style: textTheme.bodySmall,
                ),
                if (finance.inDebt)
                  Text(
                    l10n.financeDebt,
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.lifestyleTitle, style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final l in Lifestyle.values)
              ChoiceChip(
                label: Text(l10n.lifestyleName(l)),
                selected: finance.lifestyle == l,
                onSelected: (_) =>
                    ref.read(activeCareerProvider.notifier).setLifestyle(l),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.lifestyleInfo(
            l10n.moneyWeek(ClubBalance.lifestyleCost[finance.lifestyle]!),
            '+${ClubBalance.lifestyleMorale[finance.lifestyle]}',
          ),
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LeagueTableView extends StatelessWidget {
  const _LeagueTableView({required this.career, required this.world});

  final CareerState career;
  final ClubWorld world;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final clubId = career.contract!.clubId;
    final rounds = SeasonCalendar.roundsPlayed(career.week);
    if (rounds == 0) return Text(l10n.tableEmpty);

    final rows = LeagueTable.compute(
      world: world,
      tier: world.tierOf(clubId),
      season: career.season,
      throughRound: rounds,
      playerResults: career.results,
    ).sorted;

    Widget cell(String text, {double? width, bool bold = false}) {
      final t = Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: bold
            ? textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)
            : textTheme.bodyMedium,
      );
      return width == null
          ? Expanded(child: t)
          : SizedBox(width: width, child: t);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                cell('', width: 28),
                cell(''),
                cell(l10n.tableHeaderPlayed, width: 32),
                cell(l10n.tableHeaderGd, width: 36),
                cell(l10n.tableHeaderPoints, width: 32),
              ],
            ),
            for (var i = 0; i < rows.length; i++)
              Container(
                color: rows[i].teamId == clubId
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    cell('${i + 1}', width: 28),
                    cell(
                      world.team(rows[i].teamId).name,
                      bold: rows[i].teamId == clubId,
                    ),
                    cell('${rows[i].played}', width: 32),
                    cell('${rows[i].goalDifference}', width: 36),
                    cell('${rows[i].points}', width: 32, bold: true),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
