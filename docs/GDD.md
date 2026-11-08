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
| Lig, fikstür, maç simülasyonu, kritik anlar | 2 | Tamam |
| Şut mini oyunu (Flame) + maç akışı | 3 | Tamam (elle oynanış testi bekliyor) |
| Form/kondisyon/moral/sakatlık, haftalık döngü | 4 | Tamam (elle oynanış testi bekliyor) |
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

### 3.2 Lig piramidi (Faz 2)

5 kademe × 18 takım (306 maç/sezon, 34 hafta). Kademe başına ortalama takım gücü: 76 / 66 / 56 / 46 / 36, takımlar arası sapma 6. Lig adları ARB'de (Ulusal, Birinci, İkinci, Üçüncü, Amatör); takım adları uydurma "{yer} {Spor|Gücü|Atletik}". Fikstür: daire yöntemi, ikinci devre ilkinin ev/deplasman tersi; art arda 3'ten fazla aynı saha yok.

**Sezon takvimi (42 hafta):** 1-4 hazırlık, 5-38 lig turları 1-34, 39-42 sezon arası. Transfer penceresi: hafta 1-6 (yaz) ve 22-24 (kış). Kupa ve milli takım araları ileride eklenecek.

### 3.3 Maç simülasyonu (Faz 2)

Tüm parametreler `lib/domain/match/match_balance.dart` içinde.

- Dakika başına bağımsız gol denemesi (yaklaşık Poisson). Beklenen gol: `1.33 × ev çarpanı(1.1) × exp(0.018 × güç farkı)`; deplasman için `1.33 / 1.1 × exp(-0.018 × fark)`.
- `dart run tool/match_stats.dart` ile ölçülen (20.000 maç):

| Karşılaşma (ev vs dep) | Gol/maç | Ev | Ber. | Dep |
|---|---|---|---|---|
| 60 vs 60 | 2.67 | %43.6 | %25.8 | %30.6 |
| 70 vs 60 | 2.76 | %55.3 | %23.7 | %21.0 |
| 85 vs 50 | 3.40 | %81.6 | %12.5 | %5.9 |

**Kritik anlar:** maç başı 5-8 (ort. 6.5). Türler: şut, bire bir, kafa, serbest vuruş, penaltı, kilit pas, dribling, müdahale. Mevki dağılımı `momentWeights` tablosunda (forvet: şut %32; orta saha: kilit pas %35; defans: müdahale %55).

**Geri besleme:** `MatchSession` oyuncunun anlarının referans (nitelik 50) beklenen golünü takım beklentisinden düşer; ortalama bir oyuncu otomatik oynasa da maç ortalaması bozulmaz (test: 2.5-3.0 gol/maç), nitelikli veya iyi oynayan oyuncu fark yaratır. Mini oyunlar `MomentOutcome` (gol / asist / yenilen gol / yok) döndürür.

**Nitelik etkisi:** an olasılığı = referans × `(0.5 + nitelik/100)`; nitelik 50 → ×1.0, 90 → ×1.4.


### 3.4 Şut mini oyunu (Faz 3)

