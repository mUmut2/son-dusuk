# Son Düdük

16 yaşında başla, dünya yıldızı ol. Kurgusal bir futbolcu kariyer oyunu: maçta yalnızca kritik anları oynarsın, kararların uzun vadeli sonuçları olur.

> **Durum:** Faz 0 — altyapı hazır, oyun geliştirme aşamasında.
> ▶ Oyna: _GitHub Pages bağlantısı Faz 9'da eklenecek._

**Felsefe:** reklam yok, gerçek para yok, enerji bekleme süresi yok. İlerleme yalnızca karar ve becerinle olur. Tüm kulüp, oyuncu ve lig isimleri kurguseldir.

## Özellikler (planlanan)

- Oyuncu gelişimi, yaş eğrisi, form / kondisyon / moral / sakatlık
- Seed'li maç simülasyonu + Flame ile mini oyunlar (şut, penaltı, serbest vuruş, pas, dribling, kafa, savunma)
- Transfer, kontrat, menajer, ekonomi
- Olay motoru, basın, ilişkiler, başarımlar
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

## Yol Haritası

Faz 0 Hazırlık ✅ · 1 Oyuncu/kariyer · 2 Lig + simülasyon · 3 Şut · 4 Haftalık döngü · 5 Diğer mini oyunlar · 6 Transfer/ekonomi · 7 Olaylar/sosyal · 8 Milli takım/başarım · 9 Cila ve yayın

## Lisans

Henüz belirlenmedi (Faz 9'da eklenecek).

---

## English summary

**Son Düdük** ("The Final Whistle") is an offline, single-player football career game built with Flutter and Flame, in the spirit of mobile career sims but with deeper long-term consequences and no ads, IAP, or energy timers. You play only the critical moments of each match; the rest is career management. All clubs, players, and leagues are fictional. In-game language is Turkish (localization-ready via ARB files). Currently at Phase 0 (project scaffold).
