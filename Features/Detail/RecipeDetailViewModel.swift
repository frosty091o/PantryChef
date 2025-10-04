//
//  RecipeDetailViewModel.swift
//  PantryChef
//
//  Created by Ethan on 4/10/2025.
//

import CoreData
import SwiftUI
import Combine

@MainActor
final class RecipeDetailViewModel: ObservableObject {
    @Published var detail: RecipeDetailDTO?
    @Published var isFavourite = false
    @Published var loading = false
    @Published var error: String?

    let recipeID: Int
    let titleText: String
    let imageURL: String?
    private let ctx: NSManagedObjectContext

    init(recipeID: Int, title: String, imageURL: String?, ctx: NSManagedObjectContext) {
        self.recipeID = recipeID
        self.titleText = title
        self.imageURL = imageURL
        self.ctx = ctx
        loadFromCache()
    }

    func load() async {
        loading = true; error = nil
        do {
            let dto = try await RecipeAPI.shared.getRecipeDetail(id: recipeID)
            detail = dto
            cache(dto)
        } catch {
            self.error = "Couldn’t load details."
        }
        loading = false
    }

    func toggleFavourite() {
        let local = fetchLocal() ?? RecipeLocal(context: ctx)
        local.id = String(recipeID)
        local.title = titleText
        local.imageURL = imageURL
        if let dto = detail, let data = try? JSONEncoder().encode(dto) {
            local.jsonBlob = data
        }
        local.isFavourite.toggle()
        local.updatedAt = Date()
        try? ctx.save()
        FirestoreSync.shared.pushFavourite(local)

        isFavourite = local.isFavourite
    }

    // MARK: - Cache helpers
    private func cache(_ dto: RecipeDetailDTO) {
        let local = fetchLocal() ?? RecipeLocal(context: ctx)
        local.id = String(recipeID)
        local.title = titleText
        local.imageURL = imageURL
        local.jsonBlob = try? JSONEncoder().encode(dto)
        local.updatedAt = Date()
        try? ctx.save()
    }

    private func fetchLocal() -> RecipeLocal? {
        let req: NSFetchRequest<RecipeLocal> = RecipeLocal.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "id == %@", String(recipeID))
        return try? ctx.fetch(req).first
    }

    private func loadFromCache() {
        if let local = fetchLocal() {
            isFavourite = local.isFavourite
            if let data = local.jsonBlob,
               let dto = try? JSONDecoder().decode(RecipeDetailDTO.self, from: data) {
                detail = dto
            }
        }
    }
}
