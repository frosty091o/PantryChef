//
//  PantryChefApp.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI
import CoreData
import FirebaseCore   

@main
struct PantryChefApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        // Configure Firebase on app launch
        FirebaseApp.configure()
        
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
