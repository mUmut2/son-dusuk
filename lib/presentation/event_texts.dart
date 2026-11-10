import '../app/l10n/app_localizations.dart';

/// Bir olayın yerelleştirilmiş metinleri (ARB: `ev_<id>_*`).
class EventTexts {
  const EventTexts({
    required this.title,
    required this.body,
    required this.choices,
    required this.results,
    required this.backfires,
    this.headlines = const [],
  });

  final String title;
  final String body;
  final List<String> choices;

  /// Seçenek başına sonuç cümlesi.
  final List<String> results;

  /// Seçenek başına "ters tepti" cümlesi (riskli olmayanlarda null).
  final List<String?> backfires;

  /// Seçenek başına gazete manşeti (yalnızca röportajlarda dolu).
  final List<String> headlines;
}

extension EventTextLookup on AppLocalizations {
  EventTexts eventTexts(String id, Map<String, String> p) {
    final l = this;
    return switch (id) {
      'pressWin' => EventTexts(
        title: l.ev_pressWin_title,
        headlines: [l.ev_pressWin_h0, l.ev_pressWin_h1, l.ev_pressWin_h2],
        body: l.ev_pressWin_body(p['opponent'] ?? '', p['score'] ?? ''),
        choices: [l.ev_pressWin_c0, l.ev_pressWin_c1, l.ev_pressWin_c2],
        results: [l.ev_pressWin_r0, l.ev_pressWin_r1, l.ev_pressWin_r2],
        backfires: [null, null, l.ev_pressWin_b2],
      ),
      'pressLoss' => EventTexts(
        title: l.ev_pressLoss_title,
        headlines: [l.ev_pressLoss_h0, l.ev_pressLoss_h1, l.ev_pressLoss_h2],
        body: l.ev_pressLoss_body(p['opponent'] ?? '', p['score'] ?? ''),
        choices: [l.ev_pressLoss_c0, l.ev_pressLoss_c1, l.ev_pressLoss_c2],
        results: [l.ev_pressLoss_r0, l.ev_pressLoss_r1, l.ev_pressLoss_r2],
        backfires: [null, l.ev_pressLoss_b1, null],
      ),
      'pressStar' => EventTexts(
        title: l.ev_pressStar_title,
        headlines: [l.ev_pressStar_h0, l.ev_pressStar_h1, l.ev_pressStar_h2],
        body: l.ev_pressStar_body(p['opponent'] ?? '', p['score'] ?? ''),
        choices: [l.ev_pressStar_c0, l.ev_pressStar_c1, l.ev_pressStar_c2],
        results: [l.ev_pressStar_r0, l.ev_pressStar_r1, l.ev_pressStar_r2],
        backfires: [null, l.ev_pressStar_b1, null],
      ),
      'pressPoor' => EventTexts(
        title: l.ev_pressPoor_title,
        headlines: [l.ev_pressPoor_h0, l.ev_pressPoor_h1, l.ev_pressPoor_h2],
        body: l.ev_pressPoor_body(p['opponent'] ?? '', p['score'] ?? ''),
        choices: [l.ev_pressPoor_c0, l.ev_pressPoor_c1, l.ev_pressPoor_c2],
        results: [l.ev_pressPoor_r0, l.ev_pressPoor_r1, l.ev_pressPoor_r2],
        backfires: [null, null, null],
      ),
      'pressBench' => EventTexts(
        title: l.ev_pressBench_title,
        headlines: [l.ev_pressBench_h0, l.ev_pressBench_h1, l.ev_pressBench_h2],
        body: l.ev_pressBench_body,
        choices: [l.ev_pressBench_c0, l.ev_pressBench_c1, l.ev_pressBench_c2],
        results: [l.ev_pressBench_r0, l.ev_pressBench_r1, l.ev_pressBench_r2],
        backfires: [null, null, null],
      ),
      'pressDraw' => EventTexts(
        title: l.ev_pressDraw_title,
        body: l.ev_pressDraw_body,
        headlines: [l.ev_pressDraw_h0, l.ev_pressDraw_h1, l.ev_pressDraw_h2],
        choices: [l.ev_pressDraw_c0, l.ev_pressDraw_c1, l.ev_pressDraw_c2],
        results: [l.ev_pressDraw_r0, l.ev_pressDraw_r1, l.ev_pressDraw_r2],
        backfires: [null, null, l.ev_pressDraw_b2],
      ),
      'pressFood' => EventTexts(
        title: l.ev_pressFood_title,
        body: l.ev_pressFood_body,
        headlines: [l.ev_pressFood_h0, l.ev_pressFood_h1, l.ev_pressFood_h2],
        choices: [l.ev_pressFood_c0, l.ev_pressFood_c1, l.ev_pressFood_c2],
        results: [l.ev_pressFood_r0, l.ev_pressFood_r1, l.ev_pressFood_r2],
        backfires: [null, l.ev_pressFood_b1, null],
      ),
      'pressCelebration' => EventTexts(
        title: l.ev_pressCelebration_title,
        body: l.ev_pressCelebration_body,
        headlines: [
          l.ev_pressCelebration_h0,
          l.ev_pressCelebration_h1,
          l.ev_pressCelebration_h2,
        ],
        choices: [
          l.ev_pressCelebration_c0,
          l.ev_pressCelebration_c1,
          l.ev_pressCelebration_c2,
        ],
        results: [
          l.ev_pressCelebration_r0,
          l.ev_pressCelebration_r1,
          l.ev_pressCelebration_r2,
        ],
        backfires: [null, null, null],
      ),
      'pressRival' => EventTexts(
        title: l.ev_pressRival_title,
        body: l.ev_pressRival_body,
        headlines: [l.ev_pressRival_h0, l.ev_pressRival_h1, l.ev_pressRival_h2],
        choices: [l.ev_pressRival_c0, l.ev_pressRival_c1, l.ev_pressRival_c2],
        results: [l.ev_pressRival_r0, l.ev_pressRival_r1, l.ev_pressRival_r2],
        backfires: [null, null, l.ev_pressRival_b2],
      ),
      'pressMascot' => EventTexts(
        title: l.ev_pressMascot_title,
        body: l.ev_pressMascot_body,
        headlines: [
          l.ev_pressMascot_h0,
          l.ev_pressMascot_h1,
          l.ev_pressMascot_h2,
        ],
        choices: [
          l.ev_pressMascot_c0,
          l.ev_pressMascot_c1,
          l.ev_pressMascot_c2,
        ],
        results: [
          l.ev_pressMascot_r0,
          l.ev_pressMascot_r1,
          l.ev_pressMascot_r2,
        ],
        backfires: [null, null, null],
      ),
      'pressPower' => EventTexts(
        title: l.ev_pressPower_title,
        body: l.ev_pressPower_body,
        headlines: [l.ev_pressPower_h0, l.ev_pressPower_h1, l.ev_pressPower_h2],
        choices: [l.ev_pressPower_c0, l.ev_pressPower_c1, l.ev_pressPower_c2],
        results: [l.ev_pressPower_r0, l.ev_pressPower_r1, l.ev_pressPower_r2],
        backfires: [null, null, null],
      ),
      'pressKids' => EventTexts(
        title: l.ev_pressKids_title,
        body: l.ev_pressKids_body,
        headlines: [l.ev_pressKids_h0, l.ev_pressKids_h1, l.ev_pressKids_h2],
        choices: [l.ev_pressKids_c0, l.ev_pressKids_c1, l.ev_pressKids_c2],
        results: [l.ev_pressKids_r0, l.ev_pressKids_r1, l.ev_pressKids_r2],
        backfires: [null, null, null],
      ),
      'familyDinner' => EventTexts(
        title: l.ev_familyDinner_title,
        body: l.ev_familyDinner_body,
        choices: [
          l.ev_familyDinner_c0,
          l.ev_familyDinner_c1,
          l.ev_familyDinner_c2,
        ],
        results: [
          l.ev_familyDinner_r0,
          l.ev_familyDinner_r1,
          l.ev_familyDinner_r2,
        ],
        backfires: [null, null, null],
      ),
      'partyInvite' => EventTexts(
        title: l.ev_partyInvite_title,
        body: l.ev_partyInvite_body,
        choices: [
          l.ev_partyInvite_c0,
          l.ev_partyInvite_c1,
          l.ev_partyInvite_c2,
        ],
        results: [
          l.ev_partyInvite_r0,
          l.ev_partyInvite_r1,
          l.ev_partyInvite_r2,
        ],
        backfires: [l.ev_partyInvite_b0, null, null],
      ),
      'fanMeet' => EventTexts(
        title: l.ev_fanMeet_title,
        body: l.ev_fanMeet_body,
        choices: [l.ev_fanMeet_c0, l.ev_fanMeet_c1, l.ev_fanMeet_c2],
        results: [l.ev_fanMeet_r0, l.ev_fanMeet_r1, l.ev_fanMeet_r2],
        backfires: [null, null, null],
      ),
      'coachTalk' => EventTexts(
        title: l.ev_coachTalk_title,
        body: l.ev_coachTalk_body,
        choices: [l.ev_coachTalk_c0, l.ev_coachTalk_c1, l.ev_coachTalk_c2],
        results: [l.ev_coachTalk_r0, l.ev_coachTalk_r1, l.ev_coachTalk_r2],
        backfires: [null, null, l.ev_coachTalk_b2],
      ),
      'teammateRift' => EventTexts(
        title: l.ev_teammateRift_title,
        body: l.ev_teammateRift_body,
        choices: [
          l.ev_teammateRift_c0,
          l.ev_teammateRift_c1,
          l.ev_teammateRift_c2,
        ],
        results: [
          l.ev_teammateRift_r0,
          l.ev_teammateRift_r1,
          l.ev_teammateRift_r2,
        ],
        backfires: [null, null, null],
      ),
      'sponsorOffer' => EventTexts(
        title: l.ev_sponsorOffer_title,
        body: l.ev_sponsorOffer_body,
        choices: [
          l.ev_sponsorOffer_c0,
          l.ev_sponsorOffer_c1,
          l.ev_sponsorOffer_c2,
        ],
        results: [
          l.ev_sponsorOffer_r0,
          l.ev_sponsorOffer_r1,
          l.ev_sponsorOffer_r2,
        ],
        backfires: [null, null, null],
      ),
      'charity' => EventTexts(
        title: l.ev_charity_title,
        body: l.ev_charity_body,
        choices: [l.ev_charity_c0, l.ev_charity_c1, l.ev_charity_c2],
        results: [l.ev_charity_r0, l.ev_charity_r1, l.ev_charity_r2],
        backfires: [null, null, null],
      ),
      'transferRumor' => EventTexts(
        title: l.ev_transferRumor_title,
        body: l.ev_transferRumor_body,
        choices: [
          l.ev_transferRumor_c0,
          l.ev_transferRumor_c1,
          l.ev_transferRumor_c2,
        ],
        results: [
          l.ev_transferRumor_r0,
          l.ev_transferRumor_r1,
          l.ev_transferRumor_r2,
        ],
        backfires: [null, null, null],
      ),
      'socialPost' => EventTexts(
        title: l.ev_socialPost_title,
        body: l.ev_socialPost_body,
        choices: [l.ev_socialPost_c0, l.ev_socialPost_c1, l.ev_socialPost_c2],
        results: [l.ev_socialPost_r0, l.ev_socialPost_r1, l.ev_socialPost_r2],
        backfires: [null, l.ev_socialPost_b1, null],
      ),
      'injuryRehab' => EventTexts(
        title: l.ev_injuryRehab_title,
        body: l.ev_injuryRehab_body,
        choices: [
          l.ev_injuryRehab_c0,
          l.ev_injuryRehab_c1,
          l.ev_injuryRehab_c2,
        ],
        results: [
          l.ev_injuryRehab_r0,
          l.ev_injuryRehab_r1,
          l.ev_injuryRehab_r2,
        ],
        backfires: [null, l.ev_injuryRehab_b1, null],
      ),
      'youthAcademy' => EventTexts(
        title: l.ev_youthAcademy_title,
        body: l.ev_youthAcademy_body,
        choices: [l.ev_youthAcademy_c0, l.ev_youthAcademy_c1],
        results: [l.ev_youthAcademy_r0, l.ev_youthAcademy_r1],
        backfires: [null, null],
      ),
      'debtHelp' => EventTexts(
        title: l.ev_debtHelp_title,
        body: l.ev_debtHelp_body,
        choices: [l.ev_debtHelp_c0, l.ev_debtHelp_c1],
        results: [l.ev_debtHelp_r0, l.ev_debtHelp_r1],
        backfires: [null, null],
      ),
      _ => throw ArgumentError('Bilinmeyen olay: $id'),
    };
  }
}
