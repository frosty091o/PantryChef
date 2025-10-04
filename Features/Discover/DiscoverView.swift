//
//  DiscoverView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

//
//  DiscoverView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI

struct DiscoverView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PantryItem.updatedAt, ascending: false)]
    ) private var items: FetchedResults<PantryItem>

    @StateObject private var vm = DiscoverViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                switch vm.state {
                case .idle:
                    Text("Search recipes using your pantry items.")
                        .foregroundStyle(.secondary)
                case .loading:
                    ProgressView("Searching…")
                case .results(let recipes):
                    List(recipes) { recipe in
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
                                Text("\(recipe.usedIngredientCount ?? 0) used, \(recipe.missedIngredientCount ?? 0) missing")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                    }
                case .error(let msg):
                    Text(msg).foregroundStyle(.red)
                }

                Button("Find Recipes") {
                    Task {
                        await vm.search(using: Array(items))
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Discover")
        }
    }
}