Parametreler: `lib/domain/match/shot/shot_balance.dart`. Çözüm: `ShotResolver` (saf Dart, seed'li). Flame katmanı (`lib/game/shot`) yalnızca girdiyi toplar ve canlandırır; swipe okuma `ShotGeometry` ile test edilir.

**Oynanış:** topun etrafında küçülen bir zamanlama halkası döner (3 tur sonra fırsat kaçar). Halka topa ulaştığında parmağı topa koy (kalite 1 = mükemmel), kaleye doğru kaydır: **swipe'ın hedefi** = nişan noktası, **hız** = güç, **yolun bükülmesi** = falso. Sürüklerken sarı halka tahmini varış noktasını (sapma ve zamanlama hariç) gösterir.

**Çözüm sırası:** kötü vuruş (kötü zamanlamada olasılık `0.9·(1-kalite)²`) → savunmacı bloku (yerden ve çizgisi önündeyse) → sapma (`σ`: Plase/Şut, zamanlama, baskı×(1-Sakinlik), aşırı güç) → kaleci (şutu okuma olasılığı kaleci becerisine bağlı; üst köşelere erişimi %40 azalır) → isabet/direk/üst direk → gol.

**Nitelikler:** Şut + Plase: sapma ↓, Şut: zamanlama penceresi ↑, Plase: falso etkisi ↑, Sakinlik: halka yavaşlar ve baskı cezası ↓. **Zorluk:** Kolay halka ×1.25, pencere ×1.3, kaleci -0.1; Zor halka ×0.85, pencere ×0.8, kaleci +0.1.

**Ölçülen gol oranı** (`dart run tool/shot_stats.dart`, nitelik 50, normal zorluk): özensiz oyuncu (rastgele hedef ve zamanlama) %33, düzgün oyuncu (köşe hedefi, iyi zamanlama) %45, uzman ~%46. Nitelik 30'da özensiz %30, nitelik 80'de %39. Kolay/Normal/Zor farkı ~48/45/42.

**Kritik an ile ilişki:** şut anı "net pozisyon" sayılır. Otomatik (hızlı) çözümde şut gol olasılığı %30 (≈ özensiz oyuncu); elle oynayan düzgün oyuncu ~1.4-1.5 kat daha iyi. Şut an ağırlıkları buna göre azaltıldı (forvet %32 → %12), böylece forvetin maç başı beklenen golü ~0.7'de kalır.

**Reyting:** `6.0 + 1.3·gol + 0.8·asist − 0.6·hatadan yenen gol ± 0.3 (galibiyet/mağlubiyet)`, 1-10 arası.

> Bilinen sınır: elle oynanış hissi (halka hızı, nişan toleransı) gerçek cihazda ayarlanmalı; değerler `shot_balance.dart` içindedir.


### 3.5 Haftalık yaşam döngüsü (Faz 4)

Parametreler: `lib/domain/career/week_balance.dart`. Motor: `WeekEngine.advance` (saf Dart, seed'li). Her hafta: **antrenman odağı** (Şut / Fizik / Teknik / Taktik / Dinlenme) + **yoğunluk** (Hafif / Orta / Sert) + **sosyal hayat** (Yok / Aile / Arkadaşlar / Hobi) seçilir; lig haftalarında (hafta 5-38) maç oynanır. Sonunda özet ekranı "ne değişti, neden" gösterir ve kayıt otomatik alınır.

**Kondisyon (0-100):** haftalık toparlanma +30; antrenman -5 / -10 / -18; dinlenme odağı +15; maç -15; arkadaşlarla -3, hobi +2. Orta antrenman + maç dengededir; sürekli sert antrenman + maç kondisyonu eritir (ölçülen ort. 100 → 75).

**Antrenman kazancı:** odaktaki her nitelik için hafta başına `0.05 × yoğunluk(0.6/1/1.5) × (0.6+0.8·profesyonellik) × yaş çarpanı(1/0.7/0.4/0.2) × tavan boşluğu`. Doğal yaşlanma gelişimi (yıllık) ayrıca sürer; antrenman bunun üstüne bonus ekler.

**Sakatlık:** haftalık risk = `0.01 + 0.015·eğilim + düşük kondisyon (60 altında, 0'da +0.06) + maç 0.01 + yoğunluk (0 / 0.005 / 0.015) + tekrar riski`. Türler: kas %60 (1-4 hf), bağ %30 (4-10 hf), kırık %10 (8-16 hf). Sakatken antrenman dinlenmeye çevrilir, maç yok; dinlenme odağı iyileşmeyi %25 olasılıkla bir hafta kısaltır. Ölçülen: normal planda ~1.15 sakatlık/sezon, sürekli sert planda ~1.6.
**Riskli erken dönüş:** sakatlık anında biter, kondisyon -10, tekrar sakatlanma riski 0.35 (haftalık yarıya iner); tekrar sakatlanma süreyi ×1.5 yapar. Testte dönüşten sonra sakatlanma ihtimali sağlıklı oyuncunun >5 katı.

**Form (-10..+10):** son 5 maç reytinginin ortalaması: `(ort - 6) × 5`. Maç yoksa her hafta %20 söner; sakatken haftada 1 puan sıfıra yaklaşır.

**Moral (0-100):** galibiyet +3, mağlubiyet -3, reyting ≥7.5 +3 / ≤5 -3, sakatlık sürerken -2/hf, sakatlanma anı -6, iyileşme +3, bitkinlik (kondisyon <30) -3, sert antrenman -1, sosyal: aile +4 / arkadaş +5 / hobi +3; ayrıca haftada boşluğun %8'i kadar 60'a doğru dengelenir.

**Performans çarpanı:** `1 + 0.01·form − 0.004·(60−kondisyon) − 0.003·(40−moral)` (0.6-1.15). Mini oyunda form halkayı yavaşlatır; düşük kondisyon halkayı hızlandırıp sapmayı büyütür, düşük moral sapmayı biraz büyütür. Otomatik çözümde olasılıklar bu çarpanla çarpılır.

**Zincir:** düşük kondisyon → sakatlık riski ↑ → sakatlık = maç yok → form sönümü → moral düşüşü → performans çarpanı ↓.

Kayıt şeması 2'ye çıktı (durum + istatistik alanları); v1 kayıtları `SaveMigrator` ile varsayılan değerlerle yükseltilir. Medya ve sponsor kararları Faz 6-7'de eklenecek.

## 4. Tasarım kararları ve gerekçeleri

| Karar | Gerekçe |
|---|---|
| Kayıt: `shared_preferences` + JSON | Web dahil tüm hedeflerde çalışır, ek kod üretimi/native bağımlılık yok, kayıt boyutu küçük (tek oyuncu), `schemaVersion` ile göç kolay. Drift/Isar web'de ek kurulum ve yapı gerektirir; bu ölçek için gereksiz. |
| Durum yönetimi: Riverpod | Test edilebilir, bağlamdan bağımsız provider'lar; domain katmanını UI'dan ayırmayı kolaylaştırır. |
| Routing: go_router | Flutter ekibinin resmi paketi, web URL desteği. |
| Modeller elle yazılır (freezed yok) | build_runner karmaşası ve üretilen kod yükü olmadan okunabilir kod; model sayısı yönetilebilir. |
| Domain saf Dart | Simülasyon seed'li testlerle hızlıca doğrulanabilir, UI'dan bağımsızdır. Test ile zorlanır. |
| Flame Faz 3'te eklendi | Faz 0-2'de kullanılmayan bağımlılık taşımamak için. |
| Mini oyun fiziği domain'de, Flame sadece girdi/animasyon | Sonuç mantığı seed'li testlerle doğrulanır; mini oyun sonucu `MomentOutcome` ile simülasyona döner. |
| Yerelleştirme ARB ile, varsayılan `tr` | Metinler koda gömülmez; ileride yeni dil eklemek kolay. |
| Tüm içerik kurgusal | Telif/lisans riski yok. |
| Nitelikler içeride `double`, dışarıda `int` | Yıllık küçük gelişimler yuvarlamada kaybolmaz; ileride haftalık antrenman da aynı modele oturur. |
| Gizli nitelikler arayüzde gösterilmez | Potansiyel ve profesyonellik keşfedilen bir sürpriz olarak kalır. |
| Kayıt zarfı `{schemaVersion, savedAt, career}` + `SaveMigrator` | Şema değişince eski kayıtlar adım adım yükseltilir; bozuk veya daha yeni sürüm kayıt çökmeden "bozuk" işaretlenir. |
| Haftalık motor tek fonksiyon (`WeekEngine.advance`) | Tüm haftalık sonuçlar tek yerde, seed'li testlerle doğrulanır; UI yalnızca plan toplar ve raporu gösterir. Rapor her değişimin NEDENİNİ taşır. |
| Zaman kısıtı: seçimlerin bedeli var | Sert antrenman + arkadaşlarla zaman kondisyonu eritir, dinlenmek gelişimi durdurur; ayrı bir 'zaman bütçesi' yerine bu ödünleşmeler kullanıldı. |
| Zorluk yalnızca ayar | Ekonomi/ilerleme satın alınamaz; zorluk mini oyun toleransı ve rakip gücüne bağlanacak (Faz 3+). |
