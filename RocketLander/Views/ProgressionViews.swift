import SwiftUI
import SpriteKit

// MARK: - Ship Preview (SpriteKit-rendered, matches in-game art)

struct ShipPreviewView: UIViewRepresentable {
    let skin: ShipSkin
    var showsFlame = true

    final class Coordinator {
        var presentedSkin: ShipSkin?
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.allowsTransparency = true
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.preferredFramesPerSecond = showsFlame ? 60 : 30
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {
        guard context.coordinator.presentedSkin != skin else { return }
        context.coordinator.presentedSkin = skin
        view.presentScene(ShipPreviewScene(skin: skin, size: CGSize(width: 120, height: 180), showsFlame: showsFlame))
    }
}

// MARK: - XP Bar

struct XPBar: View {
    let progress: Double
    var height: CGFloat = 8
    var colors: [Color] = [.cyan, .blue]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                Capsule()
                    .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(height, geo.size.width * CGFloat(progress)))
                    .shadow(color: colors.first?.opacity(0.6) ?? .clear, radius: 4)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Pilot Rank Card (Menu)

struct PilotRankCard: View {
    @ObservedObject var progress: PilotProgress

    var body: some View {
        let rank = progress.rank
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.cyan.opacity(0.35), Color.blue.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 38, height: 38)
                    Image(systemName: rank.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("PILOT RANK \(rank.index + 1)")
                        .font(.custom("Orbitron", size: 9).weight(.bold))
                        .foregroundColor(.cyan.opacity(0.8))
                    Text(rank.title.uppercased())
                        .font(.custom("Orbitron", size: 15).weight(.black))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
                if progress.landingStreak >= 2 {
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.fill")
                        Text("x\(progress.landingStreak)")
                    }
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.15))
                    .cornerRadius(6)
                }
            }

            XPBar(progress: rank.progress(xp: progress.xp))

            HStack {
                if let next = rank.next {
                    Text("\(progress.xp) / \(next.xpRequired) XP")
                    Spacer()
                    Text("Next: \(next.title)")
                        .lineLimit(1)
                } else {
                    Text("\(progress.xp) XP · Max rank")
                    Spacer()
                }
            }
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundColor(.gray)
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.cyan.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Flight Reward (Game Over)

struct FlightRewardView: View {
    let reward: FlightReward
    @State private var animatedProgress: Double = 0
    @State private var showLines = false

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("+\(reward.xpEarned) XP")
                    .font(.custom("Orbitron", size: 15).weight(.black))
                    .foregroundColor(.cyan)
                Spacer()
                if reward.landingStreak >= 2 {
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.fill")
                        Text(reward.isNewBestStreak ? "BEST STREAK x\(reward.landingStreak)" : "STREAK x\(reward.landingStreak)")
                    }
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow)
                }
            }

            XPBar(progress: animatedProgress, height: 6)

            if showLines {
                HStack(spacing: 6) {
                    ForEach(Array(reward.lines.enumerated()), id: \.offset) { _, line in
                        Text("\(line.label) +\(line.xp)")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .minimumScaleFactor(0.6)
                .transition(.opacity)
            }

            if reward.rankedUp {
                HStack(spacing: 6) {
                    Image(systemName: reward.rankAfter.icon)
                    Text("PROMOTED: \(reward.rankAfter.title.uppercased())")
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    if reward.blueStarsAwarded > 0 {
                        Image(systemName: "star.fill").foregroundColor(.cyan)
                        Text("+\(reward.blueStarsAwarded)")
                    }
                }
                .font(.custom("Orbitron", size: 11).weight(.bold))
                .foregroundColor(.yellow)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.yellow.opacity(0.12))
                .cornerRadius(8)
            }
        }
        .padding(10)
        .background(Color.cyan.opacity(0.06))
        .cornerRadius(10)
        .onAppear {
            animatedProgress = reward.rankedUp ? 0 : reward.rankBefore.progress(xp: reward.previousXP)
            withAnimation(.easeOut(duration: 0.9).delay(0.25)) {
                animatedProgress = reward.rankAfter.progress(xp: reward.newXP)
            }
            withAnimation(.easeIn(duration: 0.3).delay(0.6)) {
                showLines = true
            }
        }
    }
}
