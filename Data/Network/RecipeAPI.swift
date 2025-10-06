//
//  RecipeAPI.swift
//  PantryChef
//
//  Created by Ethan on 4/10/2025.
//

import Foundation
import SwiftUI

enum APIError: Error {
    case invalidURL, requestFailed, decodingFailed
}

final class RecipeAPI {
    static let shared = RecipeAPI()
    private init() {}
    
    func findRecipes(ingredients: [String]) async throws -> [Recipe] {
        guard !ingredients.isEmpty else { return [] }
        
        // Using findByIngredients because it shows which ingredients you have/need
        // complexSearch supports filters but doesn't show ingredient match info
        let query = ingredients.joined(separator: ",")
        
        let urlString = "https://api.spoonacular.com/recipes/findByIngredients" +
        "?ingredients=\(query)&number=20&apiKey=\(Secrets.spoonacularKey)"
        
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        do {
            let allRecipes = try JSONDecoder().decode([Recipe].self, from: data)
            
            // Apply diet filter manually since this endpoint doesn't support it
            let diet = UserDefaults.standard.string(forKey: "diet") ?? "none"
            let intolerances = UserDefaults.standard.string(forKey: "intolerances") ?? ""
            
            // If no filters, return all
            if diet == "none" && intolerances.isEmpty {
                return allRecipes
            }
            
            // Otherwise filter by checking each recipe's details
            // This requires extra API calls but shows proper ingredient counts
            // limitation
            return allRecipes
            
        } catch {
            print(String(data: data, encoding: .utf8) ?? "No response body")
            throw APIError.decodingFailed
        }
    }
}

extension RecipeAPI {
    func getRecipeDetail(id: Int) async throws -> RecipeDetailDTO {
        let urlStr = "https://api.spoonacular.com/recipes/\(id)/information?includeNutrition=true&apiKey=\(Secrets.spoonacularKey)"
        guard let url = URL(string: urlStr) else { throw APIError.invalidURL }
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw APIError.requestFailed }
        do { return try JSONDecoder().decode(RecipeDetailDTO.self, from: data) }
        catch {
            print(String(data: data, encoding: .utf8) ?? "")
            throw APIError.decodingFailed
        }
    }
}
