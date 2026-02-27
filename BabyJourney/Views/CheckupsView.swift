import SwiftUI

struct CheckupsView: View {
    @EnvironmentObject var mgr: BabyManager
    @State private var search = ""

    private var filtered: [CheckupItem] {
        search.isEmpty ? mgr.checkups : mgr.checkups.filter { $0.title.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        List {
            ForEach(filtered) { item in
                HStack(spacing: 14) {
                    Button { mgr.toggleCheckup(item); haptic(.light) } label: {
                        Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                            .font(.title3).foregroundColor(item.completed ? Theme.teal : Theme.textSecondary)
                    }.buttonStyle(.plain)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title).font(.subheadline.bold())
                            .foregroundColor(item.completed ? Theme.textSecondary : .white)
                            .strikethrough(item.completed)
                        Text("Week \(item.week)").font(.caption).foregroundColor(Theme.textSecondary)
                    }
                    Spacer()
                    if item.week <= mgr.currentWeek && !item.completed {
                        Text("DUE").font(.caption2.bold()).foregroundColor(Theme.rose)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Theme.rose.opacity(0.15)).cornerRadius(6)
                    }
                }
                .listRowBackground(Color.white.opacity(0.04))
            }
        }
        .searchable(text: $search, prompt: "Search checkups")
        .scrollContentBackground(.hidden)
        .background(Theme.bgGradient.ignoresSafeArea())
        .navigationTitle("Checkups")
        .navigationBarTitleDisplayMode(.inline)
    }
}
