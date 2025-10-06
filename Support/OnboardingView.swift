//
//  Untitled.swift
//  PantryChef
//
//  Created by Ethan on 6/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                // Page 1: Welcome
                OnboardingPage(
                    icon: "fork.knife.circle.fill",
                    iconColor: .blue,
                    title: "Welcome to PantryChef",
                    description: "Find recipes based on ingredients you already have. Never waste food again!",
                    page: 0
                )
                .tag(0)
                
                // Page 2: Pantry
                OnboardingPage(
                    icon: "tray.fill",
                    iconColor: .green,
                    title: "Manage Your Pantry",
                    description: "Add ingredients you have at home. We'll keep track of everything for you.",
                    page: 1
                )
                .tag(1)
                
                // Page 3: Discover
                OnboardingPage(
                    icon: "magnifyingglass.circle.fill",
                    iconColor: .orange,
                    title: "Discover Recipes",
                    description: "Search for recipes using your pantry items. See exactly what you need to buy!",
                    page: 2
                )
                .tag(2)
                
                // Page 4: Features
                OnboardingPage(
                    icon: "star.circle.fill",
                    iconColor: .purple,
                    title: "More Features",
                    description: "Save favorites, find nearby supermarkets, and sync across devices with Firebase.",
                    page: 3
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // Bottom button
            Button {
                if currentPage < 3 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    hasOnboarded = true
                }
            } label: {
                Text(currentPage < 3 ? "Next" : "Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
        .contentShape(Rectangle())
    }
}

struct OnboardingPage: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let page: Int
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 100))
                .foregroundStyle(iconColor)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
