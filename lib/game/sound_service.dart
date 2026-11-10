import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Oyundaki kısa ses efektleri. Dosyalar `assets/sounds/<ad>.wav`; hepsi
/// `tool/make_sounds.dart` ile koddan üretilir (telifli ses yok).
enum Sfx { good, bad, goal, whistle, buy }

/// Ses efektlerini çalar. Ses hiçbir zaman oyunu bozmamalıdır: cihazda ses
/// yoksa ya da çalma hata verirse sessizce yutulur.
class SoundService {
  final Map<Sfx, AudioPlayer> _players = {};

  Future<void> play(Sfx sfx) async {
    try {
      final player = _players.putIfAbsent(sfx, AudioPlayer.new);
      await player.stop();
      await player.play(AssetSource('sounds/${sfx.name}.wav'), volume: 0.8);
    } on Object catch (e) {
      debugPrint('Ses çalınamadı (${sfx.name}): $e');
    }
  }

  Future<void> dispose() async {
    for (final p in _players.values) {
      try {
        await p.dispose();
      } on Object catch (_) {}
    }
    _players.clear();
  }
}
