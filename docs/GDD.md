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
| Penaltı, serbest vuruş, pas, dribling, kafa, savunma, bire bir | 5 | Tamam (elle oynanış testi bekliyor) |
| Transfer, kontrat, menajer, ekonomi | 6 | Tamam (elle oynanış testi bekliyor) |
| Sosyal sistemler, olay motoru, basın | 7 | Tamam (elle oynanış testi bekliyor) |
| Milli takım, başarımlar, emeklilik | 8 | Tamam (elle oynanış testi bekliyor) |
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

**Sezon takvimi (42 hafta):** 1-4 hazırlık, 5-38 lig turları 1-34, 39-42 sezon arası. Transfer penceresi: hafta 1-6 (yaz) ve 22-24 (kış). Çift sezonlarda 39-42. haftalarda milli takım turnuvası oynanır (bkz. 3.9). Kupa ileride eklenecek.

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

**Form (0-10):** son 5 maçın reyting ortalaması (10 en iyi, 0 en kötü; hiç maç oynanmadıysa 6.0). Maç oynanmayan haftalarda (sakatlık dahil) değişmez; yeni maç eskisini pencereden düşürür. Performansa etkisi: `formBonus = (form − 6) × 2.5` (−10..+10 puan), yani form 10 → +%10, form ≤2 → −%10.

**Moral (0-100):** galibiyet +3, mağlubiyet -3, reyting ≥7.5 +3 / ≤5 -3, sakatlık sürerken -2/hf, sakatlanma anı -6, iyileşme +3, bitkinlik (kondisyon <30) -3, sert antrenman -1, sosyal: aile +4 / arkadaş +5 / hobi +3; ayrıca haftada boşluğun %8'i kadar 60'a doğru dengelenir.

**Performans çarpanı:** `1 + 0.01·formBonus − 0.004·(60−kondisyon) − 0.003·(40−moral)` (0.6-1.15). Mini oyunda iyi form halkayı yavaşlatır; düşük kondisyon halkayı hızlandırıp sapmayı büyütür, düşük moral sapmayı biraz büyütür. Otomatik çözümde olasılıklar bu çarpanla çarpılır.

**Zincir:** düşük kondisyon → sakatlık riski ↑ → sakatlık = maç yok → form sönümü → moral düşüşü → performans çarpanı ↓.

Kayıt şeması 2'ye çıktı (durum + istatistik alanları); v1 kayıtları `SaveMigrator` ile varsayılan değerlerle yükseltilir. Medya ve sponsor kararları Faz 6-7'de eklenecek.


### 3.6 Diğer mini oyunlar (Faz 5)

Hepsi tek elle, 5-15 sn, tekrar yok. Parametreler: `lib/domain/match/minigames/mini_balance.dart` (şut/serbest vuruş/kafa/bire bir fiziği `shot_balance.dart` ile paylaşır). Sonuçlar `MomentOutcome` olarak maça döner. Ölçümler `dart run tool/minigame_stats.dart` (nitelik 50, normal zorluk):

