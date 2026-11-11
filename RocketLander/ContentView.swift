import SwiftUI
import GameKit

struct ContentView: View {
    @State private var showingGame = false
    @State private var showingLevelSelect = false
    @State private var showingLeaderboard = false
    @State private var showingDailyBriefing = false
    @State private var showingHangar = false
    @StateObject private var highScoreManager = HighScoreManager()
    @StateObject private var campaignState = CampaignState()
    @StateObject private var gameState = GameState()
    @StateObject private var gameCenterManager = GameCenterManager.shared

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0.05, green: 0.05, blue: 0.15)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if showingGame {
                GameContainerView(
                    showingGame: $showingGame,
                    highScoreManager: highScoreManager,
                    campaignState: campaignState,
                    gameCenterManager: gameCenterManager
                )
                .environmentObject(gameState)
            } else if showingLeaderboard {
                LeaderboardView(
                    showingLeaderboard: $showingLeaderboard,
                    highScoreManager: highScoreManager,
                    campaignState: campaignState,
                    gameCenterManager: gameCenterManager
                )
            } else if showingLevelSelect {
                LevelSelectView(
                    showingGame: $showingGame,
                    campaignState: campaignState,
                    gameState: gameState,
                    showingLevelSelect: $showingLevelSelect,
                    gameCenterManager: gameCenterManager
                )
            } else if showingHangar {
                HangarView(
                    showingHangar: $showingHangar,
                    hangar: HangarManager.shared,
                    blueStars: BlueStarManager.shared,
                    progress: PilotProgress.shared
                )
            } else if showingDailyBriefing {
                DailyChallengeBriefingView(
                    gameState: gameState,
                    gameCenterManager: gameCenterManager,
                    blueStarManager: BlueStarManager.shared,
                    showingGame: $showingGame,
                    showingBriefing: $showingDailyBriefing
                )
            } else {
                MenuView(
                    showingGame: $showingGame,
                    showingLevelSelect: $showingLevelSelect,
                    showingLeaderboard: $showingLeaderboard,
                    showingDailyBriefing: $showingDailyBriefing,
                    showingHangar: $showingHangar,
                    highScoreManager: highScoreManager,
                    campaignState: campaignState,
                    gameState: gameState,
                    gameCenterManager: gameCenterManager
                )
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            gameCenterManager.authenticate()
            #if DEBUG
            applyDebugLaunch()
            #endif
        }
    }
}

#if DEBUG
extension ContentView {
    private func applyDebugLaunch() {
        switch DebugLaunch.value("-screen") {
        case "hangar":
            showingHangar = true
        case "levels":
            showingLevelSelect = true
        case "game":
            switch DebugLaunch.value("-mode") {
            case "campaign":
                gameState.currentMode = .campaign
                gameState.currentLevelId = Int(DebugLaunch.value("-level") ?? "1") ?? 1
            case "daily":
                gameState.currentMode = .dailyChallenge
                gameState.currentLevelId = DailyChallenge.level.id
                gameState.dailyChallengeTargetPlatform = DailyChallenge.targetPlatform
            default:
                gameState.currentMode = .classic
            }
            gameState.reset()
            showingGame = true
        default:
            break
        }
    }
}
#endif

struct MenuView: View {
    @Binding var showingGame: Bool
    @Binding var showingLevelSelect: Bool
    @Binding var showingLeaderboard: Bool
    @Binding var showingDailyBriefing: Bool
    @Binding var showingHangar: Bool
    @ObservedObject var highScoreManager: HighScoreManager
    @ObservedObject var campaignState: CampaignState
    @ObservedObject var gameState: GameState
    @ObservedObject var gameCenterManager: GameCenterManager
    @ObservedObject private var pilotProgress = PilotProgress.shared
    @ObservedObject private var hangar = HangarManager.shared
    @ObservedObject private var blueStars = BlueStarManager.shared
    @State private var showingHowToPlay = false
    @State private var showingSettings = false

