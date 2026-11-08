// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Son Düdük';

  @override
  String get tagline => '16 yaşında başla, dünya yıldızı ol.';

  @override
  String get menuTitle => 'Kariyer Seç';

  @override
  String slotTitle(int number) {
    return 'Kayıt $number';
  }

  @override
  String get slotEmpty => 'Boş — yeni kariyer başlat';

  @override
  String get slotCorrupt => 'Bozuk kayıt';

  @override
  String slotSummary(int age, String position, int overall) {
    return '$age yaş · $position · Genel $overall';
  }

  @override
  String get deleteSave => 'Kaydı sil';

  @override
  String deleteSaveConfirm(String name) {
    return '$name kariyeri kalıcı olarak silinecek. Bu işlem geri alınamaz.';
  }

  @override
  String get deleteCorruptConfirm =>
      'Bozuk kayıt silinecek. Bu işlem geri alınamaz.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get delete => 'Sil';

  @override
  String get settings => 'Ayarlar';

  @override
  String get simulatorTitle => 'Lig Simülatörü';

  @override
  String get simulatorSeed => 'Seed (boş = rastgele)';

  @override
  String get simulatorSeedInvalid => 'Seed bir tam sayı olmalı.';

  @override
  String get simulateSeason => 'Sezonu Simüle Et';

  @override
  String get simulatorHint =>
      'Seçilen ligin 34 haftalık sezonunu saf Dart motoruyla oynatır.';

  @override
  String get leagueTier1 => 'Ulusal Lig';

  @override
  String get leagueTier2 => 'Birinci Lig';

  @override
  String get leagueTier3 => 'İkinci Lig';

  @override
  String get leagueTier4 => 'Üçüncü Lig';

  @override
  String get leagueTier5 => 'Amatör Lig';

  @override
  String get colPlayed => 'O';

  @override
  String get colWon => 'G';

  @override
  String get colDrawn => 'B';

  @override
  String get colLost => 'M';

  @override
  String get colGoalsFor => 'A';

  @override
  String get colGoalsAgainst => 'Y';

  @override
  String get colGoalDiff => 'Av';

  @override
  String get colPoints => 'P';

  @override
  String get colTeam => 'Takım';

  @override
  String simulatorStats(
    int matches,
    String goals,
    String homeWin,
    String draw,
  ) {
    return '$matches maç · maç başı $goals gol · ev sahibi galibiyeti %$homeWin · beraberlik %$draw';
  }

  @override
  String get createTitle => 'Yeni Oyuncu';

  @override
  String get nameLabel => 'Oyuncu adı';

  @override
  String get nameRequired => 'Bir isim gir.';

  @override
  String get nameTooLong => 'En fazla 24 karakter.';

  @override
  String get birthplaceLabel => 'Doğum yeri';

  @override
  String get positionLabel => 'Mevki';

  @override
  String get footLabel => 'Güçlü ayak';

  @override
  String get appearanceLabel => 'Görünüm';

  @override
  String get skinLabel => 'Ten';

  @override
  String get hairLabel => 'Saç';

  @override
  String get kitLabel => 'Forma';

  @override
  String get startCareer => 'Kariyere Başla';

  @override
  String get position_forward => 'Forvet';

  @override
  String get position_winger => 'Kanat';

  @override
  String get position_attackingMid => 'Ofansif Orta Saha';

  @override
  String get position_centralMid => 'Merkez Orta Saha';

  @override
  String get position_defender => 'Defans';

  @override
  String get foot_left => 'Sol';

  @override
  String get foot_right => 'Sağ';

  @override
  String get foot_both => 'Her İkisi';

  @override
  String get attr_shooting => 'Şut';

  @override
  String get attr_finesse => 'Plase';

  @override
  String get attr_passing => 'Pas';

  @override
  String get attr_vision => 'Vizyon';

  @override
  String get attr_dribbling => 'Dribling';

  @override
  String get attr_pace => 'Hız';

  @override
  String get attr_agility => 'Çabukluk';

  @override
  String get attr_strength => 'Güç';

  @override
  String get attr_stamina => 'Dayanıklılık';

  @override
  String get attr_defending => 'Defans';

  @override
  String get attr_ballControl => 'Top Kontrolü';

  @override
  String get attr_heading => 'Kafa Vuruşu';

  @override
  String get attr_setPieces => 'Duran Top';

  @override
  String get attr_composure => 'Sakinlik';

  @override
  String get attr_charisma => 'Karizma';

  @override
  String get kind_physical => 'Fiziksel';

  @override
  String get kind_technical => 'Teknik';

  @override
  String get kind_mental => 'Zihinsel';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navTraining => 'Antrenman';

  @override
  String get navClub => 'Kulüp';

  @override
  String get navSocial => 'Sosyal';

  @override
  String get navProfile => 'Profil';

  @override
  String get comingSoon => 'Bu bölüm yakında geliyor.';

  @override
  String get overallLabel => 'Genel Güç';

  @override
  String ageYears(int age) {
    return '$age yaş';
  }

  @override
  String seasonWeek(int season, int week) {
    return 'Sezon $season · Hafta $week';
  }

  @override
  String get nextMatch => 'Sıradaki maç';

  @override
  String get nextMatchPlaceholder => 'Fikstür henüz hazır değil.';

  @override
  String get attributesTitle => 'Nitelikler';

  @override
  String get backToMenu => 'Ana menüye dön';

  @override
  String birthplaceValue(String city) {
    return 'Doğum yeri: $city';
  }

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get soundLabel => 'Ses';

  @override
  String get vibrationLabel => 'Titreşim';

  @override
  String get difficultyLabel => 'Zorluk';

  @override
  String get difficultyHint =>
      'Zorluk yalnızca mini oyun toleransını ve rakip gücünü etkiler.';

  @override
  String get difficulty_easy => 'Kolay';

  @override
  String get difficulty_normal => 'Normal';

  @override
  String get difficulty_hard => 'Zor';

  @override
  String get languageLabel => 'Dil';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get deleteAllSaves => 'Tüm kayıtları sil';

  @override
  String get deleteAllConfirm =>
      'Üç slottaki tüm kariyerler kalıcı olarak silinecek. Bu işlem geri alınamaz.';

  @override
  String get allSavesDeleted => 'Tüm kayıtlar silindi.';
}
