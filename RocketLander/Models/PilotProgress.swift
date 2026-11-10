import Foundation
import Combine

// MARK: - Pilot Rank

struct PilotRank: Equatable {
    let index: Int
    let title: String
    let xpRequired: Int
    let icon: String

    static let all: [PilotRank] = [
        PilotRank(index: 0, title: "Cadet", xpRequired: 0, icon: "graduationcap.fill"),
        PilotRank(index: 1, title: "Test Pilot", xpRequired: 100, icon: "airplane"),
        PilotRank(index: 2, title: "Flight Engineer", xpRequired: 300, icon: "wrench.and.screwdriver.fill"),
        PilotRank(index: 3, title: "Lunar Pilot", xpRequired: 600, icon: "moon.fill"),
        PilotRank(index: 4, title: "Orbital Pilot", xpRequired: 1000, icon: "globe.americas.fill"),
        PilotRank(index: 5, title: "Mars Pilot", xpRequired: 1600, icon: "flame.fill"),
        PilotRank(index: 6, title: "Booster Catcher", xpRequired: 2400, icon: "scope"),
        PilotRank(index: 7, title: "Mission Commander", xpRequired: 3500, icon: "star.circle.fill"),
        PilotRank(index: 8, title: "Fleet Admiral", xpRequired: 5000, icon: "shield.fill"),
        PilotRank(index: 9, title: "Starship Legend", xpRequired: 7500, icon: "crown.fill"),
    ]

    static func rank(forXP xp: Int) -> PilotRank {
        all.last { xp >= $0.xpRequired } ?? all[0]
    }

    var next: PilotRank? {
        index + 1 < PilotRank.all.count ? PilotRank.all[index + 1] : nil
    }

    /// 0...1 progress from this rank toward the next one (1 at max rank).
    func progress(xp: Int) -> Double {
        guard let next = next else { return 1 }
        let span = Double(next.xpRequired - xpRequired)
        return min(1, max(0, Double(xp - xpRequired) / span))
    }
}

// MARK: - Flight Outcome / Reward

struct FlightOutcome {
    let landed: Bool
    let platform: LandingPlatform?
    let speedBand: SpeedBand
    let mode: GameMode
    let challengeSuccess: Bool
}

struct XPLine: Equatable {
    let label: String
    let xp: Int
}

struct FlightReward: Equatable {
    let lines: [XPLine]
    let previousXP: Int
    let newXP: Int
    let rankBefore: PilotRank
    let rankAfter: PilotRank
    let landingStreak: Int
    let isNewBestStreak: Bool
    let blueStarsAwarded: Int

    var xpEarned: Int { newXP - previousXP }
    var rankedUp: Bool { rankAfter.index > rankBefore.index }
}

// MARK: - Pilot Progress

final class PilotProgress: ObservableObject {
    static let shared = PilotProgress()

    static let blueStarsPerPromotion = 5

    @Published private(set) var xp: Int = 0
    @Published private(set) var landingStreak: Int = 0
    @Published private(set) var bestLandingStreak: Int = 0
    @Published private(set) var totalFlights: Int = 0
    @Published private(set) var totalLandings: Int = 0

    private let defaults: UserDefaults
    private let key = "pilotProgress.v1"

    var rank: PilotRank { PilotRank.rank(forXP: xp) }

    /// Flights flown before this one. Used to show onboarding tips to new pilots.
    var isRookie: Bool { totalFlights < 3 }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    // MARK: XP Formula (pure)

    static func xpLines(for outcome: FlightOutcome, streakAfter: Int) -> [XPLine] {
        guard outcome.landed, let platform = outcome.platform else {
            return [XPLine(label: "Flight time", xp: 5)]
        }
        var lines = [XPLine(label: "Touchdown", xp: 25)]
        switch platform {
        case .a: break
        case .b: lines.append(XPLine(label: "Precision pad", xp: 15))
        case .c: lines.append(XPLine(label: "Elite pad", xp: 40))
        }
        if outcome.speedBand == .safe {
            lines.append(XPLine(label: "Clean landing", xp: 15))
        }
        if streakAfter >= 2 {
            lines.append(XPLine(label: "Streak x\(streakAfter)", xp: min(streakAfter, 10) * 4))
        }
        if outcome.mode == .dailyChallenge && outcome.challengeSuccess {
            lines.append(XPLine(label: "Daily challenge", xp: 30))
        }
        return lines
    }

    // MARK: Recording

    @discardableResult
    func recordFlight(_ outcome: FlightOutcome, blueStarManager: BlueStarManager = .shared) -> FlightReward {
        let previousXP = xp
        let rankBefore = rank

        totalFlights += 1
        var newBest = false
        if outcome.landed {
            totalLandings += 1
            landingStreak += 1
            if landingStreak > bestLandingStreak {
                bestLandingStreak = landingStreak
                newBest = landingStreak >= 2
            }
        } else {
            landingStreak = 0
        }

        let lines = Self.xpLines(for: outcome, streakAfter: landingStreak)
        xp += lines.reduce(0) { $0 + $1.xp }

        let rankAfter = rank
        let promotions = rankAfter.index - rankBefore.index
        let blueStars = max(0, promotions) * Self.blueStarsPerPromotion
        if blueStars > 0 {
            blueStarManager.award(blueStars)
        }

        save()

        return FlightReward(
            lines: lines,
            previousXP: previousXP,
            newXP: xp,
            rankBefore: rankBefore,
            rankAfter: rankAfter,
            landingStreak: landingStreak,
            isNewBestStreak: newBest,
            blueStarsAwarded: blueStars
        )
    }

    // MARK: Persistence

    private struct Stored: Codable {
        var xp: Int
        var landingStreak: Int
        var bestLandingStreak: Int
        var totalFlights: Int
        var totalLandings: Int
    }

    private func save() {
        let stored = Stored(
            xp: xp,
            landingStreak: landingStreak,
            bestLandingStreak: bestLandingStreak,
            totalFlights: totalFlights,
            totalLandings: totalLandings
        )
        if let data = try? JSONEncoder().encode(stored) {
            defaults.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = defaults.data(forKey: key),
              let stored = try? JSONDecoder().decode(Stored.self, from: data) else { return }
        xp = stored.xp
        landingStreak = stored.landingStreak
        bestLandingStreak = stored.bestLandingStreak
        totalFlights = stored.totalFlights
        totalLandings = stored.totalLandings
    }
}