    var body: some View {
        ScrollView {
        VStack(spacing: 12) {
            // Top bar — version left, settings/help right
            HStack {
                Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray.opacity(0.3))
                Spacer()
                HStack(spacing: 16) {
                    Button(action: { showingHowToPlay = true }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 8)

            // Title — chrome metallic effect
            VStack(spacing: 2) {
                Text("STARSHIP")
                    .font(.custom("Orbitron", size: 32).weight(.black))
                    .tracking(6)
                    .padding(.leading, 6)
                    .foregroundStyle(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 0.85, green: 0.9, blue: 0.95), location: 0.0),
                                .init(color: Color(red: 0.55, green: 0.6, blue: 0.72), location: 0.35),
                                .init(color: Color(red: 0.95, green: 0.97, blue: 1.0), location: 0.5),
                                .init(color: Color(red: 0.5, green: 0.55, blue: 0.68), location: 0.65),
                                .init(color: Color(red: 0.35, green: 0.4, blue: 0.52), location: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.8), radius: 4, y: 3)

                Text("LANDER")
                    .font(.custom("Orbitron", size: 32).weight(.black))
                    .tracking(10)
                    .padding(.leading, 10)
                    .foregroundStyle(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 1.0, green: 0.85, blue: 0.4), location: 0.0),
                                .init(color: Color(red: 0.9, green: 0.5, blue: 0.05), location: 0.35),
                                .init(color: Color(red: 1.0, green: 0.78, blue: 0.25), location: 0.5),
                                .init(color: Color(red: 0.82, green: 0.38, blue: 0.02), location: 0.65),
                                .init(color: Color(red: 0.55, green: 0.22, blue: 0.0), location: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.8), radius: 4, y: 3)
            }

            // Equipped Starship (tap to open the Hangar)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) { showingHangar = true }
            }) {
                ShipPreviewView(skin: hangar.selectedSkin)
                    .frame(width: 76, height: 110)
            }
            .buttonStyle(.plain)

            // Pilot rank + XP
            PilotRankCard(progress: pilotProgress)
                .frame(maxWidth: 300)

            // Play buttons card
            VStack(spacing: 10) {
                // Classic Mode
                Button(action: {
                    gameState.currentMode = .classic
                    gameState.reset()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingGame = true
                    }
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("CLASSIC")
                    }
                    .font(.custom("Orbitron", size: 20).weight(.bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: .orange.opacity(0.4), radius: 8, y: 4)
                }

                // Daily Challenge
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingDailyBriefing = true
                    }
                }) {
                    VStack(spacing: 2) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("DAILY CHALLENGE")
                        }
                        .font(.custom("Orbitron", size: 14).weight(.bold))
                        Text(DailyChallenge.displayTitle)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .opacity(0.8)
                        if DailyChallenge.isCompleted {
                            HStack(spacing: 3) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 9))
                                Text("Completed")
                                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            }
                            .opacity(0.7)
                        } else if let best = DailyChallenge.localBestScore {
                            Text("Today's Best: \(best) pts")
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .opacity(0.7)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.teal, Color(red: 0.0, green: 0.5, blue: 0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: .teal.opacity(0.3), radius: 8, y: 4)
                }

                // Campaign Mode
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingLevelSelect = true
                    }
                }) {
                    HStack {
                        Image(systemName: "globe")
                        Text("CAMPAIGN")
                    }
                    .font(.custom("Orbitron", size: 18).weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                }

                // Hangar
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingHangar = true
                    }
                }) {
                    HStack {
                        Image(systemName: "paintbrush.fill")
                        Text("HANGAR")
                        Spacer()
                        Text("\(hangar.ownedSkins.count)/\(ShipSkin.allCases.count)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .opacity(0.8)
                    }
                    .font(.custom("Orbitron", size: 15).weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.04))
            .cornerRadius(18)
            .frame(maxWidth: 300)

            // Top Pilots leaderboard card
            if !highScoreManager.scores.isEmpty {
                VStack(spacing: 8) {
                    // Header
                    HStack {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                        Text("TOP PILOTS")
                            .font(.custom("Orbitron", size: 13).weight(.bold))
                            .foregroundColor(.orange)
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                    }

                    // Score rows (up to 3)
                    ForEach(Array(highScoreManager.scores.prefix(3).enumerated()), id: \.element.id) { index, entry in
                        HStack {
                            Text("\(index + 1).")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.yellow)
                                .frame(width: 28, alignment: .trailing)
                            Text(entry.name)
                                .font(.custom("Orbitron", size: 14).weight(.bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            HStack(spacing: 1) {
                                ForEach(0..<entry.stars, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.yellow)
                                }
                            }
                            Spacer()
                            Text("\(entry.score)")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                        }
                    }

                    // Global Leaderboards link
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingLeaderboard = true
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            Text("Global Leaderboards")
                                .font(.custom("Orbitron", size: 10).weight(.medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.06))
                .cornerRadius(14)
                .frame(maxWidth: 300)
            }

            // Stats row — stars, blue stars, rank, streak
            HStack(spacing: 16) {
                if campaignState.totalStars > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                        Text("\(campaignState.totalStars)/30 Stars")
                            .font(.custom("Orbitron", size: 13).weight(.bold))
                            .foregroundColor(.yellow)
                    }
                }

                if blueStars.blueStars > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.cyan)
                        Text("\(blueStars.blueStars)")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan)
                    }
                }

                if blueStars.currentStreak > 0 && blueStars.isStreakActive {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                        Text("\(blueStars.currentStreak)d")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                }
            }

            if gameCenterManager.isAuthenticated, let rank = gameCenterManager.galaxyRank {
                HStack(spacing: 4) {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.cyan)
                    Text("Galaxy Rank: #\(rank)")
                        .font(.custom("Orbitron", size: 13).weight(.bold))
                        .foregroundColor(.cyan)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BannerAdContainer()
        }
        .sheet(isPresented: $showingHowToPlay) {
            HowToPlayView(useAccelerometer: gameState.useAccelerometer)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsSheetView(gameState: gameState)
        }
        .onAppear {
            gameCenterManager.fetchGalaxyRank()
            if gameCenterManager.isAuthenticated {
                GKAccessPoint.shared.location = .topLeading
                GKAccessPoint.shared.isActive = true
            }
        }
        .onDisappear {
            GKAccessPoint.shared.isActive = false
        }
    }
}

