# Son Düdük — Oyun Tasarım Dokümanı (GDD)

> Durum: İSKELET (Faz 0). Her fazda güncellenir.

## 1. Vizyon

16 yaşında genç bir futbolcuyu amatör liglerden dünya yıldızlığına taşıyan, tamamen offline, tek oyunculu kariyer oyunu. Maçın yalnızca kritik anları oynanır; kararların gerçek ve uzun vadeli sonuçları vardır.

**Temel felsefe:** reklam yok, gerçek para yok, enerji bekleme süresi yok, pay-to-win yok. İlerleme yalnızca oyuncunun kararları ve becerisiyle olur.

**Hedef platform:** Android + Web (GitHub Pages demo), sonra iOS. Dikey yön, tek elle oynanabilir.

## 2. Sistemler (özet — fazlarda detaylanacak)

| Sistem | Faz | Durum |
|---|---|---|
| Oyuncu, nitelikler, yaş eğrisi | 1 | Tamam |
| Kayıt sistemi (3 slot), ayarlar | 1 | Tamam |
| Lig, fikstür, maç simülasyonu | 2 | Planlı |
| Şut mini oyunu | 3 | Planlı |
| Form/kondisyon/moral/sakatlık, haftalık döngü | 4 | Planlı |
| Penaltı, serbest vuruş, pas, dribling, kafa, savunma | 5 | Planlı |
| Transfer, kontrat, menajer, ekonomi | 6 | Planlı |
| Sosyal sistemler, olay motoru, basın | 7 | Planlı |
| Milli takım, başarımlar, emeklilik | 8 | Planlı |
| Cila, CI/CD, yayın | 9 | Planlı |

## 3. Denge tabloları

### 3.1 Oyuncu nitelikleri (Faz 1)

15 nitelik, 1-99: Şut, Plase, Pas, Vizyon, Dribling, Hız, Çabukluk, Güç, Dayanıklılık, Defans, Top Kontrolü, Kafa Vuruşu, Duran Top, Sakinlik, Karizma. Gizli: Potansiyel (55-97), Sakatlanma Eğilimi (0-1), Profesyonellik (0-1).

**Mevki ağırlıkları:** her mevkide 4 ana (1.0), 5 ikincil (0.6), kalan düşük (0.3) nitelik vardır. "Genel güç" ağırlıklı ortalamadır. Nitelik tavanı = `potansiyel - (1 - ağırlık) * 18`; yani ana nitelikler potansiyele kadar çıkar, düşük ağırlıklılar ~12 puan altında kalır.

**Başlangıç (16 yaş):** `28 + ağırlık * 20 + N(0, 3)` → ana nitelikler ~48, ikincil ~40, düşük ~34. Potansiyel ~ N(76, 9), 55-97 aralığına sıkıştırılır.

**Yaş eğrisi (puan/yıl, taban değerler):**

| Yaş | Fiziksel | Teknik | Zihinsel |
|---|---|---|---|
| 16-17 | +4.5 | +4.0 | +3.2 |
| 18 | +4.0 | +3.8 | +3.2 |
| 19 | +3.5 | +3.4 | +3.2 |
| 20 | +3.0 | +3.0 | +3.2 |
| 21 | +2.2 | +2.5 | +3.2 |
| 22 | +1.2 | +1.8 | +1.8 |
| 23-24 | +0.3 | +1.0 | +1.8 |
| 25-26 | +0.3 | +0.4 | +1.0 |
| 27-28 | 0 | +0.4 | +1.0 |
| 29 | -1.0 | 0 | +0.5 |
| 30 | -1.5 | 0 | +0.5 |
| 31 | -2.0 | 0 | +0.5 |
| 32-33 | -2.5 | -0.5 | +0.5 |
| 34+ | -2.5 | -0.5 | 0 |

Pozitif değişim: `taban × potansiyel çarpanı (0.8-1.5) × profesyonellik çarpanı (0.6-1.4) × tavan boşluğu` + gürültü. Negatif değişim tavandan bağımsızdır.

**Doğrulama (300 kariyer × 22 sezon, seed'li test):** ortalama zirve genel güç ≈ 67, min 49, max 87. Aşırı güçlü ya da hiç gelişmeyen oyuncu yok; yüksek potansiyel anlamlı biçimde daha yüksek zirve verir; 28→36 yaş arası Hız ortalama >10 puan düşer, Vizyon düşmez.

### 3.2 Diğer

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
| Nitelikler içeride `double`, dışarıda `int` | Yıllık küçük gelişimler yuvarlamada kaybolmaz; ileride haftalık antrenman da aynı modele oturur. |
| Gizli nitelikler arayüzde gösterilmez | Potansiyel ve profesyonellik keşfedilen bir sürpriz olarak kalır. |
| Kayıt zarfı `{schemaVersion, savedAt, career}` + `SaveMigrator` | Şema değişince eski kayıtlar adım adım yükseltilir; bozuk veya daha yeni sürüm kayıt çökmeden "bozuk" işaretlenir. |
| Zorluk yalnızca ayar | Ekonomi/ilerleme satın alınamaz; zorluk mini oyun toleransı ve rakip gücüne bağlanacak (Faz 3+). |
