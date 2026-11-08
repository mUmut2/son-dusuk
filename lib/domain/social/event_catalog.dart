import 'event_models.dart';
import 'relationships.dart';
import 'social_balance.dart';

/// Tüm olay şablonları. Metinler ARB'de `ev_<id>_title`, `ev_<id>_body`,
/// `ev_<id>_c<n>` (seçenek etiketi) anahtarlarıyla tutulur.
abstract final class EventCatalog {
  static final List<EventTemplate> all = [
    // --- Basın toplantısı (maç sonrası) ---
    EventTemplate(
      id: 'pressWin',
      kind: EventKind.press,
      when: (c) => c.won,
      cooldownWeeks: 3,
      ignore: const EventEffect(media: -2),
      choices: const [
        EventChoice(EventEffect(teammates: 4, coach: 2, media: 1, morale: 1)),
        EventChoice(
          EventEffect(fans: 3, media: 3, teammates: -3, coach: -1, morale: 3),
        ),
        EventChoice(
          EventEffect(media: 5, fans: 2, teammates: -4),
          alt: EventEffect(media: -6, coach: -3, fans: -2),
          altChance: 0.35,
        ),
      ],
    ),
    EventTemplate(
      id: 'pressLoss',
      kind: EventKind.press,
      when: (c) => c.lost,
      cooldownWeeks: 3,
      ignore: const EventEffect(media: -2),
      choices: const [
        EventChoice(EventEffect(coach: 3, teammates: 2, fans: 1, morale: -1)),
        EventChoice(
          EventEffect(fans: 3, media: 2),
          alt: EventEffect(coach: -5, media: -3, teammates: -2),
          altChance: 0.5,
        ),
        EventChoice(EventEffect(media: -1)),
      ],
    ),
    EventTemplate(
      id: 'pressStar',
      kind: EventKind.press,
      when: (c) => c.goals >= SocialBalance.notableGoals,
      cooldownWeeks: 3,
      ignore: const EventEffect(media: -1),
      choices: const [
        EventChoice(EventEffect(fans: 3, teammates: 2, media: 2)),
        EventChoice(
          EventEffect(fans: 4, media: 4, teammates: -1),
          alt: EventEffect(media: -2, teammates: -3, fans: 1),
          altChance: 0.25,
        ),
        EventChoice(EventEffect(coach: 2, morale: 2, media: 1)),
      ],
    ),
    EventTemplate(
      id: 'pressPoor',
      kind: EventKind.press,
      when: (c) => (c.rating ?? 10) <= SocialBalance.notableRatingLow,
      cooldownWeeks: 3,
      ignore: const EventEffect(media: -2),
      choices: const [
        EventChoice(EventEffect(coach: 3, fans: 2)),
        EventChoice(EventEffect(media: -3, fans: 1, morale: 2)),
        EventChoice(EventEffect(media: -1, morale: -1)),
      ],
    ),
    EventTemplate(
      id: 'pressBench',
      kind: EventKind.press,
      when: (c) => c.benched,
      cooldownWeeks: 6,
      ignore: const EventEffect(media: -1),
      choices: const [
        EventChoice(EventEffect(coach: 3, morale: -1)),
        EventChoice(EventEffect(coach: -3, media: 3, morale: 2)),
        EventChoice(EventEffect(teammates: 2, coach: 1)),
      ],
    ),

    // --- Kişisel gelişmeler ---
    EventTemplate(
      id: 'familyDinner',
      kind: EventKind.personal,
      when: (c) => !c.state.status.isInjured,
      weight: 1.2,
      choices: const [
        EventChoice(
          EventEffect(family: 6, morale: 4, condition: -3, moneyWeeks: -0.5),
        ),
        EventChoice(EventEffect(family: -4, coach: 2)),
        EventChoice(EventEffect(family: 2, morale: 1)),
      ],
    ),
    EventTemplate(
      id: 'partyInvite',
      kind: EventKind.personal,
      when: (c) => !c.state.status.isInjured,
      choices: const [
        EventChoice(
          EventEffect(teammates: 5, morale: 5, condition: -12),
          alt: EventEffect(
            teammates: 3,
            morale: 3,
            condition: -14,
            media: -5,
            coach: -4,
          ),
          altChance: 0.3,
        ),
        EventChoice(EventEffect(teammates: -2, coach: 1, condition: 3)),
        EventChoice(EventEffect(teammates: 2, morale: 1, condition: -3)),
      ],
    ),
    EventTemplate(
      id: 'fanMeet',
      kind: EventKind.personal,
      when: (c) => c.state.contract != null,
      weight: 1.1,
      choices: const [
        EventChoice(EventEffect(fans: 6, morale: 3, condition: -3)),
        EventChoice(EventEffect(fans: -3)),
        EventChoice(EventEffect(fans: 2, media: 1)),
      ],
    ),
    EventTemplate(
      id: 'coachTalk',
      kind: EventKind.career,
      when: (c) =>
          c.state.contract != null && c.state.relations[Relation.coach] < 55,
      weight: 1.5,
      choices: const [
        EventChoice(EventEffect(coach: 5, morale: -1)),
        EventChoice(EventEffect(coach: -6, media: 1, morale: 2)),
        EventChoice(
          EventEffect(coach: 7, morale: 3),
          alt: EventEffect(coach: -3, morale: -2),
          altChance: 0.5,
        ),
      ],
    ),
    EventTemplate(
      id: 'teammateRift',
      kind: EventKind.career,
      when: (c) =>
          c.state.contract != null &&
          c.state.relations[Relation.teammates] < 45,
      weight: 1.5,
      choices: const [
        EventChoice(EventEffect(teammates: 6, coach: 1, condition: -2)),
        EventChoice(EventEffect(teammates: -5, coach: 1)),
        EventChoice(EventEffect(teammates: -2)),
      ],
    ),
    EventTemplate(
      id: 'sponsorOffer',
      kind: EventKind.money,
      when: (c) =>
          c.state.contract != null &&
          c.state.relations[Relation.fans] >= 45 &&
          c.state.relations[Relation.media] >= 40,
      weight: 1.3,
      cooldownWeeks: 20,
      choices: const [
        EventChoice(EventEffect(moneyWeeks: 6, fans: -2)),
        EventChoice(EventEffect(moneyWeeks: 2, fans: 2, media: 1)),
        EventChoice(EventEffect(media: 1, coach: 1)),
      ],
    ),
    EventTemplate(
      id: 'charity',
      kind: EventKind.money,
      when: (c) => c.state.contract != null,
      cooldownWeeks: 20,
      choices: const [
        EventChoice(
          EventEffect(moneyWeeks: -2, fans: 6, media: 3, family: 2, morale: 3),
        ),
        EventChoice(EventEffect(fans: 2, condition: -2)),
        EventChoice(EventEffect(fans: -1)),
      ],
    ),
    EventTemplate(
      id: 'transferRumor',
      kind: EventKind.career,
      when: (c) => c.state.contract != null && c.state.offers.isNotEmpty,
      cooldownWeeks: 8,
      choices: const [
        EventChoice(EventEffect(coach: 3, media: -1)),
        EventChoice(EventEffect(media: 2)),
        EventChoice(EventEffect(media: 4, coach: -4, fans: -2)),
      ],
    ),
    EventTemplate(
      id: 'socialPost',
      kind: EventKind.personal,
      when: (c) => c.state.relations[Relation.media] >= 35,
      cooldownWeeks: 10,
      ignore: const EventEffect(media: -1),
      choices: const [
        EventChoice(EventEffect(media: -1)),
        EventChoice(
          EventEffect(fans: 3, media: 1),
          alt: EventEffect(media: -6, fans: -4),
          altChance: 0.4,
        ),
        EventChoice(EventEffect(media: 2, fans: 1, morale: -1)),
      ],
    ),
    EventTemplate(
      id: 'injuryRehab',
      kind: EventKind.personal,
      when: (c) =>
          c.state.status.isInjured && c.state.status.injury!.weeksLeft >= 3,
      weight: 3,
      cooldownWeeks: 6,
      choices: const [
        EventChoice(EventEffect(healWeeks: 1, morale: 2, coach: 2)),
        EventChoice(
          EventEffect(healWeeks: 2, morale: 3),
          alt: EventEffect(relapseRisk: 0.25, morale: -3),
          altChance: 0.4,
        ),
        EventChoice(EventEffect(family: 3, morale: 3)),
      ],
    ),
    EventTemplate(
      id: 'youthAcademy',
      kind: EventKind.personal,
      when: (c) => c.state.contract != null && c.state.player.age >= 19,
      cooldownWeeks: 24,
      choices: const [
        EventChoice(EventEffect(fans: 3, coach: 2, condition: -3, morale: 2)),
        EventChoice(EventEffect(fans: -1)),
      ],
    ),
    EventTemplate(
      id: 'debtHelp',
      kind: EventKind.money,
      when: (c) => c.state.finance.inDebt,
      weight: 4,
      cooldownWeeks: 8,
      choices: const [
        EventChoice(EventEffect(money: 2500, family: -4)),
        EventChoice(EventEffect(morale: -2, family: 2)),
      ],
    ),
  ];

  static EventTemplate byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => throw ArgumentError(id));
}
