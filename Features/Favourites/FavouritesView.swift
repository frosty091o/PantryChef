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
            if favs.isEmpty {
                ContentUnavailableView("No favourites yet", systemImage: "heart",
                                       description: Text("Save recipes to view them offline."))
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
                                    .frame(width: 60, height: 60).clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            Text(r.title ?? "Recipe").lineLimit(2)
                        }
                    }
                }
                .navigationTitle("Favourites")
            }
        }
    }
}
