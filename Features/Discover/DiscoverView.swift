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
                        HStack(spacing: 6) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            Text(filterText)
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.12))
                        )
                        .foregroundStyle(.blue)
                    }
                    
                    Spacer()
                    
                    // Show ingredient count
                    if !items.isEmpty {
                        Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
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
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Searching recipes...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    case .results(let recipes):
                        if recipes.isEmpty {
                            ContentUnavailableView(
                                "No matches found",
                                systemImage: "fork.knife",
                                description: Text("Try adjusting your filters or adding more ingredients.")
                            )
                        } else {
                            // Recipe count header
                            HStack {
                                Text("\(recipes.count) recipe\(recipes.count == 1 ? "" : "s") found")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            List(recipes) { recipe in
                                NavigationLink {
                                    RecipeDetailView(
                                        id: recipe.id,
                                        title: recipe.title,
                                        imageURL: recipe.image
                                    )
                                } label: {
                                    HStack(spacing: 12) {
                                        AsyncImage(url: URL(string: recipe.image ?? "")) { img in
                                            img.resizable().scaledToFill()
                                        } placeholder: {
                                            Color.gray.opacity(0.15)
                                        }
                                        .frame(width: 70, height: 70)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(recipe.title)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .lineLimit(2)
                                            
                                            if let used = recipe.usedIngredientCount, let missed = recipe.missedIngredientCount {
                                                HStack(spacing: 8) {
                                                    Label("\(used)", systemImage: "checkmark.circle.fill")
                                                        .font(.caption)
                                                        .foregroundStyle(.green)
                                                    Label("\(missed)", systemImage: "cart")
                                                        .font(.caption)
                                                        .foregroundStyle(.orange)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .listStyle(.plain)
                        }
                    case .error(let msg):
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundStyle(.red)
                            Text(msg)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            Button("Try Again") {
                                Task { await vm.search(using: Array(items)) }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    }
                    
                    Spacer()

                    // Search button
                    Button {
                        Task {
                            await vm.search(using: Array(items))
                        }
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Find Recipes")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(items.isEmpty ? Color.gray : Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    }
                    .disabled(items.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom)
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
