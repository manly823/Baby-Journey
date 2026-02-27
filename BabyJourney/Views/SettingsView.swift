import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var mgr: BabyManager
    @State private var showReset = false
    @State private var mamaName: String = ""
    @State private var babyName: String = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                profileSection

                if mgr.settings.mode == .pregnancy {
                    switchSection
                }

                exportSection
                resetSection
                aboutSection
            }.padding().padding(.bottom, 30)
        }
        .background(Theme.bgGradient.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { mamaName = mgr.settings.mamaName; babyName = mgr.settings.baby.name }
        .alert("Reset App?", isPresented: $showReset) {
            Button("Reset", role: .destructive) {
                mgr.settings = BabySettings()
                mgr.checkups = []; mgr.weights = []; mgr.kicks = []
                mgr.hospitalBag = []; mgr.milestones = []; mgr.growth = []
            }
            Button("Cancel", role: .cancel) { }
        } message: { Text("This will erase all data and show onboarding again.") }
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Profile").font(.headline).foregroundColor(.white)
            HStack {
                Image(systemName: "person.fill").foregroundColor(Theme.rose)
                TextField("Your name", text: $mamaName).foregroundColor(.white)
                    .onChange(of: mamaName) { mgr.settings.mamaName = mamaName }
            }.padding().background(Color.white.opacity(0.06)).cornerRadius(12)

            if mgr.settings.mode == .pregnancy {
                HStack {
                    Image(systemName: "calendar").foregroundColor(Theme.lavender)
                    Text("Due: \(mgr.settings.dueDate, style: .date)").foregroundColor(.white)
                    Spacer()
                    Text("Week \(mgr.currentWeek)").font(.caption.bold()).foregroundColor(Theme.rose)
                }.padding().background(Color.white.opacity(0.06)).cornerRadius(12)
            } else {
                HStack {
                    Image(systemName: "face.smiling.fill").foregroundColor(Theme.peach)
                    TextField("Baby name", text: $babyName).foregroundColor(.white)
                        .onChange(of: babyName) { mgr.settings.baby.name = babyName }
                }.padding().background(Color.white.opacity(0.06)).cornerRadius(12)

                HStack {
                    Image(systemName: "birthday.cake.fill").foregroundColor(Theme.lavender)
                    Text("Born: \(mgr.settings.baby.birthDate, style: .date)").foregroundColor(.white)
                    Spacer()
                    Text("\(mgr.babyAgeMonths) months").font(.caption.bold()).foregroundColor(Theme.teal)
                }.padding().background(Color.white.opacity(0.06)).cornerRadius(12)
            }
        }.cardStyle()
    }

    private var switchSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Baby Born?").font(.headline).foregroundColor(.white)
            Text("Switch to baby tracking mode to start recording milestones and growth.").font(.caption).foregroundColor(Theme.textSecondary)
            Button {
                mgr.switchToBaby(); haptic()
            } label: {
                Label("Switch to Baby Mode", systemImage: "arrow.right.circle.fill")
                    .font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding()
                    .background(Theme.teal).cornerRadius(14)
            }
        }.cardStyle()
    }

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Export").font(.headline).foregroundColor(.white)
            ShareLink(item: mgr.exportJSON()) {
                Label("Export Data (JSON)", systemImage: "square.and.arrow.up")
                    .font(.subheadline).foregroundColor(Theme.sky).frame(maxWidth: .infinity).padding()
                    .background(Theme.sky.opacity(0.1)).cornerRadius(12)
            }
        }.cardStyle()
    }

    private var resetSection: some View {
        Button { showReset = true } label: {
            Label("Reset All Data", systemImage: "trash.fill")
                .font(.subheadline).foregroundColor(.red).frame(maxWidth: .infinity).padding()
                .background(Color.red.opacity(0.08)).cornerRadius(12)
        }.cardStyle()
    }

    private var aboutSection: some View {
        VStack(spacing: 6) {
            Text("Baby Journey").font(.caption.bold()).foregroundColor(Theme.textSecondary)
            Text("Version 1.0").font(.caption2).foregroundColor(Theme.textSecondary)
            Text("Made with ♥ for mamas").font(.caption2).foregroundColor(Theme.rose)
        }.frame(maxWidth: .infinity).padding()
    }
}
