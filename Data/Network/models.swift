//
//  models.swift
//  PantryChef
//
//  Created by Ethan on 4/10/2025.
//

import Foundation

struct Recipe: Identifiable, Decodable {
    let id: Int
    let title: String
    let image: String?
    let missedIngredientCount: Int?
    let usedIngredientCount: Int?
}
