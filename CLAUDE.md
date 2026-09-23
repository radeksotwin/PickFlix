# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# PickFlix

iOS app that picks one movie for the user to watch. Tagline: "Still scrolling? Let's fix that."

## Build & Test Commands

```bash
# Build (simulator)
xcodebuild -project PickFlix.xcodeproj -scheme PickFlix \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all tests
xcodebuild -project PickFlix.xcodeproj -scheme PickFlix \
  -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test class
xcodebuild test -project PickFlix.xcodeproj -scheme PickFlix \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:PickFlixTests/PickFlixTests

# Run UI tests
xcodebuild test -project PickFlix.xcodeproj -scheme PickFlix \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:PickFlixUITests
```

## Tech Stack

- **Platform:** iOS, SwiftUI
- **Architecture:** MVVM (`@StateObject` ViewModels)
- **Persistence:** SwiftData (`Item` model, `ModelContainer`)
- **Language:** Swift

## Navigation Architecture

No NavigationStack — navigation is driven by a custom `AppScreen` enum. `PickFlixAppContainerView` is the root container that observes `currentScreen` in its ViewModel and switches between child views using a `switch` statement and spring-animated transitions.

```
AppScreen
  .welcomeToPickFlix  -> WelcomeScreenView
  .searchForMovie     -> SearchMovieView
```

To add a new screen: add a case to `AppScreen+Enum.swift`, add a branch in `PickFlixMainContainerView.swift`, create the View + ViewModel pair under `Screens/`.

## Key Conventions

- ViewModels are `@StateObject`, instantiated directly inside the View (`@StateObject var viewModel = SomeViewModel()`)
- `GradientBackgroundView` is rendered once in the container — do not add it inside individual screens
- Screen transitions use `.spring(duration:bounce:)` animations on the container level
- Haptics via `Haptics.swift` utility
- Custom colors via `AppColors.swift`

## Current State (as of Sept 2026)

- `WelcomeScreenView`: complete — entrance animations, logo, subtitle, start button
- `PickFlixMainContainerView`: working, animated screen transitions
- `SearchMovieView`: stub — animated "Finding your movie" loader; movie result display not yet built
- Movie search / AI integration: not yet implemented
- Active branch: `claudeParty` (main: `main`)
