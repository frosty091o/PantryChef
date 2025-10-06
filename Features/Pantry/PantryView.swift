//
//  PantryView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI
import CoreData

struct PantryView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm: PantryViewModel

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PantryItem.updatedAt, ascending: false)],
        animation: .default)
    private var items: FetchedResults<PantryItem>

    init(context: NSManagedObjectContext) {
        _vm = StateObject(wrappedValue: PantryViewModel(context: context))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Input section - slightly improved layout
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        TextField("Ingredient name", text: $vm.name)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()

                        TextField("Qty", text: $vm.quantity)
                            .frame(width: 55)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)

                        TextField("Unit", text: $vm.unit)
                            .frame(width: 70)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()

                        Button {
                            vm.addItem()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(vm.name.isEmpty ? .gray : .blue)
                        }
                        .disabled(vm.name.isEmpty)
                    }
                    
                    if !vm.name.isEmpty || !vm.quantity.isEmpty || !vm.unit.isEmpty {
                        Button("Clear") {
                            vm.clearForm()
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))

                if items.isEmpty {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView(
                            "No pantry items yet",
                            systemImage: "tray",
                            description: Text("Add ingredients to start getting recipe suggestions.")
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No pantry items yet").font(.headline)
                            Text("Add ingredients to start getting recipe suggestions.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    }
                } else {
                    List {
                        ForEach(items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name?.capitalized ?? "Unnamed")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    if item.quantity > 0 {
                                        Text("\(item.quantity, specifier: "%.1f") \(item.unit ?? "")")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.title3)
                            }
                            .padding(.vertical, 6)
                        }
                        .onDelete { offsets in
                            offsets.map { items[$0] }.forEach(vm.deleteItem)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Pantry")
        }
    }
}
