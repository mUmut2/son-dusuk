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

  @override
  String get matchTitle => 'Hazırlık Maçı';

  @override
  String get matchPlay => 'Maçı Oyna';

  @override
  String get matchStart => 'Maça Başla';

  @override
  String get matchQuickSim => 'Hızlı Simüle Et';

  @override
  String get matchQuickSimRest => 'Kalanı Hızlı Simüle Et';

  @override
  String matchYourTeam(String team) {
    return 'Takımın: $team';
  }

  @override
  String matchVersus(String home, String away) {
    return '$home - $away';
  }

  @override
  String matchMinute(int minute) {
    return '$minute. dakika';
  }

  @override
  String get momentTitle_shot => 'Şut';

  @override
  String get momentIntro_shot =>
      'Top ayağına geldi, kaleci karşında. Zamanı tut ve vur!';

  @override
  String get momentTitle_oneOnOne => 'Bire Bir';

  @override
  String get momentIntro_oneOnOne => 'Kalecinin karşısında tek başınasın!';

  @override
  String get momentTitle_header => 'Kafa Vuruşu';

  @override
  String get momentIntro_header => 'Ortayı yükselen sen oldun, top havada.';

  @override
  String get momentTitle_freeKick => 'Serbest Vuruş';

  @override
  String get momentIntro_freeKick =>
      'Ceza sahası önünde serbest vuruş kazanıldı.';

  @override
  String get momentTitle_penalty => 'Penaltı';

  @override
  String get momentIntro_penalty => 'Penaltı! Tüm stadyum sessizleşti.';

  @override
  String get momentTitle_keyPass => 'Kilit Pas';

  @override
  String get momentIntro_keyPass => 'Savunmanın arkasına bir pas fırsatı var.';

  @override
  String get momentTitle_dribble => 'Çalım';

  @override
  String get momentIntro_dribble => 'Savunmacı karşında; geçmek senin elinde.';

  @override
  String get momentTitle_tackle => 'Müdahale';

  @override
  String get momentIntro_tackle =>
      'Rakip hızla üstüne geliyor, doğru zamanda müdahale et.';

  @override
  String get momentPlay => 'Oyna';

  @override
  String get momentAuto => 'Otomatik Çöz';

  @override
  String get momentAutoNote =>
      'Bu mini oyun henüz hazır değil; sonuç niteliklerine göre hesaplanır.';

  @override
  String get momentContinue => 'Devam';

  @override
  String get outcomeGoal => 'Gol!';

  @override
  String get outcomeAssist => 'Asist!';

  @override
  String get outcomeConceded => 'Hatan gole yol açtı.';

  @override
  String get outcomeNothing => 'Pozisyon sonuçsuz kaldı.';

  @override
  String get summaryTitle => 'Maç Sonu';

  @override
  String get resultWin => 'Galibiyet';

  @override
  String get resultDraw => 'Beraberlik';

  @override
  String get resultLoss => 'Mağlubiyet';

  @override
  String get ratingLabel => 'Oyuncu Reytingi';

  @override
  String timelineGoal(int minute, String team) {
    return '$minute\'  Gol — $team';
  }

  @override
  String timelineGoalYou(int minute, String team) {
    return '$minute\'  Gol (sen) — $team';
  }

  @override
  String timelineAssistYou(int minute, String team) {
    return '$minute\'  Asist (sen) — $team';
  }

  @override
  String get noGoals => 'Gol olmadı.';

  @override
  String get backHome => 'Ana Sayfaya Dön';

  @override
  String get shotHint => 'Zamanı tut, topa dokun ve kaleye doğru kaydır.';

  @override
  String get shotInvalid => 'Yukarı doğru, daha uzun kaydır.';

  @override
  String get shotGoal => 'GOL!';

  @override
  String get shotSaved => 'Kaleci kurtardı!';

  @override
  String get shotBlocked => 'Savunma engelledi!';

  @override
  String get shotOff => 'Auta gitti!';

  @override
  String get shotWood => 'Direkten döndü!';

  @override
  String get shotTimeout => 'Fırsat kaçtı!';

  @override
  String get shotPerfect => 'Mükemmel zamanlama!';

  @override
  String get nextMatchHint =>
      'Şimdilik hazırlık maçı oynayabilirsin; lig maçları kulüp sistemiyle gelecek.';
}
