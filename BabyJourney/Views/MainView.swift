import SwiftUI

struct MainView: View {
    @EnvironmentObject var mgr: BabyManager
    @State private var nav: String?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                    progressSection
                    if mgr.settings.mode == .pregnancy { pregnancyCards } else { babyCards }
                    settingsCard
                }.padding(.horizontal).padding(.bottom, 30)
            }
            .background(Theme.bgGradient.ignoresSafeArea())
            .navigationDestination(for: String.self) { dest in
                switch dest {
                case "week": WeekDetailView()
                case "checkups": CheckupsView()
                case "weight": WeightView()
                case "kicks": KickCounterView()
                case "bag": HospitalBagView()
                case "milestones": MilestonesView()
                case "growth": GrowthView()
                case "settings": SettingsView()
                default: EmptyView()
                }
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            if mgr.settings.mode == .pregnancy {
                Text("Week \(mgr.currentWeek)").font(.system(size: 42, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text(mgr.weekInfo.fruitIcon).font(.system(size: 60))
                Text("Baby is the size of a \(mgr.weekInfo.fruit)").font(.subheadline).foregroundColor(Theme.textSecondary)
                Text("\(mgr.daysLeft) days to go").font(.caption).foregroundColor(Theme.rose)
            } else {
                Text(mgr.settings.baby.name.isEmpty ? "Baby" : mgr.settings.baby.name).font(.system(size: 36, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text("\(mgr.babyAgeMonths) months").font(.title2).foregroundColor(Theme.peach)
                Text("\(mgr.babyAgeDays) days old").font(.caption).foregroundColor(Theme.textSecondary)
            }
        }.frame(maxWidth: .infinity).padding(.vertical, 24)
         .background(LinearGradient(colors: [Theme.rose.opacity(0.12), Theme.lavender.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
         .cornerRadius(20)
    }

    // MARK: - Progress
    private var progressSection: some View {
        VStack(spacing: 10) {
            if mgr.settings.mode == .pregnancy {
                WaveProgressBar(progress: mgr.pregnancyProgress, label: "Pregnancy", detail: "\(mgr.currentWeek)/40 weeks", color: Theme.rose)
                WaveProgressBar(progress: mgr.bagProgress, label: "Hospital Bag", detail: "\(mgr.hospitalBag.filter(\.packed).count)/\(mgr.hospitalBag.count)", color: Theme.peach)
            } else {
                WaveProgressBar(progress: mgr.milestoneProgress, label: "Milestones", detail: "\(mgr.milestones.filter(\.achieved).count)/\(mgr.milestones.count)", color: Theme.teal)
            }
        }.cardStyle()
    }

    // MARK: - Nav Cards
    private var pregnancyCards: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            navCard(dest: "week", icon: "leaf.fill", title: "This Week", subtitle: mgr.weekInfo.fruit, color: Theme.teal)
            navCard(dest: "checkups", icon: "stethoscope", title: "Checkups", subtitle: "\(mgr.checkups.filter(\.completed).count) done", color: Theme.lavender)
            navCard(dest: "weight", icon: "scalemass.fill", title: "Weight", subtitle: weights, color: Theme.peach)
            navCard(dest: "kicks", icon: "hand.tap.fill", title: "Kick Counter", subtitle: "\(mgr.kicks.count) sessions", color: Theme.rose)
            navCard(dest: "bag", icon: "bag.fill", title: "Hospital Bag", subtitle: "\(Int(mgr.bagProgress * 100))%", color: Theme.sky)
            navCard(dest: "settings", icon: "gearshape.fill", title: "Settings", subtitle: "", color: Theme.textSecondary)
        }
    }

    private var babyCards: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            navCard(dest: "milestones", icon: "star.fill", title: "Milestones", subtitle: "\(mgr.milestones.filter(\.achieved).count) achieved", color: Theme.peach)
            navCard(dest: "growth", icon: "chart.line.uptrend.xyaxis", title: "Growth", subtitle: "\(mgr.growth.count) entries", color: Theme.teal)
            navCard(dest: "settings", icon: "gearshape.fill", title: "Settings", subtitle: "", color: Theme.textSecondary)
        }
    }

    private var settingsCard: some View { EmptyView() }

    private func navCard(dest: String, icon: String, title: String, subtitle: String, color: Color) -> some View {
        NavigationLink(value: dest) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon).font(.title2).foregroundColor(color)
                    .frame(width: 40, height: 40).background(color.opacity(0.15)).cornerRadius(10)
                Text(title).font(.subheadline.bold()).foregroundColor(.white)
                if !subtitle.isEmpty { Text(subtitle).font(.caption2).foregroundColor(Theme.textSecondary) }
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding()
            .background(Color.white.opacity(0.06)).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var weights: String {
        guard let last = mgr.weights.last else { return "—" }
        return String(format: "%.1f kg", last.weightKg)
    }
}
