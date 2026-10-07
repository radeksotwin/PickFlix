# PickFlix

> Still scrolling? Let's fix that.

PickFlix is an iOS app that ends the endless scroll. Tap one button — get one movie to watch, right now.

---

## Features

- **One-tap movie pick** — no filters, no rabbit holes
- **Real movie data** — powered by [The Movie Database (TMDb)](https://www.themoviedb.org/)
- **Streaming availability** — shows which platforms the movie is on via [Watchmode](https://www.watchmode.com/)
- **Polished animations** — spring transitions, entrance sequences, haptic feedback

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 6 |
| UI | SwiftUI |
| Architecture | MVVM |
| Persistence | SwiftData |
| Movie data | TMDb API |
| Streaming sources | Watchmode API |

---

## Architecture

Navigation is driven by a custom `AppScreen` enum — no `NavigationStack`. The root `PickFlixMainContainerView` observes `currentScreen` in its ViewModel and switches between child views with animated transitions.

```
PickFlixMainContainerView
├── WelcomeScreenView       — entrance animation, logo, start button
└── SearchMovieView         — "Finding your movie" loader → result
```

The `MoviePickEngine` ties together both APIs: it picks a random page from TMDb, draws a random movie from the results, then fetches streaming sources from Watchmode (best-effort — a missing Watchmode result never blocks the pick).

---

## Setup

1. Clone the repo
2. Create `Config.xcconfig` at the project root (this file is gitignored):

```
TMDB_API_KEY = your_tmdb_key_here
WATCHMODE_API_KEY = your_watchmode_key_here
```

3. Open `PickFlix.xcodeproj` in Xcode 16+
4. Select the `iPhone 16` simulator and run

---

## Building & Testing

```bash
# Build
xcodebuild -project PickFlix.xcodeproj -scheme PickFlix \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all tests
xcodebuild -project PickFlix.xcodeproj -scheme PickFlix \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

---

## Requirements

- Xcode 16+
- iOS 17+
- TMDb API key (free) — [themoviedb.org/settings/api](https://www.themoviedb.org/settings/api)
- Watchmode API key (free tier available) — [watchmode.com](https://www.watchmode.com/)

---

## License

MIT
