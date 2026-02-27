import SwiftUI

@MainActor
final class BabyManager: ObservableObject {
    @Published var settings: BabySettings { didSet { Storage.shared.save(settings, forKey: "settings") } }
    @Published var checkups: [CheckupItem] { didSet { Storage.shared.save(checkups, forKey: "checkups") } }
    @Published var weights: [WeightEntry] { didSet { Storage.shared.save(weights, forKey: "weights") } }
    @Published var kicks: [KickSession] { didSet { Storage.shared.save(kicks, forKey: "kicks") } }
    @Published var hospitalBag: [HospitalBagItem] { didSet { Storage.shared.save(hospitalBag, forKey: "bag") } }
    @Published var milestones: [Milestone] { didSet { Storage.shared.save(milestones, forKey: "milestones") } }
    @Published var growth: [GrowthEntry] { didSet { Storage.shared.save(growth, forKey: "growth") } }

    init() {
        self.settings = Storage.shared.load(forKey: "settings", default: BabySettings())
        self.checkups = Storage.shared.load(forKey: "checkups", default: [])
        self.weights = Storage.shared.load(forKey: "weights", default: [])
        self.kicks = Storage.shared.load(forKey: "kicks", default: [])
        self.hospitalBag = Storage.shared.load(forKey: "bag", default: [])
        self.milestones = Storage.shared.load(forKey: "milestones", default: [])
        self.growth = Storage.shared.load(forKey: "growth", default: [])
    }

    // MARK: - Setup
    func setupPregnancy(name: String, dueDate: Date) {
        settings.mamaName = name; settings.dueDate = dueDate; settings.mode = .pregnancy
        checkups = Self.defaultCheckups(); hospitalBag = Self.defaultBag()
        weights = [WeightEntry(weightKg: 62)]
        kicks = []
    }

    func setupBaby(name: String, birthDate: Date, gender: String, weightG: Int, lengthCm: Double) {
        settings.mode = .baby; settings.baby = BabyProfile(name: name, birthDate: birthDate, gender: gender, birthWeightG: weightG, birthLengthCm: lengthCm)
        milestones = Self.defaultMilestones(); growth = [GrowthEntry(weightKg: Double(weightG) / 1000, lengthCm: lengthCm, headCm: 35)]
    }

    func switchToBaby() { settings.mode = .baby; if milestones.isEmpty { milestones = Self.defaultMilestones() } }

