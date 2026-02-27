import SwiftUI

struct HospitalBagView: View {
    @EnvironmentObject var mgr: BabyManager
    @State private var search = ""
    @State private var showAdd = false
    @State private var newName = ""
    @State private var newCategory = "Clothing"

    private let categories = ["Documents", "Clothing", "Hygiene", "Comfort", "Baby", "Electronics"]

    private var filtered: [HospitalBagItem] {
        search.isEmpty ? mgr.hospitalBag : mgr.hospitalBag.filter { $0.name.localizedCaseInsensitiveContains(search) || $0.category.localizedCaseInsensitiveContains(search) }
    }

    private var grouped: [(String, [HospitalBagItem])] {
        Dictionary(grouping: filtered, by: \.category).sorted { $0.key < $1.key }
    }

    var body: some View {
        List {
            progressHeader

            ForEach(grouped, id: \.0) { cat, items in
                Section {
                    ForEach(items) { item in
                        HStack(spacing: 12) {
                            Button { mgr.toggleBagItem(item); haptic(.light) } label: {
                                Image(systemName: item.packed ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.packed ? Theme.teal : Theme.textSecondary).font(.title3)
                            }.buttonStyle(.plain)
                            Text(item.name).font(.subheadline)
                                .foregroundColor(item.packed ? Theme.textSecondary : .white)
                                .strikethrough(item.packed)
                        }.listRowBackground(Color.white.opacity(0.04))
                    }
                } header: {
                    HStack {
                        Text(cat).font(.caption.bold()).foregroundColor(Theme.lavender)
                        Spacer()
                        let done = items.filter(\.packed).count
                        Text("\(done)/\(items.count)").font(.caption2).foregroundColor(Theme.textSecondary)
                    }
                }
            }
        }
        .searchable(text: $search, prompt: "Search items")
        .scrollContentBackground(.hidden)
        .background(Theme.bgGradient.ignoresSafeArea())
        .navigationTitle("Hospital Bag")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { showAdd = true } label: { Image(systemName: "plus.circle.fill").foregroundColor(Theme.peach) } } }
        .alert("Add Item", isPresented: $showAdd) {
            TextField("Item name", text: $newName)
            Button("Add") { if !newName.isEmpty { mgr.hospitalBag.append(HospitalBagItem(name: newName, category: newCategory)); newName = "" }; haptic() }
            Button("Cancel", role: .cancel) { newName = "" }
        }
    }

    private var progressHeader: some View {
        Section {
            VStack(spacing: 8) {
                let pct = Int(mgr.bagProgress * 100)
                Text("\(pct)% packed").font(.title2.bold()).foregroundColor(Theme.peach)
                WaveProgressBar(progress: mgr.bagProgress, label: "Progress", detail: "\(mgr.hospitalBag.filter(\.packed).count)/\(mgr.hospitalBag.count)", color: Theme.peach)
            }.listRowBackground(Color.white.opacity(0.04))
        }
    }
}
