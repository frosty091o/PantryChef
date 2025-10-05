//
//  FavouritesView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI

struct FavouritesView: View {
    @Environment(\.managedObjectContext) private var ctx
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RecipeLocal.updatedAt, ascending: false)],
        predicate: NSPredicate(format: "isFavourite == YES"))
    private var favs: FetchedResults<RecipeLocal>

    var body: some View {
        NavigationStack {
            Group {
                if favs.isEmpty {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView(
                            "No favourites yet",
                            systemImage: "heart",
                            description: Text("Save recipes to view them offline.")
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "heart")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No favourites yet").font(.headline)
                            Text("Save recipes to view them offline.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    }
                } else {
                    List(favs) { r in
                        NavigationLink(destination:
                            RecipeDetailView(id: Int(r.id ?? "0") ?? 0,
                                             title: r.title ?? "Recipe",
                                             imageURL: r.imageURL)) {
                            HStack {
                                if let s = r.imageURL, let u = URL(string: s) {
                                    AsyncImage(url: u) { $0.resizable().scaledToFill() }
                                        placeholder: { Color.gray.opacity(0.2) }
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                Text(r.title ?? "Recipe").lineLimit(2)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Favourites")
        }
    }
}
