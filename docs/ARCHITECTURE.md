# Mimari

## Katmanlar

```mermaid
flowchart TD
    subgraph UI["Flutter / Flame"]
        presentation["presentation<br/>ekranlar, Riverpod provider'lar"]
        game["game<br/>Flame mini oyunlar"]
        app["app<br/>tema, router, l10n"]
    end
    data["data<br/>kayıt / yükleme, repository'ler"]
    subgraph Pure["Saf Dart"]
        domain["domain<br/>player, career, match, league,<br/>economy, social, events"]
        core["core<br/>GameRandom, sabitler, yardımcılar"]
    end

    app --> presentation
    presentation --> game
    presentation --> data
    presentation --> domain
    game --> domain
    data --> domain
    domain --> core
```

## Kurallar

- Oklar yalnızca aşağı doğru: `domain` ve `core` hiçbir üst katmanı bilmez.
- `domain` / `core` içinde `flutter`, `flame`, `flutter_riverpod`, `go_router` import edilemez (`test/architecture_test.dart`).
- Rastgelelik yalnızca `GameRandom` ile gelir; seed verilebilir.

## Veri akışı (hedef, Faz 1+)

```mermaid
sequenceDiagram
    participant UI as presentation
    participant P as Riverpod provider
    participant D as domain (saf Dart)
    participant R as data (SaveRepository)
    UI->>P: kullanıcı kararı (örn. antrenman seç)
    P->>D: kural uygula (immutable state -> yeni state)
    D-->>P: yeni CareerState
    P->>R: otomatik kayıt (hafta sonu)
    P-->>UI: state güncellenir
```

Mini oyunlar (Faz 3+): `domain/match` kritik an üretir → `game/` Flame sahnesi oynanır → `ShotResult` gibi basit bir sonuç nesnesi domain'e döner.

## Kulüp sistemi (Faz 6)

- `CareerState` artık `worldSeed`, `contract` (null = serbest oyuncu), `agent`, `finance`, `offers`, `results` taşır; kayıt şeması 4.
- `WeekEngine.advance` hafta sonunda sırasıyla: antrenman/durum -> para (`Economy.weekly`) -> skor kaydı -> `ClubEngine.process` (sezon geçişi, süresi dolan teklifler, yenileme, yeni teklifler).
- `ClubWorld` (lig piramidi + fikstür) ve `LeagueTable` (deterministik puan durumu) `domain/league/` içinde; UI'da `clubWorldProvider` ile paylaşılır.
- Kulüp aksiyonları (`TransferMarket.sign`, `ClubActions.*`) saf fonksiyonlardır; `ActiveCareerNotifier` yalnızca çağırıp kaydeder.

## Sosyal sistem (Faz 7)

- `CareerState` ek alanları: `relations`, `pendingEvents`, `news`, `eventSeen`; kayıt şeması 5 (v4→v5 yalnızca sürüm adımı, eksik alanlar varsayılanla yüklenir).
- `WeekEngine.advance` en son `SocialEngine.afterWeek` çağırır: ilişki değişimi -> haber -> süresi dolan olaylar -> yeni olay.
- Olay şablonları saf veridir (`EventCatalog`); koşullar `EventContext` üzerinden sorgulanır. Cevap `SocialEngine.resolve` ile uygulanır, UI yalnızca seçim alır ve `ResolveResult`'ı gösterir.
- Oyuna etkiler tek yerde: `SocialEngine.coachSelectionBonus`, `offerFactor`, `moraleBaseline` (Squad, TransferMarket, WeekEngine bunları çağırır).

## Milli takım, başarımlar, emeklilik (Faz 8)

- `CareerState` ek alanları: `seasonStats`, `history` (`SeasonRecord`), `national` (`NationalCareer`), `achievements`, `retired`; `CareerStats.transfers`. Kayıt şeması 6 (v5→v6 yalnızca sürüm adımı, eksik alanlar varsayılanla yüklenir).
- `WeekEngine.advance` sırası: antrenman/durum -> para -> skor -> `ClubEngine.process` (sezon geçişinde `SeasonRecord` yazar) -> `NationalEngine.afterWeek` (kadro açıklaması, turnuva maçı, ödül) -> `SocialEngine.afterWeek` -> `AchievementEngine.sync` -> zorunlu emeklilik.
- `domain/national/`: `Tournament` (16 ülkeli tablo; kura ve diğer maçlar seed'li, ülkenin maçları `NationalMatchRecord`), `NationalEngine` (`dayOf` o haftanın durumu), `Shootout`. Ülke maçı oyuncu oynamazsa seed'le simüle edilir.
- Maç ekranı hem lig hem turnuva maçını oynatır (`NationalEngine.dayOf == play` ise ülke takımları, tarafsız saha, beraberlikte penaltılar).
- Emekli kayıtta `/game` rotaları `/game/summary`'ye yönlenir (router redirect). Başarımlar/milli takım/özet ekranları kabuk dışı tam ekran rotalardır.

