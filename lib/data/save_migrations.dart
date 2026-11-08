import 'save_repository.dart';

/// Şema [from] sürümünden bir üst sürüme dönüştüren adım.
typedef MigrationStep = Map<String, dynamic> Function(Map<String, dynamic> e);

/// Eski kayıtları güncel şemaya taşır.
///
/// Şema değiştiğinde: [currentSchemaVersion]'ı artır ve `steps`'e
/// `eskiSürüm: dönüştürücü` ekle.
const int currentSchemaVersion = 1;

const Map<int, MigrationStep> _defaultSteps = {};

class SaveMigrator {
  const SaveMigrator({
    this.currentVersion = currentSchemaVersion,
    this.steps = _defaultSteps,
  });

  final int currentVersion;
  final Map<int, MigrationStep> steps;

  Map<String, dynamic> migrate(Map<String, dynamic> envelope) {
    var version = envelope['schemaVersion'];
    if (version is! int || version < 1) {
      throw const SaveException('Geçersiz kayıt sürümü.');
    }
    if (version > currentVersion) {
      throw SaveException(
        'Kayıt daha yeni bir sürümden ($version > $currentVersion).',
      );
    }
    var current = envelope;
    while (version! < currentVersion) {
      final step = steps[version];
      if (step == null) {
        throw SaveException('$version sürümü için göç adımı yok.');
      }
      current = step(current);
      version += 1;
      current = {...current, 'schemaVersion': version};
    }
    return current;
  }
}
