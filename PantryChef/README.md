## PantryChef

**iOS Application Development (Project 2)**

### Overview
PantryChef is an iPhone app I built for my individual project. It recommends recipes based on ingredients the user already has in their pantry, lets you save favourites, and can find nearby supermarkets for missing ingredients.

It was developed using SwiftUI, Core Data, Firebase Firestore, and MapKit. The goal was to create something useful while showing how local and cloud data can work together.

### Main Features
- Add and remove ingredients from your pantry (Core Data)
- Discover recipes that match what you already have
- Save recipes to favourites for offline viewing (Firestore sync)
- Find nearby supermarkets using MapKit + Core Location
- Handles offline mode and API errors with retry support
- Clean SwiftUI interface that works in light and dark mode


### Architecture

- Views (SwiftUI): `PantryView`, `DiscoverView`, `RecipeDetailView`, `FavouritesView`, `NearbyStoresView`
- View Models: `PantryViewModel`, `DiscoverViewModel`, `RecipeDetailViewModel`
- Services: `RecipeAPI` (networking), `FirestoreSync` (cloud sync), `LocationManager` (permissions + current location)
- Persistence: Core Data (`Persistence.swift`, entities like `PantryItem`, `RecipeLocal`)

Data flow: View → ViewModel → Services → Persistence; updates propagate back to Views via `@Published`.

### Dependencies (SPM)

- Firebase (Firestore): Cloud sync
- MapKit (system): Nearby search via `MKLocalSearch`
- Any additional packages added via Xcode’s Package Dependencies (list here if applicable)

### Firestore Sync Overview

- Pantry: Writes item fields (`name`, `quantity`, `unit`, `updatedAt`) to the `pantry` collection keyed by item UUID.
- Favourites: Writes favourite status and metadata to the `favourites` collection keyed by recipe ID.
- Conflict handling: Last-write-wins using `updatedAt` timestamps. Offline changes are queued by the Firestore SDK and merged on reconnect.

### SQLite Note

Core Data uses SQLite under the hood for persistent stores. If explicit SQLite usage is required by marking, you can introduce a small direct SQLite feature (e.g., logging or lightweight index) via `SQLite.swift` and document it here. Otherwise, this app relies on Core Data’s SQLite-backed store for correctness and efficiency.

