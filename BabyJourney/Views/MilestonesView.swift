import SwiftUI
import Charts

struct MilestonesView: View {
    @EnvironmentObject var mgr: BabyManager
    @State private var selectedCategory: MilestoneCategory?
    @State private var search = ""

    private var filtered: [Milestone] {
        var list = mgr.milestones
        if let cat = selectedCategory { list = list.filter { $0.category == cat } }
        if !search.isEmpty { list = list.filter { $0.title.localizedCaseInsensitiveContains(search) } }
        return list.sorted { $0.typicalMonth < $1.typicalMonth }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                progressChart
                categoryFilter
                milestoneList
            }.padding().padding(.bottom, 30)
        }
        .searchable(text: $search, prompt: "Search milestones")
        .background(Theme.bgGradient.ignoresSafeArea())
        .navigationTitle("Milestones")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var progressChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress by Category").font(.headline).foregroundColor(.white)
            Chart {
                ForEach(MilestoneCategory.allCases) { cat in
                    let total = mgr.milestones.filter { $0.category == cat }.count
                    let done = mgr.milestones.filter { $0.category == cat && $0.achieved }.count
                    BarMark(x: .value("Done", done), y: .value("Category", cat.rawValue))
                        .foregroundStyle(cat.color)
                    BarMark(x: .value("Remaining", total - done), y: .value("Category", cat.rawValue))
                        .foregroundStyle(Color.white.opacity(0.08))
                }
            }
            .chartXAxis { AxisMarks { _ in AxisValueLabel().foregroundStyle(Theme.textSecondary) } }
            .chartYAxis { AxisMarks { _ in AxisValueLabel().foregroundStyle(Theme.textSecondary) } }
            .frame(height: 160)
        }.cardStyle()
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(nil, label: "All")
                ForEach(MilestoneCategory.allCases) { cat in
                    filterChip(cat, label: cat.rawValue)
                }
            }
        }
    }

    private func filterChip(_ cat: MilestoneCategory?, label: String) -> some View {
        Button { withAnimation { selectedCategory = cat }; haptic(.light) } label: {
            Text(label).font(.caption.bold()).foregroundColor(selectedCategory == cat ? .white : Theme.textSecondary)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(selectedCategory == cat ? (cat?.color ?? Theme.rose) : Color.white.opacity(0.06))
                .cornerRadius(20)
        }
    }

    private var milestoneList: some View {
        LazyVStack(spacing: 10) {
            ForEach(filtered) { m in
                HStack(spacing: 14) {
                    Button { mgr.toggleMilestone(m); haptic() } label: {
                        Image(systemName: m.achieved ? "star.fill" : "star")
                            .font(.title3).foregroundColor(m.achieved ? Theme.peach : Theme.textSecondary)
                    }.buttonStyle(.plain)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(m.title).font(.subheadline.bold()).foregroundColor(m.achieved ? Theme.textSecondary : .white).strikethrough(m.achieved)
                        HStack(spacing: 6) {
                            Image(systemName: m.category.icon).font(.caption2).foregroundColor(m.category.color)
                            Text("~\(m.typicalMonth) months").font(.caption2).foregroundColor(Theme.textSecondary)
                            if let d = m.achievedDate { Text("✓ \(d, style: .date)").font(.caption2).foregroundColor(Theme.teal) }
                        }
                    }
                    Spacer()
                }.padding(12).background(Color.white.opacity(0.04)).cornerRadius(12)
            }
        }
    }
}
