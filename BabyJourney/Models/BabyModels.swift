import SwiftUI

enum AppMode: String, Codable { case pregnancy, baby }

enum Trimester: String, Codable, CaseIterable {
    case first = "1st Trimester"
    case second = "2nd Trimester"
    case third = "3rd Trimester"
    static func from(week: Int) -> Trimester { week <= 12 ? .first : week <= 27 ? .second : .third }
}

enum MilestoneCategory: String, Codable, CaseIterable, Identifiable {
    case motor = "Motor"
    case speech = "Speech"
    case social = "Social"
    case cognitive = "Cognitive"
    var id: String { rawValue }
    var icon: String {
        switch self { case .motor: return "figure.walk"; case .speech: return "bubble.left.fill"; case .social: return "heart.fill"; case .cognitive: return "brain.head.profile.fill" }
    }
    var color: Color {
        switch self { case .motor: return Color(red: 0.3, green: 0.7, blue: 0.65); case .speech: return Color(red: 0.6, green: 0.5, blue: 0.8); case .social: return Color(red: 0.9, green: 0.5, blue: 0.55); case .cognitive: return Color(red: 0.95, green: 0.7, blue: 0.35) }
    }
}

struct PregnancyWeekInfo {
    let week: Int; let fruit: String; let fruitIcon: String; let sizeCm: Double; let weightG: Int; let development: String; let tip: String
}

struct CheckupItem: Identifiable, Codable, Hashable {
    var id = UUID(); var week: Int; var title: String; var completed: Bool = false; var notes: String = ""
}

struct WeightEntry: Identifiable, Codable, Hashable {
    var id = UUID(); var date: Date = Date(); var weightKg: Double
}

struct KickSession: Identifiable, Codable, Hashable {
    var id = UUID(); var date: Date = Date(); var count: Int; var durationSec: Int
}

struct HospitalBagItem: Identifiable, Codable, Hashable {
    var id = UUID(); var name: String; var category: String; var packed: Bool = false
}

struct BabyProfile: Codable {
    var name: String = ""; var birthDate: Date = Date(); var gender: String = ""; var birthWeightG: Int = 3500; var birthLengthCm: Double = 50
}

struct Milestone: Identifiable, Codable, Hashable {
    var id = UUID(); var category: MilestoneCategory; var title: String; var typicalMonth: Int; var achieved: Bool = false; var achievedDate: Date?; var notes: String = ""
}

struct GrowthEntry: Identifiable, Codable, Hashable {
    var id = UUID(); var date: Date = Date(); var weightKg: Double = 0; var lengthCm: Double = 0; var headCm: Double = 0
}

struct BabySettings: Codable {
    var hasCompletedOnboarding: Bool = false
    var mode: AppMode = .pregnancy
    var dueDate: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    var mamaName: String = ""
    var baby: BabyProfile = BabyProfile()
    var weightUnit: String = "kg"
}
