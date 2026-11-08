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
