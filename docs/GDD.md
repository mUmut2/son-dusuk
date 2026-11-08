# Son Düdük — Oyun Tasarım Dokümanı (GDD)

> Durum: İSKELET (Faz 0). Her fazda güncellenir.

## 1. Vizyon

16 yaşında genç bir futbolcuyu amatör liglerden dünya yıldızlığına taşıyan, tamamen offline, tek oyunculu kariyer oyunu. Maçın yalnızca kritik anları oynanır; kararların gerçek ve uzun vadeli sonuçları vardır.

**Temel felsefe:** reklam yok, gerçek para yok, enerji bekleme süresi yok, pay-to-win yok. İlerleme yalnızca oyuncunun kararları ve becerisiyle olur.

**Hedef platform:** Android + Web (GitHub Pages demo), sonra iOS. Dikey yön, tek elle oynanabilir.

## 2. Sistemler (özet — fazlarda detaylanacak)

| Sistem | Faz | Durum |
|---|---|---|
| Oyuncu, nitelikler, yaş eğrisi | 1 | Planlı |
| Kayıt sistemi (3 slot) | 1 | Planlı |
| Lig, fikstür, maç simülasyonu | 2 | Planlı |
| Şut mini oyunu | 3 | Planlı |
| Form/kondisyon/moral/sakatlık, haftalık döngü | 4 | Planlı |
| Penaltı, serbest vuruş, pas, dribling, kafa, savunma | 5 | Planlı |
| Transfer, kontrat, menajer, ekonomi | 6 | Planlı |
| Sosyal sistemler, olay motoru, basın | 7 | Planlı |
| Milli takım, başarımlar, emeklilik | 8 | Planlı |
| Cila, CI/CD, yayın | 9 | Planlı |

## 3. Denge tabloları

(Faz 2'den itibaren doldurulacak. Mini oyun parametreleri tek denge dosyasında tutulur.)

## 4. Tasarım kararları ve gerekçeleri

| Karar | Gerekçe |
|---|---|
| Kayıt: `shared_preferences` + JSON | Web dahil tüm hedeflerde çalışır, ek kod üretimi/native bağımlılık yok, kayıt boyutu küçük (tek oyuncu), `schemaVersion` ile göç kolay. Drift/Isar web'de ek kurulum ve yapı gerektirir; bu ölçek için gereksiz. |
| Durum yönetimi: Riverpod | Test edilebilir, bağlamdan bağımsız provider'lar; domain katmanını UI'dan ayırmayı kolaylaştırır. |
| Routing: go_router | Flutter ekibinin resmi paketi, web URL desteği. |
| Modeller elle yazılır (freezed yok) | build_runner karmaşası ve üretilen kod yükü olmadan okunabilir kod; model sayısı yönetilebilir. |
| Domain saf Dart | Simülasyon seed'li testlerle hızlıca doğrulanabilir, UI'dan bağımsızdır. Test ile zorlanır. |
| Flame Faz 3'te eklenir | Faz 0-2'de kullanılmayan bağımlılık taşımamak için. |
| Yerelleştirme ARB ile, varsayılan `tr` | Metinler koda gömülmez; ileride yeni dil eklemek kolay. |
| Tüm içerik kurgusal | Telif/lisans riski yok. |
