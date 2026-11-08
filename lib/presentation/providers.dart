import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/save_repository.dart';
import '../data/settings_repository.dart';
import '../domain/career/career_state.dart';
import '../domain/career/difficulty.dart';

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
