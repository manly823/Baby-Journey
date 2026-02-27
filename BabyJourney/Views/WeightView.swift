import SwiftUI
import Charts

struct WeightView: View {
    @EnvironmentObject var mgr: BabyManager
    @State private var showAdd = false
    @State private var newWeight = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                currentCard
                chartCard
                historySection
            }.padding().padding(.bottom, 30)
        }
        .background(Theme.bgGradient.ignoresSafeArea())
        .navigationTitle("Weight Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { showAdd.toggle() } label: { Image(systemName: "plus.circle.fill").foregroundColor(Theme.peach) } } }
        .alert("Add Weight", isPresented: $showAdd) {
            TextField("Weight (kg)", text: $newWeight).keyboardType(.decimalPad)
            Button("Save") { if let w = Double(newWeight) { mgr.addWeight(WeightEntry(weightKg: w)); newWeight = "" }; haptic() }
            Button("Cancel", role: .cancel) { newWeight = "" }
        }
    }

    private var currentCard: some View {
        VStack(spacing: 8) {
            Text("Current").font(.caption).foregroundColor(Theme.textSecondary)
            Text(String(format: "%.1f kg", mgr.weights.last?.weightKg ?? 0)).font(.system(size: 42, weight: .bold, design: .rounded)).foregroundColor(Theme.peach)
            if mgr.weights.count > 1, let first = mgr.weights.first, let last = mgr.weights.last {
                let diff = last.weightKg - first.weightKg
                Text(String(format: "%+.1f kg total", diff)).font(.caption).foregroundColor(diff > 0 ? Theme.rose : Theme.teal)
            }
        }.frame(maxWidth: .infinity).cardStyle()
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weight Trend").font(.headline).foregroundColor(.white)
            if mgr.weights.count >= 2 {
                Chart {
                    ForEach(Array(mgr.weights.enumerated()), id: \.element.id) { i, w in
                        LineMark(x: .value("Entry", i + 1), y: .value("kg", w.weightKg))
                            .foregroundStyle(Theme.peach)
                            .interpolationMethod(.catmullRom)
                        PointMark(x: .value("Entry", i + 1), y: .value("kg", w.weightKg))
                            .foregroundStyle(Theme.peach)
                    }
                }
                .chartYAxis { AxisMarks(position: .leading) { _ in AxisValueLabel().foregroundStyle(Theme.textSecondary) } }
                .chartXAxis { AxisMarks { _ in AxisValueLabel().foregroundStyle(Theme.textSecondary) } }
                .frame(height: 200)
            } else {
                Text("Add at least 2 entries to see chart").font(.caption).foregroundColor(Theme.textSecondary).frame(maxWidth: .infinity).frame(height: 100)
            }
        }.cardStyle()
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("History").font(.headline).foregroundColor(.white)
            ForEach(mgr.weights.reversed()) { w in
                HStack {
                    Text(w.date, style: .date).font(.caption).foregroundColor(Theme.textSecondary)
                    Spacer()
                    Text(String(format: "%.1f kg", w.weightKg)).font(.subheadline.bold()).foregroundColor(.white)
                }.padding(.vertical, 4)
                Divider().background(Color.white.opacity(0.06))
            }
        }.cardStyle()
    }
}
