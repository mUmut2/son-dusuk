# Faz 10 — Sosyal Ağ, Harcama, Bahis ve Eğlence Planı

Hedef: oyuncuyu oyunda tutan, her hafta "bir şey olan" bir döngü. Kural: gerçek
para, reklam, bekleme süresi, pay-to-win YOK; her şey kurgusal ve kararla
ilerler (CLAUDE.md 8-9). Bahis ve at yarışı **kurgusal oyun parasıyla** ve
**sonuçlarıyla birlikte** (ceza, itibar kaybı, yardım) işlenir; amaç özendirmek
değil, "fazlası zarar" mesajını oyun içinde yaşatmaktır.

Her alt faz kendi commit'i ve onayıyla ilerler.

## 10a — Sosyal ağ akışı ✅
- Haber akışının yanına **Akış** sekmesi: taraftar, gazeteci, takım arkadaşı,
  kulüp, mizah sayfası ve aile hesaplarından paylaşımlar, altında yorumlar.
- Paylaşımlar maç sonucundan, performanstan, sakatlıktan, imzadan, başarımdan,
  milli takımdan ve cevaplanan röportajdan doğar; yorumların havası (övgü,
  espri, eleştiri, destek) taraftar ilişkisine göre kayar.
- **Takipçi sayısı** performansla büyür; sezon başına kabaca ikiye katlanır.
- Oyuncu haftada bir kez **kendi hesabından paylaşım** yapar (teşekkür,
  komik, antrenman, iddialı); riskli olanlar ters tepebilir (hoca/medya ilişkisi).
- Kod: `domain/social/feed_*.dart`, arayüz `presentation/social/feed_*.dart`,
  metinler ARB `sm_*`/`feed*`, denge `feed_balance.dart`, araç `tool/feed_stats.dart`.
- Kayıt şeması 8.

## 10b — Harcama ve Şans Köşesi ✅
- **Harcama mağazası:** ev, araba, saat, bağış, aileye hediye (moral/aile/
  taraftar/medya etkisi, hepsi para sinki; kalıcı "mülk" rafı).
- **Bahis (kurgusal):** haftanın fikstüründeki maçlara oyun parasıyla tahmin.
  Oranlar takım gücünden; üst sınır ve **bahis alışkanlığı sayacı** vardır.
- **Ceza zinciri:** sayaç yükseldikçe uyarı → hoca/medya ilişkisi düşer →
  kulüp para cezası → birkaç maçlık kadro dışı → yardım programı olayı
  (sayaç sıfırlanır, para ve itibar kaybı kalır). Akışta ilgili gazete/yorumlar.
- Kendi takımına bahis oynama: yasak (ceza + olay). Ödül yok, kar etme
  garantisi yok; beklenen değer negatif.

## 10c — At yarışı mini oyunu (öneri)
- Kurgusal atlar (isim, form, pist uyumu); oyuncu at seçer, oyun parasıyla
  bahis yapar, yarış Flame ile kısa animasyonla oynanır (saf Dart çözümleyici,
  seed'li).
- Bahis sayacına ve cezalara 10b ile aynı zincir üzerinden bağlanır.
- Sürpriz: ucuz at kazanırsa akışta "olay" paylaşımı.

## 10d — Tutundurma (öneri)
- Haftalık **hedefler** (3 hedef: gol, reyting, takipçi, taraftar...) ve ödülü
  (rozet/küçük para); tamamlayınca akışta paylaşım.
- **Seri göstergesi** (üst üste iyi maç) ve ekranda kutlama.
- Akışa "gündem" paylaşımları: transfer dedikodusu, rakip oyuncu, derbi
  heyecanı (maçsız haftalar da canlı olsun).

## Kararlar (10b)
Önerilen tasarım onaylandı: maç bahsi kurgusal oyun parasıyla var; sözleşme feshi yok (para cezası + kadro dışı + yardım programı); mülkler tek seferlik etki + küçük haftalık moral katkısı verir. Denge: ara sıra (4 haftada bir) oynayan ceza almaz, haftada bir küçük bahis çoğunlukla ceza almaz, haftada 2+ bahis ya da büyük tutar uyarı → ceza → kadro dışına gider.

## Eski sorular (cevaplandı)
1. Bahis hedef kitle (9-15) için uygun mu, yoksa "şans köşesi" yalnızca at
   yarışı + kurgusal çekiliş olarak mı kalsın (maç bahsi yok)?
2. Ceza şiddeti: para cezası + kadro dışı kalma yeterli mi, yoksa sözleşme
   feshi/kariyer sonu riski de olsun mu?
3. Mülkler (ev, araba) yalnızca görünüm mü, yoksa küçük bir bonus mu versin?
