# Migracja PickFlix: Swift 5 → Swift 6

Data: październik 2026
Branch: `claudeParty`

---

## Kontekst

Swift 6 wprowadza **ścisłe sprawdzanie współbieżności** (`strict concurrency checking`) jako błędy kompilatora — to, co w Swift 5 było warningiem, w Swift 6 nie skompiluje się. Celem migracji jest jawne zadeklarowanie, które typy mogą być bezpiecznie przesyłane między aktorami (`Sendable`), oraz upewnienie się, że `@MainActor`-izolowany kod jest wywoływany tylko z właściwego kontekstu.

Projekt działa na **iOS 26 SDK**, który agresywniej adnotuje typy Foundation jako `@MainActor` niż wcześniejsze wersje SDK — ma to bezpośredni wpływ na kilka decyzji opisanych poniżej.

---

## Zmiana 1 — `SWIFT_VERSION = 6.0` w project.pbxproj

**Plik:** `PickFlix.xcodeproj/project.pbxproj`
**Zmiana:** `SWIFT_VERSION = 5.0` → `SWIFT_VERSION = 6.0` (wszystkie 5 wpisów dla wszystkich targetów i konfiguracji)

Właściwy przełącznik trybu języka. Do momentu tej zmiany projekt kompilował się w trybie Swift 5, gdzie naruszenia współbieżności były jedynie warningami.

---

## Zmiana 2 — `AppConfig`: `static var` → `static let`

**Plik:** `PickFlix/Config/AppConfig.swift`

```swift
// Przed
static var tmdbAPIKey: String {
    Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String ?? "..."
}

// Po
static let tmdbAPIKey: String =
    Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String ?? "..."
```

**Powód:** `static var` (computed property) jest przeliczany przy każdym wywołaniu. W Swift 6, jeśli ciało tej właściwości sięga do API oznaczonego `@MainActor` (np. `Bundle.main` w iOS 26 SDK), cała computed property staje się `@MainActor`-izolowana. To powoduje kaskadę inferencji:

```
AppConfig.tmdbAPIKey (@MainActor)
    → TMDbService.init(apiKey:) (@MainActor)
        → MoviePickEngine.init(tmdb:watchmode:) (@MainActor)
```

`static let` jest inicjalizowany leniwie raz przez Swift runtime, poza konkretnym aktorem — przerywa tę kaskadę.

---

## Zmiana 3 — Modele danych: dodanie `Sendable`

**Pliki:**
- `PickFlix/Models/Movie.swift`
- `PickFlix/Models/AppScreen+Enum.swift`
- `PickFlix/Networking/TMDb/TMDbModels.swift`
- `PickFlix/Networking/Watchmode/WatchmodeModels.swift`
- `PickFlix/Networking/APIClient.swift` (`APIError`)

```swift
struct Movie: Sendable { ... }
enum AppScreen: Hashable, Sendable { ... }
struct TMDbDiscoverResponse: Decodable, Sendable { ... }
struct TMDbMovie: Decodable, Sendable { ... }
struct WatchmodeSearchResponse: Decodable, Sendable { ... }
struct WatchmodeTitle: Decodable, Sendable { ... }
struct WatchmodeTitleDetails: Decodable, Sendable { ... }
struct WatchmodeSource: Decodable, Sendable { ... }
enum APIError: LocalizedError, Sendable { ... }
```

**Powód:** W Swift 6 wartości przesyłane przez granicę aktorów (np. `Movie` zwracane przez `async func pickMovie()` do `@MainActor` ViewModelu) muszą być `Sendable`. Struktury z wyłącznie `Sendable` właściwościami mogłyby mieć to syntetyzowane automatycznie, ale jawna deklaracja:
- eliminuje niejednoznaczność inferencji kompilatora,
- dokumentuje intencję projektową (te typy są bezpieczne wielowątkowo),
- zapobiega przyszłym błędom przy dodawaniu nowych właściwości.

---

## Zmiana 4 — Protokoły serwisów: dodanie `Sendable`

**Pliki:**
- `PickFlix/Networking/TMDb/TMDbService.swift`
- `PickFlix/Networking/Watchmode/WatchmodeService.swift`
- `PickFlix/Engine/MoviePickEngine.swift`

```swift
protocol TMDbServiceProtocol: Sendable { ... }
protocol WatchmodeServiceProtocol: Sendable { ... }
protocol MoviePickEngineProtocol: Sendable { ... }
```

**Powód:** Protokoły są przechowywane jako `let` właściwości w klasie `MoviePickEngine: Sendable`. Aby klasa mogła sama być `Sendable`, wszystkie jej przechowywane właściwości muszą być `Sendable`. Protokół bez `Sendable` ograniczenia nie daje kompilatorowi gwarancji, że conforming type będzie `Sendable`.

---

## Zmiana 5 — Klasy silnika: dodanie `Sendable`

