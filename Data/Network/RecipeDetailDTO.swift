//
//  RecipeDetailDTO..swift
//  PantryChef
//
//  Created by Ethan on 4/10/2025.
//

import Foundation

struct RecipeDetailDTO: Codable {
    let id: Int
    let title: String
    let image: String?
    let readyInMinutes: Int?
    let servings: Int?
    let extendedIngredients: [Ingredient]?
    let analyzedInstructions: [Instruction]?
    let nutrition: Nutrition?

    struct Ingredient: Codable {
        let id: Int?
        let name: String
        let amount: Double?
        let unit: String?
    }

    struct Instruction: Codable {
        let name: String?
        let steps: [Step]?
        struct Step: Codable { let number: Int; let step: String }
    }

    struct Nutrition: Codable {
        let nutrients: [Nutrient]?
        struct Nutrient: Codable {
            let name: String
            let amount: Double?
            let unit: String?
        }
    }
}
