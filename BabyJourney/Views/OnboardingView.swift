import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var mgr: BabyManager
    @State private var page = 0
    @State private var mode: AppMode = .pregnancy
    @State private var mamaName = ""
    @State private var dueDate = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @State private var babyName = ""
    @State private var birthDate = Date()
    @State private var gender = "👶"
    @State private var birthWeight = "3500"
    @State private var birthLength = "50"

    var body: some View {
        ZStack {
            Theme.bgGradient.ignoresSafeArea()
            TabView(selection: $page) {
                welcomePage.tag(0)
                featurePage1.tag(1)
                featurePage2.tag(2)
                modePage.tag(3)
                setupPage.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.spring(response: 0.4), value: page)
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("🤰").font(.system(size: 80))
            Text("Baby Journey").font(.largeTitle.bold()).foregroundColor(.white)
            Text("From first heartbeat to first steps").font(.title3).foregroundColor(Theme.textSecondary).multilineTextAlignment(.center)
            Spacer()
            nextBtn(to: 1)
        }.padding()
    }

    private var featurePage1: some View {
        VStack(spacing: 24) {
            Spacer()
            featureRow(icon: "calendar.badge.clock", color: Theme.rose, title: "Week by Week", desc: "Track baby's growth with fun fruit comparisons")
            featureRow(icon: "stethoscope", color: Theme.lavender, title: "Medical Checkups", desc: "Never miss an important appointment")
            featureRow(icon: "bag.fill", color: Theme.peach, title: "Hospital Bag", desc: "Pack everything you need, stress-free")
            featureRow(icon: "hand.tap.fill", color: Theme.teal, title: "Kick Counter", desc: "Monitor baby's activity daily")
            Spacer()
            nextBtn(to: 2)
        }.padding()
    }

    private var featurePage2: some View {
        VStack(spacing: 24) {
            Spacer()
            featureRow(icon: "star.fill", color: Theme.peach, title: "Milestones", desc: "Track rolling, crawling, first words")
            featureRow(icon: "chart.line.uptrend.xyaxis", color: Theme.teal, title: "Growth Charts", desc: "Weight, length & head with WHO curves")
            featureRow(icon: "brain.head.profile.fill", color: Theme.lavender, title: "Development Guide", desc: "What to expect each month")
            featureRow(icon: "square.and.arrow.up", color: Theme.sky, title: "Export & Share", desc: "Save your data as JSON anytime")
            Spacer()
            nextBtn(to: 3)
        }.padding()
    }

    private var modePage: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Where are you?").font(.title2.bold()).foregroundColor(.white)
            HStack(spacing: 16) {
                modeCard(m: .pregnancy, icon: "🤰", title: "Expecting", desc: "I'm pregnant")
                modeCard(m: .baby, icon: "👶", title: "Baby born", desc: "Already a mom")
            }
            Spacer()
            nextBtn(to: 4)
        }.padding()
    }

    private var setupPage: some View {
        ScrollView {
            VStack(spacing: 16) {
                if mode == .pregnancy { pregnancySetup } else { babySetup }
                Button(action: finish) {
                    Text(mode == .pregnancy ? "Start Tracking 🤰" : "Start Tracking 👶")
                        .font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding()
                        .background(canFinish ? Theme.rose : Color.gray.opacity(0.3)).cornerRadius(14)
                }.disabled(!canFinish).padding(.top, 8)
            }.padding().padding(.top, 40)
        }
    }

    // MARK: - Setup Forms
    private var pregnancySetup: some View {
        VStack(spacing: 14) {
            Text("About You").font(.title2.bold()).foregroundColor(.white)
            field("Your name", text: $mamaName, icon: "person.fill")
            VStack(alignment: .leading, spacing: 4) {
                Label("Due date", systemImage: "calendar").font(.caption).foregroundColor(Theme.textSecondary)
                DatePicker("", selection: $dueDate, displayedComponents: .date).datePickerStyle(.compact).labelsHidden()
            }.padding().background(Color.white.opacity(0.06)).cornerRadius(12)
        }
    }

    private var babySetup: some View {
        VStack(spacing: 14) {
            Text("About Your Baby").font(.title2.bold()).foregroundColor(.white)
            field("Baby's name", text: $babyName, icon: "face.smiling.fill")
            HStack(spacing: 12) {
                genderBtn("👦", label: "Boy"); genderBtn("👧", label: "Girl"); genderBtn("👶", label: "Other")
            }
            VStack(alignment: .leading, spacing: 4) {
                Label("Birth date", systemImage: "calendar").font(.caption).foregroundColor(Theme.textSecondary)
                DatePicker("", selection: $birthDate, displayedComponents: .date).datePickerStyle(.compact).labelsHidden()
            }.padding().background(Color.white.opacity(0.06)).cornerRadius(12)
            field("Birth weight (g)", text: $birthWeight, icon: "scalemass.fill", keyboard: .numberPad)
            field("Birth length (cm)", text: $birthLength, icon: "ruler.fill", keyboard: .decimalPad)
        }
    }

    // MARK: - Helpers
    private func featureRow(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.title2).foregroundColor(color).frame(width: 44, height: 44).background(color.opacity(0.15)).cornerRadius(10)
            VStack(alignment: .leading) { Text(title).font(.headline).foregroundColor(.white); Text(desc).font(.caption).foregroundColor(Theme.textSecondary) }
            Spacer()
        }.padding(.horizontal)
    }

    private func modeCard(m: AppMode, icon: String, title: String, desc: String) -> some View {
        Button { withAnimation { mode = m }; haptic(.light) } label: {
            VStack(spacing: 10) { Text(icon).font(.system(size: 44)); Text(title).font(.headline).foregroundColor(.white); Text(desc).font(.caption).foregroundColor(Theme.textSecondary) }
            .frame(maxWidth: .infinity).padding(20)
            .background(mode == m ? Theme.rose.opacity(0.2) : Color.white.opacity(0.06))
            .cornerRadius(16).overlay(RoundedRectangle(cornerRadius: 16).stroke(mode == m ? Theme.rose : Color.clear, lineWidth: 2))
        }
    }

    private func field(_ ph: String, text: Binding<String>, icon: String, keyboard: UIKeyboardType = .default) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(Theme.textSecondary)
            TextField(ph, text: text).foregroundColor(.white).keyboardType(keyboard)
        }.padding().background(Color.white.opacity(0.06)).cornerRadius(12)
    }

    private func genderBtn(_ emoji: String, label: String) -> some View {
        Button { gender = emoji; haptic(.light) } label: {
            VStack { Text(emoji).font(.title); Text(label).font(.caption).foregroundColor(.white) }
            .frame(maxWidth: .infinity).padding(10)
            .background(gender == emoji ? Theme.lavender.opacity(0.2) : Color.white.opacity(0.06))
            .cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(gender == emoji ? Theme.lavender : .clear, lineWidth: 1))
        }
    }

    private func nextBtn(to: Int) -> some View {
        Button { withAnimation { page = to }; haptic(.light) } label: {
            Text("Continue").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding()
                .background(Theme.rose).cornerRadius(14)
        }.padding(.horizontal)
    }

    private var canFinish: Bool { mode == .pregnancy ? !mamaName.isEmpty : !babyName.isEmpty }

    private func finish() {
        haptic()
        if mode == .pregnancy {
            mgr.setupPregnancy(name: mamaName, dueDate: dueDate)
        } else {
            mgr.setupBaby(name: babyName, birthDate: birthDate, gender: gender, weightG: Int(birthWeight) ?? 3500, lengthCm: Double(birthLength) ?? 50)
        }
        withAnimation { mgr.settings.hasCompletedOnboarding = true }
    }
}
