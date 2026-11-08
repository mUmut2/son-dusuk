import '../domain/match/critical_moment.dart';
import '../domain/match/moment_resolver.dart';
import '../domain/match/shot/shot_models.dart';

/// Bir mini oyunun domain'e döndürdüğü sonuç.
class MiniGameFinish {
  const MiniGameFinish(this.outcome, {this.penaltyZone});

  final MomentOutcome outcome;

  /// Penaltıda seçilen bölge (kalecinin sonraki penaltılarda okuması için).
  final int? penaltyZone;
}

/// Mini oyunlarda gösterilen yerelleştirilmiş metinler (Flutter tarafından verilir).
class MiniGameLabels {
  const MiniGameLabels({
    required this.hints,
    required this.invalidSwipe,
    required this.goal,
    required this.saved,
    required this.blocked,
    required this.offTarget,
    required this.woodwork,
    required this.timeout,
    required this.perfect,
    required this.passComplete,
    required this.passAssist,
    required this.passIntercepted,
    required this.dribbleBeaten,
    required this.dribbleFail,
    required this.tackleWon,
    required this.tackleFoul,
    required this.tackleBeaten,
    required this.shootButton,
    required this.tooEarly,
  });

  /// Her mini oyun için kısa talimat.
  final Map<MomentType, String> hints;
  final String invalidSwipe;
  final String goal;
  final String saved;
  final String blocked;
  final String offTarget;
  final String woodwork;
  final String timeout;
  final String perfect;
  final String passComplete;
  final String passAssist;
  final String passIntercepted;
  final String dribbleBeaten;
  final String dribbleFail;
  final String tackleWon;
  final String tackleFoul;
  final String tackleBeaten;
  final String shootButton;
  final String tooEarly;

  String forShotOutcome(ShotOutcome o) => switch (o) {
    ShotOutcome.goal => goal,
    ShotOutcome.saved => saved,
    ShotOutcome.blocked => blocked,
    ShotOutcome.offTarget => offTarget,
    ShotOutcome.woodwork => woodwork,
    ShotOutcome.timeout => timeout,
  };
}
