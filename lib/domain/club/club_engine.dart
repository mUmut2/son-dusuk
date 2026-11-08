import '../../core/game_random.dart';
import '../career/career_state.dart';
import '../career/week_report.dart';
import '../league/club_world.dart';
import 'squad.dart';
import 'transfer_market.dart';
import 'transfer_offer.dart';

class ClubUpdate {
  const ClubUpdate(this.state, this.events);

  final CareerState state;
  final List<WeekEvent> events;
}

/// Hafta ilerledikten sonra kulüp tarafını günceller: sezon geçişinde
/// sözleşme/rol, süresi dolan teklifler, yeni teklifler ve yenilemeler.
abstract final class ClubEngine {
  /// [next]: hafta sayacı ilerlemiş durum; [newSeason]: bu geçişte sezon değişti mi.
  static ClubUpdate process(
    CareerState next, {
    required bool newSeason,
    required GameRandom random,
  }) {
    final world = ClubWorld(next.worldSeed);
    final events = <WeekEvent>[];
    var s = next;

    if (newSeason) {
      s = s.copyWith(results: const []);
      final c = s.contract;
      if (c != null) {
        if (c.endSeason < s.season) {
          s = s.copyWith(
            clearContract: true,
            offers: [
              for (final o in s.offers)
                if (o.kind != OfferKind.renewal) o,
            ],
          );
          events.add(
            WeekEvent(WeekEventKind.contractExpired, clubId: c.clubId),
          );
        } else {
          final role = Squad.roleOrProspect(s.player, world.team(c.clubId));
          s = s.copyWith(contract: c.copyWith(role: role));
        }
      }
    }

    s = s.copyWith(
      offers: [
        for (final o in s.offers)
          if (o.expiresAt >= s.absoluteWeek) o,
      ],
    );

    final renewal = TransferMarket.renewalOffer(s, world, random);
    if (renewal != null) {
      s = s.copyWith(offers: [...s.offers, renewal]);
      events.add(
        WeekEvent(WeekEventKind.renewalOffered, clubId: renewal.clubId),
      );
    }

    final fresh = TransferMarket.newOffers(s, world, random);
    if (fresh.isNotEmpty) {
      s = s.copyWith(offers: [...s.offers, ...fresh]);
      for (final o in fresh) {
        events.add(WeekEvent(WeekEventKind.offerReceived, clubId: o.clubId));
      }
    }
    return ClubUpdate(s, events);
  }
}
