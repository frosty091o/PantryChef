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
            VStack {
                HStack {
                    TextField("Ingredient name", text: $vm.name)
                        .textFieldStyle(.roundedBorder)

                    TextField("Qty", text: $vm.quantity)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)

                    TextField("Unit", text: $vm.unit)
                        .frame(width: 80)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        vm.addItem()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(vm.name.isEmpty)
                }
                .padding()

                if items.isEmpty {
                    Text("No pantry items yet.\nAdd some ingredients to get started!")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(items) { item in
                            VStack(alignment: .leading) {
                                Text(item.name ?? "Unnamed")
                                    .font(.headline)
                                if item.quantity > 0 {
                                    Text("\(item.quantity, specifier: "%.1f") \(item.unit ?? "")")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { offsets in
                            offsets.map { items[$0] }.forEach(vm.deleteItem)
                        }
                    }
                }
            }
            .navigationTitle("Pantry")
        }
    }
}
