import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('tr')];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Son Düdük'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In tr, this message translates to:
  /// **'16 yaşında başla, dünya yıldızı ol.'**
  String get tagline;

  /// No description provided for @menuTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kariyer Seç'**
  String get menuTitle;

  /// No description provided for @slotTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt {number}'**
  String slotTitle(int number);

  /// No description provided for @slotEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Boş — yeni kariyer başlat'**
  String get slotEmpty;

  /// No description provided for @slotCorrupt.
  ///
  /// In tr, this message translates to:
  /// **'Bozuk kayıt'**
  String get slotCorrupt;

  /// No description provided for @slotSummary.
  ///
  /// In tr, this message translates to:
  /// **'{age} yaş · {position} · Genel {overall}'**
  String slotSummary(int age, String position, int overall);

  /// No description provided for @deleteSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydı sil'**
  String get deleteSave;

  /// No description provided for @deleteSaveConfirm.
  ///
  /// In tr, this message translates to:
  /// **'{name} kariyeri kalıcı olarak silinecek. Bu işlem geri alınamaz.'**
  String deleteSaveConfirm(String name);

  /// No description provided for @deleteCorruptConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bozuk kayıt silinecek. Bu işlem geri alınamaz.'**
  String get deleteCorruptConfirm;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @simulatorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Lig Simülatörü'**
  String get simulatorTitle;

  /// No description provided for @simulatorSeed.
  ///
  /// In tr, this message translates to:
  /// **'Seed (boş = rastgele)'**
  String get simulatorSeed;

  /// No description provided for @simulatorSeedInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Seed bir tam sayı olmalı.'**
  String get simulatorSeedInvalid;

  /// No description provided for @simulateSeason.
  ///
  /// In tr, this message translates to:
  /// **'Sezonu Simüle Et'**
  String get simulateSeason;

  /// No description provided for @simulatorHint.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen ligin 34 haftalık sezonunu saf Dart motoruyla oynatır.'**
  String get simulatorHint;

  /// No description provided for @leagueTier1.
  ///
  /// In tr, this message translates to:
  /// **'Ulusal Lig'**
  String get leagueTier1;

  /// No description provided for @leagueTier2.
  ///
  /// In tr, this message translates to:
  /// **'Birinci Lig'**
  String get leagueTier2;

  /// No description provided for @leagueTier3.
  ///
  /// In tr, this message translates to:
  /// **'İkinci Lig'**
  String get leagueTier3;

  /// No description provided for @leagueTier4.
  ///
  /// In tr, this message translates to:
  /// **'Üçüncü Lig'**
  String get leagueTier4;

  /// No description provided for @leagueTier5.
  ///
  /// In tr, this message translates to:
  /// **'Amatör Lig'**
  String get leagueTier5;

  /// No description provided for @colPlayed.
  ///
  /// In tr, this message translates to:
  /// **'O'**
  String get colPlayed;

  /// No description provided for @colWon.
  ///
  /// In tr, this message translates to:
  /// **'G'**
  String get colWon;

  /// No description provided for @colDrawn.
  ///
  /// In tr, this message translates to:
  /// **'B'**
  String get colDrawn;

  /// No description provided for @colLost.
  ///
  /// In tr, this message translates to:
  /// **'M'**
  String get colLost;

  /// No description provided for @colGoalsFor.
  ///
  /// In tr, this message translates to:
  /// **'A'**
  String get colGoalsFor;

  /// No description provided for @colGoalsAgainst.
  ///
  /// In tr, this message translates to:
  /// **'Y'**
  String get colGoalsAgainst;

  /// No description provided for @colGoalDiff.
  ///
  /// In tr, this message translates to:
  /// **'Av'**
  String get colGoalDiff;

  /// No description provided for @colPoints.
  ///
  /// In tr, this message translates to:
  /// **'P'**
  String get colPoints;

  /// No description provided for @colTeam.
  ///
  /// In tr, this message translates to:
  /// **'Takım'**
  String get colTeam;

  /// No description provided for @simulatorStats.
  ///
  /// In tr, this message translates to:
  /// **'{matches} maç · maç başı {goals} gol · ev sahibi galibiyeti %{homeWin} · beraberlik %{draw}'**
  String simulatorStats(int matches, String goals, String homeWin, String draw);

  /// No description provided for @createTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Oyuncu'**
  String get createTitle;

  /// No description provided for @nameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu adı'**
  String get nameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bir isim gir.'**
  String get nameRequired;

  /// No description provided for @nameTooLong.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 24 karakter.'**
  String get nameTooLong;

  /// No description provided for @birthplaceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Doğum yeri'**
  String get birthplaceLabel;

  /// No description provided for @positionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mevki'**
  String get positionLabel;

  /// No description provided for @footLabel.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü ayak'**
  String get footLabel;

  /// No description provided for @appearanceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get appearanceLabel;

  /// No description provided for @skinLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ten'**
  String get skinLabel;

  /// No description provided for @hairLabel.
  ///
  /// In tr, this message translates to:
  /// **'Saç'**
  String get hairLabel;

  /// No description provided for @kitLabel.
  ///
  /// In tr, this message translates to:
  /// **'Forma'**
  String get kitLabel;

  /// No description provided for @startCareer.
  ///
  /// In tr, this message translates to:
  /// **'Kariyere Başla'**
  String get startCareer;

  /// No description provided for @position_forward.
  ///
  /// In tr, this message translates to:
  /// **'Forvet'**
  String get position_forward;

  /// No description provided for @position_winger.
  ///
  /// In tr, this message translates to:
  /// **'Kanat'**
  String get position_winger;

  /// No description provided for @position_attackingMid.
  ///
  /// In tr, this message translates to:
  /// **'Ofansif Orta Saha'**
  String get position_attackingMid;

  /// No description provided for @position_centralMid.
  ///
  /// In tr, this message translates to:
  /// **'Merkez Orta Saha'**
  String get position_centralMid;

  /// No description provided for @position_defender.
  ///
  /// In tr, this message translates to:
  /// **'Defans'**
  String get position_defender;

  /// No description provided for @foot_left.
  ///
  /// In tr, this message translates to:
  /// **'Sol'**
  String get foot_left;

  /// No description provided for @foot_right.
  ///
  /// In tr, this message translates to:
  /// **'Sağ'**
  String get foot_right;

  /// No description provided for @foot_both.
  ///
  /// In tr, this message translates to:
  /// **'Her İkisi'**
  String get foot_both;

  /// No description provided for @attr_shooting.
  ///
  /// In tr, this message translates to:
  /// **'Şut'**
  String get attr_shooting;

  /// No description provided for @attr_finesse.
  ///
  /// In tr, this message translates to:
  /// **'Plase'**
  String get attr_finesse;

  /// No description provided for @attr_passing.
  ///
  /// In tr, this message translates to:
  /// **'Pas'**
  String get attr_passing;

  /// No description provided for @attr_vision.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon'**
  String get attr_vision;

  /// No description provided for @attr_dribbling.
  ///
  /// In tr, this message translates to:
  /// **'Dribling'**
  String get attr_dribbling;

  /// No description provided for @attr_pace.
  ///
  /// In tr, this message translates to:
  /// **'Hız'**
  String get attr_pace;

  /// No description provided for @attr_agility.
  ///
  /// In tr, this message translates to:
  /// **'Çabukluk'**
  String get attr_agility;

  /// No description provided for @attr_strength.
  ///
  /// In tr, this message translates to:
  /// **'Güç'**
  String get attr_strength;

  /// No description provided for @attr_stamina.
  ///
  /// In tr, this message translates to:
  /// **'Dayanıklılık'**
  String get attr_stamina;

  /// No description provided for @attr_defending.
  ///
  /// In tr, this message translates to:
  /// **'Defans'**
  String get attr_defending;

  /// No description provided for @attr_ballControl.
  ///
  /// In tr, this message translates to:
  /// **'Top Kontrolü'**
  String get attr_ballControl;

  /// No description provided for @attr_heading.
  ///
  /// In tr, this message translates to:
  /// **'Kafa Vuruşu'**
  String get attr_heading;

  /// No description provided for @attr_setPieces.
  ///
  /// In tr, this message translates to:
  /// **'Duran Top'**
  String get attr_setPieces;

  /// No description provided for @attr_composure.
  ///
  /// In tr, this message translates to:
  /// **'Sakinlik'**
  String get attr_composure;

  /// No description provided for @attr_charisma.
  ///
  /// In tr, this message translates to:
  /// **'Karizma'**
  String get attr_charisma;

  /// No description provided for @kind_physical.
  ///
  /// In tr, this message translates to:
  /// **'Fiziksel'**
  String get kind_physical;

  /// No description provided for @kind_technical.
  ///
  /// In tr, this message translates to:
  /// **'Teknik'**
  String get kind_technical;

  /// No description provided for @kind_mental.
  ///
  /// In tr, this message translates to:
  /// **'Zihinsel'**
  String get kind_mental;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// No description provided for @navTraining.
  ///
  /// In tr, this message translates to:
  /// **'Antrenman'**
  String get navTraining;

  /// No description provided for @navClub.
  ///
  /// In tr, this message translates to:
  /// **'Kulüp'**
  String get navClub;

  /// No description provided for @navSocial.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal'**
  String get navSocial;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @comingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölüm yakında geliyor.'**
  String get comingSoon;

  /// No description provided for @overallLabel.
  ///
  /// In tr, this message translates to:
  /// **'Genel Güç'**
  String get overallLabel;

  /// No description provided for @ageYears.
  ///
  /// In tr, this message translates to:
  /// **'{age} yaş'**
  String ageYears(int age);

  /// No description provided for @seasonWeek.
  ///
  /// In tr, this message translates to:
  /// **'Sezon {season} · Hafta {week}'**
  String seasonWeek(int season, int week);

  /// No description provided for @nextMatch.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki maç'**
  String get nextMatch;

  /// No description provided for @nextMatchPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Fikstür henüz hazır değil.'**
  String get nextMatchPlaceholder;

  /// No description provided for @attributesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nitelikler'**
  String get attributesTitle;

  /// No description provided for @backToMenu.
  ///
  /// In tr, this message translates to:
  /// **'Ana menüye dön'**
  String get backToMenu;

  /// No description provided for @birthplaceValue.
  ///
  /// In tr, this message translates to:
  /// **'Doğum yeri: {city}'**
  String birthplaceValue(String city);

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @soundLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ses'**
  String get soundLabel;

  /// No description provided for @vibrationLabel.
  ///
  /// In tr, this message translates to:
  /// **'Titreşim'**
  String get vibrationLabel;

  /// No description provided for @difficultyLabel.
  ///
  /// In tr, this message translates to:
  /// **'Zorluk'**
  String get difficultyLabel;

  /// No description provided for @difficultyHint.
  ///
  /// In tr, this message translates to:
  /// **'Zorluk yalnızca mini oyun toleransını ve rakip gücünü etkiler.'**
  String get difficultyHint;

  /// No description provided for @difficulty_easy.
  ///
  /// In tr, this message translates to:
  /// **'Kolay'**
  String get difficulty_easy;

  /// No description provided for @difficulty_normal.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get difficulty_normal;

  /// No description provided for @difficulty_hard.
  ///
  /// In tr, this message translates to:
  /// **'Zor'**
  String get difficulty_hard;

  /// No description provided for @languageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get languageLabel;

  /// No description provided for @languageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @deleteAllSaves.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kayıtları sil'**
  String get deleteAllSaves;

  /// No description provided for @deleteAllConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Üç slottaki tüm kariyerler kalıcı olarak silinecek. Bu işlem geri alınamaz.'**
  String get deleteAllConfirm;

  /// No description provided for @allSavesDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kayıtlar silindi.'**
  String get allSavesDeleted;

  /// No description provided for @matchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hazırlık Maçı'**
  String get matchTitle;

  /// No description provided for @matchPlay.
  ///
  /// In tr, this message translates to:
  /// **'Maçı Oyna'**
  String get matchPlay;

  /// No description provided for @matchStart.
  ///
  /// In tr, this message translates to:
  /// **'Maça Başla'**
  String get matchStart;

  /// No description provided for @matchQuickSim.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Simüle Et'**
  String get matchQuickSim;

  /// No description provided for @matchQuickSimRest.
  ///
  /// In tr, this message translates to:
  /// **'Kalanı Hızlı Simüle Et'**
  String get matchQuickSimRest;

  /// No description provided for @matchYourTeam.
  ///
  /// In tr, this message translates to:
  /// **'Takımın: {team}'**
  String matchYourTeam(String team);

  /// No description provided for @matchVersus.
  ///
  /// In tr, this message translates to:
  /// **'{home} - {away}'**
  String matchVersus(String home, String away);

  /// No description provided for @matchMinute.
  ///
  /// In tr, this message translates to:
  /// **'{minute}. dakika'**
  String matchMinute(int minute);

  /// No description provided for @momentTitle_shot.
  ///
  /// In tr, this message translates to:
  /// **'Şut'**
  String get momentTitle_shot;

  /// No description provided for @momentIntro_shot.
  ///
  /// In tr, this message translates to:
  /// **'Top ayağına geldi, kaleci karşında. Zamanı tut ve vur!'**
  String get momentIntro_shot;

  /// No description provided for @momentTitle_oneOnOne.
  ///
  /// In tr, this message translates to:
  /// **'Bire Bir'**
  String get momentTitle_oneOnOne;

  /// No description provided for @momentIntro_oneOnOne.
  ///
  /// In tr, this message translates to:
  /// **'Kalecinin karşısında tek başınasın!'**
  String get momentIntro_oneOnOne;

  /// No description provided for @momentTitle_header.
  ///
  /// In tr, this message translates to:
  /// **'Kafa Vuruşu'**
  String get momentTitle_header;

  /// No description provided for @momentIntro_header.
  ///
  /// In tr, this message translates to:
  /// **'Ortayı yükselen sen oldun, top havada.'**
  String get momentIntro_header;

  /// No description provided for @momentTitle_freeKick.
  ///
  /// In tr, this message translates to:
  /// **'Serbest Vuruş'**
  String get momentTitle_freeKick;

  /// No description provided for @momentIntro_freeKick.
  ///
  /// In tr, this message translates to:
  /// **'Ceza sahası önünde serbest vuruş kazanıldı.'**
  String get momentIntro_freeKick;

  /// No description provided for @momentTitle_penalty.
  ///
  /// In tr, this message translates to:
  /// **'Penaltı'**
  String get momentTitle_penalty;

  /// No description provided for @momentIntro_penalty.
  ///
  /// In tr, this message translates to:
  /// **'Penaltı! Tüm stadyum sessizleşti.'**
  String get momentIntro_penalty;

  /// No description provided for @momentTitle_keyPass.
  ///
  /// In tr, this message translates to:
  /// **'Kilit Pas'**
  String get momentTitle_keyPass;

  /// No description provided for @momentIntro_keyPass.
  ///
  /// In tr, this message translates to:
  /// **'Savunmanın arkasına bir pas fırsatı var.'**
  String get momentIntro_keyPass;

  /// No description provided for @momentTitle_dribble.
  ///
  /// In tr, this message translates to:
  /// **'Çalım'**
  String get momentTitle_dribble;

  /// No description provided for @momentIntro_dribble.
  ///
  /// In tr, this message translates to:
  /// **'Savunmacı karşında; geçmek senin elinde.'**
  String get momentIntro_dribble;

  /// No description provided for @momentTitle_tackle.
  ///
  /// In tr, this message translates to:
  /// **'Müdahale'**
  String get momentTitle_tackle;

  /// No description provided for @momentIntro_tackle.
  ///
  /// In tr, this message translates to:
  /// **'Rakip hızla üstüne geliyor, doğru zamanda müdahale et.'**
  String get momentIntro_tackle;

  /// No description provided for @momentPlay.
  ///
  /// In tr, this message translates to:
  /// **'Oyna'**
  String get momentPlay;

  /// No description provided for @momentAuto.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik Çöz'**
  String get momentAuto;

  /// No description provided for @momentContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get momentContinue;

  /// No description provided for @outcomeGoal.
  ///
  /// In tr, this message translates to:
  /// **'Gol!'**
  String get outcomeGoal;

  /// No description provided for @outcomeAssist.
  ///
  /// In tr, this message translates to:
  /// **'Asist!'**
  String get outcomeAssist;

  /// No description provided for @outcomeConceded.
  ///
  /// In tr, this message translates to:
  /// **'Hatan gole yol açtı.'**
  String get outcomeConceded;

  /// No description provided for @outcomeNothing.
  ///
  /// In tr, this message translates to:
  /// **'Pozisyon sonuçsuz kaldı.'**
  String get outcomeNothing;

  /// No description provided for @summaryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Maç Sonu'**
  String get summaryTitle;

  /// No description provided for @resultWin.
  ///
  /// In tr, this message translates to:
  /// **'Galibiyet'**
  String get resultWin;

  /// No description provided for @resultDraw.
  ///
  /// In tr, this message translates to:
  /// **'Beraberlik'**
  String get resultDraw;

  /// No description provided for @resultLoss.
  ///
  /// In tr, this message translates to:
  /// **'Mağlubiyet'**
  String get resultLoss;

  /// No description provided for @ratingLabel.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu Reytingi'**
  String get ratingLabel;

  /// No description provided for @timelineGoal.
  ///
  /// In tr, this message translates to:
  /// **'{minute}\'  Gol — {team}'**
  String timelineGoal(int minute, String team);

  /// No description provided for @timelineGoalYou.
  ///
  /// In tr, this message translates to:
  /// **'{minute}\'  Gol (sen) — {team}'**
  String timelineGoalYou(int minute, String team);

  /// No description provided for @timelineAssistYou.
  ///
  /// In tr, this message translates to:
  /// **'{minute}\'  Asist (sen) — {team}'**
  String timelineAssistYou(int minute, String team);

  /// No description provided for @noGoals.
  ///
  /// In tr, this message translates to:
  /// **'Gol olmadı.'**
  String get noGoals;

  /// No description provided for @backHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfaya Dön'**
  String get backHome;

  /// No description provided for @shotHint.
  ///
  /// In tr, this message translates to:
  /// **'Zamanı tut, topa dokun ve kaleye doğru kaydır.'**
  String get shotHint;

  /// No description provided for @shotInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Yukarı doğru, daha uzun kaydır.'**
  String get shotInvalid;

  /// No description provided for @shotGoal.
  ///
  /// In tr, this message translates to:
  /// **'GOL!'**
  String get shotGoal;

  /// No description provided for @shotSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kaleci kurtardı!'**
  String get shotSaved;

  /// No description provided for @shotBlocked.
  ///
  /// In tr, this message translates to:
  /// **'Savunma engelledi!'**
  String get shotBlocked;

  /// No description provided for @shotOff.
  ///
  /// In tr, this message translates to:
  /// **'Auta gitti!'**
  String get shotOff;

  /// No description provided for @shotWood.
  ///
  /// In tr, this message translates to:
  /// **'Direkten döndü!'**
  String get shotWood;

  /// No description provided for @shotTimeout.
  ///
  /// In tr, this message translates to:
  /// **'Fırsat kaçtı!'**
  String get shotTimeout;

  /// No description provided for @shotPerfect.
  ///
  /// In tr, this message translates to:
  /// **'Mükemmel zamanlama!'**
  String get shotPerfect;

  /// No description provided for @nextMatchHint.
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik hazırlık maçı oynayabilirsin; lig maçları kulüp sistemiyle gelecek.'**
  String get nextMatchHint;

  /// No description provided for @statCondition.
  ///
  /// In tr, this message translates to:
  /// **'Kondisyon'**
  String get statCondition;

  /// No description provided for @statForm.
  ///
  /// In tr, this message translates to:
  /// **'Form'**
  String get statForm;

  /// No description provided for @statMorale.
  ///
  /// In tr, this message translates to:
  /// **'Moral'**
  String get statMorale;

  /// No description provided for @injuryBanner.
  ///
  /// In tr, this message translates to:
  /// **'Sakatsın: {type} · {weeks} hafta kaldı'**
  String injuryBanner(String type, int weeks);

  /// No description provided for @injury_muscle.
  ///
  /// In tr, this message translates to:
  /// **'Kas sakatlığı'**
  String get injury_muscle;

  /// No description provided for @injury_ligament.
  ///
  /// In tr, this message translates to:
  /// **'Bağ sakatlığı'**
  String get injury_ligament;

  /// No description provided for @injury_fracture.
  ///
  /// In tr, this message translates to:
  /// **'Kırık'**
  String get injury_fracture;

  /// No description provided for @trainingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Plan'**
  String get trainingTitle;

  /// No description provided for @focusLabel.
  ///
  /// In tr, this message translates to:
  /// **'Antrenman odağı'**
  String get focusLabel;

  /// No description provided for @focus_shooting.
  ///
  /// In tr, this message translates to:
  /// **'Şut'**
  String get focus_shooting;

  /// No description provided for @focus_physical.
  ///
  /// In tr, this message translates to:
  /// **'Fizik'**
  String get focus_physical;

  /// No description provided for @focus_technical.
  ///
  /// In tr, this message translates to:
  /// **'Teknik'**
  String get focus_technical;

  /// No description provided for @focus_tactical.
  ///
  /// In tr, this message translates to:
  /// **'Taktik'**
  String get focus_tactical;

  /// No description provided for @focus_rest.
  ///
  /// In tr, this message translates to:
  /// **'Dinlenme'**
  String get focus_rest;

  /// No description provided for @intensityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yoğunluk'**
  String get intensityLabel;

  /// No description provided for @intensity_light.
  ///
  /// In tr, this message translates to:
  /// **'Hafif'**
  String get intensity_light;

  /// No description provided for @intensity_normal.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get intensity_normal;

  /// No description provided for @intensity_hard.
  ///
  /// In tr, this message translates to:
  /// **'Sert'**
  String get intensity_hard;

  /// No description provided for @socialLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal hayat'**
  String get socialLabel;

  /// No description provided for @social_none.
  ///
  /// In tr, this message translates to:
  /// **'Yok'**
  String get social_none;

  /// No description provided for @social_family.
  ///
  /// In tr, this message translates to:
  /// **'Aile'**
  String get social_family;

  /// No description provided for @social_friends.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlar'**
  String get social_friends;

  /// No description provided for @social_hobby.
  ///
  /// In tr, this message translates to:
  /// **'Hobi'**
  String get social_hobby;

  /// No description provided for @trainingHint.
  ///
  /// In tr, this message translates to:
  /// **'Sert antrenman daha çok geliştirir ama kondisyonu eritir ve sakatlık riskini artırır. Düşük kondisyon performansı ve sağlığı bozar.'**
  String get trainingHint;

  /// No description provided for @playWeekMatch.
  ///
  /// In tr, this message translates to:
  /// **'Maçı Oyna ve Haftayı Bitir'**
  String get playWeekMatch;

  /// No description provided for @playWeekNoMatch.
  ///
  /// In tr, this message translates to:
  /// **'Haftayı Geçir'**
  String get playWeekNoMatch;

  /// No description provided for @injuredNoTraining.
  ///
  /// In tr, this message translates to:
  /// **'Sakatken antrenman yapamazsın; bu hafta dinlenmeye çevrilir.'**
  String get injuredNoTraining;

  /// No description provided for @earlyReturn.
  ///
  /// In tr, this message translates to:
  /// **'Riskli Erken Dönüş'**
  String get earlyReturn;

  /// No description provided for @earlyReturnBody.
  ///
  /// In tr, this message translates to:
  /// **'Hemen sahaya dönersin ama kondisyonun düşer ve birkaç hafta boyunca tekrar sakatlanma riskin çok yüksek olur. Tekrar sakatlanırsan çok daha uzun sürer.'**
  String get earlyReturnBody;

  /// No description provided for @earlyReturnConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Dön'**
  String get earlyReturnConfirm;

  /// No description provided for @weekHeader.
  ///
  /// In tr, this message translates to:
  /// **'Sezon {season} · Hafta {week}'**
  String weekHeader(int season, int week);

  /// No description provided for @phase_preseason.
  ///
  /// In tr, this message translates to:
  /// **'Hazırlık dönemi'**
  String get phase_preseason;

  /// No description provided for @phase_regularSeason.
  ///
  /// In tr, this message translates to:
  /// **'Lig turu {round}'**
  String phase_regularSeason(int round);

  /// No description provided for @phase_offseason.
  ///
  /// In tr, this message translates to:
  /// **'Sezon arası'**
  String get phase_offseason;

  /// No description provided for @transferWindowOpen.
  ///
  /// In tr, this message translates to:
  /// **'Transfer penceresi açık'**
  String get transferWindowOpen;

  /// No description provided for @thisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta'**
  String get thisWeek;

  /// No description provided for @matchThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta lig maçı var.'**
  String get matchThisWeek;

  /// No description provided for @noMatchThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta maç yok.'**
  String get noMatchThisWeek;

  /// No description provided for @injuredNoMatch.
  ///
  /// In tr, this message translates to:
  /// **'Sakatsın, bu hafta maçta yoksun.'**
  String get injuredNoMatch;

  /// No description provided for @goTraining.
  ///
  /// In tr, this message translates to:
  /// **'Haftayı Planla'**
  String get goTraining;

  /// No description provided for @weekSummaryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hafta Özeti'**
  String get weekSummaryTitle;

  /// No description provided for @summaryWeekOf.
  ///
  /// In tr, this message translates to:
  /// **'Sezon {season}, Hafta {week}'**
  String summaryWeekOf(int season, int week);

  /// No description provided for @attributeGainsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelişim'**
  String get attributeGainsTitle;

  /// No description provided for @changesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ne değişti, neden?'**
  String get changesTitle;

  /// No description provided for @statLine.
  ///
  /// In tr, this message translates to:
  /// **'{stat}: {before} → {after}'**
  String statLine(String stat, String before, String after);

  /// No description provided for @reason_recovery.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık toparlanma'**
  String get reason_recovery;

  /// No description provided for @reason_trainingLight.
  ///
  /// In tr, this message translates to:
  /// **'Hafif antrenman'**
  String get reason_trainingLight;

  /// No description provided for @reason_trainingNormal.
  ///
  /// In tr, this message translates to:
  /// **'Orta antrenman'**
  String get reason_trainingNormal;

  /// No description provided for @reason_trainingHard.
  ///
  /// In tr, this message translates to:
  /// **'Sert antrenman'**
  String get reason_trainingHard;

  /// No description provided for @reason_restFocus.
  ///
  /// In tr, this message translates to:
  /// **'Dinlenme'**
  String get reason_restFocus;

  /// No description provided for @reason_match.
  ///
  /// In tr, this message translates to:
  /// **'Maç yorgunluğu'**
  String get reason_match;

  /// No description provided for @reason_socialFamily.
  ///
  /// In tr, this message translates to:
  /// **'Aileyle zaman'**
  String get reason_socialFamily;

  /// No description provided for @reason_socialFriends.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlarla zaman'**
  String get reason_socialFriends;

  /// No description provided for @reason_socialHobby.
  ///
  /// In tr, this message translates to:
  /// **'Hobi'**
  String get reason_socialHobby;

  /// No description provided for @reason_matchWin.
  ///
  /// In tr, this message translates to:
  /// **'Galibiyet'**
  String get reason_matchWin;

  /// No description provided for @reason_matchLoss.
  ///
  /// In tr, this message translates to:
  /// **'Mağlubiyet'**
  String get reason_matchLoss;

  /// No description provided for @reason_greatPerformance.
  ///
  /// In tr, this message translates to:
  /// **'Parlak performans'**
  String get reason_greatPerformance;

  /// No description provided for @reason_poorPerformance.
  ///
  /// In tr, this message translates to:
  /// **'Kötü performans'**
  String get reason_poorPerformance;

  /// No description provided for @reason_injured.
  ///
  /// In tr, this message translates to:
  /// **'Sakatlık süreci'**
  String get reason_injured;

  /// No description provided for @reason_injuryOnset.
  ///
  /// In tr, this message translates to:
  /// **'Sakatlanma'**
  String get reason_injuryOnset;

  /// No description provided for @reason_healed.
  ///
  /// In tr, this message translates to:
  /// **'İyileşme'**
  String get reason_healed;

  /// No description provided for @reason_exhausted.
  ///
  /// In tr, this message translates to:
  /// **'Bitkinlik'**
  String get reason_exhausted;

  /// No description provided for @reason_formFromRatings.
  ///
  /// In tr, this message translates to:
  /// **'Son maç reytingleri'**
  String get reason_formFromRatings;

  /// No description provided for @reason_earlyReturn.
  ///
  /// In tr, this message translates to:
  /// **'Erken dönüş'**
  String get reason_earlyReturn;

  /// No description provided for @reason_drift.
  ///
  /// In tr, this message translates to:
  /// **'Zamanla dengelenme'**
  String get reason_drift;

  /// No description provided for @eventInjured.
  ///
  /// In tr, this message translates to:
  /// **'Sakatlandın: {type} ({weeks} hafta).'**
  String eventInjured(String type, int weeks);

  /// No description provided for @eventRelapse.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar sakatlandın: {type} ({weeks} hafta).'**
  String eventRelapse(String type, int weeks);

  /// No description provided for @eventHealed.
  ///
  /// In tr, this message translates to:
  /// **'Sakatlığın iyileşti, sahaya dönebilirsin.'**
  String get eventHealed;

  /// No description provided for @eventNewSeason.
  ///
  /// In tr, this message translates to:
  /// **'Yeni sezon başladı! {age} yaşına girdin.'**
  String eventNewSeason(int age);

  /// No description provided for @eventTrainingBlocked.
  ///
  /// In tr, this message translates to:
  /// **'Sakat olduğun için antrenman dinlenmeye çevrildi.'**
  String get eventTrainingBlocked;

  /// No description provided for @continueButton.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get continueButton;

  /// No description provided for @finishWeek.
  ///
  /// In tr, this message translates to:
  /// **'Haftayı Bitir'**
  String get finishWeek;

  /// No description provided for @miniHint_oneOnOne.
  ///
  /// In tr, this message translates to:
  /// **'Kaleci çok yakın! Zamanı tut, topa dokun ve köşeye doğru kaydır.'**
  String get miniHint_oneOnOne;

  /// No description provided for @miniHint_freeKick.
  ///
  /// In tr, this message translates to:
  /// **'Duvarın üstünden aş ya da yanından kavisle dolan. Topa dokun ve kaydır; yolu bükersen falso olur.'**
  String get miniHint_freeKick;

  /// No description provided for @miniHint_header.
  ///
  /// In tr, this message translates to:
  /// **'Top kafa hizasına gelince parmağını oyuncuya koy ve kale yönüne kaydır.'**
  String get miniHint_header;

  /// No description provided for @miniHint_penalty.
  ///
  /// In tr, this message translates to:
  /// **'Kaleye dokunarak köşeyi seç, sonra ibreyi yeşil bölgede durdurmak için aşağıya dokun.'**
  String get miniHint_penalty;

  /// No description provided for @miniHint_keyPass.
  ///
  /// In tr, this message translates to:
  /// **'Bir arkadaşını seç, sonra ibreyi yeşil bölgede durdurmak için aşağıya dokun.'**
  String get miniHint_keyPass;

  /// No description provided for @miniHint_dribble.
  ///
  /// In tr, this message translates to:
  /// **'Sürükleyerek yönlendir. Savunmacı atılmadan hemen önce, atıldığı yanın tersine hızlıca kaydır!'**
  String get miniHint_dribble;

  /// No description provided for @miniHint_tackle.
  ///
  /// In tr, this message translates to:
  /// **'Parmağınla rakibin önünde kal. Top ayağından en çok açıldığı anda parmağını bırak!'**
  String get miniHint_tackle;

  /// No description provided for @shootButton.
  ///
  /// In tr, this message translates to:
  /// **'Durdur'**
  String get shootButton;

  /// No description provided for @tooEarly.
  ///
  /// In tr, this message translates to:
  /// **'Çok erken!'**
  String get tooEarly;

  /// No description provided for @passComplete.
  ///
  /// In tr, this message translates to:
  /// **'Pas tamam!'**
  String get passComplete;

  /// No description provided for @passAssist.
  ///
  /// In tr, this message translates to:
  /// **'ASİST!'**
  String get passAssist;

  /// No description provided for @passIntercepted.
  ///
  /// In tr, this message translates to:
  /// **'Pas kesildi!'**
  String get passIntercepted;

  /// No description provided for @dribbleBeaten.
  ///
  /// In tr, this message translates to:
  /// **'Çalım tuttu!'**
  String get dribbleBeaten;

  /// No description provided for @dribbleFail.
  ///
  /// In tr, this message translates to:
  /// **'Savunmacı topu aldı!'**
  String get dribbleFail;

  /// No description provided for @tackleWon.
  ///
  /// In tr, this message translates to:
  /// **'Top kazanıldı!'**
  String get tackleWon;

  /// No description provided for @tackleFoul.
  ///
  /// In tr, this message translates to:
  /// **'Faul!'**
  String get tackleFoul;

  /// No description provided for @tackleBeaten.
  ///
  /// In tr, this message translates to:
  /// **'Geçildi!'**
  String get tackleBeaten;

  /// No description provided for @momentAutoSkip.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik Çöz'**
  String get momentAutoSkip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
