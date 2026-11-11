import '../social/event_models.dart';
import 'spending_models.dart';

/// Harcama, bahis ve ceza dengesi (tek yer). Bahis kurgusaldır ve beklenen
/// değeri negatiftir; fazlası ceza getirir.
abstract final class SpendingBalance {
  // --- Mülkler ---
  static const Map<Property, int> propertyPrice = {
    Property.watch: 2500,
    Property.car: 15000,
    Property.flat: 60000,
    Property.villa: 400000,
    Property.yacht: 1500000,
  };

  /// Satın alınca bir kerelik etki.
  static const Map<Property, EventEffect> propertyEffect = {
    Property.watch: EventEffect(morale: 2, media: 1),
    Property.car: EventEffect(morale: 3, fans: 1, media: 1),
    Property.flat: EventEffect(morale: 2, family: 4),
    Property.villa: EventEffect(morale: 3, family: 5, media: 2, fans: 1),
    Property.yacht: EventEffect(morale: 5, media: 4, fans: 2, teammates: -2),
  };

  /// Her mülkün haftalık moral taban katkısı ve toplam üst sınırı.
  static const Map<Property, double> propertyMorale = {
    Property.watch: 0.1,
    Property.car: 0.2,
    Property.flat: 0.3,
    Property.villa: 0.4,
    Property.yacht: 0.5,
  };
  static const double propertyMoraleCap = 1.2;

  // --- Bağış / hediye ---
  /// Maliyet: haftalık maaşın katı, en az [donationMin].
  static const Map<Donation, double> donationWeeks = {
    Donation.charity: 2,
    Donation.familyGift: 1,
  };
  static const Map<Donation, int> donationMin = {
    Donation.charity: 200,
    Donation.familyGift: 150,
  };
  static const Map<Donation, EventEffect> donationEffect = {
    Donation.charity: EventEffect(fans: 4, media: 3, family: 1, morale: 1),
    Donation.familyGift: EventEffect(family: 6, morale: 2),
  };

  /// İki bağış/hediye arası en az hafta.
  static const int donationGapWeeks = 3;

  // --- Kupon ve oranlar ---
  /// Haftalık kuponda kaç maç olur.
  static const int couponSize = 3;

  /// Bahis bürosu payı: oranlar gerçek olasılıktan bu kadar düşük (beklenen
  /// değer negatif).
  static const double houseMargin = 0.12;
  static const double minOdds = 1.1;
  static const double maxOdds = 15;

  /// Bahis tutarı seçenekleri: bakiyenin oranı, en az [minStake].
  static const List<double> stakeShares = [0.02, 0.05, 0.1];
  static const int minStake = 20;

  // --- Alışkanlık ---
  /// Her bahis: sabit + tutarın bakiyeye oranı x [habitPerStakeShare].
  static const double habitPerBet = 4;
  static const double habitPerStakeShare = 40;

  /// Önceki bahsini kaybedip yeniden oynayana ek ("kaybı çıkarma").
  static const double habitChase = 2;

  /// Her hafta kendiliğinden azalma (bahis oynansa da oynanmasa da).
  static const double habitDecay = 5;
  static const double habitMax = 100;

  // --- Ceza basamakları ---
  static const double warnAt = 40;
  static const double fineAt = 65;
  static const double banAt = 85;

  /// Alışkanlık bunun altına inince basamak sıfırlanır.
  static const double relaxBelow = 25;

  /// Para cezası: haftalık maaşın katı, en az [minFine]; kadro dışı için çarpan.
  static const double fineWeeks = 3;
  static const int minFine = 300;
  static const double banFineMultiplier = 2;
  static const int banWeeks = 3;

  /// Yardım programı sonrası alışkanlık.
  static const double habitAfterHelp = 35;

  static const EventEffect warnEffect = EventEffect(coach: -3, media: -2);
  static const EventEffect fineEffect = EventEffect(
    coach: -6,
    media: -5,
    fans: -3,
    morale: -3,
  );
  static const EventEffect banEffect = EventEffect(
    coach: -10,
    media: -8,
    fans: -6,
    teammates: -3,
    morale: -8,
  );

  /// Gösterilen son sonuç sayısı.
  static const int settledCap = 8;
}
