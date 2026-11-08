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

  @override
  String get statCondition => 'Kondisyon';

  @override
  String get statForm => 'Form';

  @override
  String get statMorale => 'Moral';

  @override
  String injuryBanner(String type, int weeks) {
    return 'Sakatsın: $type · $weeks hafta kaldı';
  }

  @override
  String get injury_muscle => 'Kas sakatlığı';

  @override
  String get injury_ligament => 'Bağ sakatlığı';

  @override
  String get injury_fracture => 'Kırık';

  @override
  String get trainingTitle => 'Haftalık Plan';

  @override
  String get focusLabel => 'Antrenman odağı';

  @override
  String get focus_shooting => 'Şut';

  @override
  String get focus_physical => 'Fizik';

  @override
  String get focus_technical => 'Teknik';

  @override
  String get focus_tactical => 'Taktik';

  @override
  String get focus_rest => 'Dinlenme';

  @override
  String get intensityLabel => 'Yoğunluk';

  @override
  String get intensity_light => 'Hafif';

  @override
  String get intensity_normal => 'Orta';

  @override
  String get intensity_hard => 'Sert';

  @override
  String get socialLabel => 'Sosyal hayat';

  @override
  String get social_none => 'Yok';

  @override
  String get social_family => 'Aile';

  @override
  String get social_friends => 'Arkadaşlar';

  @override
  String get social_hobby => 'Hobi';

  @override
  String get trainingHint =>
      'Sert antrenman daha çok geliştirir ama kondisyonu eritir ve sakatlık riskini artırır. Düşük kondisyon performansı ve sağlığı bozar.';

  @override
  String get playWeekMatch => 'Maçı Oyna ve Haftayı Bitir';

  @override
  String get playWeekNoMatch => 'Haftayı Geçir';

  @override
  String get injuredNoTraining =>
      'Sakatken antrenman yapamazsın; bu hafta dinlenmeye çevrilir.';

  @override
  String get earlyReturn => 'Riskli Erken Dönüş';

  @override
  String get earlyReturnBody =>
      'Hemen sahaya dönersin ama kondisyonun düşer ve birkaç hafta boyunca tekrar sakatlanma riskin çok yüksek olur. Tekrar sakatlanırsan çok daha uzun sürer.';

  @override
  String get earlyReturnConfirm => 'Dön';

  @override
  String weekHeader(int season, int week) {
    return 'Sezon $season · Hafta $week';
  }

  @override
  String get phase_preseason => 'Hazırlık dönemi';

  @override
  String phase_regularSeason(int round) {
    return 'Lig turu $round';
  }

  @override
  String get phase_offseason => 'Sezon arası';

  @override
  String get transferWindowOpen => 'Transfer penceresi açık';

  @override
  String get thisWeek => 'Bu hafta';

  @override
  String get matchThisWeek => 'Bu hafta lig maçı var.';

  @override
  String get noMatchThisWeek => 'Bu hafta maç yok.';

  @override
  String get injuredNoMatch => 'Sakatsın, bu hafta maçta yoksun.';

  @override
  String get goTraining => 'Haftayı Planla';

  @override
  String get weekSummaryTitle => 'Hafta Özeti';

  @override
  String summaryWeekOf(int season, int week) {
    return 'Sezon $season, Hafta $week';
  }

  @override
  String get attributeGainsTitle => 'Gelişim';

  @override
  String get changesTitle => 'Ne değişti, neden?';

  @override
  String statLine(String stat, int before, int after) {
    return '$stat: $before → $after';
  }

  @override
  String get reason_recovery => 'Haftalık toparlanma';

  @override
  String get reason_trainingLight => 'Hafif antrenman';

  @override
  String get reason_trainingNormal => 'Orta antrenman';

  @override
  String get reason_trainingHard => 'Sert antrenman';

  @override
  String get reason_restFocus => 'Dinlenme';

  @override
  String get reason_match => 'Maç yorgunluğu';

  @override
  String get reason_socialFamily => 'Aileyle zaman';

  @override
  String get reason_socialFriends => 'Arkadaşlarla zaman';

  @override
  String get reason_socialHobby => 'Hobi';

  @override
  String get reason_matchWin => 'Galibiyet';

  @override
  String get reason_matchLoss => 'Mağlubiyet';

  @override
  String get reason_greatPerformance => 'Parlak performans';

  @override
  String get reason_poorPerformance => 'Kötü performans';

  @override
  String get reason_injured => 'Sakatlık süreci';

  @override
  String get reason_injuryOnset => 'Sakatlanma';

  @override
  String get reason_healed => 'İyileşme';

  @override
  String get reason_exhausted => 'Bitkinlik';

  @override
  String get reason_formFromRatings => 'Son maç reytingleri';

  @override
  String get reason_formFades => 'Maç yok, form sönüyor';

  @override
  String get reason_earlyReturn => 'Erken dönüş';

  @override
  String get reason_drift => 'Zamanla dengelenme';

  @override
  String eventInjured(String type, int weeks) {
    return 'Sakatlandın: $type ($weeks hafta).';
  }

  @override
  String eventRelapse(String type, int weeks) {
    return 'Tekrar sakatlandın: $type ($weeks hafta).';
  }

  @override
  String get eventHealed => 'Sakatlığın iyileşti, sahaya dönebilirsin.';

  @override
  String eventNewSeason(int age) {
    return 'Yeni sezon başladı! $age yaşına girdin.';
  }

  @override
  String get eventTrainingBlocked =>
      'Sakat olduğun için antrenman dinlenmeye çevrildi.';

  @override
  String get continueButton => 'Devam';

  @override
  String get finishWeek => 'Haftayı Bitir';
}
