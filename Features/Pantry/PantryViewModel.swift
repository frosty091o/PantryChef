//
//  PantryViewModel.swift
//  PantryChef
//
//  Created by Ethan on 4/10/2025.
//
import SwiftUI
import CoreData
import Combine

@MainActor
final class PantryViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var quantity: String = ""
    @Published var unit: String = ""
    @Published var isSyncing = false

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addItem() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let item = PantryItem(context: context)
        item.id = UUID()
        item.name = name.lowercased()
        item.quantity = Double(quantity) ?? 0
        item.unit = unit
        item.updatedAt = Date()

        do {
            try context.save()
            FirestoreSync.shared.pushPantryItem(item) // sync to Firebase
            clearForm()
        } catch {
            print("Failed to save item: \(error)")
        }
    }

    func deleteItem(_ item: PantryItem) {
        let itemId = item.id
        context.delete(item)
        do {
            try context.save()
            // Delete from Firestore
            if let id = itemId {
                FirestoreSync.shared.deletePantryItem(id: id)
            }
        } catch {
            print("Delete failed: \(error)")
        }
    }
    
    func syncWithCloud() {
        isSyncing = true
        FirestoreSync.shared.syncPantryItems(context: context) { result in
            Task { @MainActor in
                self.isSyncing = false
                switch result {
                case .success(let count):
                    print("Synced \(count) pantry items")
                case .failure(let error):
                    print("Sync failed: \(error)")
                }
            }
        }
    }

    func clearForm() {
        name = ""
        quantity = ""
        unit = ""
    }
}
