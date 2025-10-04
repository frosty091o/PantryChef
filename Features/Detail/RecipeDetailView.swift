//
//  Untitled.swift
//  PantryChef
//
//  Created by Ethan on 4/10/2025.
//

import SwiftUI
import CoreData

struct RecipeDetailView: View {
    @Environment(\.managedObjectContext) private var ctx
    @StateObject private var vm: RecipeDetailViewModel
    @State private var showNearby = false
    @StateObject private var loc = LocationManager()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PantryItem.updatedAt, ascending: false)]
    ) private var pantry: FetchedResults<PantryItem>

    // Lowercased, trimmed pantry names for case-insensitive matching
    private var pantrySet: Set<String> {
        Set(
            pantry.compactMap {
                $0.name?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()
            }
            .filter { !$0.isEmpty }
        )
    }

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

                        // You have
                        let have = ings.filter { pantrySet.contains($0.name.lowercased()) }
                        if !have.isEmpty {
                            Text("You have")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                            ForEach(have, id: \.name) { ing in
                                Label("\(ing.name.capitalized)\(amount(ing))", systemImage: "checkmark.circle")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // You need
                        let need = ings.filter { !pantrySet.contains($0.name.lowercased()) }
                        if !need.isEmpty {
                            Text("You need")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, have.isEmpty ? 2 : 8)
                            ForEach(need, id: \.name) { ing in
                                Label("\(ing.name.capitalized)\(amount(ing))", systemImage: "xmark.circle")
                            }
                            Button {
                                loc.request()
                                showNearby = true
                            } label: {
                                Label("Find nearby supermarkets", systemImage: "mappin.and.ellipse")
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 8)
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
                    VStack(spacing: 8) {
                        Text(e).foregroundStyle(.red)
                        Button("Retry") { Task { await vm.load() } }
                            .buttonStyle(.borderedProminent)
                    }
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
        .task {
            if vm.detail == nil {
                await vm.load()
            }
        }
        .sheet(isPresented: $showNearby) {
            NearbyStoresView(userCoordinate: loc.coordinate)
        }
    }

    private func amount(_ ing: RecipeDetailDTO.Ingredient) -> String {
        guard let a = ing.amount, let u = ing.unit, !u.isEmpty else { return "" }
        return " — \(String(format: "%.1f", a)) \(u)"
    }
}
