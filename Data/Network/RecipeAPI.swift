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
        
        // Changed to complexSearch endpoint - supports diet and intolerances
        let query = ingredients.joined(separator: ",")
        
        // Get filters from UserDefaults
        let diet = UserDefaults.standard.string(forKey: "diet") ?? "none"
        let intolerances = UserDefaults.standard.string(forKey: "intolerances") ?? ""
        
        var urlString = "https://api.spoonacular.com/recipes/complexSearch" +
        "?includeIngredients=\(query)&number=10&addRecipeInformation=true&apiKey=\(Secrets.spoonacularKey)"
        
        // Add diet filter if not "none"
        if diet != "none" {
            urlString += "&diet=\(diet)"
        }
        
        // Add intolerances if any
        if !intolerances.isEmpty {
            let cleaned = intolerances.replacingOccurrences(of: " ", with: "")
            urlString += "&intolerances=\(cleaned)"
        }
        
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        do {
            // complexSearch returns different format
            let searchResult = try JSONDecoder().decode(ComplexSearchResult.self, from: data)
            return searchResult.results
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

//complexSearch response
struct ComplexSearchResult: Decodable {
    let results: [Recipe]
}


extension Recipe {

}

