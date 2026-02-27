import SwiftUI

struct WeekDetailView: View {
    @EnvironmentObject var mgr: BabyManager
    @State private var selectedWeek: Int = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                weekSelector
                fruitCard
                statsGrid
                devCard
                tipCard
            }.padding().padding(.bottom, 30)
        }
        .background(Theme.bgGradient.ignoresSafeArea())
        .navigationTitle("Week \(week)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { selectedWeek = mgr.currentWeek }
    }

    private var week: Int { selectedWeek == 0 ? mgr.currentWeek : selectedWeek }
    private var info: PregnancyWeekInfo { BabyManager.weekData(for: week) }

    private var weekSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(1...40, id: \.self) { w in
                    Button { withAnimation(.spring(response: 0.3)) { selectedWeek = w }; haptic(.light) } label: {
                        Text("\(w)").font(.caption2.bold())
                            .foregroundColor(w == week ? .white : Theme.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(w == week ? Theme.rose : (w == mgr.currentWeek ? Theme.rose.opacity(0.2) : Color.white.opacity(0.05)))
                            .cornerRadius(8)
                    }
                }
            }.padding(.horizontal, 4)
        }
    }

    private var fruitCard: some View {
        VStack(spacing: 12) {
            Text(info.fruitIcon).font(.system(size: 80))
            Text(info.fruit).font(.title2.bold()).foregroundColor(.white)
            Text("Week \(week) • \(Trimester.from(week: week).rawValue)")
                .font(.subheadline).foregroundColor(Theme.textSecondary)
        }.frame(maxWidth: .infinity).padding(24)
         .background(LinearGradient(colors: [Theme.rose.opacity(0.1), Theme.lavender.opacity(0.06)], startPoint: .top, endPoint: .bottom))
         .cornerRadius(20)
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            statBox(title: "Size", value: String(format: "%.1f cm", info.sizeCm), color: Theme.teal)
            statBox(title: "Weight", value: info.weightG > 0 ? "\(info.weightG) g" : "< 1g", color: Theme.peach)
            statBox(title: "Trimester", value: trimesterNum, color: Theme.lavender)
        }
    }

    private var trimesterNum: String {
        switch Trimester.from(week: week) { case .first: return "1st"; case .second: return "2nd"; case .third: return "3rd" }
    }

    private func statBox(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(title).font(.caption2).foregroundColor(Theme.textSecondary)
            Text(value).font(.headline.bold()).foregroundColor(color)
        }.frame(maxWidth: .infinity).padding(12).background(Color.white.opacity(0.06)).cornerRadius(12)
    }

    private var devCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Development", systemImage: "brain.head.profile.fill").font(.headline).foregroundColor(Theme.lavender)
            Text(info.development).font(.body).foregroundColor(Theme.textPrimary)
        }.frame(maxWidth: .infinity, alignment: .leading).cardStyle()
    }

    private var tipCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Tip for Mama", systemImage: "lightbulb.fill").font(.headline).foregroundColor(Theme.peach)
            Text(info.tip).font(.body).foregroundColor(Theme.textPrimary)
        }.frame(maxWidth: .infinity, alignment: .leading).cardStyle()
    }
}