| Mini oyun | Oynanış | Ölçülen |
|---|---|---|
| **Penaltı** | Kaleye dokunarak 6 bölgeden birini seç (3×2); aşağıya dokunarak güç ibresini durdur (yeşil bölge ideal). Kaleci bölgeyi oyuncunun GEÇMİŞ penaltı tercihlerine göre seçer; Sakinlik titremeyi azaltır, aşırı güç sapmayı ×1.7 yapar, zayıf vuruş kurtarılır. | Rastgele/dağınık %73; hep aynı köşe (okunmuş) %49; aşırı güç %63 |
| **Serbest vuruş** | Şut mekaniği (halka + swipe) + duvar. Duvarın üstünden (yükseklik) ya da kenarından (kavis) geç; duvar %30 zıplar (yüksekliği +0.25). Duran Top falsoyu güçlendirir. | Duvar üstü köşe %44; özensiz %29; düz/alçak %0 |
| **Kafa vuruşu** | Ortanın yayı topu kafa hizasına getirir; halka 1.0'a gelince oyuncuya dokunup kale yönüne kaydır (falso yok). Rakip baskısı × kötü zamanlama = havada mücadele kaybı; Güç dengeler. | Mükemmel zamanlama %34; rastgele %25 |
| **Bire bir** | Şut mekaniği, halka %20 hızlı, kaleci +0.12 güçlü, savunmacı yok. | Özensiz %32; düzgün %40 |
| **Pas** | 2-4 seçenek (Vizyon: <40 → 2, <70 → 3, değilse 4; yüksek vizyon riski %30'a kadar azaltır, ödülü %40 artırır). Arkadaşı seç, ibreyi yeşil bölgede durdur. Rakip büyüklüğü = kesilme riski; ara pas riskli ama en ödüllü. | Rastgele seçim asist %3.8; EV'ye göre akıllı seçim %11 (tamamlama %62) |
| **Dribling** | Parmakla sürükleyerek oyuncuyu yönlendir; savunmacı yaklaşır, atılmadan önce işaret verir; atıldığı yanın TERSİNE hızlı yatay swipe yap. Çabukluk/Dribling/Top Kontrolü başarıyı etkiler. | Mükemmel zamanlama %74; rastgele %45; yanlış yön %4 |
| **Müdahale** | Parmakla rakibin önünde kal (hizalama), top ayağından en çok açıldığı anda parmağı bırak. Çok erken/yanlış hizada → faul veya geçilme (yenilen gol riski). | Mükemmel %94; rastgele zamanlama %62; hizasız %0 |

**Otomatik çözümle uyum:** hızlı simülasyon olasılıkları, vasat bir oyuncunun mini oyundaki oranına yaklaştırıldı (şut %30, bire bir %32, serbest vuruş %25, kafa %15, penaltı %76, kilit pas %6, dribling %3.5 asist). İyi oynayan 1.3-3 kat daha iyi sonuç alır. Kritik an ağırlıkları buna göre yeniden dağıtıldı (forvet maç başı ≈0.7 gol/asist katkısı, defans ≈0.3).

**Ortak:** form/kondisyon/moral `performanceMultiplier` ile mini oyunları etkiler (ibre hızı, sapma, olasılıklar). Zorluk: Kolay/Zor ibre hızını, savunmacı hamlesinin belirginliğini, rakip becerisini ve kaleci gücünü değiştirir. Penaltı bölgesi tercihleri kayda (`stats.penaltyZones`) yazılır.

### 3.7 Kulüp, kontrat, menajer ve ekonomi (Faz 6)

Tüm parametreler `lib/domain/club/club_balance.dart`'ta. Para birimi kurgusal ₺, maaşlar haftalık. Ölçüm: `dart run tool/club_stats.dart`.

**Dünya:** `worldSeed` kayıtta saklanır; 5 kademeli, 90 takımlı piramit her açılışta aynı seed'den kurulur (takım listesi kayda yazılmaz). Oyuncu amatör ligden (kademe 5) bir kulüple, 2 yıllık sözleşmeyle başlar. Maçlar artık oyuncunun kulübünün gerçek fikstürüdür (rakip ve ev/deplasman turdan gelir).

**Puan durumu:** oyuncunun kulübü dışındaki maçlar `LeagueTable` ile (seed + sezon + tur) tekrarlanabilir şekilde simüle edilir; oyuncunun oynadığı maçlarda gerçek skor kullanılır (`CareerState.results`). Yükselme/düşme henüz yok: kademe değiştirmenin yolu transferdir.

**Rol ve kadro:** oyuncunun (etkin) gücü, kulüp seviyesine (`takım gücü + 6`) göre rolü belirler: fark ≥ 8 Yıldız, ≥ 1 İlk 11, ≥ -6 Rotasyon, genç (≤20) için ≥ -10 Yedek. Etkin güç = genel güç + (21 yaşa kadar) potansiyel farkının %20'si; kulüpler gelecek görür ama potansiyel arayüzde gösterilmez. Maça çıkma olasılığı: Yıldız %100, İlk 11 %95, Rotasyon %70, Yedek %35. Seçim `(worldSeed, sezon, hafta)` ile kararlıdır; yedekteysen o hafta maç oynamazsın (yalnızca antrenman). Rol her sezon başında yeniden hesaplanır.

**Maaş:** `taban[kademe] × 1.045^(etkin güç − kulüp seviyesi) × yaş × rol`. Kademe tabanları 80.000 / 24.000 / 6.500 / 1.900 / 600. Yaş çarpanı 17↓: 0.5, 18: 0.7, 19-20: 0.85, 34↑: 0.8. Rol çarpanı: Yedek 0.6, Rotasyon 0.85, İlk 11 1.0, Yıldız 1.4. Galibiyet primi maaşın %25'i, gol primi %15'i.

**Teklifler:** yalnızca transfer pencerelerinde (hafta 1-6, 22-24) ya da serbest oyuncuyken. Haftalık olasılık `0.30 × menajer çarpanı × form çarpanı` (serbest oyuncuda 0.9). Aday kulüp: seviyesi oyuncunun etkin gücünün -14..+3 aralığında, rolü hesaplanabilen. En fazla 3 bekleyen teklif, 3 hafta geçerli. Teklif maaşı adil maaşın %90-105'i; kulübün GİZLİ üst sınırı %112-122 (+menajer bonusu). Serbest oyuncu asla işsiz kalmaz: aday yoksa amatör ligden bir kulüp teklif eder. Sözleşmenin son sezonunda 30. haftadan sonra mevcut kulüp yenileme teklifi yapabilir (rol bazlı olasılık: Yıldız %95 … Yedek %25).

**Pazarlık (tek tur):** istek teklif maaşına eşit/altıysa teklif maaşı, üst sınırdaysa istenen maaş geçerli; üst sınırın %12'sine kadar karşı teklif (üst sınır maaşı); daha fazlasında kulüp teklifi geri çeker. Zam en fazla %40 istenebilir. Karşı teklifi reddedersen aynı teklif kalır ama pazarlık hakkın biter.

**İmza:** imza parası = yeni haftalık maaş × 8 (menajer komisyonu düşülür). Sözleşme sezon sonuna kadar sayılır; ofsezonda (hafta ≥ 39) imzalanan sözleşme gelecek sezondan başlar. Yenileme mevcut bitişe eklenir. Sözleşme biterse (sezon geçişinde) oyuncu serbest kalır.

**Menajer:** Seviye 1/2/3 — komisyon %5/%8/%12, pazarlık üst sınırına +%3/+%8/+%15, teklif sıklığı ×1.0/×1.35/×1.8. Seviye 2 için genel güç ≥ 50, seviye 3 için ≥ 68. Komisyon maaş, prim ve imza parasından düşülür.

**Finans:** haftalık gelir maaş + primler; gider menajer komisyonu + yaşam tarzı (Mütevazı 150, Rahat 1.200, Lüks 12.000). Yaşam tarzı haftalık moral verir (0 / +1 / +2.5); bakiye eksiye düşerse -2 moral/hafta. Reklam, gerçek para ve satın alma yoktur: para yalnızca kariyer içi bir denge aracıdır.

**Ölçülen (60 kariyer, her pencerede en iyi teklifi alan politika):** sezon başına ≈2 teklif; 27 yaşında kademe dağılımı ≈ %23 üst lig, %55 ikinci, %20 üçüncü; yedek kalma oranı ≈ %13.

### 3.8 Sosyal sistem ve olaylar (Faz 7)

Parametreler `lib/domain/social/social_balance.dart`, olaylar `event_catalog.dart`. Ölçüm: `dart run tool/social_stats.dart`.

**İlişkiler (0-100):** Teknik direktör, takım arkadaşları, taraftar, aile, medya. Nötr değerler 50/50/40/70/40; her hafta %3 nötre yaklaşır (itibar bakım ister). Maç sonrası: galibiyet taraftar +1.5 ve takım +1; yenilgi taraftar -1.5; her gol taraftar +1 (en çok 3); reyting ≥7.5 hoca +1.5 ve medya +1; reyting ≤5 hoca -1.5 ve medya -1; sakatken aile +1.

**Oyuna etkileri:** Hoca ilişkisi maça çıkma olasılığına ±%10; medya teklif sıklığına ×0.85…1.15; aile ve takım arkadaşları moralin yöneldiği tabanı kaydırır (aile ±%20, takım ±%10 oranında). Taraftar+medya sponsor teklifinin açılmasını belirler.

**Olay motoru:** Her hafta sonu en fazla 1 yeni olay gelir, en çok 3 olay bekleyebilir. Maç oynandıysa önce basın sorusu denenir (olağan maçta %45, dikkat çekici maçta %90: reyting ≥7.5 / ≤5 ya da ≥2 gol). Yoksa maçtan bağımsız olay %22. Şablonların koşulu, ağırlığı ve bekleme süresi vardır (tekrarı önler). Basın soruları 2 hafta, diğerleri 5 hafta geçerlidir; cevapsız kalırsa küçük bir "yok say" cezası uygulanır.

**Seçimler:** Her olayda 2-3 seçenek. Arayüz etkilenecek ALANLARI etiketle gösterir (taraftar, medya, para…), yönü ve miktarı göstermez; riskli seçenekte "Riskli" etiketi vardır ve belli olasılıkla (%25-50) alternatif (ters tepen) sonuç uygulanır. Sonuç ekranı kısa bir hikâye cümlesi ve gerçek değişimleri (ok + sayı) gösterir.

**Katalog (17 olay):** 5 basın (galibiyet, yenilgi, gol yıldızı, kötü performans, yedek kalma), aile yemeği, doğum günü daveti (riskli), taraftar buluşması, hoca görüşmesi (hoca <55), soyunma odası gerginliği (takım <45), sponsor teklifi (taraftar≥45 ve medya≥40), yardım maçı, transfer dedikodusu (bekleyen teklif varken), sosyal medya fırtınası (riskli), rehabilitasyon kararı (≥3 hafta sakatlık, riskli), akademi ziyareti, borç baskısı (bakiye <0).

**Haber akışı:** son 25 kayıt (maç, imza, sakatlık, verilen cevaplar). Metinler kayıtta değil, tür + parametre olarak saklanır ve gösterimde yerelleştirilir.

**Ölçülen (60 kariyer × 3 sezon, rastgele cevaplarla):** sezon başına ≈14 olay; oynanan maçların %38'inde basın sorusu; ilişki ortalamaları hoca 55, takım 53, taraftar 46, aile 75, medya 44.

### 3.9 Milli takım, başarımlar, emeklilik (Faz 8)

Parametreler `lib/domain/national/national_balance.dart` ve `lib/domain/career/legacy_balance.dart`. Ölçüm: `dart run tool/national_stats.dart`.

**Turnuva:** Çift sezonlarda (2, 4, 6...) sezon arasında, 39-42. haftalarda 16 kurgusal ülkeyle tek maçlık eleme turnuvası: Son 16 → Çeyrek → Yarı → Final. Dört sezonda bir "Dünya Kupası", aradakiler "Kıtalar Kupası". Oyuncunun ülkesi **Anatolya**; diğer 15 ülke uydurmadır, güçleri dünya seed'inden ve turnuva sezonundan gelir (ülke gücü 74, rakipler ortalama 66 ± 7; tarafsız saha, ev sahibi avantajı yok). Kura ve diğer maçlar seed'e bağlıdır (her açılışta aynı); ülkenin maçları gerçek sonuçla işlenir. Beraberlikte penaltı atışları (güce hafif bağlı).

**Çağrılma:** 38. haftadan 39'a geçerken kadro açıklanır. Puan = genel güç + lig kademesi payı (üst lig +4 … amatör -8) + form payı (±4); en az 18 yaş. ≥70 yedek, ≥77 rotasyon, ≥84 ana kadro; ilk 11 olasılığı %35 / %70 / %95. Kadroda olmasan da ülke turnuvayı oynar, tabloyu ve sonuçları izlersin.

**Ödül ve etki:** Oynadığın her maça maaşın yarısı kadar prim; turnuva sonunda (kadrodaysan) şampiyon 6, finalist 3, yarı finalist 1.5, çeyrek finalist 0.75 haftalık maaş; moral ve taraftar/medya/aile etkisi.

**Başarımlar:** 37 adet, 5 kategori (kariyer, kulüp, milli takım, gelişim, para). Koşullar durumdan hesaplanır (`AchievementEngine.sync`), her hafta sonu açılanlar hafta özetine ve habere düşer. Açılma anı kayda yazılır.

**Sezon geçmişi:** Her sezon sonu `SeasonRecord` (kulüp, kademe, lig sırası, maç/gol/asist, ortalama reyting, güç) eklenir; lig sırası o sezon oyuncunun gördüğü tablodan hesaplanır.

**Emeklilik:** 30 yaşından itibaren isteğe bağlı (onaylı, geri alınamaz), 40 yaşında sezon başında zorunlu. Emekli kayıt yalnızca kariyer özetini açar. **Miras puanı** gol/asist/maç, lig ve turnuva kupaları, milli maç, zirve güç, ulaşılan en üst lig ve başarımlardan hesaplanır; sıralama: Amatör Ruh (<400), Yerel Kahraman (400), Profesyonel (650), Yıldız (950), Efsane (1300).

**Ölçülen (60 kariyer, emekliliğe kadar, basit politika):** %48 kariyerde en az bir çağrılma; turnuva başına çağrılma %29; kariyer başına ≈3.3 milli maç; ülke sonuçları: Son 16 %44, çeyrek %26, yarı %13, finalist %8, şampiyon %9; miras: yerel %20, profesyonel %52, yıldız %25, efsane %3.

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
| Mini oyunların ortak Flame tabanı (`MiniGameBase`) | Yerleşim, dokunma, sonuç gösterimi, sarsıntı/yavaş çekim tek yerde; her oyun yalnızca kendi girdisini ve çizimini yazar. Fizik/sonuç domain'de, widget testleriyle (boş oynanış ve gerçek dokunuş) doğrulanır. |
| Zorluk yalnızca ayar | Ekonomi/ilerleme satın alınamaz; zorluk mini oyun toleransı ve rakip gücüne bağlanacak (Faz 3+). |
| Dünya yerine seed saklanır | 90 takımlık piramit kayda yazılmaz; `worldSeed` aynı dünyayı üretir, kayıt küçük kalır. |
| Pazarlık sınırı gizli, tek tur | Oyuncu "kaç para isteyeyim" riskini hisseder ama sonsuz deneme-yanılma ile en yüksek maaşı bulamaz. |
| Puan durumu deterministik yeniden hesap | Diğer maçlar kayda yazılmaz; (seed, sezon, tur) ile her açılışta aynı sonuç, oyuncunun maçları gerçek skorla. |
| Yaşam tarzı + borç | Para harcanacak yer olmadan anlamsız; küçük ama gerçek bir moral/maliyet dengesi. Satın alma/reklam yok. |
| Seçim etkisi gizli, alan etiketi açık | Oyuncu hangi ilişkiye dokunduğunu bilir ama sonucu tahmin eder; sonuç ekranı gerçek değişimi gösterir (öğrenme ve sürpriz). |
| Olay metinleri ARB'de, mantık domain'de | Şablon kimliği `ev_<id>_*` anahtarlarına bağlanır; metin değişikliği mantığa dokunmaz. Test, her şablonun metninin tam olduğunu doğrular. |
| Rozetler (Kulüp / Sosyal) | Bekleyen teklif ve olay, sekmeye girmeden fark edilir; hafta özeti ve ana sayfa da doğrudan cevap vermeye götürür. |
| Turnuva her iki sezonda bir, tek maçlık eleme | Sezon arasındaki 4 hafta tam dört tura yetiyor; kariyer ritmini bozmadan her maç kritik. Grup aşaması ya da eleme turları için takvim genişletilebilir (Faz 9 ya da sonrası). |
| Milli takım rakipleri ve ülkesi kurgusal | Telif/gerçek ülke markası riski yok; `Anatolya` ve 15 uydurma ülke. |
| Başarımlar durumdan hesaplanır | Sayaç tutmak yerine koşul her hafta durumdan yeniden değerlendirilir; yeni başarım eklemek kayıt göçü gerektirmez. |
| Emeklilik kayıtta bayrak | Kariyer silinmez; kayıt yalnızca özet ekranını açar, kullanıcı başarımları ve sezonları sonradan da gezebilir. |
| Dribling: savunmacı dalgalarından geçit bulma | Zamanlama/yön tahmini yerine parmakla sürükleyip geçitten geçme; beceri oyuncuda, nitelikler geçidi genişletir. Pas orta zorlukta (ibre toleransı daraltıldı), figürler sütunlara yerleşir ve çakışmaz. Ekipman mağazası Kulüp sekmesinden çıkarılıp ayrı ekrana (Ana Sayfa/Antrenman kartı) taşındı. |
| Mini oyunlar çocuklar (9-15) için kolaylaştırıldı | Hedef kitle genç; dribling/pas/müdahale pencereleri genişletildi, yanlış yön affedici, varsayılan zorluk Kolay. Test geri bildirimiyle ayarlanır. |
| Ekipman mağazası (krampon, antrenman, toparlanma, tekmelik) | Paranın harcanacağı yer ve oyun içi güç: tek seferlik alım, 3 seviye; yalnızca karar ve para, gerçek parayla satın alma yok. |
