import SwiftUI

@main
struct BabyJourneyApp: App {
    @StateObject private var manager = BabyManager()
    var body: some Scene {
        WindowGroup {
            Group {
                if manager.settings.hasCompletedOnboarding {
                    MainView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(manager)
            .preferredColorScheme(.dark)
        }
    }
}
