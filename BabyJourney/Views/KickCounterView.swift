import SwiftUI

struct KickCounterView: View {
    @EnvironmentObject var mgr: BabyManager
    @State private var counting = false
    @State private var count = 0
    @State private var elapsed = 0
    @State private var timer: Timer?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                counterCircle
                controlButtons
                goalCard
                historySection
            }.padding().padding(.bottom, 30)
        }
        .background(Theme.bgGradient.ignoresSafeArea())
        .navigationTitle("Kick Counter")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { timer?.invalidate() }
    }

    private var counterCircle: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30).fill(Theme.rose.opacity(0.08)).frame(width: 220, height: 220)
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Theme.rose.opacity(0.2), lineWidth: 2))
            VStack(spacing: 8) {
                Text("\(count)").font(.system(size: 64, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text("kicks").font(.subheadline).foregroundColor(Theme.textSecondary)
                Text(timeString).font(.caption.monospacedDigit()).foregroundColor(Theme.rose)
            }
        }
        .onTapGesture { if counting { count += 1; haptic(.light) } }
    }

    private var controlButtons: some View {
        HStack(spacing: 16) {
            Button { startCounting() } label: {
                Label(counting ? "Counting..." : "Start", systemImage: counting ? "waveform.path.ecg" : "play.fill")
                    .font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding()
                    .background(counting ? Theme.teal : Theme.rose).cornerRadius(14)
            }.disabled(counting)

            if counting {
                Button { stopCounting() } label: {
                    Label("Save", systemImage: "checkmark.circle.fill")
                        .font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding()
                        .background(Theme.peach).cornerRadius(14)
                }
            }
        }
    }

    private var goalCard: some View {
        VStack(spacing: 8) {
            Text("Daily Goal: 10 kicks in 2 hours").font(.subheadline.bold()).foregroundColor(.white)
            Text("Most babies kick at least 10 times within 2 hours during active periods. Count during the same time each day.")
                .font(.caption).foregroundColor(Theme.textSecondary).multilineTextAlignment(.center)
        }.cardStyle()
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Sessions").font(.headline).foregroundColor(.white)
            if mgr.kicks.isEmpty {
                Text("No sessions yet").font(.caption).foregroundColor(Theme.textSecondary)
            } else {
                ForEach(mgr.kicks.prefix(10)) { k in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(k.count) kicks").font(.subheadline.bold()).foregroundColor(.white)
                            Text(k.date, style: .date).font(.caption2).foregroundColor(Theme.textSecondary)
                        }
                        Spacer()
                        Text(formatDuration(k.durationSec)).font(.caption.monospacedDigit()).foregroundColor(Theme.rose)
                    }.padding(.vertical, 4)
                    Divider().background(Color.white.opacity(0.06))
                }
            }
        }.cardStyle()
    }

    private var timeString: String { formatDuration(elapsed) }

    private func formatDuration(_ s: Int) -> String { String(format: "%02d:%02d", s / 60, s % 60) }

    private func startCounting() {
        counting = true; count = 0; elapsed = 0; haptic()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in elapsed += 1 }
    }

    private func stopCounting() {
        timer?.invalidate(); counting = false; haptic()
        if count > 0 { mgr.addKick(KickSession(count: count, durationSec: elapsed)) }
    }
}
