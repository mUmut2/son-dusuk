import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/save_repository.dart';
import '../data/settings_repository.dart';
import '../domain/career/career_state.dart';
import '../core/game_random.dart';
import '../domain/career/difficulty.dart';
import '../domain/career/retirement.dart';
import '../domain/career/week_engine.dart';
import '../domain/career/weekly_plan.dart';
import '../domain/club/equipment.dart';
import '../domain/club/finance.dart';
import '../domain/club/transfer_market.dart';
import '../domain/club/transfer_offer.dart';
import '../domain/league/club_world.dart';
import '../domain/social/event_models.dart';
import '../domain/social/feed_models.dart';
import '../domain/social/social_engine.dart';
import '../domain/spending/spending_engine.dart';
import '../domain/spending/spending_models.dart';
import '../game/sound_service.dart';

/// `main()` içinde gerçek örnekle, testlerde sahte örnekle override edilir.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider override edilmeli'),
);

final saveRepositoryProvider = Provider<SaveRepository>(
  (ref) => SaveRepository(ref.watch(sharedPreferencesProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

/// Menüdeki 3 slotun özeti.
class SaveSlotsNotifier extends Notifier<List<SlotInfo>> {
  @override
  List<SlotInfo> build() => ref.watch(saveRepositoryProvider).slots();

  void refresh() => state = ref.read(saveRepositoryProvider).slots();

  Future<void> delete(int slot) async {
    await ref.read(saveRepositoryProvider).delete(slot);
    refresh();
  }

  Future<void> deleteAll() async {
    await ref.read(saveRepositoryProvider).deleteAll();
    refresh();
  }
}

final saveSlotsProvider = NotifierProvider<SaveSlotsNotifier, List<SlotInfo>>(
  SaveSlotsNotifier.new,
);

/// Şu an oynanan kariyer ve hangi slotta olduğu.
class ActiveCareer {
  const ActiveCareer({required this.slot, required this.state});
  final int slot;
  final CareerState state;
}

class ActiveCareerNotifier extends Notifier<ActiveCareer?> {
  @override
  ActiveCareer? build() => null;

  /// Yeni kariyeri kaydeder ve aktif yapar.
  Future<void> start(int slot, CareerState career) async {
    await ref.read(saveRepositoryProvider).save(slot, career);
    state = ActiveCareer(slot: slot, state: career);
    ref.read(saveSlotsProvider.notifier).refresh();
  }

  /// Kayıtlı kariyeri açar (yazma yapmaz).
  void open(int slot, CareerState career) =>
      state = ActiveCareer(slot: slot, state: career);

  /// Durumu günceller ve otomatik kaydeder.
  Future<void> update(CareerState career) async {
    final current = state;
    if (current == null) return;
    await ref.read(saveRepositoryProvider).save(current.slot, career);
    state = ActiveCareer(slot: current.slot, state: career);
    ref.read(saveSlotsProvider.notifier).refresh();
  }

  /// Haftayı oynatır: plan + (varsa) maç sonucu -> yeni durum, otomatik kayıt.
  Future<void> playWeek(WeekMatch? match) async {
    final current = state;
    if (current == null) return;
    final result = WeekEngine.advance(
      current.state,
      ref.read(weeklyPlanProvider),
      match,
      GameRandom(),
    );
    ref.read(lastWeekProvider.notifier).set(result);
    await update(result.state);
  }

  /// Penaltıda seçilen bölgeyi kaydeder (sonraki penaltılarda kaleci okur).
  Future<void> recordPenalty(int zone) async {
    final current = state;
    if (current == null) return;
    await update(
      current.state.copyWith(stats: current.state.stats.addPenalty(zone)),
    );
  }

  /// Riskli erken dönüş (sakatlığı bitirir, tekrar sakatlanma riski yaratır).
  Future<void> returnEarly() async {
    final current = state;
    if (current == null) return;
    await update(WeekEngine.returnEarly(current.state));
  }

  /// Teklifi [wage] maaşıyla imzalar.
  Future<void> acceptOffer(TransferOffer offer, int wage) async {
    final current = state;
    if (current == null) return;
    await update(TransferMarket.sign(current.state, offer, wage));
  }

  Future<void> declineOffer(TransferOffer offer) async {
    final current = state;
    if (current == null) return;
    await update(ClubActions.declineOffer(current.state, offer));
  }

  /// Pazarlık hakkını harcar (karşı teklif sonrası kulüp aynı teklifte kalır).
  Future<void> markNegotiated(TransferOffer offer) async {
    final current = state;
    if (current == null) return;
    await update(ClubActions.markNegotiated(current.state, offer));
  }

  Future<void> hireAgent(int level) async {
    final current = state;
    if (current == null) return;
    await update(ClubActions.hireAgent(current.state, level));
  }

  Future<void> fireAgent() async {
    final current = state;
    if (current == null) return;
    await update(ClubActions.fireAgent(current.state));
  }

  Future<void> buyEquipment(EquipmentSlot slot) async {
    final current = state;
    if (current == null) return;
    await update(ClubActions.buyEquipment(current.state, slot));
  }

  Future<void> setLifestyle(Lifestyle l) async {
    final current = state;
    if (current == null) return;
    await update(ClubActions.setLifestyle(current.state, l));
  }

  /// Bekleyen olaya [choice]. seçenekle cevap verir; sonucu döner.
  Future<ResolveResult?> resolveEvent(PendingEvent event, int choice) async {
    final current = state;
    if (current == null) return null;
    final result = SocialEngine.resolve(
      current.state,
      event,
      choice,
      GameRandom(),
    );
    await update(result.state);
    return result;
  }

  /// Mülk satın alır; alamazsa false döner.
  Future<bool> buyProperty(Property p) async {
    final current = state;
    if (current == null) return false;
    final next = SpendingEngine.buyProperty(current.state, p, GameRandom());
    if (next == null) return false;
    await update(next);
    return true;
  }

  Future<bool> donate(Donation d) async {
    final current = state;
    if (current == null) return false;
    final next = SpendingEngine.donate(current.state, d, GameRandom());
    if (next == null) return false;
    await update(next);
    return true;
  }

  /// Kuponun [matchIndex]. maçına bahis yapar; geçersizse false döner.
  Future<bool> placeBet(int matchIndex, BetPick pick, int stake) async {
    final current = state;
    if (current == null) return false;
    final next = SpendingEngine.placeBet(
      current.state,
      ClubWorld(current.state.worldSeed),
      matchIndex,
      pick,
      stake,
    );
    if (next == null) return false;
    await update(next);
    return true;
  }

  /// Kendi hesabından paylaşım yapar; yapamazsa (haftada bir) null döner.
  Future<OwnPostResult?> postToFeed(FeedKind kind) async {
    final current = state;
    if (current == null) return null;
    final result = SocialEngine.postToFeed(current.state, kind, GameRandom());
    if (result == null) return null;
    await update(result.state);
    return result;
  }

  /// Futbolu bırakır; kariyer özeti açılır.
  Future<void> retire() async {
    final current = state;
    if (current == null) return;
    await update(Retirement.retire(current.state));
  }

  void close() => state = null;
}

final activeCareerProvider =
    NotifierProvider<ActiveCareerNotifier, ActiveCareer?>(
      ActiveCareerNotifier.new,
    );

class SettingsNotifier extends Notifier<GameSettings> {
  @override
  GameSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> _set(GameSettings next) async {
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> setSound(bool on) => _set(state.copyWith(soundOn: on));

  Future<void> setVibration(bool on) => _set(state.copyWith(vibrationOn: on));

  Future<void> setDifficulty(Difficulty d) =>
      _set(state.copyWith(difficulty: d));
}

final settingsProvider = NotifierProvider<SettingsNotifier, GameSettings>(
  SettingsNotifier.new,
);

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(service.dispose);
  return service;
});

extension SoundRef on WidgetRef {
  /// Ayarlardaki "Ses" açıksa efekti çalar.
  void playSfx(Sfx sfx) {
    if (!read(settingsProvider).soundOn) return;
    read(soundServiceProvider).play(sfx);
  }
}

/// Bu hafta için seçilen plan (bellekte; hafta bitince sıfırlanmaz,
/// oyuncu genelde aynı rutini sürdürür).
class WeeklyPlanNotifier extends Notifier<WeeklyPlan> {
  @override
  WeeklyPlan build() => const WeeklyPlan();

  void setFocus(TrainingFocus focus) => state = state.copyWith(focus: focus);

  void setIntensity(TrainingIntensity i) =>
      state = state.copyWith(intensity: i);

  void setSocial(SocialActivity s) => state = state.copyWith(social: s);
}

final weeklyPlanProvider = NotifierProvider<WeeklyPlanNotifier, WeeklyPlan>(
  WeeklyPlanNotifier.new,
);

/// Son oynanan haftanın sonucu (özet ekranı için).
class LastWeekNotifier extends Notifier<WeekResult?> {
  @override
  WeekResult? build() => null;

  void set(WeekResult? value) => state = value;
}

final lastWeekProvider = NotifierProvider<LastWeekNotifier, WeekResult?>(
  LastWeekNotifier.new,
);

/// Aktif kariyerin lig dünyası (seed aynı kaldıkça yeniden kurulmaz).
final clubWorldProvider = Provider<ClubWorld?>((ref) {
  final seed = ref.watch(
    activeCareerProvider.select((c) => c?.state.worldSeed),
  );
  return seed == null ? null : ClubWorld(seed);
});