**Pliki:**
- `PickFlix/Engine/MoviePickEngine.swift`
- `PickFlix/Engine/MockMoviePickEngine.swift`

```swift
// MoviePickEngine — tylko let właściwości Sendable typów → pełne Sendable
final class MoviePickEngine: MoviePickEngineProtocol, Sendable { ... }

// MockMoviePickEngine — ma var result (mutable) → @unchecked Sendable
final class MockMoviePickEngine: MoviePickEngineProtocol, @unchecked Sendable { ... }
```

**Powód:**
`MoviePickEngine` ma wyłącznie `let` właściwości (`tmdb`, `watchmode`) typów, które są `Sendable` po zmianie 4 — kompilator może zweryfikować bezpieczeństwo.

`MockMoviePickEngine` ma `var result`, co jest celowe (testy muszą móc zmieniać wynik). `@unchecked Sendable` mówi kompilatorowi "ufam, że sam pilnuję bezpieczeństwa wątków" — jest akceptowalne dla mocka używanego wyłącznie w testach i preview.

---

## Zmiana 6 — `MovieResultViewModel`: dodanie `@MainActor`

**Plik:** `PickFlix/Screens/MovieResultView/MovieResultViewModel.swift`

```swift
// Przed
final class MovieResultViewModel { ... }

// Po
@MainActor
final class MovieResultViewModel { ... }
```

**Powód:** ViewModel przechowuje `let onAnother: () -> Void` — closure przychodzący z widoku SwiftUI. Widoki SwiftUI są `@MainActor`. Jawna adnotacja `@MainActor` na ViewModelu:
- precyzyjnie opisuje, z jakiego kontekstu należy używać tej klasy,
- zapobiega sytuacji, w której kompilator musiałby zgadywać izolację przy wywołaniu closurea,
- jest spójna z pozostałymi ViewModelami projektu (`WelcomeScreenViewModel`, `SearchMovieViewModel`).

---

## Zmiana 7 — Testy: `@MainActor` na suitach

**Plik:** `PickFlixTests/PickFlixTests.swift`

```swift
@Suite("MoviePickEngine") @MainActor
struct MoviePickEngineTests { ... }

@Suite("TMDbModels — dekodowanie JSON") @MainActor
struct TMDbModelsTests { ... }

@Suite("WatchmodeModels — dekodowanie JSON") @MainActor
struct WatchmodeModelsTests { ... }
```

**Powód:** iOS 26 SDK oznaczył szereg typów Foundation jako `@MainActor` (m.in. powiązane z `Bundle`, `JSONDecoder` przy określonych typach dekodalnych). W efekcie:
- `MoviePickEngine.init(tmdb:watchmode:)` jest inferred jako `@MainActor`,
- konformancje `TMDbMovie: Decodable`, `TMDbDiscoverResponse: Decodable` itp. są traktowane jako `@MainActor`-isolated.

Wywołanie ich z kontekstu nonisolated (domyślnego dla struct bez adnotacji) jest błędem Swift 6. Oznaczenie całego suitu `@MainActor` rozwiązuje problem bez zmiany logiki testów — kompilator sam zaproponował tę zmianę w komunikatach błędów (`note: add '@MainActor' to make...`).

> **Uwaga:** Ta sytuacja może ulec zmianie w przyszłych wersjach iOS 26 SDK lub Xcode, kiedy Apple doprecyzuje adnotacje konkursowe. Warto śledzić release notes.

---

## Zmiana 8 — Testy: mocki z `@unchecked Sendable`

**Plik:** `PickFlixTests/PickFlixTests.swift`

```swift
private final class MockTMDbService: TMDbServiceProtocol, @unchecked Sendable { ... }
private final class MockWatchmodeService: WatchmodeServiceProtocol, @unchecked Sendable { ... }
```

**Powód:** Po zmianie 4 (`TMDbServiceProtocol: Sendable`, `WatchmodeServiceProtocol: Sendable`), wszystkie typy conformujące do tych protokołów muszą być `Sendable`. Mocki mają `var stubbedResult` (mutable, żeby testy mogły sterować wynikiem) — stąd `@unchecked Sendable`, analogicznie do `MockMoviePickEngine`.

---

## Czego migracja NIE zmienia (celowo)

- **`SearchMovieViewModel.findMovie(onFound:)`** — closure pozostaje `@escaping (Movie) -> Void` bez `@Sendable`. `Task { }` wewnątrz `@MainActor` metody dziedziczy izolację aktora, więc `onFound` jest zawsze wywoływany na MainActor. Dodanie `@Sendable` do parametru i typu przechowywanego w widoku powodowało błąd kompilacji przy przekazywaniu metody `viewModel.showMovie` (typ `@MainActor @Sendable` nie konwertuje się implicite do `@Sendable`).

- **`APIClient.get`** — pozostaje `static func`, nonisolated async. Nie wymaga zmian; typy zwracane są teraz `Sendable`.

- **Architektura nawigacji** — bez zmian.