    // MARK: - Pregnancy Computed
    var currentWeek: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: settings.dueDate).day ?? 0
        return max(1, min(40, 40 - (days / 7)))
    }
    var daysLeft: Int { max(0, Calendar.current.dateComponents([.day], from: Date(), to: settings.dueDate).day ?? 0) }
    var trimester: Trimester { Trimester.from(week: currentWeek) }
    var pregnancyProgress: Double { Double(currentWeek) / 40.0 }

    var weekInfo: PregnancyWeekInfo { Self.weekData(for: currentWeek) }

    // MARK: - Baby Computed
    var babyAgeMonths: Int {
        let m = Calendar.current.dateComponents([.month], from: settings.baby.birthDate, to: Date()).month ?? 0
        return max(0, min(24, m))
    }
    var babyAgeDays: Int { max(0, Calendar.current.dateComponents([.day], from: settings.baby.birthDate, to: Date()).day ?? 0) }

    // MARK: - CRUD
    func toggleCheckup(_ c: CheckupItem) { if let i = checkups.firstIndex(where: { $0.id == c.id }) { checkups[i].completed.toggle() } }
    func addWeight(_ w: WeightEntry) { weights.append(w) }
    func addKick(_ k: KickSession) { kicks.insert(k, at: 0) }
    func toggleBagItem(_ b: HospitalBagItem) { if let i = hospitalBag.firstIndex(where: { $0.id == b.id }) { hospitalBag[i].packed.toggle() } }
    func toggleMilestone(_ m: Milestone) {
        if let i = milestones.firstIndex(where: { $0.id == m.id }) {
            milestones[i].achieved.toggle()
            milestones[i].achievedDate = milestones[i].achieved ? Date() : nil
        }
    }
    func addGrowth(_ g: GrowthEntry) { growth.append(g) }

    var bagProgress: Double { hospitalBag.isEmpty ? 0 : Double(hospitalBag.filter(\.packed).count) / Double(hospitalBag.count) }
    var milestoneProgress: Double { milestones.isEmpty ? 0 : Double(milestones.filter(\.achieved).count) / Double(milestones.count) }

    // MARK: - Week Data (fruit comparisons)
    static func weekData(for w: Int) -> PregnancyWeekInfo {
        let data: [(String, String, Double, Int, String, String)] = [
            ("Poppy seed", "🌰", 0.1, 0, "Fertilized egg implants", "Start taking folic acid"),
            ("Sesame seed", "🌱", 0.2, 0, "Neural tube forming", "Avoid alcohol and raw fish"),
            ("Lentil", "🫘", 0.3, 0, "Heart begins to beat", "Schedule first prenatal visit"),
            ("Blueberry", "🫐", 0.5, 1, "Facial features forming", "Rest when you feel tired"),
            ("Raspberry", "🍇", 1.2, 1, "Fingers and toes developing", "Stay hydrated"),
            ("Cherry", "🍒", 1.6, 2, "All organs are forming", "Eat small frequent meals"),
            ("Grape", "🍇", 2.5, 4, "Baby can squint and frown", "First trimester screening"),
            ("Strawberry", "🍓", 3, 7, "Vocal cords developing", "Morning sickness may peak"),
            ("Fig", "🫐", 4, 14, "Reflexes developing", "Nausea usually improves soon"),
            ("Lime", "🍋", 5, 23, "Fingerprints forming", "Tell friends the good news!"),
            ("Plum", "🫐", 6, 28, "Baby can suck thumb", "Start maternity shopping"),
            ("Peach", "🍑", 7, 42, "Baby can hear your voice", "Play music for baby"),
            ("Lemon", "🍋", 8, 70, "Bones hardening", "Feel the first flutter?"),
            ("Apple", "🍎", 10, 100, "Baby is very active", "Anatomy scan around now"),
            ("Avocado", "🥑", 12, 140, "Eyebrows and lashes growing", "You may feel kicks"),
            ("Pear", "🍐", 14, 190, "Baby responds to light", "Start a birth plan"),
            ("Turnip", "🫐", 15, 240, "Hearing is well developed", "Sign up for birth class"),
            ("Banana", "🍌", 18, 300, "Lungs developing surfactant", "Baby has sleep cycles"),
            ("Papaya", "🫐", 20, 360, "Eyes can open", "Viability milestone!"),
            ("Mango", "🥭", 22, 430, "Brain growing rapidly", "Start counting kicks"),
            ("Corn", "🌽", 25, 500, "Baby can dream (REM sleep)", "Glucose screening test"),
            ("Eggplant", "🍆", 27, 600, "Lungs practice breathing", "Third trimester begins"),
            ("Cabbage", "🥬", 30, 760, "Baby gaining fat layer", "Pack hospital bag soon"),
            ("Coconut", "🥥", 33, 900, "Immune system developing", "Nesting instinct kicks in"),
            ("Butternut squash", "🫐", 35, 1100, "Bones fully developed", "Baby drops into pelvis"),
            ("Pineapple", "🍍", 38, 1300, "Organs almost mature", "Braxton Hicks may increase"),
            ("Cantaloupe", "🍈", 40, 1500, "Ready for birth!", "Hospital bag packed?"),
            ("Cauliflower", "🫐", 42, 1700, "Fat stores increasing", "Rest and nest"),
            ("Lettuce head", "🥬", 43, 1900, "Baby is head-down usually", "Pre-register at hospital"),
            ("Cabbage", "🥬", 44, 2100, "Lungs nearly mature", "Install the car seat"),
            ("Jicama", "🫐", 45, 2300, "Baby gaining 200g/week", "Final checkup schedule"),
            ("Honeydew", "🍈", 46, 2500, "Full term approaching!", "Prepare postpartum supplies"),
            ("Pumpkin", "🎃", 47, 2700, "Brain and lungs mature", "Know the signs of labor"),
            ("Winter melon", "🍈", 48, 2900, "Almost there!", "Rest as much as possible"),
            ("Jackfruit", "🫐", 49, 3000, "Full term!", "Baby could arrive any day"),
            ("Small watermelon", "🍉", 50, 3200, "Due date week!", "Contractions? Call your doctor!"),
            ("Watermelon", "🍉", 51, 3400, "Past due — hang tight!", "Doctor may discuss induction"),
            ("Watermelon", "🍉", 52, 3500, "Overdue but fine!", "Stay in touch with your doctor"),
            ("Watermelon", "🍉", 52, 3500, "Any day now!", "You've got this, mama!"),
            ("Watermelon", "🍉", 52, 3500, "Ready to meet your baby!", "The wait is almost over!"),
        ]
        let i = max(0, min(w - 1, data.count - 1))
        let d = data[i]
        return PregnancyWeekInfo(week: w, fruit: d.0, fruitIcon: d.1, sizeCm: d.2, weightG: d.3, development: d.4, tip: d.5)
    }

    // MARK: - Default Data
    static func defaultCheckups() -> [CheckupItem] {
        [(6,"First prenatal visit"),(10,"Blood tests & urine"),(12,"First ultrasound (NT scan)"),(16,"Quad screen blood test"),
         (20,"Anatomy scan ultrasound"),(24,"Glucose tolerance test"),(28,"Rh antibody test"),(30,"Bi-weekly checkup starts"),
         (32,"Growth ultrasound"),(34,"Group B strep test"),(36,"Weekly checkup starts"),(38,"Cervical check"),(40,"Due date checkup")]
            .map { CheckupItem(week: $0.0, title: $0.1) }
    }

    static func defaultBag() -> [HospitalBagItem] {
        let m: [(String,String)] = [("ID & insurance cards","Documents"),("Birth plan copies","Documents"),("Phone charger","Electronics"),
            ("Comfortable robe","Clothing"),("Nursing bra ×2","Clothing"),("Slippers","Clothing"),("Going-home outfit","Clothing"),
            ("Toiletries bag","Hygiene"),("Lip balm","Hygiene"),("Hair ties","Hygiene"),
            ("Snacks & drinks","Comfort"),("Pillow from home","Comfort"),("Music playlist","Comfort"),
            ("Baby onesies ×3","Baby"),("Baby hat","Baby"),("Swaddle blanket","Baby"),("Car seat (installed)","Baby"),("Diapers newborn","Baby")]
        return m.map { HospitalBagItem(name: $0.0, category: $0.1) }
    }

    static func defaultMilestones() -> [Milestone] {
        let m: [(MilestoneCategory, String, Int)] = [
            (.motor,"Holds head steady",2),(.motor,"Rolls over",4),(.motor,"Sits without support",6),(.motor,"Crawls",8),(.motor,"Pulls to stand",9),(.motor,"First steps",12),(.motor,"Walks steadily",15),(.motor,"Runs",20),
            (.speech,"Coos and gurgles",2),(.speech,"Laughs out loud",4),(.speech,"Babbles (ba-ba, da-da)",6),(.speech,"Says mama/dada",10),(.speech,"First real word",12),(.speech,"10+ words",18),(.speech,"Two-word phrases",24),
            (.social,"Social smile",2),(.social,"Recognizes parents",3),(.social,"Stranger anxiety",8),(.social,"Waves bye-bye",10),(.social,"Plays peek-a-boo",9),(.social,"Shares toys",18),(.social,"Parallel play",24),
            (.cognitive,"Follows objects with eyes",1),(.cognitive,"Reaches for toys",4),(.cognitive,"Object permanence",8),(.cognitive,"Points at things",12),(.cognitive,"Stacks 2 blocks",15),(.cognitive,"Sorts shapes",20),(.cognitive,"Pretend play",24)]
        return m.map { Milestone(category: $0.0, title: $0.1, typicalMonth: $0.2) }
    }

    func exportJSON() -> String {
        struct E: Codable { let settings: BabySettings; let checkups: [CheckupItem]; let weights: [WeightEntry]; let milestones: [Milestone]; let growth: [GrowthEntry] }
        guard let d = try? JSONEncoder().encode(E(settings: settings, checkups: checkups, weights: weights, milestones: milestones, growth: growth)),
              let s = String(data: d, encoding: .utf8) else { return "{}" }
        return s
    }
}
