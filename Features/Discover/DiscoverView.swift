//
//  DiscoverView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI
import CoreData

struct DiscoverView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PantryItem.updatedAt, ascending: false)]
    ) private var items: FetchedResults<PantryItem>

    @StateObject private var vm = DiscoverViewModel()
    @State private var showFilter = false
    @AppStorage("diet") private var diet: String = "none"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter button
                HStack {
                    Button {
                        showFilter = true
                    } label: {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text(filterText)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Content area
                VStack {
                    switch vm.state {
                    case .idle:
                        ContentUnavailableView(
                            "Discover recipes",
                            systemImage: "magnifyingglass",
                            description: Text("Add some pantry items, then search to find matching recipes.")
                        )
                    case .loading:
                        ProgressView("Searching…")
                    case .results(let recipes):
                        if recipes.isEmpty {
                            ContentUnavailableView(
                                "No matches",
                                systemImage: "fork.knife",
                                description: Text("Try adding more ingredients or different ones.")
                            )
                        } else {
                            List(recipes) { recipe in
                                NavigationLink {
                                    RecipeDetailView(
                                        id: recipe.id,
                                        title: recipe.title,
                                        imageURL: recipe.image
                                    )
                                } label: {
                                    HStack {
                                        AsyncImage(url: URL(string: recipe.image ?? "")) { img in
                                            img.resizable().scaledToFill()
                                        } placeholder: {
                                            Color.gray
                                        }
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                        VStack(alignment: .leading) {
                                            Text(recipe.title).font(.headline)
                                            // complexSearch doesn't return these counts, so only show if available
                                            if let used = recipe.usedIngredientCount, let missed = recipe.missedIngredientCount {
                                                Text("\(used) used, \(missed) missing")
                                                    .font(.subheadline).foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                            .listStyle(.plain)
                        }
                    case .error(let msg):
                        ErrorView(message: msg) {
                            Task { await vm.search(using: Array(items)) }
                        }
                    }
                    
                    Spacer()

                    Button("Find Recipes") {
                        Task {
                            await vm.search(using: Array(items))
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(items.isEmpty)
                    .padding()
                }
            }
            .navigationTitle("Discover")
            .sheet(isPresented: $showFilter) {
                FilterView()
            }
        }
    }
    
    // Shows current filter status
    private var filterText: String {
        if diet != "none" {
            return "Filter: \(diet.capitalized)"
        }
        return "Filters"
    }
}

#Preview {
    DiscoverView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
