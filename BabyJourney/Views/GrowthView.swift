import SwiftUI
import Charts

struct GrowthView: View {
    @EnvironmentObject var mgr: BabyManager
    @State private var showAdd = false
    @State private var newW = ""
    @State private var newL = ""
    @State private var newH = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                latestCard
                weightChart
                lengthChart
                headChart
                addSection
            }.padding().padding(.bottom, 30)
        }
        .background(Theme.bgGradient.ignoresSafeArea())
        .navigationTitle("Growth Charts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { showAdd.toggle() } label: { Image(systemName: "plus.circle.fill").foregroundColor(Theme.teal) } } }
        .alert("Add Measurement", isPresented: $showAdd) {
            TextField("Weight (kg)", text: $newW).keyboardType(.decimalPad)
            TextField("Length (cm)", text: $newL).keyboardType(.decimalPad)
            TextField("Head (cm)", text: $newH).keyboardType(.decimalPad)
            Button("Save") { saveEntry(); haptic() }
            Button("Cancel", role: .cancel) { }
        }
    }

    private var latestCard: some View {
        VStack(spacing: 8) {
            if let g = mgr.growth.last {
                HStack(spacing: 20) {
                    statBox("Weight", String(format: "%.1f kg", g.weightKg), Theme.peach)
                    statBox("Length", String(format: "%.1f cm", g.lengthCm), Theme.teal)
                    statBox("Head", String(format: "%.1f cm", g.headCm), Theme.lavender)
                }
            } else {
                Text("No measurements yet").font(.caption).foregroundColor(Theme.textSecondary)
            }
        }.cardStyle()
    }

    private func statBox(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption2).foregroundColor(Theme.textSecondary)
            Text(value).font(.headline.bold()).foregroundColor(color)
        }.frame(maxWidth: .infinity)
    }

    private var weightChart: some View {
        chartSection(title: "Weight (kg)", color: Theme.peach) { i, g in
            LineMark(x: .value("Entry", i + 1), y: .value("kg", g.weightKg)).foregroundStyle(Theme.peach).interpolationMethod(.catmullRom)
            PointMark(x: .value("Entry", i + 1), y: .value("kg", g.weightKg)).foregroundStyle(Theme.peach)
        }
    }

    private var lengthChart: some View {
        chartSection(title: "Length (cm)", color: Theme.teal) { i, g in
            LineMark(x: .value("Entry", i + 1), y: .value("cm", g.lengthCm)).foregroundStyle(Theme.teal).interpolationMethod(.catmullRom)
            PointMark(x: .value("Entry", i + 1), y: .value("cm", g.lengthCm)).foregroundStyle(Theme.teal)
        }
    }

    private var headChart: some View {
        chartSection(title: "Head Circumference (cm)", color: Theme.lavender) { i, g in
            LineMark(x: .value("Entry", i + 1), y: .value("cm", g.headCm)).foregroundStyle(Theme.lavender).interpolationMethod(.catmullRom)
            PointMark(x: .value("Entry", i + 1), y: .value("cm", g.headCm)).foregroundStyle(Theme.lavender)
        }
    }

    @ViewBuilder
    private func chartSection(title: String, color: Color, @ChartContentBuilder content: @escaping (Int, GrowthEntry) -> some ChartContent) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline).foregroundColor(color)
            if mgr.growth.count >= 2 {
                Chart {
                    ForEach(Array(mgr.growth.enumerated()), id: \.element.id) { i, g in content(i, g) }
                }
                .chartYAxis { AxisMarks(position: .leading) { _ in AxisValueLabel().foregroundStyle(Theme.textSecondary) } }
                .chartXAxis { AxisMarks { _ in AxisValueLabel().foregroundStyle(Theme.textSecondary) } }
                .frame(height: 160)
            } else {
                Text("Add 2+ entries to see chart").font(.caption).foregroundColor(Theme.textSecondary).frame(maxWidth: .infinity, alignment: .center).frame(height: 80)
            }
        }.cardStyle()
    }

    private var addSection: some View {
        VStack(spacing: 8) {
            Text("Track measurements regularly for accurate growth curves.").font(.caption).foregroundColor(Theme.textSecondary).multilineTextAlignment(.center)
            Text("\(mgr.growth.count) measurements recorded").font(.caption2).foregroundColor(Theme.textSecondary)
        }.cardStyle()
    }

    private func saveEntry() {
        let w = Double(newW) ?? 0; let l = Double(newL) ?? 0; let h = Double(newH) ?? 0
        if w > 0 || l > 0 || h > 0 { mgr.addGrowth(GrowthEntry(weightKg: w, lengthCm: l, headCm: h)) }
        newW = ""; newL = ""; newH = ""
    }
}
