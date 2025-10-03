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
        } catch {
            state = .error("Could not load recipes")
        }
    }
}
