import SwiftUI
import GameKit

struct LeaderboardView: View {
    @Binding var showingLeaderboard: Bool
    @ObservedObject var highScoreManager: HighScoreManager
    @ObservedObject var campaignState: CampaignState
    @ObservedObject var gameCenterManager: GameCenterManager

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingLeaderboard = false
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Spacer()

                Text("LEADERBOARD")
                    .font(.custom("Orbitron", size: 20).weight(.bold))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 16) {
                    // Galaxy Rank header
                    if gameCenterManager.isAuthenticated {
                        VStack(spacing: 6) {
                            Text("Galaxy Rank reflects your total campaign mastery.")
                                .font(.custom("Orbitron", size: 10).weight(.regular))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)

                            if let rank = gameCenterManager.galaxyRank {
                                HStack(spacing: 4) {
                                    Image(systemName: "globe.americas.fill")
                                        .foregroundColor(.cyan)
                                    Text("Galaxy Rank: #\(rank)")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(.cyan)
                                    if gameCenterManager.galaxyScore > 0 {
                                        Text("(\(gameCenterManager.galaxyScore) pts)")
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(.cyan.opacity(0.7))
                                    }
                                }
                            }

                            // View Global Rankings button
                            Button(action: openGameCenterDashboard) {
                                HStack(spacing: 6) {
                                    Image(systemName: "gamecontroller.fill")
                                    Text("View Global Rankings")
                                }
                                .font(.custom("Orbitron", size: 11).weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.purple.opacity(0.4))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.bottom, 4)
                    }

                    // MARK: - Classic Mode Section
                    classicSection

                    // MARK: - Campaign Section
                    campaignHeader

                    ForEach(LevelDefinition.levels, id: \.id) { level in
                        campaignLevelCard(level: level)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }

    // MARK: - Game Center Dashboard

    private func openGameCenterDashboard() {
        guard GKLocalPlayer.local.isAuthenticated,
              let topVC = GameCenterManager.topViewController() else { return }

        let gcVC = GKGameCenterViewController(
            leaderboardID: GameCenterManager.LeaderboardID.galaxyRank,
            playerScope: .global,
            timeScope: .allTime
        )
        gcVC.gameCenterDelegate = GKDismissHandler.shared
        topVC.present(gcVC, animated: true)
    }

    // MARK: - Classic Mode Card

    private var classicSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("CLASSIC MODE")
                    .font(.custom("Orbitron", size: 11).weight(.bold))
                    .foregroundColor(.orange)
                Spacer()
            }

            ForEach(0..<3, id: \.self) { index in
                if index < highScoreManager.scores.count {
                    let entry = highScoreManager.scores[index]
                    scoreRow(rank: index + 1, name: entry.name, score: entry.score, stars: entry.stars)
                } else {
                    scoreRow(rank: index + 1, name: "---", score: nil)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Campaign Header

    private var campaignHeader: some View {
        HStack {
            Text("CAMPAIGN MISSIONS")
                .font(.custom("Orbitron", size: 11).weight(.bold))
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(campaignState.totalStars)/\(LevelDefinition.maxStars)")
                    .font(.caption.bold())
                    .foregroundColor(.yellow)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Campaign Level Card

    private func campaignLevelCard(level: LevelDefinition) -> some View {
        let isUnlocked = campaignState.isUnlocked(level.id)
        let stars = campaignState.bestStars(for: level.id)
        let levelScores = campaignState.scoresByLevel[level.id] ?? []

        return VStack(spacing: 8) {
            // Level header
            HStack {
                Text("\(level.id)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(isUnlocked ? .white : .gray)

                Text(level.name.uppercased())
                    .font(.custom("Orbitron", size: 11).weight(.bold))
                    .foregroundColor(isUnlocked ? .orange : .gray)

                Spacer()

                if isUnlocked {
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < stars ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(i < stars ? .yellow : .gray.opacity(0.3))
                        }
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                }
            }

            // Score rows
            if isUnlocked {
                ForEach(0..<3, id: \.self) { index in
                    if index < levelScores.count {
                        scoreRow(rank: index + 1, name: levelScores[index].name, score: levelScores[index].score, stars: levelScores[index].stars)
                    } else {
                        scoreRow(rank: index + 1, name: "---", score: nil)
                    }
                }
            }
        }
        .padding(12)
        .background(isUnlocked ? Color.white.opacity(0.08) : Color.white.opacity(0.03))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isUnlocked ? Color.orange.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Score Row

    private func scoreRow(rank: Int, name: String, score: Int?, stars: Int = 0) -> some View {
        let rankColor: Color = rank == 1 ? .yellow : rank == 2 ? .gray : .brown

        return HStack {
            Text("\(rank).")
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(rankColor)
                .frame(width: 25, alignment: .leading)

            Text(name)
                .font(.custom("Orbitron", size: 13).weight(.bold))
                .foregroundColor(score != nil ? (rank == 1 ? .yellow : .white) : .gray.opacity(0.4))
                .lineLimit(1)

            if stars > 0 {
                HStack(spacing: 1) {
                    ForEach(0..<stars, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.yellow)
                    }
                }
            }

            Spacer()

            if let score = score {
                Text("\(score)")
                    .font(.system(.subheadline, design: .monospaced).bold())
                    .foregroundColor(rank == 1 ? .yellow : .orange)
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - GKGameCenterControllerDelegate handler
class GKDismissHandler: NSObject, GKGameCenterControllerDelegate {
    static let shared = GKDismissHandler()
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
