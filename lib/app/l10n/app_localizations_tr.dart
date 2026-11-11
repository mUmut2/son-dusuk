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
  String get matchTitle => 'Lig Maçı';

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
  String statLine(String stat, String before, String after) {
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

  @override
  String get miniHint_oneOnOne =>
      'Kaleci çok yakın! Zamanı tut, topa dokun ve köşeye doğru kaydır.';

  @override
  String get miniHint_freeKick =>
      'Duvarın üstünden aş ya da yanından kavisle dolan. Topa dokun ve kaydır; yolu bükersen falso olur.';

  @override
  String get miniHint_header =>
      'Top kafa hizasına gelince parmağını oyuncuya koy ve kale yönüne kaydır.';

  @override
  String get miniHint_penalty =>
      'Kaleye dokunarak köşeyi seç, sonra ibreyi yeşil bölgede durdurmak için aşağıya dokun.';

  @override
  String get miniHint_keyPass =>
      'Bir arkadaşına dokun, sonra çubuk yeşil alandayken aşağıya dokun. Rakibi küçük olan pas daha güvenli!';

  @override
  String get miniHint_dribble =>
      'Parmağını sağa sola sürükle! Kırmızı savunmacılara çarpmadan yeşil geçitten geç.';

  @override
  String get miniHint_tackle =>
      'Parmağınla rakibin önünde kal. Top ayağından en çok açıldığı anda parmağını bırak!';

  @override
  String get shootButton => 'Durdur';

  @override
  String get tooEarly => 'Çok erken!';

  @override
  String get passComplete => 'Pas tamam!';

  @override
  String get passAssist => 'ASİST!';

  @override
  String get passIntercepted => 'Pas kesildi!';

  @override
  String get dribbleBeaten => 'Çalım tuttu!';

  @override
  String get dribbleFail => 'Savunmacı topu aldı!';

  @override
  String get tackleWon => 'Top kazanıldı!';

  @override
  String get tackleFoul => 'Faul!';

  @override
  String get tackleBeaten => 'Geçildi!';

  @override
  String get momentAutoSkip => 'Otomatik Çöz';

  @override
  String moneyAmount(String amount) {
    return '$amount ₺';
  }

  @override
  String moneyPerWeek(String amount) {
    return '$amount ₺ / hafta';
  }

  @override
  String clubLeagueLine(String league, int pos, int points) {
    return '$league · $pos. sıra · $points puan';
  }

  @override
  String clubLeagueLineNoMatch(String league) {
    return '$league · henüz maç oynanmadı';
  }

  @override
  String get clubFreeAgentTitle => 'Serbest oyuncusun';

  @override
  String get clubFreeAgentBody =>
      'Bir kulübe imza atana kadar maç oynayamaz ve maaş alamazsın. Teklifler her hafta gelir.';

  @override
  String get contractTitle => 'Sözleşme';

  @override
  String get contractWage => 'Maaş';

  @override
  String get contractRole => 'Rol';

  @override
  String get contractEnds => 'Sözleşme bitişi';

  @override
  String contractEndsValue(int season) {
    return 'Sezon $season sonu';
  }

  @override
  String get marketValue => 'Piyasa değeri';

  @override
  String get role_prospect => 'Yedek (genç)';

  @override
  String get role_rotation => 'Rotasyon';

  @override
  String get role_starter => 'İlk 11';

  @override
  String get role_star => 'Yıldız';

  @override
  String get offersTitle => 'Teklifler';

  @override
  String get offersNone => 'Şu an bekleyen teklif yok.';

  @override
  String get offersWindowHint =>
      'Transfer pencereleri: sezonun ilk 6 haftası ve 22-24. haftalar. Pencere dışında yalnızca sözleşme yenileme teklifi gelebilir.';

  @override
  String offerTransferTitle(String club) {
    return '$club sana teklif yaptı';
  }

  @override
  String offerRenewalTitle(String club) {
    return '$club sözleşmeni uzatmak istiyor';
  }

  @override
  String offerTerms(String league, int years, String role) {
    return '$league · $years yıl · $role';
  }

  @override
  String offerExpires(int weeks) {
    return 'Son cevap: $weeks hafta';
  }

  @override
  String get offerAccept => 'Kabul Et';

  @override
  String get offerNegotiate => 'Pazarlık Et';

  @override
  String get offerDecline => 'Reddet';

  @override
  String get negotiateTitle => 'Maaş pazarlığı';

  @override
  String get negotiateAsk => 'İstediğin maaş';

  @override
  String get negotiateHint =>
      'Fazla isteme: kulüp teklifi geri çekebilir. Pazarlık hakkı bir kez kullanılır.';

  @override
  String get negotiateSubmit => 'Teklif Et';

  @override
  String negotiateCounter(String club, String wage) {
    return '$club en fazla $wage verebilir. Bu maaşla imzalar mısın?';
  }

  @override
  String negotiateWalked(String club) {
    return '$club teklifi geri çekti.';
  }

  @override
  String get negotiateSignAt => 'Bu Maaşla İmzala';

  @override
  String offerSigned(String club) {
    return '$club ile imzaladın!';
  }

  @override
  String get agentTitle => 'Menajer';

  @override
  String get agentNone =>
      'Menajerin yok. Menajer daha çok ve daha iyi teklif getirir, pazarlıkta işini kolaylaştırır; karşılığında gelirinden komisyon alır.';

  @override
  String get agentLevel_1 => 'Amatör menajer';

  @override
  String get agentLevel_2 => 'Tecrübeli menajer';

  @override
  String get agentLevel_3 => 'Ünlü menajer';

  @override
  String agentInfo(String name, int percent) {
    return '$name · komisyon %$percent';
  }

  @override
  String get agentHire => 'Anlaş';

  @override
  String get agentFire => 'Ayrıl';

  @override
  String agentLocked(int min) {
    return 'Genel güç $min gerekir';
  }

  @override
  String get financeTitle => 'Finans';

  @override
  String get financeBalance => 'Bakiye';

  @override
  String get financeDebt => 'Borçtasın! Moralin her hafta düşüyor.';

  @override
  String financeWeekly(String income, String cost) {
    return 'Haftalık gelir: $income · gider: $cost';
  }

  @override
  String get lifestyleTitle => 'Yaşam tarzı';

  @override
  String get lifestyle_modest => 'Mütevazı';

  @override
  String get lifestyle_comfortable => 'Rahat';

  @override
  String get lifestyle_lavish => 'Lüks';

  @override
  String lifestyleInfo(String cost, String morale) {
    return '$cost / hafta · moral $morale';
  }

  @override
  String get tableTitle => 'Lig Tablosu';

  @override
  String get tableHeaderPlayed => 'O';

  @override
  String get tableHeaderGd => 'Av';

  @override
  String get tableHeaderPoints => 'P';

  @override
  String get tableEmpty => 'Henüz maç oynanmadı.';

  @override
  String get moneyTitle => 'Para';

  @override
  String get money_wage => 'Maaş';

  @override
  String get money_winBonus => 'Galibiyet primi';

  @override
  String get money_goalBonus => 'Gol primi';

  @override
  String get money_agentFee => 'Menajer komisyonu';

  @override
  String get money_living => 'Yaşam gideri';

  @override
  String get reason_lifestyle => 'Yaşam tarzı';

  @override
  String get reason_debt => 'Borç stresi';

  @override
  String get eventBenched => 'Bu hafta kadroda yer almadın.';

  @override
  String eventOfferReceived(String club) {
    return '$club sana transfer teklifi yaptı. Kulüp sekmesinden bak.';
  }

  @override
  String eventRenewalOffered(String club) {
    return '$club sözleşmeni uzatmak istiyor. Kulüp sekmesinden bak.';
  }

  @override
  String eventContractExpired(String club) {
    return '$club ile sözleşmen bitti. Artık serbest oyuncusun.';
  }

  @override
  String get benchedThisWeek => 'Bu hafta kadroda yoksun.';

  @override
  String get freeAgentNoMatch => 'Kulübün yok, bu hafta maç oynayamazsın.';

  @override
  String homeClubLine(String club, String league) {
    return '$club · $league';
  }

  @override
  String offersWaiting(int count) {
    return '$count bekleyen teklif var';
  }

  @override
  String get ev_pressWin_title => 'Galibiyet sonrası mikrofonlar';

  @override
  String ev_pressWin_body(String opponent, String score) {
    return '$opponent karşısında $score kazandınız. Gazeteciler seni bekliyor: \"Bu galibiyetteki en büyük pay kimin?\"';
  }

  @override
  String get ev_pressWin_c0 => 'Bu takımın başarısı, hepsine minnettarım.';

  @override
  String get ev_pressWin_r0 => 'Soyunma odası bu sözlere bayıldı.';

  @override
  String get ev_pressWin_c1 => 'Bugün benim günümdü, hep böyle olsun.';

  @override
  String get ev_pressWin_r1 =>
      'Manşetler seninle açıldı ama takım arkadaşları homurdandı.';

  @override
  String get ev_pressWin_c2 => 'Rakip bu seviyeye çıkamadı, herkes gördü.';

  @override
  String get ev_pressWin_r2 => 'Sert sözlerin gündem oldu.';

  @override
  String get ev_pressWin_b2 =>
      'Rakip kulüp sert tepki verdi, teknik direktör seni uyardı.';

  @override
  String get ev_pressLoss_title => 'Yenilgi sonrası sorular';

  @override
  String ev_pressLoss_body(String opponent, String score) {
    return '$opponent karşısında $score kaybettiniz. Gazeteciler soruyor: \"Bu yenilgi kimin hatası?\"';
  }

  @override
  String get ev_pressLoss_c0 => 'Hepimizin sorumluluğu var, toparlanacağız.';

  @override
  String get ev_pressLoss_r0 => 'Olgun duruşun teknik heyetin dikkatini çekti.';

  @override
  String get ev_pressLoss_c1 => 'Hakem kararları maçı değiştirdi.';

  @override
  String get ev_pressLoss_r1 => 'Taraftarlar seni haklı buldu.';

  @override
  String get ev_pressLoss_b1 =>
      'Açıklama tepki çekti; teknik direktör seni uyardı.';

  @override
  String get ev_pressLoss_c2 => 'Bu soruya cevap vermeyeceğim.';

  @override
  String get ev_pressLoss_r2 => 'Gazeteciler suskunluğunu yorumladı.';

  @override
  String get ev_pressStar_title => 'Günün yıldızı';

  @override
  String ev_pressStar_body(String opponent, String score) {
    return '$opponent maçını $score bitirdiniz ve skorda senin imzan var. Gazeteciler: \"Bu performans seni büyük kulüplere taşır mı?\"';
  }

  @override
  String get ev_pressStar_c0 => 'Takım arkadaşlarım sayesinde buradayım.';

  @override
  String get ev_pressStar_r0 => 'Mütevazı sözlerin herkesi memnun etti.';

  @override
  String get ev_pressStar_c1 =>
      'Daha fazlasını yapabilirim, kim isterse gelsin.';

  @override
  String get ev_pressStar_r1 => 'Büyük kulüplerin radarına girdin.';

  @override
  String get ev_pressStar_b1 => 'Bu sözler soyunma odasında kızgınlık yarattı.';

  @override
  String get ev_pressStar_c2 =>
      'Teknik direktörüm bana güvendi, hesabını verdim.';

  @override
  String get ev_pressStar_r2 => 'Hoca bu sözlere çok sevindi.';

  @override
  String get ev_pressPoor_title => 'Eleştiri yağmuru';

  @override
  String ev_pressPoor_body(String opponent, String score) {
    return '$opponent karşısında $score bitti ve performansın eleştirildi. Gazeteciler: \"Bugün neden sahada yoktun?\"';
  }

  @override
  String get ev_pressPoor_c0 => 'Kötüydüm, bunu kabul ediyorum.';

  @override
  String get ev_pressPoor_r0 => 'Dürüstlüğün takdir topladı.';

  @override
  String get ev_pressPoor_c1 => 'Eleştiriler beni daha da motive ediyor.';

  @override
  String get ev_pressPoor_r1 =>
      'Meydan okuman bazılarını güldürdü, bazılarını kızdırdı.';

  @override
  String get ev_pressPoor_c2 => 'Yorum yok.';

  @override
  String get ev_pressPoor_r2 => 'Kısa kesmen soru işaretleri bıraktı.';

  @override
  String get ev_pressBench_title => 'Yedek kulübesi';

  @override
  String get ev_pressBench_body =>
      'Bu hafta kadroda yoktun. Gazeteciler: \"Yedek kalmak seni nasıl etkiliyor?\"';

  @override
  String get ev_pressBench_c0 => 'Sabırlıyım, sıram gelecek.';

  @override
  String get ev_pressBench_r0 => 'Teknik direktör olgunluğunu not etti.';

  @override
  String get ev_pressBench_c1 => 'Daha fazla süre hak ediyorum.';

  @override
  String get ev_pressBench_r1 => 'Söylediklerin yazıldı, hoca pek hoşlanmadı.';

  @override
  String get ev_pressBench_c2 => 'Önemli olan takımın kazanması.';

  @override
  String get ev_pressBench_r2 => 'Takım arkadaşların bunu duyunca memnun oldu.';

  @override
  String get ev_familyDinner_title => 'Aile yemeği';

  @override
  String get ev_familyDinner_body =>
      'Annen ve baban seni akşam yemeğine çağırıyor. Haftanın tek boş akşamı.';

  @override
  String get ev_familyDinner_c0 => 'Yemeğe git, doyasıya sohbet et.';

  @override
  String get ev_familyDinner_r0 =>
      'Mutlu ve yorgun döndün; aile seni özlemişti.';

  @override
  String get ev_familyDinner_c1 => 'Antrenmana odaklan, daha sonra görüşürsün.';

  @override
  String get ev_familyDinner_r1 =>
      'Annen biraz kırıldı ama hoca çalışkanlığını görüyor.';

  @override
  String get ev_familyDinner_c2 => 'Kısa bir telefon görüşmesi yap.';

  @override
  String get ev_familyDinner_r2 => 'Sesini duymak yetti, ama sarılmak başka.';

  @override
  String get ev_partyInvite_title => 'Doğum günü daveti';

  @override
  String get ev_partyInvite_body =>
      'Takım arkadaşların bir doğum günü kutlamasına seni çağırıyor.';

  @override
  String get ev_partyInvite_c0 => 'Katıl, gece uzasın.';

  @override
  String get ev_partyInvite_r0 => 'Soyunma odasında bağların güçlendi.';

  @override
  String get ev_partyInvite_b0 =>
      'Bir video sızdı. Medya ve teknik direktör hoşnut değil.';

  @override
  String get ev_partyInvite_c1 => 'Nazikçe reddet, dinlen.';

  @override
  String get ev_partyInvite_r1 => 'Dinlendin ama bazıları seni mesafeli buldu.';

  @override
  String get ev_partyInvite_c2 => 'Bir saat uğrayıp çık.';

  @override
  String get ev_partyInvite_r2 => 'Hem orada oldun hem dinlenebildin.';

  @override
  String get ev_fanMeet_title => 'Taraftar buluşması';

  @override
  String get ev_fanMeet_body =>
      'Antrenman çıkışı, kapıda onlarca taraftar seni bekliyor.';

  @override
  String get ev_fanMeet_c0 => 'Durup herkesle fotoğraf çektir.';

  @override
  String get ev_fanMeet_r0 => 'Taraftarlar bu ilgiyi uzun süre unutmayacak.';

  @override
  String get ev_fanMeet_c1 => 'Hızlıca geç, yorgunsun.';

  @override
  String get ev_fanMeet_r1 => 'Bazı taraftarlar küstü.';

  @override
  String get ev_fanMeet_c2 => 'Birkaç imza ver, el salla.';

  @override
  String get ev_fanMeet_r2 => 'Hem hızlı hem samimi oldu.';

  @override
  String get ev_coachTalk_title => 'Hoca çağırıyor';

  @override
  String get ev_coachTalk_body =>
      'Teknik direktör seni ofisine çağırdı. Aranızın pek iyi olmadığı belli.';

  @override
  String get ev_coachTalk_c0 => 'Dinle ve çalışmaya odaklan.';

  @override
  String get ev_coachTalk_r0 => 'Hoca ciddiyetini gördü.';

  @override
  String get ev_coachTalk_c1 => 'Haklı olduğunu savun.';

  @override
  String get ev_coachTalk_r1 => 'Konuşma gerginleşti ama içini döktün.';

  @override
  String get ev_coachTalk_c2 => 'Taktik önerin olduğunu söyle.';

  @override
  String get ev_coachTalk_r2 => 'Hoca önerini dikkate aldı!';

  @override
  String get ev_coachTalk_b2 =>
      'Önerin fazla iddialı bulundu, hoca aldırış etmedi.';

  @override
  String get ev_teammateRift_title => 'Soyunma odası gerginliği';

  @override
  String get ev_teammateRift_body =>
      'Antrenmanda bir takım arkadaşınla sürtüşme yaşadın, soyunma odası ikiye bölündü.';

  @override
  String get ev_teammateRift_c0 => 'Konuşup barışmayı dene.';

  @override
  String get ev_teammateRift_r0 => 'Barıştınız, hava yumuşadı.';

  @override
  String get ev_teammateRift_c1 => 'Durumu teknik direktöre anlat.';

  @override
  String get ev_teammateRift_r1 =>
      'Hoca ilgilendi ama arkadaşların seni küçümsedi.';

  @override
  String get ev_teammateRift_c2 => 'Görmezden gel.';

  @override
  String get ev_teammateRift_r2 => 'Gerginlik bir süre daha sürecek.';

  @override
  String get ev_sponsorOffer_title => 'Sponsor teklifi';

  @override
  String get ev_sponsorOffer_body =>
      'Bir spor markası seninle sponsorluk görüşmesi yapmak istiyor.';

  @override
  String get ev_sponsorOffer_c0 => 'Büyük, uluslararası markayla anlaş.';

  @override
  String get ev_sponsorOffer_r0 =>
      'Hesabına iyi bir para girdi; bazı taraftarlar fazla ticari buldu.';

  @override
  String get ev_sponsorOffer_c1 => 'Yerel esnafın küçük markasıyla anlaş.';

  @override
  String get ev_sponsorOffer_r1 => 'Para az ama taraftar bunu sevdi.';

  @override
  String get ev_sponsorOffer_c2 => 'Şimdilik reddet, futbola odaklan.';

  @override
  String get ev_sponsorOffer_r2 => 'Odağın hocanın hoşuna gitti.';

  @override
  String get ev_charity_title => 'Yardım maçı';

  @override
  String get ev_charity_body =>
      'Kulübün düzenlediği yardım maçına katılman ve bağış yapman isteniyor.';

  @override
  String get ev_charity_c0 => 'Katıl ve maaşından bağışla.';

  @override
  String get ev_charity_r0 => 'Hem insanlar hem basın bu jesti çok sevdi.';

  @override
  String get ev_charity_c1 => 'Katıl ama bağış yapma.';

  @override
  String get ev_charity_r1 => 'Sahadaydın, bu da bir şey.';

  @override
  String get ev_charity_c2 => 'Katılma.';

  @override
  String get ev_charity_r2 => 'Birileri hatırlayacak.';

  @override
  String get ev_transferRumor_title => 'Transfer dedikodusu';

  @override
  String get ev_transferRumor_body =>
      'Gazeteler adını başka bir kulüple yazıyor: \"Gizli görüşme yapıldı.\"';

  @override
  String get ev_transferRumor_c0 => 'Yalanla: buradayım.';

  @override
  String get ev_transferRumor_r0 => 'Hoca bu sadakate sevindi.';

  @override
  String get ev_transferRumor_c1 => 'Yorum yapma.';

  @override
  String get ev_transferRumor_r1 => 'Söylenti sürdü, adın konuşuldu.';

  @override
  String get ev_transferRumor_c2 => 'Ucu açık bırak, söylentiyi körükle.';

  @override
  String get ev_transferRumor_r2 =>
      'Gündemdesin ama kulüp ve taraftar rahatsız.';

  @override
  String get ev_socialPost_title => 'Sosyal medya fırtınası';

  @override
  String get ev_socialPost_body =>
      'Eskiden attığın bir paylaşım gündem oldu, yorumlar alevlendi.';

  @override
  String get ev_socialPost_c0 => 'Paylaşımı sil, konuşma.';

  @override
  String get ev_socialPost_r0 => 'Fırtına yavaş yavaş dindi.';

  @override
  String get ev_socialPost_c1 => 'Paylaşımı savun.';

  @override
  String get ev_socialPost_r1 => 'Destekçilerin sana sahip çıktı.';

  @override
  String get ev_socialPost_b1 => 'Savunma ters tepti; olay daha da büyüdü.';

  @override
  String get ev_socialPost_c2 => 'Açıkça özür dile.';

  @override
  String get ev_socialPost_r2 =>
      'Özrün samimi bulundu ama biraz moralin bozuldu.';

  @override
  String get ev_injuryRehab_title => 'Rehabilitasyon kararı';

  @override
  String get ev_injuryRehab_body =>
      'Sakatlığın uzun sürecek. Fizyoterapist sana bir program öneriyor.';

  @override
  String get ev_injuryRehab_c0 => 'Programa sıkı sıkıya bağlı kal.';

  @override
  String get ev_injuryRehab_r0 => 'Düzenli çalışman iyileşmeyi hızlandırdı.';

  @override
  String get ev_injuryRehab_c1 => 'Gizlice ekstra çalış.';

  @override
  String get ev_injuryRehab_r1 => 'Fazladan çalışman işe yaradı!';

  @override
  String get ev_injuryRehab_b1 =>
      'Aşırıya kaçtın; sakatlığın nüksetme riski arttı.';

  @override
  String get ev_injuryRehab_c2 => 'Ailenle vakit geçir, moral topla.';

  @override
  String get ev_injuryRehab_r2 => 'Sevdiklerinin yanında içini rahatlattın.';

  @override
  String get ev_youthAcademy_title => 'Akademi ziyareti';

  @override
  String get ev_youthAcademy_body =>
      'Kulüp, gençlik akademisini ziyaret etmeni istiyor. Çocuklar seni görmek için sabırsız.';

  @override
  String get ev_youthAcademy_c0 => 'Git, çocuklarla vakit geçir.';

  @override
  String get ev_youthAcademy_r0 => 'Çocukların gözlerindeki ışık değdi.';

  @override
  String get ev_youthAcademy_c1 => 'Bu hafta olmaz.';

  @override
  String get ev_youthAcademy_r1 => 'Ziyaret bir başkasına kaldı.';

  @override
  String get ev_debtHelp_title => 'Borç baskısı';

  @override
  String get ev_debtHelp_body =>
      'Hesabın eksiye düştü ve banka seni arıyor. Ne yapacaksın?';

  @override
  String get ev_debtHelp_c0 => 'Aileden borç iste.';

  @override
  String get ev_debtHelp_r0 => 'Ailen yardım etti, ama bunu unutmayacaklar.';

  @override
  String get ev_debtHelp_c1 => 'Kimseden yardım isteme, kendin çöz.';

  @override
  String get ev_debtHelp_r1 => 'Gururun yerinde ama stres arttı.';

  @override
  String get socialTitle => 'Sosyal';

  @override
  String get socialPending => 'Cevap bekleyenler';

  @override
  String get socialNoPending =>
      'Şu an cevap bekleyen bir gelişme yok. Maçlardan ve haftalardan sonra yenileri gelir.';

  @override
  String get socialRelations => 'İlişkiler';

  @override
  String get rel_coach => 'Teknik direktör';

  @override
  String get rel_teammates => 'Takım arkadaşları';

  @override
  String get rel_fans => 'Taraftar';

  @override
  String get rel_family => 'Aile';

  @override
  String get rel_media => 'Medya';

  @override
  String get relHint_coach => 'Maça çıkma şansını etkiler';

  @override
  String get relHint_teammates => 'Moral dengeni etkiler';

  @override
  String get relHint_fans => 'Sponsor ve prim fırsatlarını etkiler';

  @override
  String get relHint_family => 'Moral dengeni etkiler';

  @override
  String get relHint_media => 'Teklif sıklığını etkiler';

  @override
  String get relLevel_0 => 'Soğuk';

  @override
  String get relLevel_1 => 'Mesafeli';

  @override
  String get relLevel_2 => 'Normal';

  @override
  String get relLevel_3 => 'Sıcak';

  @override
  String get relLevel_4 => 'Çok yakın';

  @override
  String get socialNews => 'Haber akışı';

  @override
  String get socialNewsEmpty => 'Henüz haber yok.';

  @override
  String newsMatch(String opponent, String score) {
    return '$opponent maçı: $score';
  }

  @override
  String newsMatchGoals(String opponent, String score, String goals) {
    return '$opponent maçı: $score · $goals gol';
  }

  @override
  String newsSigned(String club) {
    return '$club ile imza attın';
  }

  @override
  String newsInjury(String type, String weeks) {
    return 'Sakatlandın: $type, $weeks hafta';
  }

  @override
  String newsEvent(String title, String choice) {
    return '$title: $choice';
  }

  @override
  String get eventKind_press => 'Röportaj';

  @override
  String get eventKind_personal => 'Kişisel';

  @override
  String get eventKind_career => 'Kariyer';

  @override
  String get eventKind_money => 'Para';

  @override
  String get eventAnswer => 'Cevap ver';

  @override
  String eventExpires(int weeks) {
    return '$weeks hafta içinde cevapla';
  }

  @override
  String get eventExpiresLast => 'Son hafta!';

  @override
  String get eventChooseHint =>
      'Bir seçenek seç. Etkilenecek alanlar işaretli, sonuç sürpriz.';

  @override
  String get eventRiskyTag => 'Riskli';

  @override
  String get eventResult => 'Sonuç';

  @override
  String get eventBackfired => 'Ters tepti!';

  @override
  String get eventDone => 'Tamam';

  @override
  String get effectMorale => 'Moral';

  @override
  String get effectCondition => 'Kondisyon';

  @override
  String get effectMoney => 'Para';

  @override
  String get effectHeal => 'Sakatlık süresi';

  @override
  String effectHealValue(int weeks) {
    return '$weeks hafta kısaldı';
  }

  @override
  String get effectRelapse => 'Tekrar sakatlanma riski';

  @override
  String eventNewEvent(String title) {
    return 'Yeni gelişme: $title';
  }

  @override
  String get summaryPendingEvent => 'Cevap bekleyen bir gelişme var';

  @override
  String get summaryAnswerNow => 'Şimdi Cevapla';

  @override
  String pendingEventsCard(int count) {
    return '$count gelişme cevap bekliyor';
  }

  @override
  String get pendingEventsHint => 'Sosyal sekmesinde';

  @override
  String seasonWeekShort(int season, int week) {
    return 'S$season · H$week';
  }

  @override
  String get profileCareerSection => 'Kariyer';

  @override
  String get profileNationalCard => 'Milli Takım';

  @override
  String profileNationalSub(int caps, int goals) {
    return '$caps maç · $goals gol';
  }

  @override
  String get profileAchievementsCard => 'Başarımlar';

  @override
  String profileAchievementsSub(int done, int total) {
    return '$done / $total açıldı';
  }

  @override
  String get profileSummaryCard => 'Kariyer Özeti';

  @override
  String get profileSummarySub => 'Şimdiye kadarki yolculuğun';

  @override
  String get retireButton => 'Futbolu Bırak';

  @override
  String get retireTitle => 'Futbolu bırakıyor musun?';

  @override
  String get retireBody =>
      'Kariyerin burada biter ve kariyer özetin açılır. Bu geri alınamaz.';

  @override
  String get retireConfirm => 'Evet, bırak';

  @override
  String retireAgeHint(int age) {
    return 'Emekli olmak için en az $age yaşında olmalısın.';
  }

  @override
  String get tournament_continental => 'Kıtalar Kupası';

  @override
  String get tournament_world => 'Dünya Kupası';

  @override
  String get round_0 => 'Son 16';

  @override
  String get round_1 => 'Çeyrek Final';

  @override
  String get round_2 => 'Yarı Final';

  @override
  String get round_3 => 'Final';

  @override
  String get stageResult_roundOf16 => 'Son 16\'da elendi';

  @override
  String get stageResult_quarterFinal => 'Çeyrek finalde elendi';

  @override
  String get stageResult_semiFinal => 'Yarı finalde elendi';

  @override
  String get stageResult_runnerUp => 'Finalde kaybetti';

  @override
  String get stageResult_champion => 'Şampiyon oldu';

  @override
  String get natRole_starter => 'Ana kadro';

  @override
  String get natRole_rotation => 'Rotasyon';

  @override
  String get natRole_reserve => 'Yedek';

  @override
  String get nationalTitle => 'Milli Takım';

  @override
  String nationalCapsGoals(int caps, int goals) {
    return '$caps milli maç · $goals gol';
  }

  @override
  String nationalStatusCalled(String role) {
    return 'Kadrodasın · $role';
  }

  @override
  String get nationalStatusOmitted =>
      'Bu turnuvanın kadrosunda değilsin. Ülkeni uzaktan destekle.';

  @override
  String get nationalStatusEliminated => 'Ülken turnuvadan elendi.';

  @override
  String get nationalStatusChampion => 'Ülken turnuvayı kazandı!';

  @override
  String nationalNextTournament(String name, int season) {
    return 'Sıradaki turnuva: $name, sezon $season sonunda.';
  }

  @override
  String get nationalEmpty =>
      'Henüz milli takım geçmişin yok. Turnuvalar iki sezonda bir, sezon arasında oynanır. Genel gücü ve formu yüksek, üst liglerde oynayan oyuncular çağrılır.';

  @override
  String get nationalBracketTitle => 'Eşleşmeler';

  @override
  String nationalRoundHeader(String round, int week) {
    return '$round · Hafta $week';
  }

  @override
  String get nationalHistoryTitle => 'Geçmiş Turnuvalar';

  @override
  String nationalHistoryLine(String name, int season) {
    return '$name · Sezon $season';
  }

  @override
  String nationalHistorySub(String result, int apps, int goals) {
    return '$result · $apps maç, $goals gol';
  }

  @override
  String nationalHistoryNotCalled(String result) {
    return '$result · Kadroda değildin';
  }

  @override
  String get nationalYouPlayed => 'Oynadın';

  @override
  String nationalPens(String score) {
    return 'pen. $score';
  }

  @override
  String homeNationalCalled(String tournament) {
    return '$tournament için milli takıma çağrıldın!';
  }

  @override
  String homeNationalNext(String tournament) {
    return 'Bu sezon sonunda $tournament var.';
  }

  @override
  String homeNationalRound(String tournament, String round, String opponent) {
    return '$tournament · $round: $opponent';
  }

  @override
  String homeNationalOut(String tournament) {
    return '$tournament: ülken elendi.';
  }

  @override
  String homeNationalChampion(String tournament) {
    return '$tournament şampiyonusun!';
  }

  @override
  String nationalMatchThisWeek(String opponent) {
    return 'Bu hafta milli maç var: $opponent.';
  }

  @override
  String get nationalBenchedThisWeek => 'Milli takımda bu hafta yedeksin.';

  @override
  String get nationalNotCalledThisWeek =>
      'Bu hafta turnuva maçı var ama kadroda değilsin.';

  @override
  String get nationalEliminatedThisWeek =>
      'Ülken turnuvadan elendi, bu hafta maç yok.';

  @override
  String get nationalInjuredThisWeek => 'Sakatsın, milli maçı kaçıracaksın.';

  @override
  String get playWeekNationalMatch => 'Milli Maçı Oyna';

  @override
  String nationalMatchTitle(String round) {
    return 'Milli Maç · $round';
  }

  @override
  String get nationalKnockoutNote =>
      'Eleme maçı: beraberlikte penaltılara gidilir.';

  @override
  String shootoutWon(String score) {
    return 'Penaltılarda kazandınız: $score';
  }

  @override
  String shootoutLost(String score) {
    return 'Penaltılarda kaybettiniz: $score';
  }

  @override
  String eventNationalCalled(String tournament, String role) {
    return 'Milli takıma çağrıldın! $tournament kadrosundasın ($role).';
  }

  @override
  String eventNationalOmitted(String tournament) {
    return '$tournament kadrosunda yer alamadın.';
  }

  @override
  String eventNationalMatch(
    String round,
    String home,
    String score,
    String opponent,
  ) {
    return '$round: $home $score $opponent';
  }

  @override
  String eventNationalMatchPens(
    String round,
    String home,
    String score,
    String opponent,
    String pens,
  ) {
    return '$round: $home $score $opponent ($pens)';
  }

  @override
  String eventNationalOut(String tournament, String result) {
    return '$tournament: $result';
  }

  @override
  String eventNationalRunnerUp(String tournament) {
    return '$tournament finalini kaybettiniz. Gurur duyulacak bir yol oldu.';
  }

  @override
  String eventNationalChampion(String tournament) {
    return 'ŞAMPİYONSUN! $tournament kupasını kaldırdın!';
  }

  @override
  String eventAchievement(String title) {
    return 'Başarım açıldı: $title';
  }

  @override
  String get eventRetired => 'Kariyerin sona erdi. Futbola veda ettin.';

  @override
  String get money_nationalBonus => 'Milli takım primi';

  @override
  String get summarySeeCareer => 'Kariyer Özetini Gör';

  @override
  String newsNational(String tournament, String result) {
    return '$tournament: $result';
  }

  @override
  String newsAchievement(String title) {
    return 'Başarım: $title';
  }

  @override
  String newsRetired(String age) {
    return '$age yaşında futbolu bıraktın.';
  }

  @override
  String get achievementsTitle => 'Başarımlar';

  @override
  String achievementsProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get achCategory_career => 'Kariyer';

  @override
  String get achCategory_club => 'Kulüp';

  @override
  String get achCategory_national => 'Milli Takım';

  @override
  String get achCategory_growth => 'Gelişim';

  @override
  String get achCategory_wealth => 'Para';

  @override
  String get achLocked => 'Kilitli';

  @override
  String get ach_firstMatch_title => 'İlk Düdük';

  @override
  String get ach_firstMatch_desc => 'İlk maçına çık.';

  @override
  String get ach_firstGoal_title => 'Ağlar Sallandı';

  @override
  String get ach_firstGoal_desc => 'İlk golünü at.';

  @override
  String get ach_firstAssist_title => 'Takım Oyuncusu';

  @override
  String get ach_firstAssist_desc => 'İlk asistini yap.';

  @override
  String get ach_goals10_title => 'Çift Haneli';

  @override
  String get ach_goals10_desc => 'Kariyerinde 10 gol at.';

  @override
  String get ach_goals50_title => 'Golcü';

  @override
  String get ach_goals50_desc => 'Kariyerinde 50 gol at.';

  @override
  String get ach_goals150_title => 'Gol Avcısı';

  @override
  String get ach_goals150_desc => 'Kariyerinde 150 gol at.';

  @override
  String get ach_goals400_title => 'Gol Makinesi';

  @override
  String get ach_goals400_desc => 'Kariyerinde 400 gol at.';

  @override
  String get ach_matches50_title => 'Yerleşik Oyuncu';

  @override
  String get ach_matches50_desc => '50 maç oyna.';

  @override
  String get ach_matches250_title => 'Sahanın Adamı';

  @override
  String get ach_matches250_desc => '250 maç oyna.';

  @override
  String get ach_matches500_title => 'Demir Adam';

  @override
  String get ach_matches500_desc => '500 maç oyna.';

  @override
  String get ach_hatTrick_title => 'Hat-trick';

  @override
  String get ach_hatTrick_desc => 'Tek maçta 3 gol at.';

  @override
  String get ach_starPerformance_title => 'Maçın Adamı';

  @override
  String get ach_starPerformance_desc => 'Bir maçta 9.8 ve üzeri reyting al.';

  @override
  String get ach_seasons10_title => 'On Yıllık Yol';

  @override
  String get ach_seasons10_desc => '10 sezon boyunca oyna.';

  @override
  String get ach_veteran_title => 'Tecrübe';

  @override
  String get ach_veteran_desc => '35 yaşına ulaş.';

  @override
  String get ach_firstTransfer_title => 'Yeni Sayfa';

  @override
  String get ach_firstTransfer_desc => 'Kulüp değiştir.';

  @override
  String get ach_topLeague_title => 'Büyükler Ligi';

  @override
  String get ach_topLeague_desc => 'En üst ligde bir kulüpte oyna.';

  @override
  String get ach_leagueChampion_title => 'Şampiyon';

  @override
  String get ach_leagueChampion_desc => 'Bir sezonu ligin zirvesinde bitir.';

  @override
  String get ach_topLeagueChampion_title => 'Zirvenin Sahibi';

  @override
  String get ach_topLeagueChampion_desc => 'En üst ligde şampiyon ol.';

  @override
  String get ach_loyal_title => 'Sadık Yürek';

  @override
  String get ach_loyal_desc => 'Aynı kulüpte arka arkaya 10 sezon geçir.';

  @override
  String get ach_agentTop_title => 'Güçlü Bağlantılar';

  @override
  String get ach_agentTop_desc => 'En üst seviye menajerle çalış.';

  @override
  String get ach_nationalDebut_title => 'Milli Forma';

  @override
  String get ach_nationalDebut_desc => 'Milli takımda ilk maçına çık.';

  @override
  String get ach_nationalGoal_title => 'Milli Gol';

  @override
  String get ach_nationalGoal_desc => 'Milli takım adına gol at.';

  @override
  String get ach_nationalFinal_title => 'Büyük Final';

  @override
  String get ach_nationalFinal_desc => 'Bir turnuvada finale çık.';

  @override
  String get ach_continentalChampion_title => 'Kıtanın Zirvesi';

  @override
  String get ach_continentalChampion_desc => 'Kıtalar Kupası\'nı kazan.';

  @override
  String get ach_worldChampion_title => 'Dünya Şampiyonu';

  @override
  String get ach_worldChampion_desc => 'Dünya Kupası\'nı kazan.';

  @override
  String get ach_overall70_title => 'Yükselen Yıldız';

  @override
  String get ach_overall70_desc => 'Genel gücünü 70\'e çıkar.';

  @override
  String get ach_overall80_title => 'Dünya Sınıfı';

  @override
  String get ach_overall80_desc => 'Genel gücünü 80\'e çıkar.';

  @override
  String get ach_overall90_title => 'Efsane Seviyesi';

  @override
  String get ach_overall90_desc => 'Genel gücünü 90\'a çıkar.';

  @override
  String get ach_fanIdol_title => 'Tribünlerin Gözdesi';

  @override
  String get ach_fanIdol_desc => 'Taraftar ilişkisini en üst düzeye çıkar.';

  @override
  String get ach_comfortable_title => 'Rahat Yaşam';

  @override
  String get ach_comfortable_desc => 'Bakiyeni 100.000 ₺\'ye ulaştır.';

  @override
  String get ach_millionaire_title => 'Milyoner';

  @override
  String get ach_millionaire_desc => 'Bakiyeni 1.000.000 ₺\'ye ulaştır.';

  @override
  String get summaryTitleRetired => 'Kariyer Özeti';

  @override
  String get summaryTitleLive => 'Kariyerin Şu Ana Kadar';

  @override
  String summaryRetiredAt(int age) {
    return '$age yaşında futbolu bıraktı';
  }

  @override
  String get summaryLegacy => 'Miras';

  @override
  String get legacy_amateur => 'Amatör Ruh';

  @override
  String get legacy_local => 'Yerel Kahraman';

  @override
  String get legacy_pro => 'Profesyonel';

  @override
  String get legacy_star => 'Yıldız';

  @override
  String get legacy_legend => 'Efsane';

  @override
  String get legacyBlurb_amateur =>
      'Sahada az göründün ama futbol sevgin gerçekti.';

  @override
  String get legacyBlurb_local =>
      'Mahallede adın hâlâ anılır; tribünler seni unutmadı.';

  @override
  String get legacyBlurb_pro =>
      'Yıllarca sağlam bir kariyer sürdürdün; saygın bir isimsin.';

  @override
  String get legacyBlurb_star =>
      'Gollerin ve kupalarınla bir döneme damga vurdun.';

  @override
  String get legacyBlurb_legend =>
      'Adın futbol tarihine yazıldı. Gelecek kuşaklar seni konuşacak.';

  @override
  String get sumStat_matches => 'Maç';

  @override
  String get sumStat_goals => 'Gol';

  @override
  String get sumStat_assists => 'Asist';

  @override
  String get sumStat_rating => 'Ort. Reyting';

  @override
  String get sumStat_seasons => 'Sezon';

  @override
  String get sumStat_peak => 'Zirve Güç';

  @override
  String get sumStat_clubs => 'Kulüp';

  @override
  String get sumStat_titles => 'Lig Şampiyonluğu';

  @override
  String get sumStat_caps => 'Milli Maç';

  @override
  String get sumStat_natTitles => 'Turnuva Kupası';

  @override
  String get sumStat_bestLeague => 'En Üst Lig';

  @override
  String get sumStat_achievements => 'Başarım';

  @override
  String get summarySeasonsTitle => 'Sezon Sezon';

  @override
  String summarySeasonTitle(int season, int age) {
    return 'Sezon $season · $age yaş';
  }

  @override
  String summarySeasonSub(String club, String league) {
    return '$club · $league';
  }

  @override
  String summarySeasonStats(int matches, int goals, int assists) {
    return '$matches maç · $goals gol · $assists asist';
  }

  @override
  String summaryPosition(int pos) {
    return '$pos. sırada bitirdi';
  }

  @override
  String get summaryNoClub => 'Kulüpsüz';

  @override
  String get summaryBalance => 'Son bakiye';

  @override
  String get summaryHonorsTitle => 'Öne Çıkanlar';

  @override
  String get summaryToMenu => 'Ana Menüye Dön';

  @override
  String get summaryBack => 'Geri';

  @override
  String get summaryOpenAchievements => 'Başarımlar';

  @override
  String slotRetired(int age, int peak) {
    return 'Emekli · $age yaş · Zirve $peak';
  }

  @override
  String get ach_tycoon_title => 'Servet Sahibi';

  @override
  String get ach_tycoon_desc => 'Bakiyeni 25.000.000 ₺\'ye ulaştır.';

  @override
  String get ach_prolific_title => 'Gol Makinesi';

  @override
  String get ach_prolific_desc => 'Tek sezonda 25 gol at.';

  @override
  String get ach_playmaker_title => 'Oyun Kurucu';

  @override
  String get ach_playmaker_desc => 'Tek sezonda 15 asist yap.';

  @override
  String get ach_steady_title => 'İstikrar Abidesi';

  @override
  String get ach_steady_desc =>
      'En az 20 maçlık bir sezonu 7.5 ve üzeri ortalama reytingle bitir.';

  @override
  String get ach_globetrotter_title => 'Gezgin';

  @override
  String get ach_globetrotter_desc => 'Kariyerinde 6 kez kulüp değiştir.';

  @override
  String get ach_nationalVeteran_title => 'Milli Gurur';

  @override
  String get ach_nationalVeteran_desc => 'Milli takımla 8 maça çık.';

  @override
  String get equipmentTitle => 'Ekipman Mağazası';

  @override
  String get equipmentIntro =>
      'Ekipmanlar bir kez alınır ve kariyerin boyunca seninle kalır.';

  @override
  String equipmentLevel(String level, String max) {
    return 'Seviye $level/$max';
  }

  @override
  String equipmentBuy(String price) {
    return 'Satın al · $price';
  }

  @override
  String get equipmentMaxed => 'En üst seviye';

  @override
  String equipmentBought(String name) {
    return '$name alındı!';
  }

  @override
  String equipmentNext(String name) {
    return 'Sıradaki: $name';
  }

  @override
  String get equip_boots => 'Krampon';

  @override
  String equipEffect_boots(String value) {
    return 'Maçlarda şut, dribling, hız ve top kontrolü +$value';
  }

  @override
  String get equipName_boots_1 => 'Okul Kramponu';

  @override
  String get equipName_boots_2 => 'Profesyonel Krampon';

  @override
  String get equipName_boots_3 => 'Altın Krampon';

  @override
  String get equip_trainingKit => 'Antrenman ekipmanı';

  @override
  String equipEffect_trainingKit(String value) {
    return 'Antrenman kazancı +%$value';
  }

  @override
  String get equipName_trainingKit_1 => 'Antrenman Çantası';

  @override
  String get equipName_trainingKit_2 => 'Pro Antrenman Seti';

  @override
  String get equipName_trainingKit_3 => 'Elit Performans Seti';

  @override
  String get equip_recoveryKit => 'Toparlanma ekipmanı';

  @override
  String equipEffect_recoveryKit(String value) {
    return 'Haftalık toparlanma +$value kondisyon';
  }

  @override
  String get equipName_recoveryKit_1 => 'Buz Torbası';

  @override
  String get equipName_recoveryKit_2 => 'Masaj Tabancası';

  @override
  String get equipName_recoveryKit_3 => 'Toparlanma Odası';

  @override
  String get equip_shinGuards => 'Koruyucu ekipman';

  @override
  String equipEffect_shinGuards(String value) {
    return 'Sakatlanma riski -%$value';
  }

  @override
  String get equipName_shinGuards_1 => 'Plastik Tekmelik';

  @override
  String get equipName_shinGuards_2 => 'Karbon Tekmelik';

  @override
  String get equipName_shinGuards_3 => 'Akıllı Tekmelik';

  @override
  String get equipmentBonusTitle => 'Aktif güçlendirmeler';

  @override
  String get equipmentBonusNone =>
      'Henüz ekipmanın yok. İlk ekipmanını al, farkı hemen hisset!';

  @override
  String equipBonus_boots(String value) {
    return 'Maç gücü +$value';
  }

  @override
  String equipBonus_trainingKit(String value) {
    return 'Antrenman +%$value';
  }

  @override
  String equipBonus_recoveryKit(String value) {
    return 'Toparlanma +$value';
  }

  @override
  String equipBonus_shinGuards(String value) {
    return 'Sakatlık riski -%$value';
  }

  @override
  String equipmentShort(String amount) {
    return '$amount eksik';
  }

  @override
  String get equipmentEmpty => 'Henüz yok';

  @override
  String get equipmentCardNone =>
      'İlk ekipmanını al: maçlarda ve antrenmanda güçlen.';

  @override
  String equipmentCardOwned(String owned, String max) {
    return 'Ekipman seviyesi $owned/$max';
  }

  @override
  String get cm_kickoff =>
      'Hakem düdüğü çaldı, maç başladı! Tribünler ayakta, heyecan dorukta!|Top ortaya kondu ve mücadele başlıyor! İki takım da hazır görünüyor.|Başladı başladı! Çimler yeşil, toplar yuvarlak, bugün her şey olabilir!';

  @override
  String get cm_halftime =>
      'İlk yarı sona erdi! Oyuncular soyunma odasına gidiyor, ben de bir bardak su içeceğim.|Hakem devre arası için düdüğü çaldı. İkinci yarıda neler olacak, hep birlikte göreceğiz!|Devre arası! Teknik direktörler taktik tahtasının başına geçti, çaylar tazelendi.';

  @override
  String get cm_fulltimeWin =>
      'Maç bitti ve %team% kazandı! Tribünlerde bayram havası var!|Final düdüğü çaldı, galibiyet %team% için! Ne maçtı arkadaşlar!|Üç puan %team% takımının! Bu galibiyet uzun süre konuşulacak.';

  @override
  String get cm_fulltimeLoss =>
      'Maç sona erdi, bu kez kazanan %other%. Ama futbol bu, bir sonraki maç yeni bir hikaye!|Düdük çaldı, galibiyeti %other% aldı. %team% için moral çalışması zamanı!|Final düdüğü! Bugün şans %other% tarafındaydı, %team% başını dik tutmalı.';

  @override
  String get cm_fulltimeDraw =>
      'Maç berabere bitti! İki takım da puanı paylaştı.|Final düdüğü çaldı, skor eşit! Kimse kaybetmedi ama kimse tam kazanamadı.|Beraberlik! Tribünler alkışlıyor, iki takım da elinden geleni yaptı.';

  @override
  String get cm_midfield =>
      'Top orta sahada el değiştiriyor, iki takım da sabırlı oynuyor.|%team% topu ayağında tutup paslaşarak ilerliyor.|Orta alanda sıkı bir mücadele var, kimse top vermek istemiyor!|%team% kanattan hızlı bir hücuma çıkıyor, savunma tetikte!';

  @override
  String get cm_corner =>
      'Köşe vuruşu %team% lehine! Ortaya çok sayıda oyuncu yığıldı.|Korner kazandı %team%! Top ceza sahasına havalanıyor... ve savunma uzaklaştırdı.|Kale çizgisinden çıkan top korner! %team% yeni bir fırsat yakaladı.';

  @override
  String get cm_foul =>
      'Hakem düdüğü çaldı, serbest vuruş! Oyun biraz durdu.|Sert bir müdahale! Hakem oyunu durdurdu, oyuncular birbirini ayağa kaldırıyor.|Faul var! %team% serbest vuruşla oyunu yeniden başlatıyor.';

  @override
  String get cm_offside =>
      'Yan hakem bayrağı kaldırdı, ofsayt! Gol sevinci yarım kaldı.|Ofsayt! %team% forveti biraz erken koşmuş.|Bayrak havada! Ofsayt pozisyonu, hakem oyunu durdurdu.';

  @override
  String get cm_wide =>
      '%team% şutu denedi ama top yan direğin yanından dışarı gitti!|Uzaktan sert bir şut! Top kalenin üstünden aşıp tribünlere gitti.|%team% bir fırsat yakaladı ama şut dışarıda kaldı. Az kalsın!';

  @override
  String get cm_keeperSave =>
      'Harika kurtarış! %team% şutu attı ama kaleci son anda topu çıkardı!|Kaleci yere atıldı ve topu çeldi! %team% gole çok yaklaşmıştı.|Direk dibinde nefes kesen bir kurtarış! %team% şaşkın.';

  @override
  String get cm_crowd =>
      'Tribünler coşuyor! Taraftarlar bütün güçleriyle takımlarını destekliyor.|Tribünlerden büyük bir tezahürat yükseliyor, ses yer yerinden oynuyor!|Sahaya bir balon top girdi, herkes gülüyor! Görevliler topu kaptı, oyun devam ediyor.';

  @override
  String get cm_teamGoal =>
      'GOOOL! %team% ağları buldu! Müthiş bir vuruş!|Gol! %team% ağları sarstı, yedek kulübesi ayakta!|GOL! %team% golcüsü bu işi bitirdi, tribünler çılgına döndü!|Top ağlarda! %team% sevinç çığlıkları atıyor!';

  @override
  String get cm_oppGoal =>
      'Gol! %team% rakip ağları buldu. Savunma biraz daha dikkatli olmalı!|Eyvah! %team% golü attı. Tribüne bir an sessizlik çöktü.|%team% buldu! Kaleci elini uzattı ama yetişemedi.|Gol! %team% sevinç içinde, maçın havası değişiyor!';

  @override
  String get cm_introShot =>
      'Top %player% önünde! Kaleye doğru güzel bir açı var, şut zamanı!|Ceza sahasının önünde %player% topla buluştu, kaleci bekliyor!|Fırsat geldi! %player% şut pozisyonuna girdi, herkes nefesini tuttu.';

  @override
  String get cm_introOneOnOne =>
      'Kaleciyle karşı karşıya! %player% kaleciyle baş başa kaldı!|Savunma arkada kaldı, %player% kaleciyle yalnız! Sakin ol, sakin...|Muhteşem bir ara pas ve %player% kaleciyle bire bir!';

  @override
  String get cm_introHeader =>
      'Orta geliyor ve top havada! %player% yükseldi, kafa vuruşuna hazır!|Köşe vuruşundan gelen topa en iyi %player% yükselecek gibi, herkes ona bakıyor!|Kale önü karıştı! Top havada, %player% kafayı vurmaya hazırlanıyor!';

  @override
  String get cm_introFreeKick =>
      'Hakem serbest vuruşu verdi. Topun başında %player% var, duvar dizildi!|Tehlikeli bölgeden serbest vuruş! %player% topun başına geçti, tribünler susuyor.|Duvar kuruldu, kaleci eldivenlerini sıkıyor, %player% koşuya hazırlanıyor!';

  @override
  String get cm_introPenalty =>
      'PENALTI! Hakem noktayı gösterdi, topun başında %player% var!|Büyük an! %player% penaltı noktasında, kaleci çizgide hazır, tüm stat sessiz...|Penaltı kazanıldı! %player% topu noktaya koydu. Şimdi sinirlere hakim olma zamanı!';

  @override
  String get cm_introKeyPass =>
      'Orta sahada top %player% ayağında! Önünde net bir pas fırsatı var, kime verecek?|%player% kafasını kaldırdı, arkadaşları boşta. Hangi yöne pas çıkacak?|Çok iyi bir görüş açısı var, %player% bir şeyler çevirmek istiyor!';

  @override
  String get cm_introDribble =>
      '%player% topu sürüyor, önünde savunmacılar sıralandı! Çalım yapabilecek mi?|Hızlı bir atak! %player% rakiplerin arasından sıyrılmaya çalışıyor.|%player% topu ayağına yapıştırdı, savunma dizilmiş. Çalım zamanı!';

  @override
  String get cm_introTackle =>
      'Rakip hücumda, tehlike büyüyor! %player% son savunmacı, müdahale zamanı!|Hızlı bir kontra atak! %player% topu kapmak için koşuyor!|Rakip forvet ceza sahasına giriyor, %player% topu almaya hazır!';

  @override
  String get cm_playerGoal =>
      'GOOOOL! %player% topu ağlara gönderdi! İnanılmaz bir an!|%player% attı, gol! Tribünler yıkılıyor, takım arkadaşları üstüne atladı!|Muhteşem! %player% kaleciyi çaresiz bıraktı, %team% sevinç içinde!|GOL GOL GOL! %player% harika bir iş çıkardı, adını hepimiz hatırlayacağız!';

  @override
  String get cm_playerAssist =>
      'Harika bir pas! %player% golü hazırladı, asist onun!|%player% öyle bir ara pas verdi ki arkadaşı topu ağlara yolladı, gol!|Ne vizyon! %player% pasıyla golün yolunu açtı.';

  @override
  String get cm_conceded =>
      'Eyvah, rakip golü buldu! %team% bu fırsatı kaçırmadı.|Olmadı... %team% golü attı, ama maç daha bitmedi!|Gol yedik! %team% skoru değiştirdi, hemen toparlanmak lazım.';

  @override
  String get cm_missShot =>
      'Yazık oldu, top ağlara gitmedi! Az kalsın!|Şut kaleye gitmedi, tribünlerden ohh sesleri yükseldi.|Kaleci buna yetişti, olmadı bu sefer! Bir sonraki fırsatta olacak.';

  @override
  String get cm_missPlay =>
      'Pozisyon devam ediyor ama ortada net bir fırsat çıkmadı.|Oyun yine orta alanda, bu atak sonuç vermedi.|Top el değiştirdi, maç hızla devam ediyor!';

  @override
  String get cm_tackleOk =>
      'Harika bir müdahale! %player% tehlikeyi bertaraf etti.|Çok sağlam! %player% araya girdi ve gol fırsatı doğmadan topu kesti.|%player% rakibi durdurdu, savunmada kale gibi!';

  @override
  String get commentaryTitle => 'Canlı Anlatım';

  @override
  String get commentaryLive => 'CANLI';

  @override
  String get commentarySkip => 'Geç';

  @override
  String get commentaryToSummary => 'Maç Özeti';

  @override
  String get commentaryEmpty => 'Maç başlayınca spiker burada konuşacak.';

  @override
  String get ev_pressDraw_title => 'Beraberlik sonrası mikrofon';

  @override
  String get ev_pressDraw_body =>
      'Maç berabere bitti. Muhabir mikrofonu uzattı: \"Bu bir puan mı, yoksa iki puan kaybı mı?\"';

  @override
  String get ev_pressDraw_c0 => 'Bir puan da puandır, ileriye bakıyoruz.';

  @override
  String get ev_pressDraw_r0 => 'Olumlu tavrın soyunma odasını güldürdü.';

  @override
  String get ev_pressDraw_h0 => 'BİR PUAN DA PUAN!';

  @override
  String get ev_pressDraw_c1 =>
      'İkisi de değil! Gelecek maçta üç puanı toptan alacağız!';

  @override
  String get ev_pressDraw_r1 => 'Muhabir güldü, taraftarlar alkışladı.';

  @override
  String get ev_pressDraw_h1 => 'ÜÇ PUAN SÖZÜ VERDİ!';

  @override
  String get ev_pressDraw_c2 =>
      'Hakem düdüğü biraz erken çaldı, bence biz kazanmıştık.';

  @override
  String get ev_pressDraw_r2 => 'Sözlerin manşetlere çıktı.';

  @override
  String get ev_pressDraw_b2 =>
      'Hakem komitesi açıklamandan hoşlanmadı, hoca seni uyardı.';

  @override
  String get ev_pressDraw_h2 => 'HAKEME GÖNDERME!';

  @override
  String get ev_pressFood_title => 'Menüde ne vardı?';

  @override
  String get ev_pressFood_body =>
      'Muhabir mikrofonu uzattı: \"Maçtan önce ne yedin? Tribündeki herkes merak ediyor!\"';

  @override
  String get ev_pressFood_c0 => 'Annemin yaptığı makarna, başka bir şey yemem.';

  @override
  String get ev_pressFood_r0 =>
      'Anneler duyunca duygulandı, makarna satışları arttı.';

  @override
  String get ev_pressFood_h0 => 'MAKARNALI SIR ORTAYA ÇIKTI!';

  @override
  String get ev_pressFood_c1 => 'Sadece iki lahmacun ve on altı bardak çay!';

  @override
  String get ev_pressFood_r1 =>
      'Herkes kahkaha attı, çay üreticileri teşekkür mesajı yolladı.';

  @override
  String get ev_pressFood_b1 =>
      'Beslenme uzmanı duydu, hoca seni masaya oturttu ve listeni değiştirdi.';

  @override
  String get ev_pressFood_h1 => 'ON ALTI BARDAK ÇAY REKORU!';

  @override
  String get ev_pressFood_c2 => 'Şampiyonların yemeği sırdır, söylemem.';

  @override
  String get ev_pressFood_r2 => 'Gizemli cevabın bütün gün konuşuldu.';

  @override
  String get ev_pressFood_h2 => 'SIR YEMEK GÜNDEMDE!';

  @override
  String get ev_pressCelebration_title => 'O gol sevinci!';

  @override
  String get ev_pressCelebration_body =>
      'Muhabir: \"Attığın golden sonra yaptığın sevinç çok eğlenceliydi! Nasıl akıl ettin?\"';

  @override
  String get ev_pressCelebration_c0 => 'Doğaçlama oldu, çok mutluydum.';

  @override
  String get ev_pressCelebration_r0 =>
      'Samimi cevabın taraftarların kalbini kazandı.';

  @override
  String get ev_pressCelebration_h0 => 'SEVİNÇ DOĞAÇLAMAYMIŞ!';

  @override
  String get ev_pressCelebration_c1 =>
      'Aylardır evde aynanın karşısında çalışıyorum!';

  @override
  String get ev_pressCelebration_r1 =>
      'Muhabir gülmekten mikrofonu düşürdü, video herkese yayıldı.';

  @override
  String get ev_pressCelebration_h1 => 'AYNA ÖNÜNDE PROVA!';

  @override
  String get ev_pressCelebration_c2 =>
      'Bir sonraki golde daha büyük bir sürpriz hazırladım.';

  @override
  String get ev_pressCelebration_r2 =>
      'Taraftarlar bir sonraki golü iple çekiyor.';

  @override
  String get ev_pressCelebration_h2 => 'YENİ SEVİNÇ GELİYOR!';

  @override
  String get ev_pressRival_title => 'Rakibe mesaj';

  @override
  String get ev_pressRival_body =>
      'Muhabir: \"Karşı takıma bir mesajın var mı? Canlı yayında hepsi seni dinliyor!\"';

  @override
  String get ev_pressRival_c0 => 'Çok iyi oynadılar, onlara saygı duyuyoruz.';

  @override
  String get ev_pressRival_r0 => 'Centilmenliğin alkış topladı.';

  @override
  String get ev_pressRival_h0 => 'SAYGI DOLU MESAJ!';

  @override
  String get ev_pressRival_c1 =>
      'Bir dahaki sefere sandviçlerimizi paylaşırız ama topu paylaşmayız!';

  @override
  String get ev_pressRival_r1 =>
      'Herkes güldü, rakip takım da esprili bir cevap verdi.';

  @override
  String get ev_pressRival_h1 => 'SANDVİÇ PAYLAŞILIR, TOP PAYLAŞILMAZ!';

  @override
  String get ev_pressRival_c2 => 'Gelecek maça daha hazırlıklı gelsinler.';

  @override
  String get ev_pressRival_r2 => 'Meydan okuman gündem oldu.';

  @override
  String get ev_pressRival_b2 =>
      'Rakip kulüp sert bir açıklama yaptı, hoca seni uyardı.';

  @override
  String get ev_pressRival_h2 => 'MEYDAN OKUMA!';

  @override
  String get ev_pressMascot_title => 'Maskot sorusu';

  @override
  String get ev_pressMascot_body =>
      'Muhabir: \"Takımın maskotu seni çok seviyor. Sen onu seviyor musun?\"';

  @override
  String get ev_pressMascot_c0 =>
      'Maskotumuz benim en iyi arkadaşım, ona sarıldım bile.';

  @override
  String get ev_pressMascot_r0 =>
      'Maskot sevinçten dans etti, çocuklar bayıldı.';

  @override
  String get ev_pressMascot_h0 => 'MASKOTA BÜYÜK SEVGİ!';

  @override
  String get ev_pressMascot_c1 => 'Kostümün içinde kim var, hâlâ çözemedim!';

  @override
  String get ev_pressMascot_r1 => 'Maskot kostümün içinden kahkaha attı.';

  @override
  String get ev_pressMascot_h1 => 'KOSTÜMÜN İÇİNDEKİ GİZEM!';

  @override
  String get ev_pressMascot_c2 =>
      'Maskot sahaya girmese iyi olur, topu kapıp kaçıyor!';

  @override
  String get ev_pressMascot_r2 =>
      'Maskot intikam dansı yaptı, tribünler gülmekten kırıldı.';

  @override
  String get ev_pressMascot_h2 => 'MASKOT TOP ÇALIYOR!';

  @override
  String get ev_pressPower_title => 'Süper güç sorusu';

  @override
  String get ev_pressPower_body =>
      'Muhabir: \"Bir süper gücün olsaydı ne olmasını isterdin?\"';

  @override
  String get ev_pressPower_c0 =>
      'Işık hızında koşmak! Rakipler beni göremezdi.';

  @override
  String get ev_pressPower_r0 => 'Hızlı koşan oyuncu başlığı seninle anıldı.';

  @override
  String get ev_pressPower_h0 => 'IŞIK HIZINDA OYUNCU!';

  @override
  String get ev_pressPower_c1 =>
      'Görünmez olmak, böylece hakem faul çaldırırken beni bulamazdı.';

  @override
  String get ev_pressPower_r1 => 'Hakem de duyunca gülümsedi.';

  @override
  String get ev_pressPower_h1 => 'GÖRÜNMEZ FUTBOLCU!';

  @override
  String get ev_pressPower_c2 =>
      'Zamanı durdurmak ve her maçı doksan saat oynamak!';

  @override
  String get ev_pressPower_r2 =>
      'Takım arkadaşların yorulmaktan şikayet etti ama taraftarlar güldü.';

  @override
  String get ev_pressPower_h2 => 'DOKSAN SAATLİK MAÇ!';

  @override
  String get ev_pressKids_title => 'Küçük taraftarlara mesaj';

  @override
  String get ev_pressKids_body =>
      'Muhabir: \"Seni izleyen çocuklara ne söylemek istersin?\"';

  @override
  String get ev_pressKids_c0 =>
      'Çok çalışın, pes etmeyin ve derslerinizi de ihmal etmeyin!';

  @override
  String get ev_pressKids_r0 =>
      'Öğretmenler teşekkür etti, aileler sana hayran kaldı.';

  @override
  String get ev_pressKids_h0 => 'ÇOCUKLARA ALTIN ÖĞÜT!';

  @override
  String get ev_pressKids_c1 =>
      'Sebzelerinizi yiyin, ben bu yüzden bu kadar hızlıyım!';

  @override
  String get ev_pressKids_r1 =>
      'Anneler seni çok sevdi, çocuklar brokoliyi sevmeye başladı.';

  @override
  String get ev_pressKids_h1 => 'BROKOLİ HIZLANDIRIR!';

  @override
  String get ev_pressKids_c2 => 'Futbol oynamak için önce en çok eğlenin!';

  @override
  String get ev_pressKids_r2 => 'Küçük taraftarlar seni tezahüratla karşıladı.';

  @override
  String get ev_pressKids_h2 => 'ÖNCE EĞLEN!';

  @override
  String get ev_pressWin_h0 => 'TAKIM RUHU KAZANDI!';

  @override
  String get ev_pressWin_h1 => 'GÜNÜN KAHRAMANI KONUŞTU!';

  @override
  String get ev_pressWin_h2 => 'RAKİBE SERT MESAJ!';

  @override
  String get ev_pressLoss_h0 => 'TOPARLANMA SÖZÜ!';

  @override
  String get ev_pressLoss_h1 => 'HAKEM TARTIŞMASI ALEVLENDİ!';

  @override
  String get ev_pressLoss_h2 => 'SUSKUNLUK GÜNDEM OLDU!';

  @override
  String get ev_pressStar_h0 => 'MÜTEVAZI YILDIZ!';

  @override
  String get ev_pressStar_h1 => 'BÜYÜK KULÜPLER İZLİYOR!';

  @override
  String get ev_pressStar_h2 => 'HOCADAN TAM NOT!';

  @override
  String get ev_pressPoor_h0 => 'DÜRÜST İTİRAF!';

  @override
  String get ev_pressPoor_h1 => 'MEYDAN OKUDU!';

  @override
  String get ev_pressPoor_h2 => 'KISA KESTİ, MERAK ARTTI!';

  @override
  String get ev_pressBench_h0 => 'SABIR VE UMUT!';

  @override
  String get ev_pressBench_h1 => 'DAHA FAZLA SÜRE İSTİYOR!';

  @override
  String get ev_pressBench_h2 => 'ÖNCE TAKIM!';

  @override
  String get tone_humble => 'Mütevazı';

  @override
  String get tone_funny => 'Komik';

  @override
  String get tone_cool => 'Havalı';

  @override
  String get tone_harsh => 'Sert';

  @override
  String get tone_honest => 'Dürüst';

  @override
  String get tone_silent => 'Sessiz';

  @override
  String get interviewReporter => 'Muhabir';

  @override
  String get interviewPickHint => 'Cevabını seç';

  @override
  String get interviewNewspaper => 'GÜNÜN GAZETESİ';

  @override
  String get interviewBackfireHeadline => 'ŞOK AÇIKLAMA!';

  @override
  String get summaryInterviewNow => 'Mikrofonlar seni bekliyor: röportaja git';

  @override
  String get sm_post_win =>
      '%opponent% karşısında %score%! Takım harikaydı, %player% de sahadaydı!|Üç puan cepte! %score% biten maçta tribünler coştu.|%score% galibiyet! Bu takımla gurur duyuyoruz.|Rakip %opponent% mağlup oldu, keyfimiz yerinde! Skor %score%.';

  @override
  String get sm_post_loss =>
      '%opponent% maçı %score% bitti. Moralimizi bozmayalım, devam!|Bugün olmadı: %score%. Ama bu takım toparlanır.|%score%... Zor bir akşamdı, taraftar yine de yanımızdaydı.|Maç sonu skor %score%. Hocadan açıklama bekliyoruz.';

  @override
  String get sm_post_draw =>
      '%score% berabere! %opponent% karşısında bir puan aldık.|Eşitlik bozulmadı: %score%. Ne kazandık ne kaybettik.|Dolu dolu bir maç, skor %score%. Bir puana razıyız.';

  @override
  String get sm_post_scorer =>
      '%player% bu akşam %goals% golle parladı! %opponent% maçı %score% bitti.|Gol sesleri geliyor! %player% ağları havalandırdı, skor %score%.|Golcümüz %player% yine yaptı yapacağını. Attığı gol sayısı: %goals%!';

  @override
  String get sm_post_hatTrick =>
      'HAT-TRICK! %player% bu akşam %goals% gol attı, topu cebine koydu!|%goals% gol birden! %player% bu maçı kimse unutmayacak.|Maçın adamı belli: %player%! %goals% gol, skor %score%.';

  @override
  String get sm_post_star =>
      '%player% bu maçta bambaşkaydı! Herkes onu konuşuyor.|Bugünün yıldızı %player%. Onu izlemek bir ziyafetti.|Maç puanına bakın! %player% neredeyse tam not aldı, %opponent% savunması şaşırdı.';

  @override
  String get sm_post_flop =>
      '%player% için zor bir akşamdı, ama yarın yeni bir gün.|Bugün %player% için gün değildi. Toparlanır, eminiz.|Kötü bir maç herkesin başına gelir. %player%, başını dik tut!';

  @override
  String get sm_post_benched =>
      '%player% bu hafta yedek kaldı. Sabırla bekliyor, şansı gelecek.|Kadroda yoktu ama taraftarlar %player% için tezahürat yapıyor.|Yedek kulübesindeki %player% de bu takımın parçası!';

  @override
  String get sm_post_injury =>
      'Geçmiş olsun %player%! %type%, tahmini %weeks% hafta sahalardan uzak.|Kulüp açıklaması: %player% sakatlandı (%type%). Bekleme süresi %weeks% hafta.|Hızlı iyileş şampiyon! %weeks% hafta sonra sahada görüşürüz.';

  @override
  String get sm_post_signed =>
      'Resmen açıklandı: %player% artık %club% formasını giyiyor!|Yeni takımı belli oldu: %club%! Hoş geldin %player%.|%club% ailesine hoş geldin %player%! Yeni dönem başlıyor.';

  @override
  String get sm_post_interview =>
      'MANŞET: %headline%|Gazetede bugün: %headline%|Günün gündemi bu: %headline%';

  @override
  String get sm_post_achievement =>
      'Yeni rozet! %player% \"%ach%\" başarımının sahibi oldu.|Bir başarım daha: %ach%! Tebrikler %player%.|Kupa dolabına yeni bir rozet eklendi: %ach%.';

  @override
  String get sm_post_national =>
      'Milli formayla %tournament%: %player% için gözler ekranda!|%player% milli takımda! %tournament% yolunda herkes onu konuşuyor.|Bayrak dalgalanıyor! %tournament% için gözler %player% üzerinde.';

  @override
  String get sm_post_ownThanks =>
      'Bu destek için hepinize teşekkürler! Sizin için oynuyorum.|Tribünlere büyük teşekkür, siz olmasanız bu oyun olmazdı!|Aileme, takım arkadaşlarıma ve size teşekkürler. Yola devam!';

  @override
  String get sm_post_ownFunny =>
      'Soyunma odasında en komik kim? Cevap: kesinlikle ben!|Antrenmanda topu kaleye atamadım ama kameraya gülümsemeyi başardım.|Bugünün sorusu: top mu benden kaçıyor, ben mi toptan?';

  @override
  String get sm_post_ownTraining =>
      'Sabah antrenmanı tamam! Çalışmaya devam.|Bugün ekstra koşu yaptım, yarın daha güçlüyüm!|Antrenman sahasından selamlar. Sezon uzun, hazırlıklıyız.';

  @override
  String get sm_post_ownSpicy =>
      'Bu sezon kimse beni durduramaz, yazın bir kenara!|Rakipler hazır olsun, bu sezon bizim sezonumuz!|Eleştirenlere cevabım sahada: izleyin ve görün.';

  @override
  String get sm_names_fan =>
      'Tribün Kartalı|Gece Taraftarı|Golcü Kemal|Mahalle Maçı|Ceren Futbol Aşkı|Kale Arkası|Efe Tribün|Sarı Şal|Süper Teyze|Dev Davul|Miniklerin Kralı|Pas Ustası Selin|Forma Koleksiyoncusu|Deplasman Dayısı|Çimen Kokusu';

  @override
  String get sm_names_journalist =>
      'Gündem Spor|Saha Kenarı|Son Düdük Gazetesi|Haftanın Maçı|Spor Bülteni|Kulis Raporu';

  @override
  String get sm_names_teammate =>
      'Kaptan Ali|Kaleci Murat|Orta Saha Emre|Stoper Barış';

  @override
  String get sm_names_club => 'Kulüp Resmi Hesabı|Kulüp Medya|Basın Bürosu';

  @override
  String get sm_names_meme =>
      'Futbol Karikatür|Gülen Top|Tribün Mizah|Ofsayt Espri|Kırmızı Kart Komedi';

  @override
  String get sm_names_family => 'Annem|Babam|Kardeşim|Dedem';

  @override
  String get sm_name_you => 'Sen';

  @override
  String get sm_names_commenter =>
      'ahmet_k|futbolsever34|zeynepin_golleri|tribun_baba|kaleci_can|minik_taraftar|golkralı_ege|mahalle_hakemi|forma_bey|derbi_delisi|sari_lacivert_2|taktik_hoca|pasci_deniz|kornerci_murat|top_tutan_ali|ofsayt_yok|bol_gollu|calim_atan|efe_futbol|gece_maci';

  @override
  String get sm_comment_praise =>
      'Harikasın %player%!|Aferin sana, böyle devam!|Bu takımın en iyisi sensin.|Bravo, tribünler seninle.|Bugün şov yaptın.|Gurur duyduk, tebrikler!|Efsane gibi oynadın.|Aynen böyle devam şampiyon.|Seni izlemek bir zevk.|Sana güveniyoruz!';

  @override
  String get sm_comment_joke =>
      'Annem seni televizyondan görünce ağladı, sevinçten tabii.|Topu bana da pas versen!|Bu gol değil, sanat eseri.|Menajerin sanırım zam isteyecek.|Ben de sahaya çıksam bu kadar iyi olurdum. Belki.|Çay içerken izledim, çayı döktüm.|Kalecinin yüzü görülmeye değerdi.|Mahalle maçında da böyle oynasana.|Poster yaptırıyorum, odama asacağım.|Bu hızla giderse kendi marka ayakkabısı çıkar.';

  @override
  String get sm_comment_jeer =>
      'Bugün çok kötüydün, ne oldu?|Daha çok çalışman lazım.|Bu performansla olmaz kardeşim.|Yedek kulübesi seni bekliyor.|Beklentim bu değildi.|Boş vaatler yeter, sahada göster.|Bu maç böyle oynanmaz.|Abartılmış bir oyuncu bence.|Topu hiç görmedi sanki.|Biraz daha gayret!';

  @override
  String get sm_comment_support =>
      'Geçmiş olsun, hızlı iyileş!|Toparlanırsın, biz buradayız.|Bir maçla bir şey olmaz, başını dik tut.|Moralini bozma, güçlü dönersin.|Sabret, şansın gelecek.|Herkese olur, sen yine de en iyisisin.|Seni her zaman destekleriz.|Dinlen, kendine iyi bak.|Bu da geçer, yola devam.|Takım seninle.';

  @override
  String get feedSegmentEvents => 'Gelişmeler';

  @override
  String get feedSegmentFeed => 'Akış';

  @override
  String get feedFollowers => 'takipçi';

  @override
  String get feedPostCount => 'paylaşım';

  @override
  String get feedPostButton => 'Paylaşım yap';

  @override
  String get feedPostedThisWeek => 'Bu hafta paylaştın, gelecek hafta yine gel';

  @override
  String get feedSheetTitle => 'Ne paylaşmak istersin?';

  @override
  String get feedOwnTitle_ownThanks => 'Teşekkür mesajı';

  @override
  String get feedOwnDesc_ownThanks => 'Güvenli: taraftarlar ve aile sever.';

  @override
  String get feedOwnTitle_ownFunny => 'Komik bir paylaşım';

  @override
  String get feedOwnDesc_ownFunny =>
      'Çok beğeni alır ama hoca bazen şakayı sevmez.';

  @override
  String get feedOwnTitle_ownTraining => 'Antrenman fotoğrafı';

  @override
  String get feedOwnDesc_ownTraining => 'Güvenli: hoca çalışkanlığını görür.';

  @override
  String get feedOwnTitle_ownSpicy => 'İddialı çıkış';

  @override
  String get feedOwnDesc_ownSpicy =>
      'Çok takipçi kazandırır ama büyük risk taşır.';

  @override
  String get feedPostDone => 'Paylaşımın yayında! Akışa bak.';

  @override
  String get feedPostBackfired => 'Ters tepti! Yorumlar pek olumlu değil.';

  @override
  String get feedEmpty => 'Henüz paylaşım yok. Maç oynadıkça akış canlanır.';

  @override
  String get feedYourAccount => 'Senin hesabın';

  @override
  String get feedSource_fan => 'Taraftar';

  @override
  String get feedSource_journalist => 'Gazeteci';

  @override
  String get feedSource_teammate => 'Takım arkadaşı';

  @override
  String get feedSource_club => 'Kulüp';

  @override
  String get feedSource_meme => 'Mizah sayfası';

  @override
  String get feedSource_family => 'Aile';

  @override
  String get feedSource_you => 'Sen';

  @override
  String get feedShowComments => 'Yorumları göster';

  @override
  String get feedHideComments => 'Yorumları gizle';

  @override
  String get feedCountThousand => 'B';

  @override
  String get feedCountMillion => 'Mn';

  @override
  String get sm_post_shopping =>
      '%player% yeni bir şey aldı: %item%! Herkes bunu konuşuyor.|Yeni %item%: futbolcunun keyfi yerinde!|Gösteriş mi yatırım mı? %player% %item% aldı.';

  @override
  String get sm_post_donation =>
      '%player% yardım kuruluşuna bağış yaptı. Tebrikler!|Güzel yürekli futbolcu: bağış haberi gündemde.|Sahada da sahanın dışında da örnek: %player% bağış yaptı.';

  @override
  String get sm_post_betFined =>
      'Bahis skandalı! Kulüp %player% için ceza kararı verdi.|Bahis düşkünlüğü gündemde: %player% yine konuşuluyor.|Futbolcu uyarıldı: bahis oynamak zarar verir.';

  @override
  String get prop_watch => 'Saat';

  @override
  String get prop_car => 'Araba';

  @override
  String get prop_flat => 'Daire';

  @override
  String get prop_villa => 'Villa';

  @override
  String get prop_yacht => 'Yat';

  @override
  String get propDesc_watch => 'Küçük bir keyif: moral biraz artar.';

  @override
  String get propDesc_car => 'Moral artar, taraftar ve medya fark eder.';

  @override
  String get propDesc_flat => 'Aile çok mutlu olur, moral artar.';

  @override
  String get propDesc_villa => 'Aile, moral ve medya için büyük adım.';

  @override
  String get propDesc_yacht =>
      'Büyük gösteriş: medya konuşur, ama takım arkadaşları kıskanabilir.';

  @override
  String get donation_charity => 'Yardım kuruluşuna bağış';

  @override
  String get donationDesc_charity => 'Taraftar ve medya sever.';

  @override
  String get donation_familyGift => 'Aileye hediye';

  @override
  String get donationDesc_familyGift => 'Aile çok mutlu olur.';

  @override
  String get newsBetWarned => 'Kulüp bahis alışkanlığın yüzünden seni uyardı';

  @override
  String get newsBetFined => 'Bahis alışkanlığın yüzünden para cezası aldın';

  @override
  String get newsBetSuspended => 'Bahis yüzünden kadro dışı bırakıldın';

  @override
  String eventBetWon(String amount) {
    return 'Bahislerinden $amount kazandın';
  }

  @override
  String eventBetLost(String amount) {
    return 'Bahislerinde $amount kaybettin';
  }

  @override
  String get eventBetWarning =>
      'Kulüp bahis alışkanlığın konusunda seni uyardı';

  @override
  String eventBetFined(String amount) {
    return 'Bahis cezası: kulüp $amount kesti';
  }

  @override
  String eventBetSuspended(int weeks) {
    return 'Bahis yüzünden $weeks hafta kadro dışı kaldın ve yardım programına alındın';
  }

  @override
  String get eventSuspended => 'Kadro dışısın: bahis cezan sürüyor';

  @override
  String get suspendedThisWeek => 'Bahis cezası: bu hafta kadro dışısın';

  @override
  String get spendTitle => 'Harcama ve Şans Köşesi';

  @override
  String get spendCardHint => 'Mülk al, bağış yap, şansını dene';

  @override
  String spendCardOwned(String count, String level) {
    return '$count mülk · alışkanlık: $level';
  }

  @override
  String get spendIntro =>
      'Paranı akıllıca harca. Şans köşesi tamamen kurgusaldır; kazanç garantisi yoktur.';

  @override
  String get spendPropertiesTitle => 'Mülkler';

  @override
  String get spendOwned => 'Sahipsin';

  @override
  String get spendBuy => 'Satın al';

  @override
  String get spendBought => 'Satın aldın!';

  @override
  String get spendDonationsTitle => 'Bağış ve hediye';

  @override
  String get spendDonationWait => 'Biraz bekle: üst üste bağış yapamazsın.';

  @override
  String get spendDonate => 'Yap';

  @override
  String get spendDonated => 'Teşekkürler! İyiliğin duyuldu.';

  @override
  String get betTitle => 'Şans Köşesi';

  @override
  String get betRules =>
      'Kurgusal oyun parasıyla oynanır. Oranlar bürodan gelir, uzun vadede kaybedersin. Kendi takımının maçına bahis yok. Çok bahis oynarsan ceza alırsın.';

  @override
  String get betCouponTitle => 'Haftanın kuponu';

  @override
  String get betNoCoupon =>
      'Bu hafta kupon yok: lig maçı haftası değil ya da kulübün yok.';

  @override
  String get betStakeLabel => 'Bahis tutarı';

  @override
  String get betPick_home => 'Ev sahibi';

  @override
  String get betPick_draw => 'Beraberlik';

  @override
  String get betPick_away => 'Deplasman';

  @override
  String betPlaced(String odds) {
    return 'Bahis yapıldı: $odds oranla';
  }

  @override
  String get betAlready => 'Bu maça bahis yaptın';

  @override
  String get betYourBets => 'Bu haftaki bahislerin';

  @override
  String betBetLine(String pick, String stake, String odds) {
    return '$pick · $stake · oran $odds';
  }

  @override
  String get betResultsTitle => 'Son sonuçlar';

  @override
  String get betNoResults => 'Henüz sonuçlanan bahsin yok.';

  @override
  String get betWon => 'Kazandı';

  @override
  String get betLost => 'Kaybetti';

  @override
  String betResultLine(String pick, String stake, String payout) {
    return '$pick · yatırılan $stake · geri ödeme $payout';
  }

  @override
  String get habitTitle => 'Şans alışkanlığı';

  @override
  String get habitLevel_0 => 'Sakin';

  @override
  String get habitLevel_1 => 'Dikkat';

  @override
  String get habitLevel_2 => 'Tehlikeli';

  @override
  String get habitLevel_3 => 'Kritik';

  @override
  String get habitHint_0 => 'Şans köşesine ara sıra uğramak sorun değil.';

  @override
  String get habitHint_1 => 'Kulüp seni izliyor. Biraz yavaşla!';

  @override
  String get habitHint_2 => 'Para cezası kapıda. Bahsi bırak!';

  @override
  String get habitHint_3 => 'Kadro dışı kalma riski var!';

  @override
  String habitSuspended(int weeks) {
    return 'Kadro dışısın: $weeks hafta';
  }

  @override
  String habitStats(String staked, String won, String fines) {
    return 'Yatırılan: $staked · Kazanılan: $won · Cezalar: $fines';
  }
}
