//
//  FavouritesView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI

struct FavouritesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Favourites").font(.title2).bold()
            Text("Saved recipes will appear here.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
