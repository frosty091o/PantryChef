//
//  RecipeHistoryDB.swift
//  PantryChef
//
//  Created by Ethan on 5/10/2025.
//

import Foundation
import SQLite

/// SQLite-based cache for recipe search history and analytics
final class RecipeHistoryDB {
    static let shared = RecipeHistoryDB()
    
    private var db: Connection?
    
    // Table definitions
    private let searchHistory = Table("search_history")
    private let id = Expression<Int64>("id")
    private let searchQuery = Expression<String>("search_query")
    private let timestamp = Expression<Date>("timestamp")
    private let resultCount = Expression<Int>("result_count")
    
    private let viewedRecipes = Table("viewed_recipes")
    private let recipeId = Expression<Int>("recipe_id")
    private let recipeTitle = Expression<String>("recipe_title")
    private let viewCount = Expression<Int>("view_count")
    private let lastViewed = Expression<Date>("last_viewed")
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        do {
            let documentDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let dbPath = documentDirectory.appendingPathComponent("pantry_chef.sqlite3").path
            db = try Connection(dbPath)
            createTables()
        } catch {
            print("SQLite setup error: \(error)")
        }
    }
    
    private func createTables() {
        guard let db = db else { return }
        
        do {
            // Search history table
            try db.run(searchHistory.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(searchQuery)
                t.column(timestamp)
                t.column(resultCount)
            })
            
            // Viewed recipes table
            try db.run(viewedRecipes.create(ifNotExists: true) { t in
                t.column(recipeId, primaryKey: true)
                t.column(recipeTitle)
                t.column(viewCount)
                t.column(lastViewed)
            })
            
            print("SQLite tables created successfully")
        } catch {
            print("Table creation error: \(error)")
        }
    }
    
    // MARK: - Search History Methods
    
    /// Save a search query with its result count
    func saveSearch(query: String, resultCount: Int) {
        guard let db = db, !query.isEmpty else { return }
        
        do {
            try db.run(searchHistory.insert(
                searchQuery <- query.lowercased(),
                timestamp <- Date(),
                self.resultCount <- resultCount
            ))
        } catch {
            print("Error saving search: \(error)")
        }
    }
    
    /// Get recent search queries (last 10)
    func getRecentSearches() -> [SearchHistoryItem] {
        guard let db = db else { return [] }
        
        do {
            let query = searchHistory
                .select(distinct: searchQuery, timestamp, resultCount)
                .order(timestamp.desc)
                .limit(10)
            
            var items: [SearchHistoryItem] = []
            for row in try db.prepare(query) {
                items.append(SearchHistoryItem(
                    query: row[searchQuery],
                    timestamp: row[timestamp],
                    resultCount: row[resultCount]
                ))
            }
            return items
        } catch {
            print("Error fetching searches: \(error)")
            return []
        }
    }
    
    /// Get popular search queries (most searched)
    func getPopularSearches(limit: Int = 5) -> [(query: String, count: Int)] {
        guard let db = db else { return [] }
        
        do {
            let query = searchHistory
                .select(searchQuery, count(searchQuery))
                .group(searchQuery)
                .order(count(searchQuery).desc)
                .limit(limit)
            
            var results: [(String, Int)] = []
            for row in try db.prepare(query) {
                results.append((row[searchQuery], Int(row[count(searchQuery)])))
            }
            return results
        } catch {
            print("Error fetching popular searches: \(error)")
            return []
        }
    }
    
    /// Clear all search history
    func clearSearchHistory() {
        guard let db = db else { return }
        do {
            try db.run(searchHistory.delete())
            print("Search history cleared")
        } catch {
            print("Error clearing history: \(error)")
        }
    }
    
    // MARK: - Viewed Recipes Methods
    
    /// Record a recipe view
    func recordRecipeView(id: Int, title: String) {
        guard let db = db else { return }
        
        do {
            // Check if recipe already exists
            let existing = viewedRecipes.filter(recipeId == id)
            
            if let row = try db.pluck(existing) {
                // Update view count
                try db.run(existing.update(
                    viewCount <- row[viewCount] + 1,
                    lastViewed <- Date()
                ))
            } else {
                // Insert new record
                try db.run(viewedRecipes.insert(
                    recipeId <- id,
                    recipeTitle <- title,
                    viewCount <- 1,
                    lastViewed <- Date()
                ))
            }
        } catch {
            print("Error recording recipe view: \(error)")
        }
    }
    
    /// Get most viewed recipes
    func getMostViewedRecipes(limit: Int = 10) -> [ViewedRecipeItem] {
        guard let db = db else { return [] }
        
        do {
            let query = viewedRecipes
                .order(viewCount.desc, lastViewed.desc)
                .limit(limit)
            
            var items: [ViewedRecipeItem] = []
            for row in try db.prepare(query) {
                items.append(ViewedRecipeItem(
                    id: row[recipeId],
                    title: row[recipeTitle],
                    viewCount: row[viewCount],
                    lastViewed: row[lastViewed]
                ))
            }
            return items
        } catch {
            print("Error fetching viewed recipes: \(error)")
            return []
        }
    }
    
    /// Get recently viewed recipes
    func getRecentlyViewedRecipes(limit: Int = 10) -> [ViewedRecipeItem] {
        guard let db = db else { return [] }
        
        do {
            let query = viewedRecipes
                .order(lastViewed.desc)
                .limit(limit)
            
            var items: [ViewedRecipeItem] = []
            for row in try db.prepare(query) {
                items.append(ViewedRecipeItem(
                    id: row[recipeId],
                    title: row[recipeTitle],
                    viewCount: row[viewCount],
                    lastViewed: row[lastViewed]
                ))
            }
            return items
        } catch {
            print("Error fetching recent recipes: \(error)")
            return []
        }
    }
    
    // MARK: - Analytics
    
    /// Get total number of searches performed
    func getTotalSearchCount() -> Int {
        guard let db = db else { return 0 }
        return (try? db.scalar(searchHistory.count)) ?? 0
    }
    
    /// Get total number of unique recipes viewed
    func getUniqueRecipeViewCount() -> Int {
        guard let db = db else { return 0 }
        return (try? db.scalar(viewedRecipes.count)) ?? 0
    }
}

// MARK: - Supporting Models

struct SearchHistoryItem: Identifiable {
    let id = UUID()
    let query: String
    let timestamp: Date
    let resultCount: Int
}

struct ViewedRecipeItem: Identifiable {
    let id: Int
    let title: String
    let viewCount: Int
    let lastViewed: Date
}
