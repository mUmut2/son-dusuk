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
