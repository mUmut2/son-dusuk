# Son Düdük

16 yaşında başla, dünya yıldızı ol. Kurgusal bir futbolcu kariyer oyunu: maçta yalnızca kritik anları oynarsın, kararların uzun vadeli sonuçları olur.

> **Durum:** Faz 8 tamam; Faz 9 (cila ve yayın) sürüyor. Tüm sistemler oynanabilir: kariyer, maç + mini oyunlar, transfer/ekonomi, olaylar, milli takım, başarımlar, emeklilik.
> ▶ Oyna: GitHub Pages yayınlanınca `https://<kullanıcı>.github.io/<depo>/` adresinde (bkz. Yayın).

**Felsefe:** reklam yok, gerçek para yok, enerji bekleme süresi yok. İlerleme yalnızca karar ve becerinle olur. Tüm kulüp, oyuncu ve lig isimleri kurguseldir.

## Özellikler

- Oyuncu gelişimi, yaş eğrisi, form / kondisyon / moral / sakatlık
- Seed'li maç simülasyonu + Flame ile mini oyunlar (şut, penaltı, serbest vuruş, pas, dribling, kafa, savunma)
- Transfer, kontrat, menajer, ekonomi
- Olay motoru, basın, ilişkiler
- Milli takım turnuvaları, 32 başarım, kariyer özeti ve emeklilik
- 3 kayıt slotu, tamamen offline

Yol haritası ve tasarım: [`docs/GDD.md`](docs/GDD.md), mimari: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Tasarım Kararları

- Oyun mantığı saf Dart (`lib/domain`), Flutter'dan bağımsız ve testlerle doğrulanır.
- Kayıt: `shared_preferences` + JSON (web dahil her yerde çalışır).
- Tüm metinler ARB dosyalarında, varsayılan dil Türkçe.

Gerekçelerin tamamı GDD'de.

## Kurulum ve Çalıştırma

```bash
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

Gereksinim: Flutter 3.35+ (Dart 3.9+).

## Yayın

- **CI** (`.github/workflows/ci.yml`): her push/PR'da `flutter analyze` + `flutter test`.
- **Web** (`pages.yml`): `main`'e push edilince testler geçerse GitHub Pages'e yayınlanır. Depo ayarlarında Pages kaynağını "GitHub Actions" yapın.
- **Android** (`android.yml`): `v*` etiketi ya da elle tetikleme ile APK + AAB derler. İmza için `ANDROID_KEYSTORE_B64` ve `ANDROID_KEY_PROPERTIES` (storeFile, storePassword, keyAlias, keyPassword) sırlarını ekleyin; yoksa debug imzası kullanılır.

## Yol Haritası

Faz 0-8 ✅ · 9 Cila ve yayın (CI/CD, Pages, Android release hazır; ses ve ekran görüntüleri elle test sonrası)

## Lisans

Henüz belirlenmedi.

---

## English summary

**Son Düdük** ("The Final Whistle") is an offline, single-player football career game built with Flutter and Flame, in the spirit of mobile career sims but with deeper long-term consequences and no ads, IAP, or energy timers. You play only the critical moments of each match; the rest is career management. All clubs, players, and leagues are fictional. In-game language is Turkish (localization-ready via ARB files). All gameplay systems are implemented; the project is in its release-polish phase.
