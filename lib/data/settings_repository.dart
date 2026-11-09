import 'package:shared_preferences/shared_preferences.dart';

import '../domain/career/difficulty.dart';

/// Kullanıcı ayarları. Dil şimdilik yalnızca Türkçe.
class GameSettings {
  const GameSettings({
    this.soundOn = true,
    this.vibrationOn = true,
    this.difficulty = Difficulty.easy,
  });

  final bool soundOn;
  final bool vibrationOn;
  final Difficulty difficulty;

  GameSettings copyWith({
    bool? soundOn,
    bool? vibrationOn,
    Difficulty? difficulty,
  }) => GameSettings(
    soundOn: soundOn ?? this.soundOn,
    vibrationOn: vibrationOn ?? this.vibrationOn,
    difficulty: difficulty ?? this.difficulty,
  );
}

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  GameSettings load() {
    final name = _prefs.getString('settings_difficulty');
    return GameSettings(
      soundOn: _prefs.getBool('settings_sound') ?? true,
      vibrationOn: _prefs.getBool('settings_vibration') ?? true,
      difficulty: Difficulty.values.asNameMap()[name] ?? Difficulty.easy,
    );
  }

  Future<void> save(GameSettings settings) async {
    await _prefs.setBool('settings_sound', settings.soundOn);
    await _prefs.setBool('settings_vibration', settings.vibrationOn);
    await _prefs.setString('settings_difficulty', settings.difficulty.name);
  }
}
