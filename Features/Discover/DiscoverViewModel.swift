//
//  DiscoverViewModel.swift
//  PantryChef
//
//  Created by Ethan on 4/10/2025.
//

import SwiftUI
import CoreData
import Combine

@MainActor
final class DiscoverViewModel: ObservableObject {
    enum State {
        case idle, loading, results([Recipe]), error(String)
    }

    @Published private(set) var state: State = .idle
    @Published var searchHistory: [SearchHistoryItem] = []
    @Published var showHistory = false

    init() {
        loadSearchHistory()
    }

    func search(using pantryItems: [PantryItem]) async {
        let names = pantryItems.compactMap { $0.name }
        guard !names.isEmpty else {
            state = .error("No pantry items to search")
            return
        }

        state = .loading
        do {
            let recipes = try await RecipeAPI.shared.findRecipes(ingredients: names)
            state = .results(recipes)
            
            // Save to SQLite history
            let query = names.joined(separator: ", ")
            RecipeHistoryDB.shared.saveSearch(query: query, resultCount: recipes.count)
            loadSearchHistory()
        } catch {
            state = .error("Could not load recipes")
        }
    }
    
    func loadSearchHistory() {
        searchHistory = RecipeHistoryDB.shared.getRecentSearches()
    }
    
    func clearHistory() {
        RecipeHistoryDB.shared.clearSearchHistory()
        loadSearchHistory()
    }
}
