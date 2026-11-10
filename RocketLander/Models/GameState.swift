import Foundation
import Combine

// MARK: - Game Mode
enum GameMode: String, Codable {
    case classic
    case campaign
    case dailyChallenge

    /// Whether this mode uses LevelDefinition (gravity, terrain, hazards, etc.)
    var usesLevelDefinition: Bool {
        self == .campaign || self == .dailyChallenge
    }
}

// MARK: - Game State
class GameState: ObservableObject {
    @Published var score: Int = 0
    @Published var fuel: Double = 100
    @Published var gameOver: Bool = false
    @Published var landed: Bool = false
    @Published var shouldReset: Bool = false

    // Velocity tracking
    @Published var verticalVelocity: CGFloat = 0
    @Published var horizontalVelocity: CGFloat = 0
    @Published var rotation: CGFloat = 0
    @Published var tiltAngle: CGFloat = 0  // Signed rotation (positive = left, negative = right)

    // Final stats (frozen at touchdown/crash)
    @Published var finalTiltAngle: CGFloat = 0
    @Published var finalVerticalSpeed: CGFloat = 0
    @Published var finalHorizontalSpeed: CGFloat = 0
    @Published var finalFuel: Double = 0
    @Published var finalDistanceFromCenter: CGFloat? = nil

    // Crash diagnostics
    @Published var crashDiagnosticPrimary: String = ""
    @Published var crashDiagnosticSecondary: String = ""

    // Control states
    @Published var isThrusting: Bool = false
    @Published var isRotatingLeft: Bool = false
    @Published var isRotatingRight: Bool = false

    // Platform & landing info (Phase 1)
    @Published var landedPlatform: LandingPlatform?
    @Published var landingMessage: String = ""
    @Published var starsEarned: Int = 0
    @Published var landingSpeedBand: SpeedBand = .safe

    // Mode & campaign (Phase 2)
    @Published var currentMode: GameMode = .classic
    @Published var currentLevelId: Int = 1

    // Daily Challenge
    @Published var dailyChallengeTargetPlatform: LandingPlatform? = nil
    @Published var dailyChallengeSuccess: Bool = false
    @Published var dailyChallengeWasNewBest: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var dailyRewardResult: DailyRewardResult? = nil
    @Published var campaignMilestoneRewards: [CampaignMilestoneReward] = []

    // Flight lifecycle + Pilot Rank reward for the flight that just ended
    @Published var flightStarted: Bool = false
    @Published var flightReward: FlightReward? = nil

    // Settings
    @Published var useAccelerometer: Bool {
        didSet {
            UserDefaults.standard.set(useAccelerometer, forKey: "useAccelerometer")
        }
    }
    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        }
    }
    @Published var hapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticsEnabled, forKey: "hapticsEnabled")
            HapticManager.shared.isEnabled = hapticsEnabled
        }
    }

    init() {
        self.useAccelerometer = UserDefaults.standard.bool(forKey: "useAccelerometer")
        // Default to true if key hasn't been set yet
        if UserDefaults.standard.object(forKey: "soundEnabled") == nil {
            self.soundEnabled = true
        } else {
            self.soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        }
        if UserDefaults.standard.object(forKey: "hapticsEnabled") == nil {
            self.hapticsEnabled = true
        } else {
            self.hapticsEnabled = UserDefaults.standard.bool(forKey: "hapticsEnabled")
        }
        HapticManager.shared.isEnabled = hapticsEnabled
    }

    func reset() {
        score = 0
        fuel = 100
        gameOver = false
        landed = false
        shouldReset = true
        verticalVelocity = 0
        horizontalVelocity = 0
        rotation = 0
        tiltAngle = 0
        isThrusting = false
        isRotatingLeft = false
        isRotatingRight = false
        landedPlatform = nil
        landingMessage = ""
        starsEarned = 0
        landingSpeedBand = .safe
        finalTiltAngle = 0
        finalVerticalSpeed = 0
        finalHorizontalSpeed = 0
        finalFuel = 0
        finalDistanceFromCenter = nil
        crashDiagnosticPrimary = ""
        crashDiagnosticSecondary = ""
        dailyChallengeSuccess = false
        dailyChallengeWasNewBest = false
        elapsedTime = 0
        dailyRewardResult = nil
        campaignMilestoneRewards = []
        flightStarted = false
        flightReward = nil
        // Note: dailyChallengeTargetPlatform is NOT reset here — it persists
        // across retries, same as currentMode and currentLevelId.
    }
}