// MARK: - Settings Sheet

struct SettingsSheetView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 10)

            Text("SETTINGS")
                .font(.custom("Orbitron", size: 16).weight(.bold))
                .foregroundColor(.orange)

            VStack(spacing: 12) {
                // Controls
                HStack {
                    Image(systemName: gameState.useAccelerometer ? "iphone.gen3.radiowaves.left.and.right" : "hand.tap.fill")
                        .foregroundColor(.white)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(gameState.useAccelerometer ? "Tilt to Rotate" : "Buttons")
                            .font(.custom("Orbitron", size: 13).weight(.medium))
                            .foregroundColor(.white)
                        Text(gameState.useAccelerometer ? "Tilt your phone left/right" : "Use L/R buttons on screen")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Toggle("", isOn: $gameState.useAccelerometer)
                        .labelsHidden()
                        .tint(.orange)
                }

                Divider().background(Color.white.opacity(0.1))

                // Sound
                HStack {
                    Image(systemName: gameState.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .foregroundColor(.white)
                        .frame(width: 24)

                    Text("Sound")
                        .font(.custom("Orbitron", size: 13).weight(.medium))
                        .foregroundColor(.white)

                    Spacer()

                    Toggle("", isOn: $gameState.soundEnabled)
                        .labelsHidden()
                        .tint(.orange)
                }

                Divider().background(Color.white.opacity(0.1))

                // Haptics
                HStack {
                    Image(systemName: gameState.hapticsEnabled ? "iphone.radiowaves.left.and.right" : "iphone")
                        .foregroundColor(.white)
                        .frame(width: 24)

                    Text("Haptics")
                        .font(.custom("Orbitron", size: 13).weight(.medium))
                        .foregroundColor(.white)

                    Spacer()

                    Toggle("", isOn: $gameState.hapticsEnabled)
                        .labelsHidden()
                        .tint(.orange)
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .frame(maxWidth: 280)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.05, green: 0.05, blue: 0.12).ignoresSafeArea())
        .modifier(SettingsDetentModifier())
    }
}

private struct SettingsDetentModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDetents([.height(320)])
        } else {
            content
        }
    }
}

#Preview {
    ContentView()
}
