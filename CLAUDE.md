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

0 Hazırlık ✅ · 1 Oyuncu/kariyer çekirdeği · 2 Takvim+lig+maç simülasyonu · 3 Şut mini oyunu (Flame) · 4 Haftalık yaşam döngüsü · 5 Diğer mini oyunlar · 6 Transfer/kontrat/menajer/ekonomi · 7 Sosyal/olay motoru · 8 Milli takım/başarım/emeklilik · 9 Cila ve yayın (CI/CD, Pages, README görselleri, Android release).

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
- Kayıt: `shared_preferences` + JSON, 3 slot, `schemaVersion` ile sürümleme (Faz 1'de kurulacak).

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
