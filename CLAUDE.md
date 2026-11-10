# CLAUDE.md — Son Düdük

Kurgusal, tamamen offline bir futbolcu kariyer oyunu (Flutter). 16 yaşında başlayıp 38-40'a kadar süren kariyer; maçta yalnızca kritik anlar oynanır (Flame mini oyunlar), geri kalanı kariyer kararlarıdır. Ayrıntılı vizyon: `docs/GDD.md`, mimari: `docs/ARCHITECTURE.md`.

## Çalışma kuralları (kullanıcıyla anlaşma)

1. İş KÜÇÜK FAZLARA bölünür. Her fazın sonunda DUR, özetle, nasıl test edileceğini söyle, kullanıcının "devam" demesini bekle. Onaysız sonraki faza geçme.
2. Faza başlamadan önce 5-10 maddelik plan yaz, sonra uygula.
3. Faz sonunda: `flutter analyze` temiz, `flutter test` geçiyor, uygulama açılıyor. Sonuçları raporla.
4. Her faz için ayrı commit; Conventional Commits (feat:, fix:, docs:, refactor:, test:, chore:), mesajlar İngilizce.
5. Emin olmadığın tasarım kararında tahmin yürütme, kısa soru sor.
6. Paket API'sini tahmin etme; eklemeden önce güncel kullanımı doğrula.
7. Gereksiz soyutlama / paket / aşırı mühendislik yok. Basit, okunabilir kod.
8. Telif: gerçek kulüp, oyuncu, lig, logo, forma, stadyum, lisanslı asset YOK. Her şey kurgusal.
9. Reklam, gerçek parayla satın alma, enerji bekleme süresi, pay-to-win YOK. İlerleme sadece karar ve beceriyle.
10. Oyun içi tüm metinler TÜRKÇE ve koda gömülmez: `assets/l10n/app_tr.arb` (varsayılan dil `tr`). Kodda `AppLocalizations.of(context)` kullan.

## Faz planı

0 Hazırlık ✅ · 1 Oyuncu/kariyer çekirdeği ✅ · 2 Takvim+lig+maç simülasyonu ✅ · 3 Şut mini oyunu (Flame) ✅ · 4 Haftalık yaşam döngüsü ✅ · 5 Diğer mini oyunlar ✅ · 6 Transfer/kontrat/menajer/ekonomi ✅ · 7 Sosyal/olay motoru ✅ · 8 Milli takım/başarım/emeklilik ✅ · 9 Cila ve yayın (CI/CD ✅, Pages ✅, Android imza ✅, ses ✅; README görselleri ve Android derleme doğrulaması bekliyor).

## Mimari kuralları

```
lib/
  app/           uygulama kökü, tema, router, l10n (üretilen kod: lib/app/l10n)
  core/          GameRandom, sabitler, yardımcılar — saf Dart
  domain/        modeller ve kurallar — saf Dart (player, career, match, league, economy, social, events)
  data/          kayıt/yükleme, repository'ler
  presentation/  ekranlar, widget'lar, Riverpod provider'ları
  game/          Flame mini oyunlar
```

