//
//  AnalyticsView.swift
//  PantryChef
//
//  Created by Ethan on 5/10/2025.
//

import SwiftUI

struct AnalyticsView: View {
    @State private var searchHistory: [SearchHistoryItem] = []
    @State private var mostViewed: [ViewedRecipeItem] = []
    @State private var recentlyViewed: [ViewedRecipeItem] = []
    @State private var popularSearches: [(query: String, count: Int)] = []
    @State private var totalSearches = 0
    @State private var uniqueRecipes = 0
    
    var body: some View {
        List {
            Section {
                HStack {
                    StatCard(title: "Total Searches", value: "\(totalSearches)", icon: "magnifyingglass")
                    StatCard(title: "Recipes Viewed", value: "\(uniqueRecipes)", icon: "book")
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            
            if !popularSearches.isEmpty {
                Section("Popular Searches") {
                    ForEach(popularSearches, id: \.query) { item in
                        HStack {
                            Text(item.query)
                                .font(.subheadline)
                            Spacer()
                            Text("\(item.count)×")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            if !mostViewed.isEmpty {
                Section("Most Viewed Recipes") {
                    ForEach(mostViewed) { recipe in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.title)
                                .font(.headline)
                            HStack {
                                Label("\(recipe.viewCount) views", systemImage: "eye")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(recipe.lastViewed, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            
            if !searchHistory.isEmpty {
                Section {
                    ForEach(searchHistory) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.query)
                                .font(.subheadline)
                            HStack {
                                Text("\(item.resultCount) results")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(item.timestamp, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Recent Searches")
                        Spacer()
                        Button("Clear") {
                            RecipeHistoryDB.shared.clearSearchHistory()
                            loadData()
                        }
                        .font(.caption)
                        .foregroundStyle(.red)
                    }
                }
            }
            
            if searchHistory.isEmpty && mostViewed.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Analytics Yet",
                        systemImage: "chart.bar",
                        description: Text("Start searching for recipes to see your activity.")
                    )
                }
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadData()
        }
        .refreshable {
            loadData()
        }
    }
    
    private func loadData() {
        searchHistory = RecipeHistoryDB.shared.getRecentSearches()
        mostViewed = RecipeHistoryDB.shared.getMostViewedRecipes()
        recentlyViewed = RecipeHistoryDB.shared.getRecentlyViewedRecipes()
        popularSearches = RecipeHistoryDB.shared.getPopularSearches()
        totalSearches = RecipeHistoryDB.shared.getTotalSearchCount()
        uniqueRecipes = RecipeHistoryDB.shared.getUniqueRecipeViewCount()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        AnalyticsView()
    }
}
