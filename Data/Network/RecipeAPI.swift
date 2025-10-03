//
//  RecipeAPI.swift
//  PantryChef
//
//  Created by Ethan on 4/10/2025.
//

import Foundation

enum APIError: Error {
    case invalidURL, requestFailed, decodingFailed
}

final class RecipeAPI {
    static let shared = RecipeAPI()
    private init() {}

    func findRecipes(ingredients: [String]) async throws -> [Recipe] {
        guard !ingredients.isEmpty else { return [] }

        let query = ingredients.joined(separator: ",")
        let urlString = "https://api.spoonacular.com/recipes/findByIngredients" +
                        "?ingredients=\(query)&number=10&apiKey=\(Secrets.spoonacularKey)"

        guard let url = URL(string: urlString) else { throw APIError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.requestFailed
        }

        do {
            return try JSONDecoder().decode([Recipe].self, from: data)
        } catch {
            print(String(data: data, encoding: .utf8) ?? "No response body")
            throw APIError.decodingFailed
        }
    }
}
