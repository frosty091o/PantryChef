//
//  Convenience.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import CoreData

extension PantryItem {
    static func create(
        name: String,
        qty: Double? = nil,
        unit: String? = nil,
        in ctx: NSManagedObjectContext
    ) -> PantryItem {
        let item = PantryItem(context: ctx)
        item.id = UUID()
        item.name = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        item.quantity = qty ?? 0
        item.unit = unit
        item.updatedAt = Date()
        return item
    }
}

extension NSManagedObjectContext {
    func saveIfChanged() {
        guard hasChanges else { return }
        try? save()
    }
}
