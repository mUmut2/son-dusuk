import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/career/career_state.dart';
import 'save_migrations.dart';

class SaveException implements Exception {
  const SaveException(this.message);
  final String message;

  @override
  String toString() => 'SaveException: $message';
}

enum SlotStatus { empty, ok, corrupt }

/// Bir kayıt slotunun menüde gösterilecek özeti.
class SlotInfo {
  const SlotInfo({
    required this.slot,
    required this.status,
    this.career,
    this.savedAt,
  });

  final int slot;
  final SlotStatus status;
  final CareerState? career;
  final DateTime? savedAt;
}

/// 3 slotlu kayıt deposu: `shared_preferences` içinde JSON.
/// Zarf biçimi: `{schemaVersion, savedAt, career}`.
class SaveRepository {
  SaveRepository(this._prefs, {SaveMigrator? migrator})
    : _migrator = migrator ?? const SaveMigrator();

  static const int slotCount = 3;

  final SharedPreferences _prefs;
  final SaveMigrator _migrator;

  String _key(int slot) {
    if (slot < 0 || slot >= slotCount) {
      throw RangeError.range(slot, 0, slotCount - 1, 'slot');
    }
    return 'save_slot_$slot';
  }

  Future<void> save(int slot, CareerState career, {DateTime? now}) async {
    final envelope = {
      'schemaVersion': _migrator.currentVersion,
      'savedAt': (now ?? DateTime.now()).toIso8601String(),
      'career': career.toJson(),
    };
    await _prefs.setString(_key(slot), jsonEncode(envelope));
  }

  /// Boş slot için null; bozuk kayıt için [SaveException] fırlatır.
  CareerState? load(int slot) => _read(slot)?.career;

  Future<void> delete(int slot) => _prefs.remove(_key(slot));

  Future<void> deleteAll() async {
    for (var i = 0; i < slotCount; i++) {
      await delete(i);
    }
  }

  List<SlotInfo> slots() => [for (var i = 0; i < slotCount; i++) _info(i)];

  SlotInfo _info(int slot) {
    try {
      final read = _read(slot);
      if (read == null) {
        return SlotInfo(slot: slot, status: SlotStatus.empty);
      }
      return SlotInfo(
        slot: slot,
        status: SlotStatus.ok,
        career: read.career,
        savedAt: read.savedAt,
      );
    } on SaveException {
      return SlotInfo(slot: slot, status: SlotStatus.corrupt);
    }
  }

  ({CareerState career, DateTime? savedAt})? _read(int slot) {
    final raw = _prefs.getString(_key(slot));
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final migrated = _migrator.migrate(decoded);
      return (
        career: CareerState.fromJson(
          migrated['career'] as Map<String, dynamic>,
        ),
        savedAt: DateTime.tryParse(migrated['savedAt'] as String? ?? ''),
      );
    } on SaveException {
      rethrow;
    } catch (e) {
      throw SaveException('Bozuk kayıt (slot $slot): $e');
    }
  }
}
