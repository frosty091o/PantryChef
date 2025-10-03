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
            print("❌ Failed to save item: \(error)")
        }
    }

    func deleteItem(_ item: PantryItem) {
        context.delete(item)
        do {
            try context.save()
            // Firestore delete could be added here if needed
        } catch {
            print("❌ Delete failed: \(error)")
        }
    }

    func clearForm() {
        name = ""
        quantity = ""
        unit = ""
    }
}
