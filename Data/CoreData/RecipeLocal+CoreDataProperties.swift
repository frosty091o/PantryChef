#if MANUAL_CORE_DATA

//
//  RecipeLocal+CoreDataProperties.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//
//

public import Foundation
public import CoreData


public typealias RecipeLocalCoreDataPropertiesSet = NSSet

extension RecipeLocal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeLocal> {
        return NSFetchRequest<RecipeLocal>(entityName: "RecipeLocal")
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var jsonBlob: Data?
    @NSManaged public var isFavourite: Bool
    @NSManaged public var updatedAt: Date?

}

extension RecipeLocal : Identifiable {

}

#endif