- `domain` ve `core` ASLA `flutter`/`flame`/`flutter_riverpod`/`go_router` import etmez (`test/architecture_test.dart` bunu denetler).
- Tüm rastgelelik `GameRandom` üzerinden (seed verilebilir); domain'de doğrudan `Random` kullanma.
- Mini oyunlar domain'e basit sonuç nesnesiyle döner (örn. `ShotResult`).
- Mini oyun/denge parametreleri tek bir denge dosyasında toplanır, koda gömülmez.
- Modeller immutable; freezed kullanılmıyor, elle yazılır (build_runner karmaşası yok).
- Kayıt: `shared_preferences` + JSON, 3 slot, zarf `{schemaVersion, savedAt, career}`. Şema değişirse `currentSchemaVersion`'ı artır ve `lib/data/save_migrations.dart`'a göç adımı ekle.
- State: `lib/presentation/providers.dart` (aktif kariyer, slotlar, ayarlar). Router bir provider'dır (`routerProvider`); oyun rotaları (`/game/*`) aktif kariyer yoksa `/`'e yönlenir.
- Yeni enum/metin eklerken ARB'ye yaz, enum eşlemesi `presentation/l10n_labels.dart`'ta.
- Maç denge parametreleri yalnızca `lib/domain/match/match_balance.dart`'ta; değiştirince `dart run tool/match_stats.dart` ile istatistiği kontrol et ve `test/domain/match` testlerini çalıştır.
- Oyuncunun maçı `MatchSession` ile yürür (anlar -> `MomentOutcome` -> skor). Mini oyunlar `MomentOutcome` döndürür.
- Mini oyun deseni: fizik/sonuç `domain/match/<oyun>/` içinde saf Dart (`*_resolver.dart`, `*_balance.dart`), Flame oyunu `lib/game/<oyun>/` içinde yalnızca girdi + animasyon, swipe/koordinat mantığı `*_geometry.dart` (test edilebilir). Sonuç `MomentOutcome`'a çevrilir. Denge için `dart run tool/shot_stats.dart`.
- Haftalık döngü: `WeekEngine.advance(state, plan, match, random)` tek giriş noktası; denge `week_balance.dart`. Kayıt şeması 2; şemayı değiştirince `save_migrations.dart`'a adım ekle. Mini oyunlar `PlayerStatus` (form/kondisyon/moral) kullanır.
- Mini oyunlar: `MiniGameView` (lib/game/mini_game_view.dart) tür -> oyun fabrikasıdır; şut/bire bir/serbest vuruş/kafa `ShotGame` varyantı, diğerleri `MiniGameBase` alt sınıfları (penalty/, pass/, dribble/, tackle/). Dokunma katmanı `containsLocalPoint => true` olmalı. Yeni mini oyun: `mini_balance.dart` + `domain/match/minigames/<oyun>.dart` + Flame sınıfı + `tool/minigame_stats.dart` + `test/mini_games_widget_test.dart`. Flame oyunlarında `late` alan kullanma, boş girdiyle bitişi test et.
- Kulüp sistemi (Faz 6): `domain/club/` (contract, transfer_offer, agent, finance, squad, transfer_market, club_engine, club_balance). Dünya `ClubWorld(worldSeed)` ile her seferinde aynı seed'den kurulur (takımlar kayda yazılmaz; sağlayıcı `clubWorldProvider`). Oyuncunun maçı kulübünün fikstüründen gelir; `Squad.matchDay` o hafta maç var mı (play/benched/injured/none) söyler. Kulüp/ekonomi parametreleri yalnızca `club_balance.dart`'ta; değiştirince `dart run tool/club_stats.dart`. Kayıt şeması 4 (v3→v4: `CareerFactory.assignClub`). Yeni kayıt alanı eklersen `currentSchemaVersion`'ı artır ve göç adımı yaz.
- Sosyal sistem (Faz 7): `domain/social/` (relationships, event_models, event_catalog, social_engine, social_balance). Yeni olay: `event_catalog.dart`'a şablon + ARB'ye `ev_<id>_title/body/c<n>/r<n>(/b<n>)` + `presentation/event_texts.dart`'a eşleme; `test/domain/social/social_test.dart` metin eksiğini yakalar. Olay arayüzü `presentation/social/` (SocialTab, EventScreen, rota `/game/event/:id`). Denge `social_balance.dart`; `dart run tool/social_stats.dart`. Kayıt şeması 5.
- Milli takım/başarım/emeklilik (Faz 8): `domain/national/` (nation, national_career, tournament, national_engine, national_balance), `domain/achievements/achievements.dart`, `domain/career/retirement.dart` + `legacy_balance.dart` + `season_record.dart`. Turnuva çift sezonlarda 39-42. haftalarda (16 ülke, eleme); `NationalEngine.dayOf` o haftanın durumunu verir, maç ekranı ona göre lig/turnuva maçı oynatır. Yeni başarım: `Achievement` enum + `isMet` + ARB `ach_<ad>_title/desc` + `achievementIcon` + `l10n_labels` eşlemesi. Denge: `national_balance.dart`, `legacy_balance.dart`; `dart run tool/national_stats.dart`. Kayıt şeması 6. Emekli kayıtta `/game` rotaları `/game/summary`'ye yönlenir.
- Çocuk dostu ayarlama (Faz 9): varsayılan zorluk Kolay; dribling/pas/müdahale pencereleri geniş (`mini_balance.dart`). Karakter çizimi tek yerde: `lib/game/person_painter.dart` (`paintPerson`; `variant` saç biçimi/saç ve ten rengini, `keeper` kaleci eldivenini seçer; gövde sınırı `personBounds`, boy ≈ 6.1 birim). Ekipman: `domain/club/equipment.dart` (krampon/antrenman/toparlanma/tekmelik, seviye 0-3, fiyatlar ve etkiler `club_balance.dart`), `ClubActions.buyEquipment`, arayüz `presentation/equipment/equipment_screen.dart` (rota `/game/equipment`; Ana Sayfa ve Antrenman sekmesindeki `EquipmentCard` ile açılır). Krampon yalnızca maç/mini oyunlarda `Equipment.applyToPlayer` ile geçici artı verir. Kayıt şeması 7. Dribling beceri oyunudur: aşağı inen savunmacı dalgalarının arasındaki geçitten parmakla geç (`DribbleResolver.generateWaves/gapHalf/isHit`). Pas sahnesi yerleşimi `lib/game/pass/pass_geometry.dart`'tadır; figürler sütunlara ayrılır ve `test/game/layout_overlap_test.dart` çakışma olmadığını doğrular (yeni sahne eklerken `personBounds` ile aynısını yap).
- Ses: efektler `assets/sounds/*.wav`, `tool/make_sounds.dart` ile koddan üretilir (telifli ses yok; yeniden üretmek için `dart run tool/make_sounds.dart`). Çalma `lib/game/sound_service.dart` (`Sfx` enum, `audioplayers`), arayüzden `ref.playSfx(Sfx.x)` (ayarlardaki Ses kapalıysa çalmaz, `providers.dart`). Mini oyunlar `MiniGameView.onSound` ile bildirir; ses hataları oyunu bozmaz. Yeni efekt: `make_sounds.dart`'a ekle, `Sfx`'e değer ekle (`test/sound_test.dart` dosyayı denetler).
- Spiker (canlı anlatım): `domain/match/commentary.dart` (`MatchCommentator.segment/momentIntro/momentResult`, saf Dart, `CommentaryKind` enum) + `commentary_balance.dart` (hız/aralık). Metinler ARB'de tür başına tek anahtar `cm_<tür>`; cümle varyantları `|` ile ayrılır, yer tutucular `%team%` (satırın takımı) / `%other%` / `%player%` (ICU değil, düz metin; takım adına ek getirme!). Yeni tür: enum'a ekle (`variants` = cümle sayısı), ARB'ye `cm_<tür>`, `presentation/match/commentary_texts.dart` eşlemesine ekle; `test/commentary_test.dart` sayıyı denetler. Maç ekranı `_Stage.live`: kritik anlar arasında dakika ilerler, satırlar `CommentaryFeed`'e düşer ("Geç" ile atlanır, son bölümde "Maç Özeti" düğmesi). Spiker ayrı `GameRandom` kullanır (maç sonuçlarını etkilemez). Anlatım metinlerinde ". dakika" geçmemeli (testler bunu sayar).
- Form 0-10 (son 5 maç ortalaması, varsayılan 6.0); `PlayerStatus.formBonus` performansa çevirir.
- Gizli nitelikler (potansiyel, sakatlanma eğilimi, profesyonellik) arayüzde gösterilmez.

## Komutlar

```bash
flutter pub get
flutter gen-l10n          # ARB değişince (flutter run/test da otomatik üretir)
flutter analyze
flutter test
flutter run -d chrome     # web
flutter build web --release
```

## Ortam notları

- Flutter 3.35.7 / Dart 3.9.2. `intl` sürümü SDK'nın `flutter_localizations` bağımlılığıyla uyumlu tutulmalı (^0.20.2).
- Android toolchain bu makinede eksik (cmdline-tools, lisanslar); Faz 0-8 web üzerinden doğrulanır, Android derlemesi Faz 9'da kurulacak.
