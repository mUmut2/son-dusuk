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
  /// **'Lig Maçı'**
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

  /// No description provided for @moneyAmount.
  ///
  /// In tr, this message translates to:
  /// **'{amount} ₺'**
  String moneyAmount(String amount);

  /// No description provided for @moneyPerWeek.
  ///
  /// In tr, this message translates to:
  /// **'{amount} ₺ / hafta'**
  String moneyPerWeek(String amount);

  /// No description provided for @clubLeagueLine.
  ///
  /// In tr, this message translates to:
  /// **'{league} · {pos}. sıra · {points} puan'**
  String clubLeagueLine(String league, int pos, int points);

  /// No description provided for @clubLeagueLineNoMatch.
  ///
  /// In tr, this message translates to:
  /// **'{league} · henüz maç oynanmadı'**
  String clubLeagueLineNoMatch(String league);

  /// No description provided for @clubFreeAgentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Serbest oyuncusun'**
  String get clubFreeAgentTitle;

  /// No description provided for @clubFreeAgentBody.
  ///
  /// In tr, this message translates to:
  /// **'Bir kulübe imza atana kadar maç oynayamaz ve maaş alamazsın. Teklifler her hafta gelir.'**
  String get clubFreeAgentBody;

  /// No description provided for @contractTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sözleşme'**
  String get contractTitle;

  /// No description provided for @contractWage.
  ///
  /// In tr, this message translates to:
  /// **'Maaş'**
  String get contractWage;

  /// No description provided for @contractRole.
  ///
  /// In tr, this message translates to:
  /// **'Rol'**
  String get contractRole;

  /// No description provided for @contractEnds.
  ///
  /// In tr, this message translates to:
  /// **'Sözleşme bitişi'**
  String get contractEnds;

  /// No description provided for @contractEndsValue.
  ///
  /// In tr, this message translates to:
  /// **'Sezon {season} sonu'**
  String contractEndsValue(int season);

  /// No description provided for @marketValue.
  ///
  /// In tr, this message translates to:
  /// **'Piyasa değeri'**
  String get marketValue;

  /// No description provided for @role_prospect.
  ///
  /// In tr, this message translates to:
  /// **'Yedek (genç)'**
  String get role_prospect;

  /// No description provided for @role_rotation.
  ///
  /// In tr, this message translates to:
  /// **'Rotasyon'**
  String get role_rotation;

  /// No description provided for @role_starter.
  ///
  /// In tr, this message translates to:
  /// **'İlk 11'**
  String get role_starter;

  /// No description provided for @role_star.
  ///
  /// In tr, this message translates to:
  /// **'Yıldız'**
  String get role_star;

  /// No description provided for @offersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Teklifler'**
  String get offersTitle;

  /// No description provided for @offersNone.
  ///
  /// In tr, this message translates to:
  /// **'Şu an bekleyen teklif yok.'**
  String get offersNone;

  /// No description provided for @offersWindowHint.
  ///
  /// In tr, this message translates to:
  /// **'Transfer pencereleri: sezonun ilk 6 haftası ve 22-24. haftalar. Pencere dışında yalnızca sözleşme yenileme teklifi gelebilir.'**
  String get offersWindowHint;

  /// No description provided for @offerTransferTitle.
  ///
  /// In tr, this message translates to:
  /// **'{club} sana teklif yaptı'**
  String offerTransferTitle(String club);

  /// No description provided for @offerRenewalTitle.
  ///
  /// In tr, this message translates to:
  /// **'{club} sözleşmeni uzatmak istiyor'**
  String offerRenewalTitle(String club);

  /// No description provided for @offerTerms.
  ///
  /// In tr, this message translates to:
  /// **'{league} · {years} yıl · {role}'**
  String offerTerms(String league, int years, String role);

  /// No description provided for @offerExpires.
  ///
  /// In tr, this message translates to:
  /// **'Son cevap: {weeks} hafta'**
  String offerExpires(int weeks);

  /// No description provided for @offerAccept.
  ///
  /// In tr, this message translates to:
  /// **'Kabul Et'**
  String get offerAccept;

  /// No description provided for @offerNegotiate.
  ///
  /// In tr, this message translates to:
  /// **'Pazarlık Et'**
  String get offerNegotiate;

  /// No description provided for @offerDecline.
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get offerDecline;

  /// No description provided for @negotiateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Maaş pazarlığı'**
  String get negotiateTitle;

  /// No description provided for @negotiateAsk.
  ///
  /// In tr, this message translates to:
  /// **'İstediğin maaş'**
  String get negotiateAsk;

  /// No description provided for @negotiateHint.
  ///
  /// In tr, this message translates to:
  /// **'Fazla isteme: kulüp teklifi geri çekebilir. Pazarlık hakkı bir kez kullanılır.'**
  String get negotiateHint;

  /// No description provided for @negotiateSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Teklif Et'**
  String get negotiateSubmit;

  /// No description provided for @negotiateCounter.
  ///
  /// In tr, this message translates to:
  /// **'{club} en fazla {wage} verebilir. Bu maaşla imzalar mısın?'**
  String negotiateCounter(String club, String wage);

  /// No description provided for @negotiateWalked.
  ///
  /// In tr, this message translates to:
  /// **'{club} teklifi geri çekti.'**
  String negotiateWalked(String club);

  /// No description provided for @negotiateSignAt.
  ///
  /// In tr, this message translates to:
  /// **'Bu Maaşla İmzala'**
  String get negotiateSignAt;

  /// No description provided for @offerSigned.
  ///
  /// In tr, this message translates to:
  /// **'{club} ile imzaladın!'**
  String offerSigned(String club);

  /// No description provided for @agentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Menajer'**
  String get agentTitle;

  /// No description provided for @agentNone.
  ///
  /// In tr, this message translates to:
  /// **'Menajerin yok. Menajer daha çok ve daha iyi teklif getirir, pazarlıkta işini kolaylaştırır; karşılığında gelirinden komisyon alır.'**
  String get agentNone;

  /// No description provided for @agentLevel_1.
  ///
  /// In tr, this message translates to:
  /// **'Amatör menajer'**
  String get agentLevel_1;

  /// No description provided for @agentLevel_2.
  ///
  /// In tr, this message translates to:
  /// **'Tecrübeli menajer'**
  String get agentLevel_2;

  /// No description provided for @agentLevel_3.
  ///
  /// In tr, this message translates to:
  /// **'Ünlü menajer'**
  String get agentLevel_3;

  /// No description provided for @agentInfo.
  ///
  /// In tr, this message translates to:
  /// **'{name} · komisyon %{percent}'**
  String agentInfo(String name, int percent);

  /// No description provided for @agentHire.
  ///
  /// In tr, this message translates to:
  /// **'Anlaş'**
  String get agentHire;

  /// No description provided for @agentFire.
  ///
  /// In tr, this message translates to:
  /// **'Ayrıl'**
  String get agentFire;

  /// No description provided for @agentLocked.
  ///
  /// In tr, this message translates to:
  /// **'Genel güç {min} gerekir'**
  String agentLocked(int min);

  /// No description provided for @financeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Finans'**
  String get financeTitle;

  /// No description provided for @financeBalance.
  ///
  /// In tr, this message translates to:
  /// **'Bakiye'**
  String get financeBalance;

  /// No description provided for @financeDebt.
  ///
  /// In tr, this message translates to:
  /// **'Borçtasın! Moralin her hafta düşüyor.'**
  String get financeDebt;

  /// No description provided for @financeWeekly.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık gelir: {income} · gider: {cost}'**
  String financeWeekly(String income, String cost);

  /// No description provided for @lifestyleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yaşam tarzı'**
  String get lifestyleTitle;

  /// No description provided for @lifestyle_modest.
  ///
  /// In tr, this message translates to:
  /// **'Mütevazı'**
  String get lifestyle_modest;

  /// No description provided for @lifestyle_comfortable.
  ///
  /// In tr, this message translates to:
  /// **'Rahat'**
  String get lifestyle_comfortable;

  /// No description provided for @lifestyle_lavish.
  ///
  /// In tr, this message translates to:
  /// **'Lüks'**
  String get lifestyle_lavish;

  /// No description provided for @lifestyleInfo.
  ///
  /// In tr, this message translates to:
  /// **'{cost} / hafta · moral {morale}'**
  String lifestyleInfo(String cost, String morale);

  /// No description provided for @tableTitle.
  ///
  /// In tr, this message translates to:
  /// **'Lig Tablosu'**
  String get tableTitle;

  /// No description provided for @tableHeaderPlayed.
  ///
  /// In tr, this message translates to:
  /// **'O'**
  String get tableHeaderPlayed;

  /// No description provided for @tableHeaderGd.
  ///
  /// In tr, this message translates to:
  /// **'Av'**
  String get tableHeaderGd;

  /// No description provided for @tableHeaderPoints.
  ///
  /// In tr, this message translates to:
  /// **'P'**
  String get tableHeaderPoints;

  /// No description provided for @tableEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz maç oynanmadı.'**
  String get tableEmpty;

  /// No description provided for @moneyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Para'**
  String get moneyTitle;

  /// No description provided for @money_wage.
  ///
  /// In tr, this message translates to:
  /// **'Maaş'**
  String get money_wage;

  /// No description provided for @money_winBonus.
  ///
  /// In tr, this message translates to:
  /// **'Galibiyet primi'**
  String get money_winBonus;

  /// No description provided for @money_goalBonus.
  ///
  /// In tr, this message translates to:
  /// **'Gol primi'**
  String get money_goalBonus;

  /// No description provided for @money_agentFee.
  ///
  /// In tr, this message translates to:
  /// **'Menajer komisyonu'**
  String get money_agentFee;

  /// No description provided for @money_living.
  ///
  /// In tr, this message translates to:
  /// **'Yaşam gideri'**
  String get money_living;

  /// No description provided for @reason_lifestyle.
  ///
  /// In tr, this message translates to:
  /// **'Yaşam tarzı'**
  String get reason_lifestyle;

  /// No description provided for @reason_debt.
  ///
  /// In tr, this message translates to:
  /// **'Borç stresi'**
  String get reason_debt;

  /// No description provided for @eventBenched.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta kadroda yer almadın.'**
  String get eventBenched;

  /// No description provided for @eventOfferReceived.
  ///
  /// In tr, this message translates to:
  /// **'{club} sana transfer teklifi yaptı. Kulüp sekmesinden bak.'**
  String eventOfferReceived(String club);

  /// No description provided for @eventRenewalOffered.
  ///
  /// In tr, this message translates to:
  /// **'{club} sözleşmeni uzatmak istiyor. Kulüp sekmesinden bak.'**
  String eventRenewalOffered(String club);

  /// No description provided for @eventContractExpired.
  ///
  /// In tr, this message translates to:
  /// **'{club} ile sözleşmen bitti. Artık serbest oyuncusun.'**
  String eventContractExpired(String club);

  /// No description provided for @benchedThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta kadroda yoksun.'**
  String get benchedThisWeek;

  /// No description provided for @freeAgentNoMatch.
  ///
  /// In tr, this message translates to:
  /// **'Kulübün yok, bu hafta maç oynayamazsın.'**
  String get freeAgentNoMatch;

  /// No description provided for @homeClubLine.
  ///
  /// In tr, this message translates to:
  /// **'{club} · {league}'**
  String homeClubLine(String club, String league);

  /// No description provided for @offersWaiting.
  ///
  /// In tr, this message translates to:
  /// **'{count} bekleyen teklif var'**
  String offersWaiting(int count);

  /// No description provided for @ev_pressWin_title.
  ///
  /// In tr, this message translates to:
  /// **'Galibiyet sonrası mikrofonlar'**
  String get ev_pressWin_title;

  /// No description provided for @ev_pressWin_body.
  ///
  /// In tr, this message translates to:
  /// **'{opponent} karşısında {score} kazandınız. Gazeteciler seni bekliyor: \"Bu galibiyetteki en büyük pay kimin?\"'**
  String ev_pressWin_body(String opponent, String score);

  /// No description provided for @ev_pressWin_c0.
  ///
  /// In tr, this message translates to:
  /// **'Bu takımın başarısı, hepsine minnettarım.'**
  String get ev_pressWin_c0;

  /// No description provided for @ev_pressWin_r0.
  ///
  /// In tr, this message translates to:
  /// **'Soyunma odası bu sözlere bayıldı.'**
  String get ev_pressWin_r0;

  /// No description provided for @ev_pressWin_c1.
  ///
  /// In tr, this message translates to:
  /// **'Bugün benim günümdü, hep böyle olsun.'**
  String get ev_pressWin_c1;

  /// No description provided for @ev_pressWin_r1.
  ///
  /// In tr, this message translates to:
  /// **'Manşetler seninle açıldı ama takım arkadaşları homurdandı.'**
  String get ev_pressWin_r1;

  /// No description provided for @ev_pressWin_c2.
  ///
  /// In tr, this message translates to:
  /// **'Rakip bu seviyeye çıkamadı, herkes gördü.'**
  String get ev_pressWin_c2;

  /// No description provided for @ev_pressWin_r2.
  ///
  /// In tr, this message translates to:
  /// **'Sert sözlerin gündem oldu.'**
  String get ev_pressWin_r2;

  /// No description provided for @ev_pressWin_b2.
  ///
  /// In tr, this message translates to:
  /// **'Rakip kulüp sert tepki verdi, teknik direktör seni uyardı.'**
  String get ev_pressWin_b2;

  /// No description provided for @ev_pressLoss_title.
  ///
  /// In tr, this message translates to:
  /// **'Yenilgi sonrası sorular'**
  String get ev_pressLoss_title;

  /// No description provided for @ev_pressLoss_body.
  ///
  /// In tr, this message translates to:
  /// **'{opponent} karşısında {score} kaybettiniz. Gazeteciler soruyor: \"Bu yenilgi kimin hatası?\"'**
  String ev_pressLoss_body(String opponent, String score);

  /// No description provided for @ev_pressLoss_c0.
  ///
  /// In tr, this message translates to:
  /// **'Hepimizin sorumluluğu var, toparlanacağız.'**
  String get ev_pressLoss_c0;

  /// No description provided for @ev_pressLoss_r0.
  ///
  /// In tr, this message translates to:
  /// **'Olgun duruşun teknik heyetin dikkatini çekti.'**
  String get ev_pressLoss_r0;

  /// No description provided for @ev_pressLoss_c1.
  ///
  /// In tr, this message translates to:
  /// **'Hakem kararları maçı değiştirdi.'**
  String get ev_pressLoss_c1;

  /// No description provided for @ev_pressLoss_r1.
  ///
  /// In tr, this message translates to:
  /// **'Taraftarlar seni haklı buldu.'**
  String get ev_pressLoss_r1;

  /// No description provided for @ev_pressLoss_b1.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama tepki çekti; teknik direktör seni uyardı.'**
  String get ev_pressLoss_b1;

  /// No description provided for @ev_pressLoss_c2.
  ///
  /// In tr, this message translates to:
  /// **'Bu soruya cevap vermeyeceğim.'**
  String get ev_pressLoss_c2;

  /// No description provided for @ev_pressLoss_r2.
  ///
  /// In tr, this message translates to:
  /// **'Gazeteciler suskunluğunu yorumladı.'**
  String get ev_pressLoss_r2;

  /// No description provided for @ev_pressStar_title.
  ///
  /// In tr, this message translates to:
  /// **'Günün yıldızı'**
  String get ev_pressStar_title;

  /// No description provided for @ev_pressStar_body.
  ///
  /// In tr, this message translates to:
  /// **'{opponent} maçını {score} bitirdiniz ve skorda senin imzan var. Gazeteciler: \"Bu performans seni büyük kulüplere taşır mı?\"'**
  String ev_pressStar_body(String opponent, String score);

  /// No description provided for @ev_pressStar_c0.
  ///
  /// In tr, this message translates to:
  /// **'Takım arkadaşlarım sayesinde buradayım.'**
  String get ev_pressStar_c0;

  /// No description provided for @ev_pressStar_r0.
  ///
  /// In tr, this message translates to:
  /// **'Mütevazı sözlerin herkesi memnun etti.'**
  String get ev_pressStar_r0;

  /// No description provided for @ev_pressStar_c1.
  ///
  /// In tr, this message translates to:
  /// **'Daha fazlasını yapabilirim, kim isterse gelsin.'**
  String get ev_pressStar_c1;

  /// No description provided for @ev_pressStar_r1.
  ///
  /// In tr, this message translates to:
  /// **'Büyük kulüplerin radarına girdin.'**
  String get ev_pressStar_r1;

  /// No description provided for @ev_pressStar_b1.
  ///
  /// In tr, this message translates to:
  /// **'Bu sözler soyunma odasında kızgınlık yarattı.'**
  String get ev_pressStar_b1;

  /// No description provided for @ev_pressStar_c2.
  ///
  /// In tr, this message translates to:
  /// **'Teknik direktörüm bana güvendi, hesabını verdim.'**
  String get ev_pressStar_c2;

  /// No description provided for @ev_pressStar_r2.
  ///
  /// In tr, this message translates to:
  /// **'Hoca bu sözlere çok sevindi.'**
  String get ev_pressStar_r2;

  /// No description provided for @ev_pressPoor_title.
  ///
  /// In tr, this message translates to:
  /// **'Eleştiri yağmuru'**
  String get ev_pressPoor_title;

  /// No description provided for @ev_pressPoor_body.
  ///
  /// In tr, this message translates to:
  /// **'{opponent} karşısında {score} bitti ve performansın eleştirildi. Gazeteciler: \"Bugün neden sahada yoktun?\"'**
  String ev_pressPoor_body(String opponent, String score);

  /// No description provided for @ev_pressPoor_c0.
  ///
  /// In tr, this message translates to:
  /// **'Kötüydüm, bunu kabul ediyorum.'**
  String get ev_pressPoor_c0;

  /// No description provided for @ev_pressPoor_r0.
  ///
  /// In tr, this message translates to:
  /// **'Dürüstlüğün takdir topladı.'**
  String get ev_pressPoor_r0;

  /// No description provided for @ev_pressPoor_c1.
  ///
  /// In tr, this message translates to:
  /// **'Eleştiriler beni daha da motive ediyor.'**
  String get ev_pressPoor_c1;

  /// No description provided for @ev_pressPoor_r1.
  ///
  /// In tr, this message translates to:
  /// **'Meydan okuman bazılarını güldürdü, bazılarını kızdırdı.'**
  String get ev_pressPoor_r1;

  /// No description provided for @ev_pressPoor_c2.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yok.'**
  String get ev_pressPoor_c2;

  /// No description provided for @ev_pressPoor_r2.
  ///
  /// In tr, this message translates to:
  /// **'Kısa kesmen soru işaretleri bıraktı.'**
  String get ev_pressPoor_r2;

  /// No description provided for @ev_pressBench_title.
  ///
  /// In tr, this message translates to:
  /// **'Yedek kulübesi'**
  String get ev_pressBench_title;

  /// No description provided for @ev_pressBench_body.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta kadroda yoktun. Gazeteciler: \"Yedek kalmak seni nasıl etkiliyor?\"'**
  String get ev_pressBench_body;

  /// No description provided for @ev_pressBench_c0.
  ///
  /// In tr, this message translates to:
  /// **'Sabırlıyım, sıram gelecek.'**
  String get ev_pressBench_c0;

  /// No description provided for @ev_pressBench_r0.
  ///
  /// In tr, this message translates to:
  /// **'Teknik direktör olgunluğunu not etti.'**
  String get ev_pressBench_r0;

  /// No description provided for @ev_pressBench_c1.
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla süre hak ediyorum.'**
  String get ev_pressBench_c1;

  /// No description provided for @ev_pressBench_r1.
  ///
  /// In tr, this message translates to:
  /// **'Söylediklerin yazıldı, hoca pek hoşlanmadı.'**
  String get ev_pressBench_r1;

  /// No description provided for @ev_pressBench_c2.
  ///
  /// In tr, this message translates to:
  /// **'Önemli olan takımın kazanması.'**
  String get ev_pressBench_c2;

  /// No description provided for @ev_pressBench_r2.
  ///
  /// In tr, this message translates to:
  /// **'Takım arkadaşların bunu duyunca memnun oldu.'**
  String get ev_pressBench_r2;

  /// No description provided for @ev_familyDinner_title.
  ///
  /// In tr, this message translates to:
  /// **'Aile yemeği'**
  String get ev_familyDinner_title;

  /// No description provided for @ev_familyDinner_body.
  ///
  /// In tr, this message translates to:
  /// **'Annen ve baban seni akşam yemeğine çağırıyor. Haftanın tek boş akşamı.'**
  String get ev_familyDinner_body;

  /// No description provided for @ev_familyDinner_c0.
  ///
  /// In tr, this message translates to:
  /// **'Yemeğe git, doyasıya sohbet et.'**
  String get ev_familyDinner_c0;

  /// No description provided for @ev_familyDinner_r0.
  ///
  /// In tr, this message translates to:
  /// **'Mutlu ve yorgun döndün; aile seni özlemişti.'**
  String get ev_familyDinner_r0;

  /// No description provided for @ev_familyDinner_c1.
  ///
  /// In tr, this message translates to:
  /// **'Antrenmana odaklan, daha sonra görüşürsün.'**
  String get ev_familyDinner_c1;

  /// No description provided for @ev_familyDinner_r1.
  ///
  /// In tr, this message translates to:
  /// **'Annen biraz kırıldı ama hoca çalışkanlığını görüyor.'**
  String get ev_familyDinner_r1;

  /// No description provided for @ev_familyDinner_c2.
  ///
  /// In tr, this message translates to:
  /// **'Kısa bir telefon görüşmesi yap.'**
  String get ev_familyDinner_c2;

  /// No description provided for @ev_familyDinner_r2.
  ///
  /// In tr, this message translates to:
  /// **'Sesini duymak yetti, ama sarılmak başka.'**
  String get ev_familyDinner_r2;

  /// No description provided for @ev_partyInvite_title.
  ///
  /// In tr, this message translates to:
  /// **'Doğum günü daveti'**
  String get ev_partyInvite_title;

  /// No description provided for @ev_partyInvite_body.
  ///
  /// In tr, this message translates to:
  /// **'Takım arkadaşların bir doğum günü kutlamasına seni çağırıyor.'**
  String get ev_partyInvite_body;

  /// No description provided for @ev_partyInvite_c0.
  ///
  /// In tr, this message translates to:
  /// **'Katıl, gece uzasın.'**
  String get ev_partyInvite_c0;

  /// No description provided for @ev_partyInvite_r0.
  ///
  /// In tr, this message translates to:
  /// **'Soyunma odasında bağların güçlendi.'**
  String get ev_partyInvite_r0;

  /// No description provided for @ev_partyInvite_b0.
  ///
  /// In tr, this message translates to:
  /// **'Bir video sızdı. Medya ve teknik direktör hoşnut değil.'**
  String get ev_partyInvite_b0;

  /// No description provided for @ev_partyInvite_c1.
  ///
  /// In tr, this message translates to:
  /// **'Nazikçe reddet, dinlen.'**
  String get ev_partyInvite_c1;

  /// No description provided for @ev_partyInvite_r1.
  ///
  /// In tr, this message translates to:
  /// **'Dinlendin ama bazıları seni mesafeli buldu.'**
  String get ev_partyInvite_r1;

  /// No description provided for @ev_partyInvite_c2.
  ///
  /// In tr, this message translates to:
  /// **'Bir saat uğrayıp çık.'**
  String get ev_partyInvite_c2;

  /// No description provided for @ev_partyInvite_r2.
  ///
  /// In tr, this message translates to:
  /// **'Hem orada oldun hem dinlenebildin.'**
  String get ev_partyInvite_r2;

  /// No description provided for @ev_fanMeet_title.
  ///
  /// In tr, this message translates to:
  /// **'Taraftar buluşması'**
  String get ev_fanMeet_title;

  /// No description provided for @ev_fanMeet_body.
  ///
  /// In tr, this message translates to:
  /// **'Antrenman çıkışı, kapıda onlarca taraftar seni bekliyor.'**
  String get ev_fanMeet_body;

  /// No description provided for @ev_fanMeet_c0.
  ///
  /// In tr, this message translates to:
  /// **'Durup herkesle fotoğraf çektir.'**
  String get ev_fanMeet_c0;

  /// No description provided for @ev_fanMeet_r0.
  ///
  /// In tr, this message translates to:
  /// **'Taraftarlar bu ilgiyi uzun süre unutmayacak.'**
  String get ev_fanMeet_r0;

  /// No description provided for @ev_fanMeet_c1.
  ///
  /// In tr, this message translates to:
  /// **'Hızlıca geç, yorgunsun.'**
  String get ev_fanMeet_c1;

  /// No description provided for @ev_fanMeet_r1.
  ///
  /// In tr, this message translates to:
  /// **'Bazı taraftarlar küstü.'**
  String get ev_fanMeet_r1;

  /// No description provided for @ev_fanMeet_c2.
  ///
  /// In tr, this message translates to:
  /// **'Birkaç imza ver, el salla.'**
  String get ev_fanMeet_c2;

  /// No description provided for @ev_fanMeet_r2.
  ///
  /// In tr, this message translates to:
  /// **'Hem hızlı hem samimi oldu.'**
  String get ev_fanMeet_r2;

  /// No description provided for @ev_coachTalk_title.
  ///
  /// In tr, this message translates to:
  /// **'Hoca çağırıyor'**
  String get ev_coachTalk_title;

  /// No description provided for @ev_coachTalk_body.
  ///
  /// In tr, this message translates to:
  /// **'Teknik direktör seni ofisine çağırdı. Aranızın pek iyi olmadığı belli.'**
  String get ev_coachTalk_body;

  /// No description provided for @ev_coachTalk_c0.
  ///
  /// In tr, this message translates to:
  /// **'Dinle ve çalışmaya odaklan.'**
  String get ev_coachTalk_c0;

  /// No description provided for @ev_coachTalk_r0.
  ///
  /// In tr, this message translates to:
  /// **'Hoca ciddiyetini gördü.'**
  String get ev_coachTalk_r0;

  /// No description provided for @ev_coachTalk_c1.
  ///
  /// In tr, this message translates to:
  /// **'Haklı olduğunu savun.'**
  String get ev_coachTalk_c1;

  /// No description provided for @ev_coachTalk_r1.
  ///
  /// In tr, this message translates to:
  /// **'Konuşma gerginleşti ama içini döktün.'**
  String get ev_coachTalk_r1;

  /// No description provided for @ev_coachTalk_c2.
  ///
  /// In tr, this message translates to:
  /// **'Taktik önerin olduğunu söyle.'**
  String get ev_coachTalk_c2;

  /// No description provided for @ev_coachTalk_r2.
  ///
  /// In tr, this message translates to:
  /// **'Hoca önerini dikkate aldı!'**
  String get ev_coachTalk_r2;

  /// No description provided for @ev_coachTalk_b2.
  ///
  /// In tr, this message translates to:
  /// **'Önerin fazla iddialı bulundu, hoca aldırış etmedi.'**
  String get ev_coachTalk_b2;

  /// No description provided for @ev_teammateRift_title.
  ///
  /// In tr, this message translates to:
  /// **'Soyunma odası gerginliği'**
  String get ev_teammateRift_title;

  /// No description provided for @ev_teammateRift_body.
  ///
  /// In tr, this message translates to:
  /// **'Antrenmanda bir takım arkadaşınla sürtüşme yaşadın, soyunma odası ikiye bölündü.'**
  String get ev_teammateRift_body;

  /// No description provided for @ev_teammateRift_c0.
  ///
  /// In tr, this message translates to:
  /// **'Konuşup barışmayı dene.'**
  String get ev_teammateRift_c0;

  /// No description provided for @ev_teammateRift_r0.
  ///
  /// In tr, this message translates to:
  /// **'Barıştınız, hava yumuşadı.'**
  String get ev_teammateRift_r0;

  /// No description provided for @ev_teammateRift_c1.
  ///
  /// In tr, this message translates to:
  /// **'Durumu teknik direktöre anlat.'**
  String get ev_teammateRift_c1;

  /// No description provided for @ev_teammateRift_r1.
  ///
  /// In tr, this message translates to:
  /// **'Hoca ilgilendi ama arkadaşların seni küçümsedi.'**
  String get ev_teammateRift_r1;

  /// No description provided for @ev_teammateRift_c2.
  ///
  /// In tr, this message translates to:
  /// **'Görmezden gel.'**
  String get ev_teammateRift_c2;

  /// No description provided for @ev_teammateRift_r2.
  ///
  /// In tr, this message translates to:
  /// **'Gerginlik bir süre daha sürecek.'**
  String get ev_teammateRift_r2;

  /// No description provided for @ev_sponsorOffer_title.
  ///
  /// In tr, this message translates to:
  /// **'Sponsor teklifi'**
  String get ev_sponsorOffer_title;

  /// No description provided for @ev_sponsorOffer_body.
  ///
  /// In tr, this message translates to:
  /// **'Bir spor markası seninle sponsorluk görüşmesi yapmak istiyor.'**
  String get ev_sponsorOffer_body;

  /// No description provided for @ev_sponsorOffer_c0.
  ///
  /// In tr, this message translates to:
  /// **'Büyük, uluslararası markayla anlaş.'**
  String get ev_sponsorOffer_c0;

  /// No description provided for @ev_sponsorOffer_r0.
  ///
  /// In tr, this message translates to:
  /// **'Hesabına iyi bir para girdi; bazı taraftarlar fazla ticari buldu.'**
  String get ev_sponsorOffer_r0;

  /// No description provided for @ev_sponsorOffer_c1.
  ///
  /// In tr, this message translates to:
  /// **'Yerel esnafın küçük markasıyla anlaş.'**
  String get ev_sponsorOffer_c1;

  /// No description provided for @ev_sponsorOffer_r1.
  ///
  /// In tr, this message translates to:
  /// **'Para az ama taraftar bunu sevdi.'**
  String get ev_sponsorOffer_r1;

  /// No description provided for @ev_sponsorOffer_c2.
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik reddet, futbola odaklan.'**
  String get ev_sponsorOffer_c2;

  /// No description provided for @ev_sponsorOffer_r2.
  ///
  /// In tr, this message translates to:
  /// **'Odağın hocanın hoşuna gitti.'**
  String get ev_sponsorOffer_r2;

  /// No description provided for @ev_charity_title.
  ///
  /// In tr, this message translates to:
  /// **'Yardım maçı'**
  String get ev_charity_title;

  /// No description provided for @ev_charity_body.
  ///
  /// In tr, this message translates to:
  /// **'Kulübün düzenlediği yardım maçına katılman ve bağış yapman isteniyor.'**
  String get ev_charity_body;

  /// No description provided for @ev_charity_c0.
  ///
  /// In tr, this message translates to:
  /// **'Katıl ve maaşından bağışla.'**
  String get ev_charity_c0;

  /// No description provided for @ev_charity_r0.
  ///
  /// In tr, this message translates to:
  /// **'Hem insanlar hem basın bu jesti çok sevdi.'**
  String get ev_charity_r0;

  /// No description provided for @ev_charity_c1.
  ///
  /// In tr, this message translates to:
  /// **'Katıl ama bağış yapma.'**
  String get ev_charity_c1;

  /// No description provided for @ev_charity_r1.
  ///
  /// In tr, this message translates to:
  /// **'Sahadaydın, bu da bir şey.'**
  String get ev_charity_r1;

  /// No description provided for @ev_charity_c2.
  ///
  /// In tr, this message translates to:
  /// **'Katılma.'**
  String get ev_charity_c2;

  /// No description provided for @ev_charity_r2.
  ///
  /// In tr, this message translates to:
  /// **'Birileri hatırlayacak.'**
  String get ev_charity_r2;

  /// No description provided for @ev_transferRumor_title.
  ///
  /// In tr, this message translates to:
  /// **'Transfer dedikodusu'**
  String get ev_transferRumor_title;

  /// No description provided for @ev_transferRumor_body.
  ///
  /// In tr, this message translates to:
  /// **'Gazeteler adını başka bir kulüple yazıyor: \"Gizli görüşme yapıldı.\"'**
  String get ev_transferRumor_body;

  /// No description provided for @ev_transferRumor_c0.
  ///
  /// In tr, this message translates to:
  /// **'Yalanla: buradayım.'**
  String get ev_transferRumor_c0;

  /// No description provided for @ev_transferRumor_r0.
  ///
  /// In tr, this message translates to:
  /// **'Hoca bu sadakate sevindi.'**
  String get ev_transferRumor_r0;

  /// No description provided for @ev_transferRumor_c1.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yapma.'**
  String get ev_transferRumor_c1;

  /// No description provided for @ev_transferRumor_r1.
  ///
  /// In tr, this message translates to:
  /// **'Söylenti sürdü, adın konuşuldu.'**
  String get ev_transferRumor_r1;

  /// No description provided for @ev_transferRumor_c2.
  ///
  /// In tr, this message translates to:
  /// **'Ucu açık bırak, söylentiyi körükle.'**
  String get ev_transferRumor_c2;

  /// No description provided for @ev_transferRumor_r2.
  ///
  /// In tr, this message translates to:
  /// **'Gündemdesin ama kulüp ve taraftar rahatsız.'**
  String get ev_transferRumor_r2;

  /// No description provided for @ev_socialPost_title.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal medya fırtınası'**
  String get ev_socialPost_title;

  /// No description provided for @ev_socialPost_body.
  ///
  /// In tr, this message translates to:
  /// **'Eskiden attığın bir paylaşım gündem oldu, yorumlar alevlendi.'**
  String get ev_socialPost_body;

  /// No description provided for @ev_socialPost_c0.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşımı sil, konuşma.'**
  String get ev_socialPost_c0;

  /// No description provided for @ev_socialPost_r0.
  ///
  /// In tr, this message translates to:
  /// **'Fırtına yavaş yavaş dindi.'**
  String get ev_socialPost_r0;

  /// No description provided for @ev_socialPost_c1.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşımı savun.'**
  String get ev_socialPost_c1;

  /// No description provided for @ev_socialPost_r1.
  ///
  /// In tr, this message translates to:
  /// **'Destekçilerin sana sahip çıktı.'**
  String get ev_socialPost_r1;

  /// No description provided for @ev_socialPost_b1.
  ///
  /// In tr, this message translates to:
  /// **'Savunma ters tepti; olay daha da büyüdü.'**
  String get ev_socialPost_b1;

  /// No description provided for @ev_socialPost_c2.
  ///
  /// In tr, this message translates to:
  /// **'Açıkça özür dile.'**
  String get ev_socialPost_c2;

  /// No description provided for @ev_socialPost_r2.
  ///
  /// In tr, this message translates to:
  /// **'Özrün samimi bulundu ama biraz moralin bozuldu.'**
  String get ev_socialPost_r2;

  /// No description provided for @ev_injuryRehab_title.
  ///
  /// In tr, this message translates to:
  /// **'Rehabilitasyon kararı'**
  String get ev_injuryRehab_title;

  /// No description provided for @ev_injuryRehab_body.
  ///
  /// In tr, this message translates to:
  /// **'Sakatlığın uzun sürecek. Fizyoterapist sana bir program öneriyor.'**
  String get ev_injuryRehab_body;

  /// No description provided for @ev_injuryRehab_c0.
  ///
  /// In tr, this message translates to:
  /// **'Programa sıkı sıkıya bağlı kal.'**
  String get ev_injuryRehab_c0;

  /// No description provided for @ev_injuryRehab_r0.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli çalışman iyileşmeyi hızlandırdı.'**
  String get ev_injuryRehab_r0;

  /// No description provided for @ev_injuryRehab_c1.
  ///
  /// In tr, this message translates to:
  /// **'Gizlice ekstra çalış.'**
  String get ev_injuryRehab_c1;

  /// No description provided for @ev_injuryRehab_r1.
  ///
  /// In tr, this message translates to:
  /// **'Fazladan çalışman işe yaradı!'**
  String get ev_injuryRehab_r1;

  /// No description provided for @ev_injuryRehab_b1.
  ///
  /// In tr, this message translates to:
  /// **'Aşırıya kaçtın; sakatlığın nüksetme riski arttı.'**
  String get ev_injuryRehab_b1;

  /// No description provided for @ev_injuryRehab_c2.
  ///
  /// In tr, this message translates to:
  /// **'Ailenle vakit geçir, moral topla.'**
  String get ev_injuryRehab_c2;

  /// No description provided for @ev_injuryRehab_r2.
  ///
  /// In tr, this message translates to:
  /// **'Sevdiklerinin yanında içini rahatlattın.'**
  String get ev_injuryRehab_r2;

  /// No description provided for @ev_youthAcademy_title.
  ///
  /// In tr, this message translates to:
  /// **'Akademi ziyareti'**
  String get ev_youthAcademy_title;

  /// No description provided for @ev_youthAcademy_body.
  ///
  /// In tr, this message translates to:
  /// **'Kulüp, gençlik akademisini ziyaret etmeni istiyor. Çocuklar seni görmek için sabırsız.'**
  String get ev_youthAcademy_body;

  /// No description provided for @ev_youthAcademy_c0.
  ///
  /// In tr, this message translates to:
  /// **'Git, çocuklarla vakit geçir.'**
  String get ev_youthAcademy_c0;

  /// No description provided for @ev_youthAcademy_r0.
  ///
  /// In tr, this message translates to:
  /// **'Çocukların gözlerindeki ışık değdi.'**
  String get ev_youthAcademy_r0;

  /// No description provided for @ev_youthAcademy_c1.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta olmaz.'**
  String get ev_youthAcademy_c1;

  /// No description provided for @ev_youthAcademy_r1.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret bir başkasına kaldı.'**
  String get ev_youthAcademy_r1;

  /// No description provided for @ev_debtHelp_title.
  ///
  /// In tr, this message translates to:
  /// **'Borç baskısı'**
  String get ev_debtHelp_title;

  /// No description provided for @ev_debtHelp_body.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın eksiye düştü ve banka seni arıyor. Ne yapacaksın?'**
  String get ev_debtHelp_body;

  /// No description provided for @ev_debtHelp_c0.
  ///
  /// In tr, this message translates to:
  /// **'Aileden borç iste.'**
  String get ev_debtHelp_c0;

  /// No description provided for @ev_debtHelp_r0.
  ///
  /// In tr, this message translates to:
  /// **'Ailen yardım etti, ama bunu unutmayacaklar.'**
  String get ev_debtHelp_r0;

  /// No description provided for @ev_debtHelp_c1.
  ///
  /// In tr, this message translates to:
  /// **'Kimseden yardım isteme, kendin çöz.'**
  String get ev_debtHelp_c1;

  /// No description provided for @ev_debtHelp_r1.
  ///
  /// In tr, this message translates to:
  /// **'Gururun yerinde ama stres arttı.'**
  String get ev_debtHelp_r1;

  /// No description provided for @socialTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal'**
  String get socialTitle;

  /// No description provided for @socialPending.
  ///
  /// In tr, this message translates to:
  /// **'Cevap bekleyenler'**
  String get socialPending;

  /// No description provided for @socialNoPending.
  ///
  /// In tr, this message translates to:
  /// **'Şu an cevap bekleyen bir gelişme yok. Maçlardan ve haftalardan sonra yenileri gelir.'**
  String get socialNoPending;

  /// No description provided for @socialRelations.
  ///
  /// In tr, this message translates to:
  /// **'İlişkiler'**
  String get socialRelations;

  /// No description provided for @rel_coach.
  ///
  /// In tr, this message translates to:
  /// **'Teknik direktör'**
  String get rel_coach;

  /// No description provided for @rel_teammates.
  ///
  /// In tr, this message translates to:
  /// **'Takım arkadaşları'**
  String get rel_teammates;

  /// No description provided for @rel_fans.
  ///
  /// In tr, this message translates to:
  /// **'Taraftar'**
  String get rel_fans;

  /// No description provided for @rel_family.
  ///
  /// In tr, this message translates to:
  /// **'Aile'**
  String get rel_family;

  /// No description provided for @rel_media.
  ///
  /// In tr, this message translates to:
  /// **'Medya'**
  String get rel_media;

  /// No description provided for @relHint_coach.
  ///
  /// In tr, this message translates to:
  /// **'Maça çıkma şansını etkiler'**
  String get relHint_coach;

  /// No description provided for @relHint_teammates.
  ///
  /// In tr, this message translates to:
  /// **'Moral dengeni etkiler'**
  String get relHint_teammates;

  /// No description provided for @relHint_fans.
  ///
  /// In tr, this message translates to:
  /// **'Sponsor ve prim fırsatlarını etkiler'**
  String get relHint_fans;

  /// No description provided for @relHint_family.
  ///
  /// In tr, this message translates to:
  /// **'Moral dengeni etkiler'**
  String get relHint_family;

  /// No description provided for @relHint_media.
  ///
  /// In tr, this message translates to:
  /// **'Teklif sıklığını etkiler'**
  String get relHint_media;

  /// No description provided for @relLevel_0.
  ///
  /// In tr, this message translates to:
  /// **'Soğuk'**
  String get relLevel_0;

  /// No description provided for @relLevel_1.
  ///
  /// In tr, this message translates to:
  /// **'Mesafeli'**
  String get relLevel_1;

  /// No description provided for @relLevel_2.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get relLevel_2;

  /// No description provided for @relLevel_3.
  ///
  /// In tr, this message translates to:
  /// **'Sıcak'**
  String get relLevel_3;

  /// No description provided for @relLevel_4.
  ///
  /// In tr, this message translates to:
  /// **'Çok yakın'**
  String get relLevel_4;

  /// No description provided for @socialNews.
  ///
  /// In tr, this message translates to:
  /// **'Haber akışı'**
  String get socialNews;

  /// No description provided for @socialNewsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz haber yok.'**
  String get socialNewsEmpty;

  /// No description provided for @newsMatch.
  ///
  /// In tr, this message translates to:
  /// **'{opponent} maçı: {score}'**
  String newsMatch(String opponent, String score);

  /// No description provided for @newsMatchGoals.
  ///
  /// In tr, this message translates to:
  /// **'{opponent} maçı: {score} · {goals} gol'**
  String newsMatchGoals(String opponent, String score, String goals);

  /// No description provided for @newsSigned.
  ///
  /// In tr, this message translates to:
  /// **'{club} ile imza attın'**
  String newsSigned(String club);

  /// No description provided for @newsInjury.
  ///
  /// In tr, this message translates to:
  /// **'Sakatlandın: {type}, {weeks} hafta'**
  String newsInjury(String type, String weeks);

  /// No description provided for @newsEvent.
  ///
  /// In tr, this message translates to:
  /// **'{title}: {choice}'**
  String newsEvent(String title, String choice);

  /// No description provided for @eventKind_press.
  ///
  /// In tr, this message translates to:
  /// **'Basın toplantısı'**
  String get eventKind_press;

  /// No description provided for @eventKind_personal.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel'**
  String get eventKind_personal;

  /// No description provided for @eventKind_career.
  ///
  /// In tr, this message translates to:
  /// **'Kariyer'**
  String get eventKind_career;

  /// No description provided for @eventKind_money.
  ///
  /// In tr, this message translates to:
  /// **'Para'**
  String get eventKind_money;

  /// No description provided for @eventAnswer.
  ///
  /// In tr, this message translates to:
  /// **'Cevap ver'**
  String get eventAnswer;

  /// No description provided for @eventExpires.
  ///
  /// In tr, this message translates to:
  /// **'{weeks} hafta içinde cevapla'**
  String eventExpires(int weeks);

  /// No description provided for @eventExpiresLast.
  ///
  /// In tr, this message translates to:
  /// **'Son hafta!'**
  String get eventExpiresLast;

  /// No description provided for @eventChooseHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir seçenek seç. Etkilenecek alanlar işaretli, sonuç sürpriz.'**
  String get eventChooseHint;

  /// No description provided for @eventRiskyTag.
  ///
  /// In tr, this message translates to:
  /// **'Riskli'**
  String get eventRiskyTag;

  /// No description provided for @eventResult.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç'**
  String get eventResult;

  /// No description provided for @eventBackfired.
  ///
  /// In tr, this message translates to:
  /// **'Ters tepti!'**
  String get eventBackfired;

  /// No description provided for @eventDone.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get eventDone;

  /// No description provided for @effectMorale.
  ///
  /// In tr, this message translates to:
  /// **'Moral'**
  String get effectMorale;

  /// No description provided for @effectCondition.
  ///
  /// In tr, this message translates to:
  /// **'Kondisyon'**
  String get effectCondition;

  /// No description provided for @effectMoney.
  ///
  /// In tr, this message translates to:
  /// **'Para'**
  String get effectMoney;

  /// No description provided for @effectHeal.
  ///
  /// In tr, this message translates to:
  /// **'Sakatlık süresi'**
  String get effectHeal;

  /// No description provided for @effectHealValue.
  ///
  /// In tr, this message translates to:
  /// **'{weeks} hafta kısaldı'**
  String effectHealValue(int weeks);

  /// No description provided for @effectRelapse.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar sakatlanma riski'**
  String get effectRelapse;

  /// No description provided for @eventNewEvent.
  ///
  /// In tr, this message translates to:
  /// **'Yeni gelişme: {title}'**
  String eventNewEvent(String title);

  /// No description provided for @summaryPendingEvent.
  ///
  /// In tr, this message translates to:
  /// **'Cevap bekleyen bir gelişme var'**
  String get summaryPendingEvent;

  /// No description provided for @summaryAnswerNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Cevapla'**
  String get summaryAnswerNow;

  /// No description provided for @pendingEventsCard.
  ///
  /// In tr, this message translates to:
  /// **'{count} gelişme cevap bekliyor'**
  String pendingEventsCard(int count);

  /// No description provided for @pendingEventsHint.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal sekmesinde'**
  String get pendingEventsHint;

  /// No description provided for @seasonWeekShort.
  ///
  /// In tr, this message translates to:
  /// **'S{season} · H{week}'**
  String seasonWeekShort(int season, int week);

  /// No description provided for @profileCareerSection.
  ///
  /// In tr, this message translates to:
  /// **'Kariyer'**
  String get profileCareerSection;

  /// No description provided for @profileNationalCard.
  ///
  /// In tr, this message translates to:
  /// **'Milli Takım'**
  String get profileNationalCard;

  /// No description provided for @profileNationalSub.
  ///
  /// In tr, this message translates to:
  /// **'{caps} maç · {goals} gol'**
  String profileNationalSub(int caps, int goals);

  /// No description provided for @profileAchievementsCard.
  ///
  /// In tr, this message translates to:
  /// **'Başarımlar'**
  String get profileAchievementsCard;

  /// No description provided for @profileAchievementsSub.
  ///
  /// In tr, this message translates to:
  /// **'{done} / {total} açıldı'**
  String profileAchievementsSub(int done, int total);

  /// No description provided for @profileSummaryCard.
  ///
  /// In tr, this message translates to:
  /// **'Kariyer Özeti'**
  String get profileSummaryCard;

  /// No description provided for @profileSummarySub.
  ///
  /// In tr, this message translates to:
  /// **'Şimdiye kadarki yolculuğun'**
  String get profileSummarySub;

  /// No description provided for @retireButton.
  ///
  /// In tr, this message translates to:
  /// **'Futbolu Bırak'**
  String get retireButton;

  /// No description provided for @retireTitle.
  ///
  /// In tr, this message translates to:
  /// **'Futbolu bırakıyor musun?'**
  String get retireTitle;

  /// No description provided for @retireBody.
  ///
  /// In tr, this message translates to:
  /// **'Kariyerin burada biter ve kariyer özetin açılır. Bu geri alınamaz.'**
  String get retireBody;

  /// No description provided for @retireConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Evet, bırak'**
  String get retireConfirm;

  /// No description provided for @retireAgeHint.
  ///
  /// In tr, this message translates to:
  /// **'Emekli olmak için en az {age} yaşında olmalısın.'**
  String retireAgeHint(int age);

  /// No description provided for @tournament_continental.
  ///
  /// In tr, this message translates to:
  /// **'Kıtalar Kupası'**
  String get tournament_continental;

  /// No description provided for @tournament_world.
  ///
  /// In tr, this message translates to:
  /// **'Dünya Kupası'**
  String get tournament_world;

  /// No description provided for @round_0.
  ///
  /// In tr, this message translates to:
  /// **'Son 16'**
  String get round_0;

  /// No description provided for @round_1.
  ///
  /// In tr, this message translates to:
  /// **'Çeyrek Final'**
  String get round_1;

  /// No description provided for @round_2.
  ///
  /// In tr, this message translates to:
  /// **'Yarı Final'**
  String get round_2;

  /// No description provided for @round_3.
  ///
  /// In tr, this message translates to:
  /// **'Final'**
  String get round_3;

  /// No description provided for @stageResult_roundOf16.
  ///
  /// In tr, this message translates to:
  /// **'Son 16\'da elendi'**
  String get stageResult_roundOf16;

  /// No description provided for @stageResult_quarterFinal.
  ///
  /// In tr, this message translates to:
  /// **'Çeyrek finalde elendi'**
  String get stageResult_quarterFinal;

  /// No description provided for @stageResult_semiFinal.
  ///
  /// In tr, this message translates to:
  /// **'Yarı finalde elendi'**
  String get stageResult_semiFinal;

  /// No description provided for @stageResult_runnerUp.
  ///
  /// In tr, this message translates to:
  /// **'Finalde kaybetti'**
  String get stageResult_runnerUp;

  /// No description provided for @stageResult_champion.
  ///
  /// In tr, this message translates to:
  /// **'Şampiyon oldu'**
  String get stageResult_champion;

  /// No description provided for @natRole_starter.
  ///
  /// In tr, this message translates to:
  /// **'Ana kadro'**
  String get natRole_starter;

  /// No description provided for @natRole_rotation.
  ///
  /// In tr, this message translates to:
  /// **'Rotasyon'**
  String get natRole_rotation;

  /// No description provided for @natRole_reserve.
  ///
  /// In tr, this message translates to:
  /// **'Yedek'**
  String get natRole_reserve;

  /// No description provided for @nationalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Milli Takım'**
  String get nationalTitle;

  /// No description provided for @nationalCapsGoals.
  ///
  /// In tr, this message translates to:
  /// **'{caps} milli maç · {goals} gol'**
  String nationalCapsGoals(int caps, int goals);

  /// No description provided for @nationalStatusCalled.
  ///
  /// In tr, this message translates to:
  /// **'Kadrodasın · {role}'**
  String nationalStatusCalled(String role);

  /// No description provided for @nationalStatusOmitted.
  ///
  /// In tr, this message translates to:
  /// **'Bu turnuvanın kadrosunda değilsin. Ülkeni uzaktan destekle.'**
  String get nationalStatusOmitted;

  /// No description provided for @nationalStatusEliminated.
  ///
  /// In tr, this message translates to:
  /// **'Ülken turnuvadan elendi.'**
  String get nationalStatusEliminated;

  /// No description provided for @nationalStatusChampion.
  ///
  /// In tr, this message translates to:
  /// **'Ülken turnuvayı kazandı!'**
  String get nationalStatusChampion;

  /// No description provided for @nationalNextTournament.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki turnuva: {name}, sezon {season} sonunda.'**
  String nationalNextTournament(String name, int season);

  /// No description provided for @nationalEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz milli takım geçmişin yok. Turnuvalar iki sezonda bir, sezon arasında oynanır. Genel gücü ve formu yüksek, üst liglerde oynayan oyuncular çağrılır.'**
  String get nationalEmpty;

  /// No description provided for @nationalBracketTitle.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşmeler'**
  String get nationalBracketTitle;

  /// No description provided for @nationalRoundHeader.
  ///
  /// In tr, this message translates to:
  /// **'{round} · Hafta {week}'**
  String nationalRoundHeader(String round, int week);

  /// No description provided for @nationalHistoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş Turnuvalar'**
  String get nationalHistoryTitle;

  /// No description provided for @nationalHistoryLine.
  ///
  /// In tr, this message translates to:
  /// **'{name} · Sezon {season}'**
  String nationalHistoryLine(String name, int season);

  /// No description provided for @nationalHistorySub.
  ///
  /// In tr, this message translates to:
  /// **'{result} · {apps} maç, {goals} gol'**
  String nationalHistorySub(String result, int apps, int goals);

  /// No description provided for @nationalHistoryNotCalled.
  ///
  /// In tr, this message translates to:
  /// **'{result} · Kadroda değildin'**
  String nationalHistoryNotCalled(String result);

  /// No description provided for @nationalYouPlayed.
  ///
  /// In tr, this message translates to:
  /// **'Oynadın'**
  String get nationalYouPlayed;

  /// No description provided for @nationalPens.
  ///
  /// In tr, this message translates to:
  /// **'pen. {score}'**
  String nationalPens(String score);

  /// No description provided for @homeNationalCalled.
  ///
  /// In tr, this message translates to:
  /// **'{tournament} için milli takıma çağrıldın!'**
  String homeNationalCalled(String tournament);

  /// No description provided for @homeNationalNext.
  ///
  /// In tr, this message translates to:
  /// **'Bu sezon sonunda {tournament} var.'**
  String homeNationalNext(String tournament);

  /// No description provided for @homeNationalRound.
  ///
  /// In tr, this message translates to:
  /// **'{tournament} · {round}: {opponent}'**
  String homeNationalRound(String tournament, String round, String opponent);

  /// No description provided for @homeNationalOut.
  ///
  /// In tr, this message translates to:
  /// **'{tournament}: ülken elendi.'**
  String homeNationalOut(String tournament);

  /// No description provided for @homeNationalChampion.
  ///
  /// In tr, this message translates to:
  /// **'{tournament} şampiyonusun!'**
  String homeNationalChampion(String tournament);

  /// No description provided for @nationalMatchThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta milli maç var: {opponent}.'**
  String nationalMatchThisWeek(String opponent);

  /// No description provided for @nationalBenchedThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Milli takımda bu hafta yedeksin.'**
  String get nationalBenchedThisWeek;

  /// No description provided for @nationalNotCalledThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta turnuva maçı var ama kadroda değilsin.'**
  String get nationalNotCalledThisWeek;

  /// No description provided for @nationalEliminatedThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Ülken turnuvadan elendi, bu hafta maç yok.'**
  String get nationalEliminatedThisWeek;

  /// No description provided for @nationalInjuredThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Sakatsın, milli maçı kaçıracaksın.'**
  String get nationalInjuredThisWeek;

  /// No description provided for @playWeekNationalMatch.
  ///
  /// In tr, this message translates to:
  /// **'Milli Maçı Oyna'**
  String get playWeekNationalMatch;

  /// No description provided for @nationalMatchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Milli Maç · {round}'**
  String nationalMatchTitle(String round);

  /// No description provided for @nationalKnockoutNote.
  ///
  /// In tr, this message translates to:
  /// **'Eleme maçı: beraberlikte penaltılara gidilir.'**
  String get nationalKnockoutNote;

  /// No description provided for @shootoutWon.
  ///
  /// In tr, this message translates to:
  /// **'Penaltılarda kazandınız: {score}'**
  String shootoutWon(String score);

  /// No description provided for @shootoutLost.
  ///
  /// In tr, this message translates to:
  /// **'Penaltılarda kaybettiniz: {score}'**
  String shootoutLost(String score);

  /// No description provided for @eventNationalCalled.
  ///
  /// In tr, this message translates to:
  /// **'Milli takıma çağrıldın! {tournament} kadrosundasın ({role}).'**
  String eventNationalCalled(String tournament, String role);

  /// No description provided for @eventNationalOmitted.
  ///
  /// In tr, this message translates to:
  /// **'{tournament} kadrosunda yer alamadın.'**
  String eventNationalOmitted(String tournament);

  /// No description provided for @eventNationalMatch.
  ///
  /// In tr, this message translates to:
  /// **'{round}: {home} {score} {opponent}'**
  String eventNationalMatch(
    String round,
    String home,
    String score,
    String opponent,
  );

  /// No description provided for @eventNationalMatchPens.
  ///
  /// In tr, this message translates to:
  /// **'{round}: {home} {score} {opponent} ({pens})'**
  String eventNationalMatchPens(
    String round,
    String home,
    String score,
    String opponent,
    String pens,
  );

  /// No description provided for @eventNationalOut.
  ///
  /// In tr, this message translates to:
  /// **'{tournament}: {result}'**
  String eventNationalOut(String tournament, String result);

  /// No description provided for @eventNationalRunnerUp.
  ///
  /// In tr, this message translates to:
  /// **'{tournament} finalini kaybettiniz. Gurur duyulacak bir yol oldu.'**
  String eventNationalRunnerUp(String tournament);

  /// No description provided for @eventNationalChampion.
  ///
  /// In tr, this message translates to:
  /// **'ŞAMPİYONSUN! {tournament} kupasını kaldırdın!'**
  String eventNationalChampion(String tournament);

  /// No description provided for @eventAchievement.
  ///
  /// In tr, this message translates to:
  /// **'Başarım açıldı: {title}'**
  String eventAchievement(String title);

  /// No description provided for @eventRetired.
  ///
  /// In tr, this message translates to:
  /// **'Kariyerin sona erdi. Futbola veda ettin.'**
  String get eventRetired;

  /// No description provided for @money_nationalBonus.
  ///
  /// In tr, this message translates to:
  /// **'Milli takım primi'**
  String get money_nationalBonus;

  /// No description provided for @summarySeeCareer.
  ///
  /// In tr, this message translates to:
  /// **'Kariyer Özetini Gör'**
  String get summarySeeCareer;

  /// No description provided for @newsNational.
  ///
  /// In tr, this message translates to:
  /// **'{tournament}: {result}'**
  String newsNational(String tournament, String result);

  /// No description provided for @newsAchievement.
  ///
  /// In tr, this message translates to:
  /// **'Başarım: {title}'**
  String newsAchievement(String title);

  /// No description provided for @newsRetired.
  ///
  /// In tr, this message translates to:
  /// **'{age} yaşında futbolu bıraktın.'**
  String newsRetired(String age);

  /// No description provided for @achievementsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başarımlar'**
  String get achievementsTitle;

  /// No description provided for @achievementsProgress.
  ///
  /// In tr, this message translates to:
  /// **'{done} / {total}'**
  String achievementsProgress(int done, int total);

  /// No description provided for @achCategory_career.
  ///
  /// In tr, this message translates to:
  /// **'Kariyer'**
  String get achCategory_career;

  /// No description provided for @achCategory_club.
  ///
  /// In tr, this message translates to:
  /// **'Kulüp'**
  String get achCategory_club;

  /// No description provided for @achCategory_national.
  ///
  /// In tr, this message translates to:
  /// **'Milli Takım'**
  String get achCategory_national;

  /// No description provided for @achCategory_growth.
  ///
  /// In tr, this message translates to:
  /// **'Gelişim'**
  String get achCategory_growth;

  /// No description provided for @achCategory_wealth.
  ///
  /// In tr, this message translates to:
  /// **'Para'**
  String get achCategory_wealth;

  /// No description provided for @achLocked.
  ///
  /// In tr, this message translates to:
  /// **'Kilitli'**
  String get achLocked;

  /// No description provided for @ach_firstMatch_title.
  ///
  /// In tr, this message translates to:
  /// **'İlk Düdük'**
  String get ach_firstMatch_title;

  /// No description provided for @ach_firstMatch_desc.
  ///
  /// In tr, this message translates to:
  /// **'İlk maçına çık.'**
  String get ach_firstMatch_desc;

  /// No description provided for @ach_firstGoal_title.
  ///
  /// In tr, this message translates to:
  /// **'Ağlar Sallandı'**
  String get ach_firstGoal_title;

  /// No description provided for @ach_firstGoal_desc.
  ///
  /// In tr, this message translates to:
  /// **'İlk golünü at.'**
  String get ach_firstGoal_desc;

  /// No description provided for @ach_firstAssist_title.
  ///
  /// In tr, this message translates to:
  /// **'Takım Oyuncusu'**
  String get ach_firstAssist_title;

  /// No description provided for @ach_firstAssist_desc.
  ///
  /// In tr, this message translates to:
  /// **'İlk asistini yap.'**
  String get ach_firstAssist_desc;

  /// No description provided for @ach_goals10_title.
  ///
  /// In tr, this message translates to:
  /// **'Çift Haneli'**
  String get ach_goals10_title;

  /// No description provided for @ach_goals10_desc.
  ///
  /// In tr, this message translates to:
  /// **'Kariyerinde 10 gol at.'**
  String get ach_goals10_desc;

  /// No description provided for @ach_goals50_title.
  ///
  /// In tr, this message translates to:
  /// **'Golcü'**
  String get ach_goals50_title;

  /// No description provided for @ach_goals50_desc.
  ///
  /// In tr, this message translates to:
  /// **'Kariyerinde 50 gol at.'**
  String get ach_goals50_desc;

  /// No description provided for @ach_goals150_title.
  ///
  /// In tr, this message translates to:
  /// **'Gol Avcısı'**
  String get ach_goals150_title;

  /// No description provided for @ach_goals150_desc.
  ///
  /// In tr, this message translates to:
  /// **'Kariyerinde 150 gol at.'**
  String get ach_goals150_desc;

  /// No description provided for @ach_goals400_title.
  ///
  /// In tr, this message translates to:
  /// **'Gol Makinesi'**
  String get ach_goals400_title;

  /// No description provided for @ach_goals400_desc.
  ///
  /// In tr, this message translates to:
  /// **'Kariyerinde 400 gol at.'**
  String get ach_goals400_desc;

  /// No description provided for @ach_matches50_title.
  ///
  /// In tr, this message translates to:
  /// **'Yerleşik Oyuncu'**
  String get ach_matches50_title;

  /// No description provided for @ach_matches50_desc.
  ///
  /// In tr, this message translates to:
  /// **'50 maç oyna.'**
  String get ach_matches50_desc;

  /// No description provided for @ach_matches250_title.
  ///
  /// In tr, this message translates to:
  /// **'Sahanın Adamı'**
  String get ach_matches250_title;

  /// No description provided for @ach_matches250_desc.
  ///
  /// In tr, this message translates to:
  /// **'250 maç oyna.'**
  String get ach_matches250_desc;

  /// No description provided for @ach_matches500_title.
  ///
  /// In tr, this message translates to:
  /// **'Demir Adam'**
  String get ach_matches500_title;

  /// No description provided for @ach_matches500_desc.
  ///
  /// In tr, this message translates to:
  /// **'500 maç oyna.'**
  String get ach_matches500_desc;

  /// No description provided for @ach_hatTrick_title.
  ///
  /// In tr, this message translates to:
  /// **'Hat-trick'**
  String get ach_hatTrick_title;

  /// No description provided for @ach_hatTrick_desc.
  ///
  /// In tr, this message translates to:
  /// **'Tek maçta 3 gol at.'**
  String get ach_hatTrick_desc;

  /// No description provided for @ach_starPerformance_title.
  ///
  /// In tr, this message translates to:
  /// **'Maçın Adamı'**
  String get ach_starPerformance_title;

  /// No description provided for @ach_starPerformance_desc.
  ///
  /// In tr, this message translates to:
  /// **'Bir maçta 9.8 ve üzeri reyting al.'**
  String get ach_starPerformance_desc;

  /// No description provided for @ach_seasons10_title.
  ///
  /// In tr, this message translates to:
  /// **'On Yıllık Yol'**
  String get ach_seasons10_title;

  /// No description provided for @ach_seasons10_desc.
  ///
  /// In tr, this message translates to:
  /// **'10 sezon boyunca oyna.'**
  String get ach_seasons10_desc;

  /// No description provided for @ach_veteran_title.
  ///
  /// In tr, this message translates to:
  /// **'Tecrübe'**
  String get ach_veteran_title;

  /// No description provided for @ach_veteran_desc.
  ///
  /// In tr, this message translates to:
  /// **'35 yaşına ulaş.'**
  String get ach_veteran_desc;

  /// No description provided for @ach_firstTransfer_title.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Sayfa'**
  String get ach_firstTransfer_title;

  /// No description provided for @ach_firstTransfer_desc.
  ///
  /// In tr, this message translates to:
  /// **'Kulüp değiştir.'**
  String get ach_firstTransfer_desc;

  /// No description provided for @ach_topLeague_title.
  ///
  /// In tr, this message translates to:
  /// **'Büyükler Ligi'**
  String get ach_topLeague_title;

  /// No description provided for @ach_topLeague_desc.
  ///
  /// In tr, this message translates to:
  /// **'En üst ligde bir kulüpte oyna.'**
  String get ach_topLeague_desc;

  /// No description provided for @ach_leagueChampion_title.
  ///
  /// In tr, this message translates to:
  /// **'Şampiyon'**
  String get ach_leagueChampion_title;

  /// No description provided for @ach_leagueChampion_desc.
  ///
  /// In tr, this message translates to:
  /// **'Bir sezonu ligin zirvesinde bitir.'**
  String get ach_leagueChampion_desc;

  /// No description provided for @ach_topLeagueChampion_title.
  ///
  /// In tr, this message translates to:
  /// **'Zirvenin Sahibi'**
  String get ach_topLeagueChampion_title;

  /// No description provided for @ach_topLeagueChampion_desc.
  ///
  /// In tr, this message translates to:
  /// **'En üst ligde şampiyon ol.'**
  String get ach_topLeagueChampion_desc;

  /// No description provided for @ach_loyal_title.
  ///
  /// In tr, this message translates to:
  /// **'Sadık Yürek'**
  String get ach_loyal_title;

  /// No description provided for @ach_loyal_desc.
  ///
  /// In tr, this message translates to:
  /// **'Aynı kulüpte arka arkaya 10 sezon geçir.'**
  String get ach_loyal_desc;

  /// No description provided for @ach_agentTop_title.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü Bağlantılar'**
  String get ach_agentTop_title;

  /// No description provided for @ach_agentTop_desc.
  ///
  /// In tr, this message translates to:
  /// **'En üst seviye menajerle çalış.'**
  String get ach_agentTop_desc;

  /// No description provided for @ach_nationalDebut_title.
  ///
  /// In tr, this message translates to:
  /// **'Milli Forma'**
  String get ach_nationalDebut_title;

  /// No description provided for @ach_nationalDebut_desc.
  ///
  /// In tr, this message translates to:
  /// **'Milli takımda ilk maçına çık.'**
  String get ach_nationalDebut_desc;

  /// No description provided for @ach_nationalGoal_title.
  ///
  /// In tr, this message translates to:
  /// **'Milli Gol'**
  String get ach_nationalGoal_title;

  /// No description provided for @ach_nationalGoal_desc.
  ///
  /// In tr, this message translates to:
  /// **'Milli takım adına gol at.'**
  String get ach_nationalGoal_desc;

  /// No description provided for @ach_nationalFinal_title.
  ///
  /// In tr, this message translates to:
  /// **'Büyük Final'**
  String get ach_nationalFinal_title;

  /// No description provided for @ach_nationalFinal_desc.
  ///
  /// In tr, this message translates to:
  /// **'Bir turnuvada finale çık.'**
  String get ach_nationalFinal_desc;

  /// No description provided for @ach_continentalChampion_title.
  ///
  /// In tr, this message translates to:
  /// **'Kıtanın Zirvesi'**
  String get ach_continentalChampion_title;

  /// No description provided for @ach_continentalChampion_desc.
  ///
  /// In tr, this message translates to:
  /// **'Kıtalar Kupası\'nı kazan.'**
  String get ach_continentalChampion_desc;

  /// No description provided for @ach_worldChampion_title.
  ///
  /// In tr, this message translates to:
  /// **'Dünya Şampiyonu'**
  String get ach_worldChampion_title;

  /// No description provided for @ach_worldChampion_desc.
  ///
  /// In tr, this message translates to:
  /// **'Dünya Kupası\'nı kazan.'**
  String get ach_worldChampion_desc;

  /// No description provided for @ach_overall70_title.
  ///
  /// In tr, this message translates to:
  /// **'Yükselen Yıldız'**
  String get ach_overall70_title;

  /// No description provided for @ach_overall70_desc.
  ///
  /// In tr, this message translates to:
  /// **'Genel gücünü 70\'e çıkar.'**
  String get ach_overall70_desc;

  /// No description provided for @ach_overall80_title.
  ///
  /// In tr, this message translates to:
  /// **'Dünya Sınıfı'**
  String get ach_overall80_title;

  /// No description provided for @ach_overall80_desc.
  ///
  /// In tr, this message translates to:
  /// **'Genel gücünü 80\'e çıkar.'**
  String get ach_overall80_desc;

  /// No description provided for @ach_overall90_title.
  ///
  /// In tr, this message translates to:
  /// **'Efsane Seviyesi'**
  String get ach_overall90_title;

  /// No description provided for @ach_overall90_desc.
  ///
  /// In tr, this message translates to:
  /// **'Genel gücünü 90\'a çıkar.'**
  String get ach_overall90_desc;

  /// No description provided for @ach_fanIdol_title.
  ///
  /// In tr, this message translates to:
  /// **'Tribünlerin Gözdesi'**
  String get ach_fanIdol_title;

  /// No description provided for @ach_fanIdol_desc.
  ///
  /// In tr, this message translates to:
  /// **'Taraftar ilişkisini en üst düzeye çıkar.'**
  String get ach_fanIdol_desc;

  /// No description provided for @ach_comfortable_title.
  ///
  /// In tr, this message translates to:
  /// **'Rahat Yaşam'**
  String get ach_comfortable_title;

  /// No description provided for @ach_comfortable_desc.
  ///
  /// In tr, this message translates to:
  /// **'Bakiyeni 100.000 ₺\'ye ulaştır.'**
  String get ach_comfortable_desc;

  /// No description provided for @ach_millionaire_title.
  ///
  /// In tr, this message translates to:
  /// **'Milyoner'**
  String get ach_millionaire_title;

  /// No description provided for @ach_millionaire_desc.
  ///
  /// In tr, this message translates to:
  /// **'Bakiyeni 1.000.000 ₺\'ye ulaştır.'**
  String get ach_millionaire_desc;

  /// No description provided for @summaryTitleRetired.
  ///
  /// In tr, this message translates to:
  /// **'Kariyer Özeti'**
  String get summaryTitleRetired;

  /// No description provided for @summaryTitleLive.
  ///
  /// In tr, this message translates to:
  /// **'Kariyerin Şu Ana Kadar'**
  String get summaryTitleLive;

  /// No description provided for @summaryRetiredAt.
  ///
  /// In tr, this message translates to:
  /// **'{age} yaşında futbolu bıraktı'**
  String summaryRetiredAt(int age);

  /// No description provided for @summaryLegacy.
  ///
  /// In tr, this message translates to:
  /// **'Miras'**
  String get summaryLegacy;

  /// No description provided for @legacy_amateur.
  ///
  /// In tr, this message translates to:
  /// **'Amatör Ruh'**
  String get legacy_amateur;

  /// No description provided for @legacy_local.
  ///
  /// In tr, this message translates to:
  /// **'Yerel Kahraman'**
  String get legacy_local;

  /// No description provided for @legacy_pro.
  ///
  /// In tr, this message translates to:
  /// **'Profesyonel'**
  String get legacy_pro;

  /// No description provided for @legacy_star.
  ///
  /// In tr, this message translates to:
  /// **'Yıldız'**
  String get legacy_star;

  /// No description provided for @legacy_legend.
  ///
  /// In tr, this message translates to:
  /// **'Efsane'**
  String get legacy_legend;

  /// No description provided for @legacyBlurb_amateur.
  ///
  /// In tr, this message translates to:
  /// **'Sahada az göründün ama futbol sevgin gerçekti.'**
  String get legacyBlurb_amateur;

  /// No description provided for @legacyBlurb_local.
  ///
  /// In tr, this message translates to:
  /// **'Mahallede adın hâlâ anılır; tribünler seni unutmadı.'**
  String get legacyBlurb_local;

  /// No description provided for @legacyBlurb_pro.
  ///
  /// In tr, this message translates to:
  /// **'Yıllarca sağlam bir kariyer sürdürdün; saygın bir isimsin.'**
  String get legacyBlurb_pro;

  /// No description provided for @legacyBlurb_star.
  ///
  /// In tr, this message translates to:
  /// **'Gollerin ve kupalarınla bir döneme damga vurdun.'**
  String get legacyBlurb_star;

  /// No description provided for @legacyBlurb_legend.
  ///
  /// In tr, this message translates to:
  /// **'Adın futbol tarihine yazıldı. Gelecek kuşaklar seni konuşacak.'**
  String get legacyBlurb_legend;

  /// No description provided for @sumStat_matches.
  ///
  /// In tr, this message translates to:
  /// **'Maç'**
  String get sumStat_matches;

  /// No description provided for @sumStat_goals.
  ///
  /// In tr, this message translates to:
  /// **'Gol'**
  String get sumStat_goals;

  /// No description provided for @sumStat_assists.
  ///
  /// In tr, this message translates to:
  /// **'Asist'**
  String get sumStat_assists;

  /// No description provided for @sumStat_rating.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Reyting'**
  String get sumStat_rating;

  /// No description provided for @sumStat_seasons.
  ///
  /// In tr, this message translates to:
  /// **'Sezon'**
  String get sumStat_seasons;

  /// No description provided for @sumStat_peak.
  ///
  /// In tr, this message translates to:
  /// **'Zirve Güç'**
  String get sumStat_peak;

  /// No description provided for @sumStat_clubs.
  ///
  /// In tr, this message translates to:
  /// **'Kulüp'**
  String get sumStat_clubs;

  /// No description provided for @sumStat_titles.
  ///
  /// In tr, this message translates to:
  /// **'Lig Şampiyonluğu'**
  String get sumStat_titles;

  /// No description provided for @sumStat_caps.
  ///
  /// In tr, this message translates to:
  /// **'Milli Maç'**
  String get sumStat_caps;

  /// No description provided for @sumStat_natTitles.
  ///
  /// In tr, this message translates to:
  /// **'Turnuva Kupası'**
  String get sumStat_natTitles;

  /// No description provided for @sumStat_bestLeague.
  ///
  /// In tr, this message translates to:
  /// **'En Üst Lig'**
  String get sumStat_bestLeague;

  /// No description provided for @sumStat_achievements.
  ///
  /// In tr, this message translates to:
  /// **'Başarım'**
  String get sumStat_achievements;

  /// No description provided for @summarySeasonsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sezon Sezon'**
  String get summarySeasonsTitle;

  /// No description provided for @summarySeasonTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sezon {season} · {age} yaş'**
  String summarySeasonTitle(int season, int age);

  /// No description provided for @summarySeasonSub.
  ///
  /// In tr, this message translates to:
  /// **'{club} · {league}'**
  String summarySeasonSub(String club, String league);

  /// No description provided for @summarySeasonStats.
  ///
  /// In tr, this message translates to:
  /// **'{matches} maç · {goals} gol · {assists} asist'**
  String summarySeasonStats(int matches, int goals, int assists);

  /// No description provided for @summaryPosition.
  ///
  /// In tr, this message translates to:
  /// **'{pos}. sırada bitirdi'**
  String summaryPosition(int pos);

  /// No description provided for @summaryNoClub.
  ///
  /// In tr, this message translates to:
  /// **'Kulüpsüz'**
  String get summaryNoClub;

  /// No description provided for @summaryBalance.
  ///
  /// In tr, this message translates to:
  /// **'Son bakiye'**
  String get summaryBalance;

  /// No description provided for @summaryHonorsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Öne Çıkanlar'**
  String get summaryHonorsTitle;

  /// No description provided for @summaryToMenu.
  ///
  /// In tr, this message translates to:
  /// **'Ana Menüye Dön'**
  String get summaryToMenu;

  /// No description provided for @summaryBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get summaryBack;

  /// No description provided for @summaryOpenAchievements.
  ///
  /// In tr, this message translates to:
  /// **'Başarımlar'**
  String get summaryOpenAchievements;

  /// No description provided for @slotRetired.
  ///
  /// In tr, this message translates to:
  /// **'Emekli · {age} yaş · Zirve {peak}'**
  String slotRetired(int age, int peak);

  /// No description provided for @ach_tycoon_title.
  ///
  /// In tr, this message translates to:
  /// **'Servet Sahibi'**
  String get ach_tycoon_title;

  /// No description provided for @ach_tycoon_desc.
  ///
  /// In tr, this message translates to:
  /// **'Bakiyeni 25.000.000 ₺\'ye ulaştır.'**
  String get ach_tycoon_desc;
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
