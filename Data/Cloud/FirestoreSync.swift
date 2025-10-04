//
//  FirestoreSync.swift
//  PantryChef
//
//  Created by Ethan on 4/10/2025.
//

import Foundation
import FirebaseFirestore
import CoreData

final class FirestoreSync {
    static let shared = FirestoreSync()
    private init() {}
    private let db = Firestore.firestore()

    // MARK: - Pantry sync

    func pushPantryItem(_ item: PantryItem) {
        guard let id = item.id?.uuidString,
              let name = item.name else { return }

        let data: [String: Any] = [
            "name": name,
            "quantity": item.quantity,
            "unit": item.unit ?? "",
            "updatedAt": (item.updatedAt ?? Date()).timeIntervalSince1970
        ]

        db.collection("pantry").document(id).setData(data, merge: true)
    }

    func pullPantryItems(completion: @escaping ([[String: Any]]) -> Void) {
        db.collection("pantry").getDocuments { snap, _ in
            completion(snap?.documents.map { $0.data() } ?? [])
        }
    }

    // MARK: - Favourites sync

    func pushFavourite(_ fav: RecipeLocal) {
        guard let id = fav.id else { return }

        let data: [String: Any] = [
            "title": fav.title ?? "",
            "imageURL": fav.imageURL ?? "",
            "isFavourite": fav.isFavourite,
            "updatedAt": (fav.updatedAt ?? Date()).timeIntervalSince1970
        ]

        db.collection("favourites").document(id).setData(data, merge: true)
    }
}
