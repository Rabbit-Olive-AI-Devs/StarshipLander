import SwiftUI

struct LevelSelectView: View {
    @Binding var showingGame: Bool
    @ObservedObject var campaignState: CampaignState
    @ObservedObject var gameState: GameState
    @Binding var showingLevelSelect: Bool
    @ObservedObject var gameCenterManager: GameCenterManager

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Button(action: { showingLevelSelect = false }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Spacer()

                Text("CAMPAIGN")
                    .font(.custom("Orbitron", size: 20).weight(.bold))
                    .foregroundColor(.white)

                Spacer()

                // Total stars
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(campaignState.totalStars)/\(LevelDefinition.maxStars)")
                        .font(.custom("Orbitron", size: 14).weight(.bold))
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal)

            // Level Grid
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(LevelDefinition.chapters, id: \.self) { chapter in
                        HStack {
                            Text(LevelDefinition.chapterTitle(chapter))
                                .font(.custom("Orbitron", size: 11).weight(.bold))
                                .foregroundColor(chapter == 1 ? .orange : .cyan)
                            Spacer()
                        }
                        .padding(.top, chapter == 1 ? 0 : 8)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(LevelDefinition.levels.filter { $0.chapter == chapter }, id: \.id) { level in
                                LevelCardView(
                                    level: level,
                                    isUnlocked: campaignState.isUnlocked(level.id),
                                    stars: campaignState.bestStars(for: level.id),
                                    bestScore: campaignState.bestScore(for: level.id)
                                ) {
                                    gameState.currentMode = .campaign
                                    gameState.currentLevelId = level.id
                                    gameState.reset()
                                    showingGame = true
                                }
                            }
                        }
                    }

                    // Galaxy Rank explanation
                    if gameCenterManager.isAuthenticated {
                        VStack(spacing: 6) {
                            HStack(spacing: 4) {
                                Image(systemName: "globe.americas.fill")
                                    .foregroundColor(.cyan)
                                Text("GALAXY RANK")
                                    .font(.custom("Orbitron", size: 11).weight(.bold))
                                    .foregroundColor(.cyan)
                            }
                            Text("Galaxy Rank is based on your best score on each campaign planet.")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            if let rank = gameCenterManager.galaxyRank {
                                Text("Rank #\(rank) • \(gameCenterManager.galaxyScore) pts")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.cyan)
                            }
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                    } else {
                        Text("Sign in to Game Center to see your global rank.")
                            .font(.caption2)
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
}

// MARK: - Level Card
struct LevelCardView: View {
    let level: LevelDefinition
    let isUnlocked: Bool
    let stars: Int
    let bestScore: Int
    let onSelect: () -> Void

    var body: some View {
        Button(action: {
            if isUnlocked { onSelect() }
        }) {
            VStack(spacing: 8) {
                // Level number and name
                HStack {
                    Text("\(level.id)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(isUnlocked ? .white : .gray)

                    Spacer()

                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    }
                }

                Text(level.name.uppercased())
                    .font(.custom("Orbitron", size: 10).weight(.bold))
                    .foregroundColor(isUnlocked ? (level.chapter == 1 ? .orange : .cyan) : .gray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Stars
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(i < stars ? .yellow : .gray.opacity(0.3))
                    }
                    Spacer()
                    if bestScore > 0 {
                        Text("\(bestScore)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }

                // Description
                Text(level.description)
                    .font(.custom("Orbitron", size: 8).weight(.regular))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)

                // Level details (gravity + mechanic)
                if isUnlocked {
                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 8))
                            Text(String(format: "%.1f m/s²", abs(level.gravity)))
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                        }
                        .foregroundColor(.cyan.opacity(0.8))

                        if level.specialMechanic != .none {
                            HStack(spacing: 2) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 8))
                                Text(level.specialMechanic.displayName)
                                    .font(.system(size: 8, weight: .medium))
                            }
                            .foregroundColor(.red.opacity(0.7))
                        }

                        Spacer()
                    }
                }
            }
            .padding(12)
            .background(isUnlocked ? Color.white.opacity(0.08) : Color.white.opacity(0.03))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isUnlocked ? (level.chapter == 1 ? Color.orange : Color.cyan).opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
        .disabled(!isUnlocked)
    }
}
