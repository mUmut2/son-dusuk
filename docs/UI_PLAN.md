# Arayüz Planı — "Tam Bir Futbol Oyunu" Hissi

Bu belge bir **öneridir**; onaylanmadan uygulanmaz. Kapsam: oyunun ekranlarını
standart bir futbol oyunu (FIFA / Football Manager tarzı) gibi hissettirmek,
hedef kitle 9-15 yaş olduğu için sade, renkli ve okunaklı kalarak.

## 1. Bugünkü durum (kısa değerlendirme)

- Gezinme: alt çubukta 5 sekme (Ana Sayfa, Antrenman, Kulüp, Sosyal, Profil);
  maç, olay, hafta özeti ve mağaza tam ekran rotalar.
- Görünüm: Material 3 + saha yeşili tohum renk. Ekranlar çoğunlukla standart
  `Card`/`ListTile`; futbol temasını taşıyan tek şey mini oyunlar ve yeni
  canlı anlatım/röportaj ekranları.
- Maç ekranı: aşamalı (başla → an → mini oyun → sonuç → özet). Skor tabelası
  düz yazı; sahada ne olduğu görünmüyor, dakika ilerleyişi yalnızca anlatımla.
- Eksikler: lig puan durumu yalnızca Kulüp sekmesinde bir liste; oyuncunun
  "kartı" yok; maç öncesi/sonrası heyecan yok; sayfa geçişleri sade.

## 2. Hedef his

1. **Yayın ekranı havası:** maçta üstte TV tarzı skor tabelası (takım renkleri,
   skor, dakika), altta anlatım şeridi.
2. **Koleksiyon kartı:** oyuncunun kendi kartı (puan, mevki, yıldız, nitelikler)
   — kariyerin "kimlik"i; her gelişmede parlayan kart.
3. **Menü yerine "merkez":** Ana Sayfa bir panel gibi: sıradaki maç kartı,
   form noktaları, haber şeridi, günlük hedef.
4. **Her yerde tutarlı dil:** aynı renkler, aynı köşe yuvarlaklığı, aynı
   rozet/şerit bileşenleri; takım renkleri her yerde.
5. **Hareket ve ses:** kısa geçişler, gol/rozet anlarında efekt (sesler zaten
   var).

## 3. Ekran ekran öneriler

### 3.1 Ana menü
- Gece stadyumu zemini (kod ile çizilmiş ışıklar/tribün silüeti), büyük logo,
  "Kariyere Devam" birincil düğme; slotlar mini oyuncu kartı olarak.

### 3.2 Ana Sayfa (merkez)
- Üstte oyuncu kartı (küçük); altında **Sıradaki Maç** kartı: rakip, ev/deplasman,
  hafta, rakip gücü (yıldız), "Maça Hazırlan" düğmesi.
- **Form şeridi:** son 5 maç renkli noktalar + reyting.
- **Haber şeridi:** son haberler kayan satır.
- Bekleyen röportaj/olay kartı mikrofon ikonuyla öne çıkar.

### 3.3 Maç günü (en büyük değişiklik)
1. **Tünel / kadro ekranı:** iki takım adı, "Sen 11'desin" ya da yedek durumu,
   stadyum adı, geri sayım "Maç başlıyor".
2. **Canlı maç:** üstte skor tabelası (sabit), ortada **mini saha** (üstten
   görünüm; top ve bölge ışığı: hücum/orta saha/savunma, kod ile çizilir —
   gerçek oyuncu hareketi yok, yalnızca "baskı çubuğu"), altta spiker şeridi
   (bugün var).
3. **Devre arası:** istatistik kartları (şut, isabetli şut, pas %, top hakimiyeti
   — simülasyondan türetilir) ve teknik direktör sözü.
4. **Maç sonu:** "Maçın Adamı" ve reyting animasyonu, istatistik karşılaştırma
   çubukları, gol zaman çizelgesi, ardından röportaj çağrısı.

### 3.4 Lig
- Ayrı sekme/ekran: **puan durumu** (kulüp renkli şerit, son 5 form noktaları,
  oyuncunun takımı vurgulu), **fikstür** (sonraki 5 maç), **gol krallığı**
  (kurgusal oyuncular).

### 3.5 Oyuncu kartı / Profil
- Kart tasarımı: ortalama puan, mevki, bayrak (kurgusal), yıldız; arkası:
  nitelik radar grafiği (kod ile çizilir); kariyer istatistikleri sekmesi.
- Başarım rafı: "kupa dolabı" görünümü (şu anki liste yerine).

### 3.6 Kulüp ve transfer
- Teklifler **transfer kartı** olarak (kulüp renkleri, maaş, süre rozetleri);
  "Kabul/Pazarlık/Reddet" büyük düğmeler.
- Kulüp sekmesi: kadro listesi (mevki ikonları), lig sırası özeti.

### 3.7 Ortak bileşenler
- `ScoreBug` (skor tabelası), `FormDots`, `PlayerCard`, `TeamBadge` (kurgusal
  kulüp arması: renk + şekil), `SectionHeader`, `StatBar`. Hepsi
  `lib/presentation/widgets/` altında, ARB metinleriyle.

## 4. Görsel sistem

- Renk: koyu saha yeşili + vurgu sarısı; takım renkleri dinamik. Açık/koyu tema
  korunur (mevcut ayar).
- Yazı tipi: başlıklarda kalın, geniş harf aralıklı (spor yayını); gövdede
  okunaklı sistem yazı tipi (paket eklemeden).
- Köşe/gölge: tek bir yuvarlaklık ölçeği (12/20), yumuşak gölge.
- Karakter: mevcut `paintPerson` korunur; takım forması renkleri takıma göre.
- Telif: gerçek kulüp/logo/forma yok; arma ve renkler kodla üretilen kurgusal.

## 5. Fazlar (önerilen sıra)

| Faz | İçerik | Test |
|---|---|---|
| 11a | Ortak bileşenler (ScoreBug, FormDots, TeamBadge, PlayerCard) + tema ayarı | widget testleri, ekran görüntüsü |
| 11b | Maç günü: tünel ekranı, skor tabelası, devre arası ve maç sonu istatistikleri | maç akışı testleri |
| 11c | Ana Sayfa "merkez" + Sıradaki Maç + form şeridi | ana sayfa testleri |
| 11d | Lig ekranı (puan durumu, fikstür, gol krallığı) | lig testleri |
| 11e | Oyuncu kartı + profil + başarım rafı | profil testleri |
| 11f | Menü, geçiş animasyonları, cila | elle deneme |

Her faz kendi commit'i ve onayıyla ilerler (proje kuralı).

## 6. Karar bekleyen sorular

1. **Mini saha (3.3):** maç sırasında üstten kuş bakışı sade bir saha
   (top/baskı göstergesi) olsun mu, yoksa yalnızca skor tabelası + anlatım mı?
2. **Maç istatistikleri (şut, pas %, hakimiyet):** simülasyondan türetilen
   gösterim amaçlı sayılar olsun mu (oyun dengesini etkilemez)?
3. **Takım renkleri/armaları:** her kurgusal kulübe renk + arma şekli üretelim mi?
4. **Öncelik:** önce maç günü (11b) mi, yoksa Ana Sayfa (11c) mi?
