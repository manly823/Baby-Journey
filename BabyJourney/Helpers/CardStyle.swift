import SwiftUI

struct CardStyle: ViewModifier {
    var opacity: Double = 0.08
    func body(content: Content) -> some View {
        content.padding().background(Color.white.opacity(opacity)).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}
extension View { func cardStyle(opacity: Double = 0.08) -> some View { modifier(CardStyle(opacity: opacity)) } }

struct Theme {
    static let bg = Color(red: 0.08, green: 0.07, blue: 0.12)
    static let surface = Color(red: 0.12, green: 0.11, blue: 0.16)
    static let rose = Color(red: 0.88, green: 0.45, blue: 0.52)
    static let peach = Color(red: 0.95, green: 0.7, blue: 0.42)
    static let lavender = Color(red: 0.6, green: 0.5, blue: 0.8)
    static let teal = Color(red: 0.3, green: 0.7, blue: 0.65)
    static let sky = Color(red: 0.45, green: 0.65, blue: 0.9)
    static let cream = Color(red: 0.95, green: 0.92, blue: 0.88)
    static let textPrimary = Color(red: 0.95, green: 0.93, blue: 0.92)
    static let textSecondary = Color(red: 0.55, green: 0.5, blue: 0.58)
    static var bgGradient: LinearGradient {
        LinearGradient(colors: [bg, Color(red: 0.06, green: 0.05, blue: 0.09)], startPoint: .top, endPoint: .bottom)
    }
}

func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) { UIImpactFeedbackGenerator(style: style).impactOccurred() }

// MARK: - Wave Shape (Custom Shape — unique: flowing progress wave)

struct WaveShape: Shape {
    var progress: Double
    var animatableData: Double { get { progress } set { progress = newValue } }
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let fillW = w * min(max(progress, 0), 1)
        var p = Path()
        p.move(to: .zero)
        p.addLine(to: CGPoint(x: fillW, y: 0))
        let waveH = h * 0.3
        p.addCurve(to: CGPoint(x: fillW, y: h),
                    control1: CGPoint(x: fillW + 20, y: h * 0.3 - waveH),
                    control2: CGPoint(x: fillW - 20, y: h * 0.7 + waveH))
        p.addLine(to: CGPoint(x: 0, y: h))
        p.closeSubpath()
        return p
    }
}

struct WaveProgressBar: View {
    let progress: Double
    let label: String
    let detail: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack { Text(label).font(.caption.bold()).foregroundColor(.white); Spacer(); Text(detail).font(.caption2).foregroundColor(Theme.textSecondary) }
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.06)).frame(height: 14)
                WaveShape(progress: progress).fill(color.opacity(0.6)).frame(height: 14).cornerRadius(8)
            }
        }
    }
}
