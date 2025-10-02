#if MANUAL_CORE_DATA

//
//  PantryItem+CoreDataProperties.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//
//

public import Foundation
public import CoreData


public typealias PantryItemCoreDataPropertiesSet = NSSet

extension PantryItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PantryItem> {
        return NSFetchRequest<PantryItem>(entityName: "PantryItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String?
    @NSManaged public var updatedAt: Date?

}

extension PantryItem : Identifiable {

}

#endif
