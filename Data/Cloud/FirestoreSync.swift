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

    /// Push a pantry item to Firestore
    func pushPantryItem(_ item: PantryItem) {
        guard let id = item.id?.uuidString,
              let name = item.name else { return }

        let data: [String: Any] = [
            "name": name,
            "quantity": item.quantity,
            "unit": item.unit ?? "",
            "updatedAt": (item.updatedAt ?? Date()).timeIntervalSince1970
        ]

        db.collection("pantry").document(id).setData(data, merge: true) { error in
            if let error = error {
                print("Error pushing pantry item: \(error)")
            } else {
                print("Pantry item synced: \(name)")
            }
        }
    }

    /// Pull all pantry items from Firestore
    func pullPantryItems(completion: @escaping ([[String: Any]]) -> Void) {
        db.collection("pantry").getDocuments { snap, error in
            if let error = error {
                print("Error pulling pantry items: \(error)")
                completion([])
                return
            }
            completion(snap?.documents.map { $0.data() } ?? [])
        }
    }
    
    /// Sync pantry items bidirectionally with conflict resolution
    func syncPantryItems(context: NSManagedObjectContext, completion: @escaping (Result<Int, Error>) -> Void) {
        db.collection("pantry").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success(0))
                return
            }
            
            var synced = 0
            
            for doc in documents {
                let data = doc.data()
                guard let name = data["name"] as? String else { continue }
                
                let remoteUpdated = Date(timeIntervalSince1970: data["updatedAt"] as? Double ?? 0)
                
                // Check if item exists locally
                let req: NSFetchRequest<PantryItem> = PantryItem.fetchRequest()
                req.predicate = NSPredicate(format: "id == %@", doc.documentID)
                
                if let existing = try? context.fetch(req).first {
                    // Conflict resolution: use most recent timestamp
                    if remoteUpdated > (existing.updatedAt ?? Date.distantPast) {
                        existing.name = name
                        existing.quantity = data["quantity"] as? Double ?? 0
                        existing.unit = data["unit"] as? String
                        existing.updatedAt = remoteUpdated
                        synced += 1
                    }
                } else {
                    // Create new local item
                    let item = PantryItem(context: context)
                    item.id = UUID(uuidString: doc.documentID)
                    item.name = name
                    item.quantity = data["quantity"] as? Double ?? 0
                    item.unit = data["unit"] as? String
                    item.updatedAt = remoteUpdated
                    synced += 1
                }
            }
            
            try? context.save()
            completion(.success(synced))
        }
    }
    
    /// Delete a pantry item from Firestore
    func deletePantryItem(id: UUID) {
        db.collection("pantry").document(id.uuidString).delete { error in
            if let error = error {
                print("Error deleting pantry item: \(error)")
            } else {
                print("Pantry item deleted from cloud")
            }
        }
    }

    // MARK: - Favourites sync

    /// Push a favourite recipe to Firestore
    func pushFavourite(_ fav: RecipeLocal) {
        guard let id = fav.id else { return }

        let data: [String: Any] = [
            "title": fav.title ?? "",
            "imageURL": fav.imageURL ?? "",
            "isFavourite": fav.isFavourite,
            "updatedAt": (fav.updatedAt ?? Date()).timeIntervalSince1970
        ]

        db.collection("favourites").document(id).setData(data, merge: true) { error in
            if let error = error {
                print("Error pushing favourite: \(error)")
            } else {
                print("Favourite synced: \(fav.title ?? "Unknown")")
            }
        }
    }
    
    /// Pull all favourites from Firestore
    func pullFavourites(completion: @escaping ([[String: Any]]) -> Void) {
        db.collection("favourites").getDocuments { snap, error in
            if let error = error {
                print("Error pulling favourites: \(error)")
                completion([])
                return
            }
            completion(snap?.documents.map { $0.data() } ?? [])
        }
    }
    
    /// Sync favourites bidirectionally with conflict resolution
    func syncFavourites(context: NSManagedObjectContext, completion: @escaping (Result<Int, Error>) -> Void) {
        db.collection("favourites").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success(0))
                return
            }
            
            var synced = 0
            
            for doc in documents {
                let data = doc.data()
                let remoteUpdated = Date(timeIntervalSince1970: data["updatedAt"] as? Double ?? 0)
                let isFavourite = data["isFavourite"] as? Bool ?? false
                
                // Check if recipe exists locally
                let req: NSFetchRequest<RecipeLocal> = RecipeLocal.fetchRequest()
                req.predicate = NSPredicate(format: "id == %@", doc.documentID)
                
                if let existing = try? context.fetch(req).first {
                    // Conflict resolution: use most recent timestamp
                    if remoteUpdated > (existing.updatedAt ?? Date.distantPast) {
                        existing.title = data["title"] as? String
                        existing.imageURL = data["imageURL"] as? String
                        existing.isFavourite = isFavourite
                        existing.updatedAt = remoteUpdated
                        synced += 1
                    }
                } else if isFavourite {
                    // Only create new local favourite if it's marked as favourite remotely
                    let recipe = RecipeLocal(context: context)
                    recipe.id = doc.documentID
                    recipe.title = data["title"] as? String
                    recipe.imageURL = data["imageURL"] as? String
                    recipe.isFavourite = isFavourite
                    recipe.updatedAt = remoteUpdated
                    synced += 1
                }
            }
            
            try? context.save()
            completion(.success(synced))
        }
    }
    
    /// Delete a favourite from Firestore (when unfavourited)
    func deleteFavourite(id: String) {
        db.collection("favourites").document(id).delete { error in
            if let error = error {
                print("Error deleting favourite: \(error)")
            } else {
                print("Favourite deleted from cloud")
            }
        }
    }
    
    // MARK: - Real-time listeners
    
    /// Listen for pantry changes in real-time
    func listenToPantryChanges(context: NSManagedObjectContext, onChange: @escaping () -> Void) -> ListenerRegistration {
        return db.collection("pantry").addSnapshotListener { snapshot, error in
            guard error == nil else { return }
            
            self.syncPantryItems(context: context) { result in
                if case .success = result {
                    onChange()
                }
            }
        }
    }
    
    /// Listen for favourite changes in real-time
    func listenToFavouriteChanges(context: NSManagedObjectContext, onChange: @escaping () -> Void) -> ListenerRegistration {
        return db.collection("favourites").addSnapshotListener { snapshot, error in
            guard error == nil else { return }
            
            self.syncFavourites(context: context) { result in
                if case .success = result {
                    onChange()
                }
            }
        }
    }
}
