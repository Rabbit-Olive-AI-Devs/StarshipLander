import SwiftUI
import SpriteKit

// MARK: - Game Container
struct GameContainerView: View {
    @Binding var showingGame: Bool
    @ObservedObject var highScoreManager: HighScoreManager
    @ObservedObject var campaignState: CampaignState
    @ObservedObject var gameCenterManager: GameCenterManager
    @EnvironmentObject var gameState: GameState
    /// Results appear after a short beat so the touchdown / explosion is visible.
    @State private var showingResults = false

    var body: some View {
        ZStack {
            // Game scene
            GameSceneView(gameState: gameState, campaignState: campaignState)
                .ignoresSafeArea()
                .allowsHitTesting(!gameState.gameOver)

            // HUD and controls overlay
            VStack(spacing: 0) {
                if !gameState.gameOver {
                    TopHUDView(gameState: gameState, showingGame: $showingGame)
                }

                if !gameState.gameOver && !gameState.flightStarted {
                    PreflightHintView(
                        useAccelerometer: gameState.useAccelerometer,
                        briefing: gameState.currentMode == .campaign ? LevelDefinition.level(for: gameState.currentLevelId)?.briefing : nil
                    )
                        .padding(.top, 4)
                        .transition(.opacity)
                }

                Spacer()

                if !gameState.gameOver {
                    BottomControlsView(gameState: gameState)
                }

                BannerAdContainer()
                    .padding(.bottom, 5)
            }

            // Full-screen game-over overlay
            if gameState.gameOver && showingResults {
                GeometryReader { geo in
                    ScrollView(showsIndicators: false) {
                        GameOverView(
                            gameState: gameState,
                            showingGame: $showingGame,
                            highScoreManager: highScoreManager,
                            campaignState: campaignState,
                            gameCenterManager: gameCenterManager,
                            blueStarManager: BlueStarManager.shared
                        )
                        .frame(minHeight: geo.size.height)
                    }
                }
                .transition(.scale(scale: 0.92).combined(with: .opacity))
                .padding(.bottom, 60) // clear the banner ad
            }
        }
        .environmentObject(gameState)
        .onChange(of: gameState.gameOver) { isOver in
            guard isOver else {
                showingResults = false
                return
            }
            let delay = gameState.landed ? 0.7 : 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard gameState.gameOver else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showingResults = true
                }
            }
        }
    }
}

// MARK: - Pre-flight Hint
// Shown until the first input. Chapter 2 missions show their briefing;
// otherwise new pilots get the three landing rules.
struct PreflightHintView: View {
    let useAccelerometer: Bool
    var briefing: String? = nil
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 8) {
            if let briefing = briefing {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MISSION BRIEFING")
                        .font(.custom("Orbitron", size: 10).weight(.bold))
                        .foregroundColor(.cyan)
                    Text(briefing)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .frame(maxWidth: 320, alignment: .leading)
                .background(Color.black.opacity(0.65))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cyan.opacity(0.4), lineWidth: 1))
            } else if PilotProgress.shared.isRookie {
                VStack(alignment: .leading, spacing: 4) {
                    tip("arrow.down.to.line", "Touch down slowly: watch the \u{2193} readout")
                    tip("arrow.up", "Stay upright: tilt under 3\u{00B0} is perfect")
                    tip("scope", "Both legs on the pad: follow the green guide line")
                }
                .padding(10)
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
            }
            Text(useAccelerometer ? "HOLD THRUST · TILT TO STEER" : "HOLD THRUST TO BEGIN DESCENT")
                .font(.custom("Orbitron", size: 12).weight(.bold))
                .foregroundColor(.orange)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)
                .opacity(pulse ? 1 : 0.45)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }
        }
        .allowsHitTesting(false)
    }

    private func tip(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .frame(width: 16)
                .foregroundColor(.green)
            Text(text)
                .foregroundColor(.white)
        }
        .font(.system(size: 11, weight: .medium, design: .monospaced))
    }
}

// MARK: - SpriteKit Bridge
struct GameSceneView: UIViewRepresentable {
    let gameState: GameState
    let campaignState: CampaignState

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.allowsTransparency = true

        let scene = GameScene(gameState: gameState, campaignState: campaignState)
        scene.scaleMode = .resizeFill
        view.presentScene(scene)

        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        uiView.isUserInteractionEnabled = !gameState.gameOver
    }
}
