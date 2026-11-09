import '../domain/career/career_factory.dart';
import '../domain/career/career_state.dart';
import '../domain/career/player_status.dart';
import 'save_repository.dart';

/// Şema [from] sürümünden bir üst sürüme dönüştüren adım.
typedef MigrationStep = Map<String, dynamic> Function(Map<String, dynamic> e);

/// Eski kayıtları güncel şemaya taşır.
///
/// Şema değiştiğinde: [currentSchemaVersion]'ı artır ve `steps`'e
/// `eskiSürüm: dönüştürücü` ekle.
const int currentSchemaVersion = 7;

const Map<int, MigrationStep> _defaultSteps = {
  1: _v1ToV2,
  2: _v2ToV3,
  3: _v3ToV4,
  4: _v4ToV5,
  5: _v5ToV6,
  6: _v6ToV7,
};

/// v1 -> v2 (Faz 4): kondisyon/form/moral/sakatlık ve istatistik alanları.
Map<String, dynamic> _v1ToV2(Map<String, dynamic> envelope) {
  final career = Map<String, dynamic>.from(envelope['career'] as Map);
  career.putIfAbsent('status', () => const PlayerStatus().toJson());
  career.putIfAbsent('stats', () => const CareerStats().toJson());
  return {...envelope, 'career': career};
}

/// v2 -> v3: form artık -10..+10 değil, son 5 maçın reyting ortalaması (0-10).
Map<String, dynamic> _v2ToV3(Map<String, dynamic> envelope) {
  final career = Map<String, dynamic>.from(envelope['career'] as Map);
  final status = Map<String, dynamic>.from(
    (career['status'] as Map?) ?? const PlayerStatus().toJson(),
  );
  final ratings = [
    for (final r in (status['recentRatings'] as List<dynamic>? ?? const []))
      (r as num).toDouble(),
  ];
  status['form'] = ratings.isEmpty
      ? PlayerStatus.neutralForm
      : (ratings.reduce((a, b) => a + b) / ratings.length).clamp(0.0, 10.0);
  career['status'] = status;
  return {...envelope, 'career': career};
}

/// v3 -> v4 (Faz 6): kulüp, sözleşme, finans. Eski kariyere amatör bir kulüp verilir.
Map<String, dynamic> _v3ToV4(Map<String, dynamic> envelope) {
  final career = Map<String, dynamic>.from(envelope['career'] as Map);
  final state = CareerState.fromJson(career);
  final seed =
      state.player.name.codeUnits.fold<int>(
        7,
        (a, c) => (a * 31 + c) % 1000003,
      ) +
      1;
  return {
    ...envelope,
    'career': CareerFactory.assignClub(state, seed).toJson(),
  };
}

/// v4 -> v5 (Faz 7): ilişkiler, olaylar, haberler. Eksik alanlar varsayılanla
/// yüklenir; kayıt biçimi değişmez.
Map<String, dynamic> _v4ToV5(Map<String, dynamic> envelope) => envelope;

/// v5 -> v6 (Faz 8): sezon geçmişi, milli takım, başarımlar, emeklilik. Eksik
/// alanlar varsayılanla yüklenir; kayıt biçimi değişmez.
Map<String, dynamic> _v5ToV6(Map<String, dynamic> envelope) => envelope;

/// v6 -> v7 (Faz 9): ekipman. Eksik alan boş ekipmanla yüklenir.
Map<String, dynamic> _v6ToV7(Map<String, dynamic> envelope) => envelope;

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
