⸻


# PantryChef

PantryChef is a smart recipe recommender that helps you cook using ingredients you already have.  
It’s designed to reduce food waste and make meal planning easier.

---

## What This App Does

PantryChef finds recipes based on the ingredients in your pantry.  
You can also discover nearby supermarkets for missing ingredients using MapKit.

---

## Setup Instructions

### Requirements
- macOS with Xcode 15 or newer
- iOS 17+ device or simulator
- Internet connection
- Spoonacular API key (free)
- Firebase account (free)

---

### Step 1: Clone the Repository

```bash
git clone <your-repo-url>
cd PantryChef


⸻

Step 2: Add API Key

The app uses the Spoonacular API for recipe data.
    1.    Sign up and get your free API key (150 requests/day)
    2.    Open Secrets.swift and paste your key:

enum Secrets {
    static let spoonacularKey = "PUT_YOUR_KEY_HERE"
}


⸻

Step 3: Setup Firebase

Firebase is used for cloud sync so pantry items save across devices.
    1.    Create a project in Firebase Console
    2.    Add an iOS app with bundle ID: uts.PantryChef
    3.    Download GoogleService-Info.plist
    4.    Replace the file in the project
    5.    In Firestore, create a new database
    6.    Use these development rules:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}

Note: These rules are for development only. For production, enable authentication.

⸻

Step 4: Run the App
    1.    Open PantryChef.xcodeproj in Xcode
    2.    Wait for dependencies (Firebase, SQLite, Kingfisher) to install
    3.    Select iPhone 15 Pro simulator
    4.    Press Run (⌘ + R)
    5.    Allow location when prompted

⸻

Features

1. Pantry Management

Add and manage ingredients stored at home.
Built with CoreData for local storage and Firebase for cloud sync.

Usage:
    •    Add ingredient name, quantity, and unit
    •    Swipe left to delete
    •    Syncs automatically across devices

⸻

2. Recipe Discovery

Find recipes based on your available ingredients.
    •    Use the Filter button to choose diet or intolerances
    •    Tap Find Recipes to search
    •    Green count = ingredients you have
    •    Orange count = ingredients you need

Supports vegetarian, vegan, and gluten-free filters.
Note: The API endpoint prioritizes ingredient matching over perfect filtering.

⸻

3. Recipe Details

Tap a recipe to view:
    •    Full list of ingredients (you have / you need)
    •    Cooking steps
    •    Preparation time and servings
    •    Favorite recipes (cached offline with CoreData)

⸻

4. Nearby Supermarkets

Find supermarkets near you when you’re missing ingredients.
    •    Uses Core Location and MapKit
    •    Displays stores within 5 km
    •    Opens directions in Apple Maps
    •    Allows calling the store directly

⸻

5. Analytics

Accessible via Settings → View Analytics.
Uses SQLite to track:
    •    Search history
    •    Most viewed recipes
    •    Popular searches
    •    Total usage statistics

⸻

6. Cloud Sync

All pantry and favorite data sync automatically via Firebase.
Implements bidirectional sync with timestamp-based conflict resolution.

⸻

7. Onboarding

A simple tutorial appears on first launch to explain core features.
You can replay it anytime by disabling “Skip Onboarding Tutorial” in Settings.

⸻

Architecture
    •    Pattern: MVVM (Model–View–ViewModel)
    •    Views: SwiftUI
    •    ViewModels: Business logic and state management
    •    Services: API, Firestore, CoreData, SQLite

Data Storage

Layer    Purpose    Technology
Local    Pantry and cached recipes    CoreData
Cloud    Device sync    Firebase Firestore
Analytics    Usage tracking    SQLite
Preferences    App settings    UserDefaults


⸻

API Integration

Spoonacular
    •    findByIngredients – recipe discovery
    •    complexSearch – advanced filtering
    •    getRecipeInformation – full details

Implements custom DTOs for clean parsing:
    •    RecipeDTO
    •    RecipeDetailDTO

---

Location Services

Component    Framework    Purpose
LocationManager    CoreLocation    Handles permissions and updates
MKLocalSearch    MapKit    Finds nearby supermarkets
MapView    MapKit    Displays results on the map


---


## Error Handling

### Network
- Graceful error messages and retry buttons
- Logs to console for debugging

```swift
do {
    let recipes = try await RecipeAPI.shared.findRecipes(...)
} catch {
    state = .error("Could not load recipes")
}
```

### CoreData
- Uses try-catch for saves
- Automatic migration enabled

### Firebase
- Background sync (non-blocking)
- Logs failures silently
- Works offline

### Location
- Explains purpose before requesting permission
- Shows alert if denied

---

## Testing

### Automated Tests
- `RecipeAPITests` – API and JSON parsing
- `CoreDataTests` – database operations
- `SQLiteTests` – analytics queries

Run tests with <kbd>⌘ + U</kbd>.

### Manual Testing
- Add/delete pantry items
- Test diet filters
- Test offline and permission scenarios
- Replay onboarding
- Reset app data

---

## Known Issues

| Issue               | Description                                |
|---------------------|--------------------------------------------|
| API Rate Limit      | Free plan allows 150 requests per day      |
| Filter Accuracy     | Endpoint prioritizes ingredient match      |
| Offline Limitations | Recipe search requires internet            |
| Firebase Rules      | Current setup is open for development only |

---

## What I Learned

| Topic        | Insights                                                        |
|--------------|-----------------------------------------------------------------|
| CoreData     | Understanding relationships, merges, and migrations.            |
| Firebase     | Straightforward setup but challenging sync logic.               |
| Async/Await  | Simplifies networking compared to callbacks.                    |
| MapKit       | Powerful but under-documented; trial and error required.        |
| JSON Parsing | Complex nested API responses required custom structs.           |

### Key Challenges
- Sync reliability with Firebase
- Parsing nested JSON
- Adjusting map search regions
- Optimizing SQLite queries
- Choosing between perfect filters and better UX

---

## Technologies Used

| Category   | Technologies                                      |
|------------|---------------------------------------------------|
| APIs       | - Spoonacular<br>- Firebase Firestore             |
| Libraries  | - Kingfisher (image loading)<br>- SQLite.swift (local analytics)<br>- Firebase iOS SDK |

