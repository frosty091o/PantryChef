//
//  Untitled.swift
//  PantryChef
//
//  Created by Ethan on 4/10/2025.
//

import SwiftUI
internal import CoreData

struct RecipeDetailView: View {
    @Environment(\.managedObjectContext) private var ctx
    @StateObject private var vm: RecipeDetailViewModel

    init(id: Int, title: String, imageURL: String?) {
        _vm = StateObject(wrappedValue:
            RecipeDetailViewModel(recipeID: id, title: title, imageURL: imageURL,
                                  ctx: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        ScrollView {
            if let img = vm.imageURL, let url = URL(string: img) {
                AsyncImage(url: url) { $0.resizable().scaledToFill() }
                    placeholder: { Color.gray.opacity(0.2) }
                    .frame(height: 220).clipped()
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(vm.titleText).font(.title2).bold()

                if let d = vm.detail {
                    HStack(spacing: 16) {
                        if let t = d.readyInMinutes { Label("\(t) mins", systemImage: "clock") }
                        if let s = d.servings { Label("\(s) servings", systemImage: "person.2") }
                    }.font(.subheadline).foregroundStyle(.secondary)

                    if let ings = d.extendedIngredients, !ings.isEmpty {
                        Text("Ingredients").font(.headline).padding(.top, 8)
                        ForEach(ings, id: \.name) { ing in
                            Text("• \(ing.name.capitalized)\(amount(ing))")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let instr = d.analyzedInstructions?.first?.steps, !instr.isEmpty {
                        Text("Steps").font(.headline).padding(.top, 8)
                        ForEach(instr, id: \.number) { step in
                            Text("\(step.number). \(step.step)")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } else if vm.loading {
                    ProgressView("Loading details…")
                } else if let e = vm.error {
                    Text(e).foregroundStyle(.red)
                } else {
                    Button("Load details") { Task { await vm.load() } }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                vm.toggleFavourite()
            } label: {
                Image(systemName: vm.isFavourite ? "heart.fill" : "heart")
            }
            .accessibilityLabel(vm.isFavourite ? "Remove from favourites" : "Save to favourites")
        }
    }

    private func amount(_ ing: RecipeDetailDTO.Ingredient) -> String {
        guard let a = ing.amount, let u = ing.unit, !u.isEmpty else { return "" }
        return " — \(String(format: "%.1f", a)) \(u)"
    }
}
