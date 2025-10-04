//
//  ErrorView.swift
//  PantryChef
//
//  Created by Ethan on 5/10/2025.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retry: (() -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            Text(message)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let retry = retry {
                Button("Retry", action: retry)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
