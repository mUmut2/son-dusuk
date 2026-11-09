import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../core/game_random.dart';
import '../../domain/career/season_calendar.dart';
import '../../domain/career/week_engine.dart';
import '../../domain/league/team.dart';
import '../../domain/national/nation.dart';
import '../../domain/national/national_engine.dart';
import '../../domain/national/tournament.dart';
import '../../domain/match/critical_moment.dart';
import '../../domain/match/match_session.dart';
import '../../domain/match/match_simulator.dart';
import '../../domain/match/moment_resolver.dart';
import '../../domain/match/player_rating.dart';
import '../../game/mini_game_types.dart';
import '../../game/mini_game_view.dart';
import '../l10n_labels.dart';
import '../providers.dart';

enum _Stage { preMatch, momentIntro, miniGame, momentResult, summary }

/// Lig maçı akışı: kritik an -> mini oyun -> sonuç -> maç özeti.
class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({this.seed, super.key});

  /// Testler için sabit seed.
  final int? seed;

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  late final GameRandom _random = GameRandom(widget.seed);
  late final Team _playerTeam;
  late final Team _opponent;
  late final Side _playerSide;
  late final MatchSession _session;
  late final bool _isNational;
  int _round = 0;

  /// Turnuva eleme maçı berabere bitince penaltı atışları (bizim, rakibin).
  (int, int)? _pens;

  _Stage _stage = _Stage.preMatch;
  bool _finishing = false;
  CriticalMoment? _moment;
  MomentOutcome? _lastOutcome;

  @override
  void initState() {
    super.initState();
    final career = ref.read(activeCareerProvider)!.state;
    final player = career.player;
    _isNational = NationalEngine.dayOf(career) == NationalDay.play;
    if (_isNational) {
      // Turnuva maçı: tarafsız saha, ülke takımları.
      final bracket = NationalEngine.tournamentOf(career)!;
      _round = NationalEngine.roundOfWeek(career.week)!;
      final home = bracket.nation(NationalWorld.homeId);
      final opponent = bracket.opponentOfHome(_round)!;
      _playerTeam = Team(id: home.id, name: home.name, strength: home.strength);
      _opponent = Team(
        id: opponent.id,
        name: opponent.name,
        strength: opponent.strength,
      );
      _playerSide = Side.home;
    } else {
      final world = ref.read(clubWorldProvider)!;
      final clubId = career.contract!.clubId;
      final round = SeasonCalendar.leagueRoundOf(career.week) ?? 1;
      final fixture = world.fixtureFor(clubId, round);
      _playerTeam = world.team(clubId);
      _opponent = fixture.opponent;
      _playerSide = fixture.home ? Side.home : Side.away;
    }
    final playerIsHome = _playerSide == Side.home;
    _session = MatchSession.start(
      homeStrength: playerIsHome ? _playerTeam.strength : _opponent.strength,
      awayStrength: playerIsHome ? _opponent.strength : _playerTeam.strength,
      playerSide: _playerSide,
      player: player,
      random: _random,
      neutral: _isNational,
    );
  }

  Team get _home => _playerSide == Side.home ? _playerTeam : _opponent;
  Team get _away => _playerSide == Side.home ? _opponent : _playerTeam;

  /// Maçın o ana kadarki skoru (gelecekteki golleri göstermez).
  int _goalsAt(Side side) => _session.result.goals
      .where((g) => g.side == side && g.minute <= _moment!.minute)
      .length;

  void _next() {
    final m = _session.nextMoment;
    setState(() {
      _moment = m;
      _stage = m == null ? _Stage.summary : _Stage.momentIntro;
    });
  }

  void _resolve(MomentOutcome outcome) {
    _session.resolve(_moment!, outcome);
    setState(() {
      _lastOutcome = outcome;
      _stage = _Stage.momentResult;
    });
  }

  void _autoResolve() {
    final career = ref.read(activeCareerProvider)!.state;
    _resolve(
      MomentResolver.autoResolve(
        _moment!,
        career.player,
        _random,
        performance: career.status.performanceMultiplier,
      ),
    );
  }

  void _quickSimRest() {
    final career = ref.read(activeCareerProvider)!.state;
    _session.autoPlay(
      career.player,
      _random,
      performance: career.status.performanceMultiplier,
    );
    setState(() => _stage = _Stage.summary);
  }

  Future<void> _finishWeek(double rating, int own, int other) async {
    setState(() => _finishing = true);
    final goals = _session.result.goals;
    await ref
        .read(activeCareerProvider.notifier)
        .playWeek(
          WeekMatch(
            rating: rating,
            goals: goals.where((g) => g.byPlayer).length,
            assists: goals.where((g) => g.assistedByPlayer).length,
            scoreFor: own,
            scoreAgainst: other,
            pensFor: own == other ? _pens?.$1 : null,
            pensAgainst: own == other ? _pens?.$2 : null,
            result: own > other
                ? MatchResultKind.win
                : own < other
                ? MatchResultKind.loss
                : _pens != null && _pens!.$1 > _pens!.$2
                ? MatchResultKind.win
                : _pens != null
                ? MatchResultKind.loss
                : MatchResultKind.draw,
          ),
        );
    if (!mounted) return;
    context.go('/game/week');
  }

  void _onMiniFinished(MiniGameFinish finish) {
    // Flame güncelleme döngüsünden çağrılır; widget ağacını bir sonraki karede değiştir.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final zone = finish.penaltyZone;
      if (zone != null) {
        await ref.read(activeCareerProvider.notifier).recordPenalty(zone);
        if (!mounted) return;
      }
      _resolve(finish.outcome);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_stage == _Stage.miniGame) {
      return Scaffold(body: _buildMiniGame(l10n));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNational
              ? l10n.nationalMatchTitle(l10n.roundName(_round))
              : l10n.matchTitle,
        ),
        automaticallyImplyLeading: _stage == _Stage.preMatch,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: switch (_stage) {
                _Stage.preMatch => _buildPreMatch(l10n),
                _Stage.momentIntro => _buildIntro(l10n),
                _Stage.momentResult => _buildMomentResult(l10n),
                _Stage.summary => _buildSummary(l10n),
                _Stage.miniGame => const SizedBox.shrink(),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniGame(AppLocalizations l10n) {
    final career = ref.read(activeCareerProvider)!.state;
    final settings = ref.read(settingsProvider);
    return MiniGameView(
      type: _moment!.type,
      player: career.equipment.applyToPlayer(career.player),
      status: career.status,
      difficulty: settings.difficulty,
      vibration: settings.vibrationOn,
      penaltyHistory: career.stats.penaltyZones,
      random: _random,
      labels: MiniGameLabels(
        hints: {
          MomentType.shot: l10n.shotHint,
          MomentType.oneOnOne: l10n.miniHint_oneOnOne,
          MomentType.freeKick: l10n.miniHint_freeKick,
          MomentType.header: l10n.miniHint_header,
          MomentType.penalty: l10n.miniHint_penalty,
          MomentType.keyPass: l10n.miniHint_keyPass,
          MomentType.dribble: l10n.miniHint_dribble,
          MomentType.tackle: l10n.miniHint_tackle,
        },
        invalidSwipe: l10n.shotInvalid,
        goal: l10n.shotGoal,
        saved: l10n.shotSaved,
        blocked: l10n.shotBlocked,
        offTarget: l10n.shotOff,
        woodwork: l10n.shotWood,
        timeout: l10n.shotTimeout,
        perfect: l10n.shotPerfect,
        passComplete: l10n.passComplete,
        passAssist: l10n.passAssist,
        passIntercepted: l10n.passIntercepted,
        dribbleBeaten: l10n.dribbleBeaten,
        dribbleFail: l10n.dribbleFail,
        tackleWon: l10n.tackleWon,
        tackleFoul: l10n.tackleFoul,
        tackleBeaten: l10n.tackleBeaten,
        shootButton: l10n.shootButton,
        tooEarly: l10n.tooEarly,
      ),
      onFinished: _onMiniFinished,
    );
  }

  Widget _buildPreMatch(AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Text(
          l10n.matchVersus(_home.name, _away.name),
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(l10n.matchYourTeam(_playerTeam.name), textAlign: TextAlign.center),
        if (_isNational) ...[
          const SizedBox(height: 8),
          Text(
            l10n.nationalKnockoutNote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const Spacer(),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: _next,
          child: Text(l10n.matchStart),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: _quickSimRest,
          child: Text(l10n.matchQuickSim),
        ),
      ],
    );
  }

  Widget _buildIntro(AppLocalizations l10n) {
    final moment = _moment!;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScoreBoard(
          home: _home.name,
          away: _away.name,
          homeGoals: _goalsAt(Side.home),
          awayGoals: _goalsAt(Side.away),
        ),
        const Spacer(),
        Text(
          l10n.matchMinute(moment.minute),
          textAlign: TextAlign.center,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          _momentTitle(l10n, moment.type),
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(_momentIntro(l10n, moment.type), textAlign: TextAlign.center),
        const Spacer(),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: () => setState(() => _stage = _Stage.miniGame),
          child: Text(l10n.momentPlay),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: _autoResolve,
          child: Text(l10n.momentAuto),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: _quickSimRest,
          child: Text(l10n.matchQuickSimRest),
        ),
      ],
    );
  }

  Widget _buildMomentResult(AppLocalizations l10n) {
    final o = _lastOutcome!;
    final text = o.playerGoal
        ? l10n.outcomeGoal
        : o.playerAssist
        ? l10n.outcomeAssist
        : o.concededGoal
        ? l10n.outcomeConceded
        : l10n.outcomeNothing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScoreBoard(
          home: _home.name,
          away: _away.name,
          homeGoals: _goalsAt(Side.home),
          awayGoals: _goalsAt(Side.away),
        ),
        const Spacer(),
        Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Spacer(),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: _next,
          child: Text(l10n.momentContinue),
        ),
      ],
    );
  }

  Widget _buildSummary(AppLocalizations l10n) {
    // Çözülmemiş an kaldıysa (hızlı simülasyon) otomatik tamamlanmış olur.
    final result = _session.result;
    final own = _playerSide == Side.home ? result.homeGoals : result.awayGoals;
    final other = result.totalGoals - own;
    if (_isNational && own == other && _pens == null) {
      _pens = Shootout.decide(
        _playerTeam.strength,
        _opponent.strength,
        _random,
      );
    }
    final pens = own == other ? _pens : null;
    final verdict = own > other
        ? l10n.resultWin
        : own < other
        ? l10n.resultLoss
        : pens != null
        ? (pens.$1 > pens.$2
              ? l10n.shootoutWon('${pens.$1}-${pens.$2}')
              : l10n.shootoutLost('${pens.$1}-${pens.$2}'))
        : l10n.resultDraw;
    final rating = PlayerRating.compute(_session);
    final textTheme = Theme.of(context).textTheme;

    String teamOf(Side s) => s == Side.home ? _home.name : _away.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.summaryTitle,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _ScoreBoard(
          home: _home.name,
          away: _away.name,
          homeGoals: result.homeGoals,
          awayGoals: result.awayGoals,
        ),
        const SizedBox(height: 4),
        Text(verdict, textAlign: TextAlign.center, style: textTheme.titleLarge),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: Text(l10n.ratingLabel),
            trailing: Text(
              rating.toStringAsFixed(1),
              style: textTheme.headlineSmall,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: result.goals.isEmpty
              ? Center(child: Text(l10n.noGoals))
              : ListView(
                  children: [
                    for (final g in result.goals)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.sports_soccer, size: 20),
                        title: Text(
                          g.byPlayer
                              ? l10n.timelineGoalYou(g.minute, teamOf(g.side))
                              : g.assistedByPlayer
                              ? l10n.timelineAssistYou(g.minute, teamOf(g.side))
                              : l10n.timelineGoal(g.minute, teamOf(g.side)),
                        ),
                      ),
                  ],
                ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: _finishing ? null : () => _finishWeek(rating, own, other),
          child: Text(l10n.finishWeek),
        ),
      ],
    );
  }

  String _momentTitle(AppLocalizations l10n, MomentType t) => switch (t) {
    MomentType.shot => l10n.momentTitle_shot,
    MomentType.oneOnOne => l10n.momentTitle_oneOnOne,
    MomentType.header => l10n.momentTitle_header,
    MomentType.freeKick => l10n.momentTitle_freeKick,
    MomentType.penalty => l10n.momentTitle_penalty,
    MomentType.keyPass => l10n.momentTitle_keyPass,
    MomentType.dribble => l10n.momentTitle_dribble,
    MomentType.tackle => l10n.momentTitle_tackle,
  };

  String _momentIntro(AppLocalizations l10n, MomentType t) => switch (t) {
    MomentType.shot => l10n.momentIntro_shot,
    MomentType.oneOnOne => l10n.momentIntro_oneOnOne,
    MomentType.header => l10n.momentIntro_header,
    MomentType.freeKick => l10n.momentIntro_freeKick,
    MomentType.penalty => l10n.momentIntro_penalty,
    MomentType.keyPass => l10n.momentIntro_keyPass,
    MomentType.dribble => l10n.momentIntro_dribble,
    MomentType.tackle => l10n.momentIntro_tackle,
  };
}

class _ScoreBoard extends StatelessWidget {
  const _ScoreBoard({
    required this.home,
    required this.away,
    required this.homeGoals,
    required this.awayGoals,
  });

  final String home;
  final String away;
  final int homeGoals;
  final int awayGoals;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text('$homeGoals - $awayGoals', style: textTheme.displaySmall),
        Text(
          '$home  -  $away',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
