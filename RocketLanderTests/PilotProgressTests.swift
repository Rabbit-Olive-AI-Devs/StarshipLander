import XCTest
@testable import RocketLander

final class PilotProgressTests: XCTestCase {

    private var defaults: UserDefaults!
    private let suiteName = "PilotProgressTests"
    private let blueStarsKey = "blueStars"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
        UserDefaults.standard.removeObject(forKey: blueStarsKey)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        UserDefaults.standard.removeObject(forKey: blueStarsKey)
        super.tearDown()
    }

    private func landing(_ platform: LandingPlatform, band: SpeedBand = .safe, mode: GameMode = .classic, challenge: Bool = false) -> FlightOutcome {
        FlightOutcome(landed: true, platform: platform, speedBand: band, mode: mode, challengeSuccess: challenge)
    }

    private let crash = FlightOutcome(landed: false, platform: nil, speedBand: .fail, mode: .classic, challengeSuccess: false)

    // MARK: Ranks

    func testRanksAreOrderedAndStartAtZero() {
        XCTAssertEqual(PilotRank.all.first?.xpRequired, 0)
        for (i, rank) in PilotRank.all.enumerated() {
            XCTAssertEqual(rank.index, i)
            if i > 0 { XCTAssertGreaterThan(rank.xpRequired, PilotRank.all[i - 1].xpRequired) }
        }
    }

    func testRankForXP() {
        XCTAssertEqual(PilotRank.rank(forXP: 0).title, "Cadet")
        XCTAssertEqual(PilotRank.rank(forXP: 99).index, 0)
        XCTAssertEqual(PilotRank.rank(forXP: 100).index, 1)
        XCTAssertEqual(PilotRank.rank(forXP: 1_000_000).title, "Starship Legend")
        XCTAssertNil(PilotRank.all.last?.next)
    }

    func testProgressWithinRank() {
        let testPilot = PilotRank.all[1] // 100 → 300
        XCTAssertEqual(testPilot.progress(xp: 100), 0, accuracy: 0.001)
        XCTAssertEqual(testPilot.progress(xp: 200), 0.5, accuracy: 0.001)
        XCTAssertEqual(PilotRank.all.last!.progress(xp: 99_999), 1)
    }

    // MARK: XP Formula

    func testCrashEarnsParticipationXP() {
        let lines = PilotProgress.xpLines(for: crash, streakAfter: 0)
        XCTAssertEqual(lines.reduce(0) { $0 + $1.xp }, 5)
    }

    func testPlatformAndCleanBonuses() {
        let a = PilotProgress.xpLines(for: landing(.a, band: .hard), streakAfter: 1).reduce(0) { $0 + $1.xp }
        let c = PilotProgress.xpLines(for: landing(.c), streakAfter: 1).reduce(0) { $0 + $1.xp }
        XCTAssertEqual(a, 25)
        XCTAssertEqual(c, 25 + 40 + 15)
    }

    func testStreakBonusIsCapped() {
        let five = PilotProgress.xpLines(for: landing(.a, band: .hard), streakAfter: 5)
        let twenty = PilotProgress.xpLines(for: landing(.a, band: .hard), streakAfter: 20)
        XCTAssertTrue(five.contains(XPLine(label: "Streak x5", xp: 20)))
        XCTAssertTrue(twenty.contains(XPLine(label: "Streak x20", xp: 40)))
    }

    func testDailyChallengeBonusOnlyOnSuccess() {
        let won = PilotProgress.xpLines(for: landing(.b, mode: .dailyChallenge, challenge: true), streakAfter: 1)
        let missed = PilotProgress.xpLines(for: landing(.b, mode: .dailyChallenge, challenge: false), streakAfter: 1)
        XCTAssertTrue(won.contains { $0.label == "Daily challenge" })
        XCTAssertFalse(missed.contains { $0.label == "Daily challenge" })
    }

    // MARK: Recording

    func testRecordingTracksStreaksAndPersists() {
        let progress = PilotProgress(defaults: defaults)
        progress.recordFlight(landing(.a), blueStarManager: BlueStarManager())
        let second = progress.recordFlight(landing(.b), blueStarManager: BlueStarManager())
        XCTAssertEqual(second.landingStreak, 2)
        XCTAssertTrue(second.isNewBestStreak)

        progress.recordFlight(crash, blueStarManager: BlueStarManager())
        XCTAssertEqual(progress.landingStreak, 0)
        XCTAssertEqual(progress.bestLandingStreak, 2)
        XCTAssertEqual(progress.totalFlights, 3)
        XCTAssertEqual(progress.totalLandings, 2)

        let reloaded = PilotProgress(defaults: defaults)
        XCTAssertEqual(reloaded.xp, progress.xp)
        XCTAssertEqual(reloaded.bestLandingStreak, 2)
    }

    func testPromotionAwardsBlueStars() {
        let progress = PilotProgress(defaults: defaults)
        let stars = BlueStarManager()
        let before = stars.blueStars
        var reward: FlightReward?
        // Elite clean landings (80+ XP each) cross the 100 XP Test Pilot threshold on the 2nd flight
        for _ in 0..<2 {
            reward = progress.recordFlight(landing(.c), blueStarManager: stars)
        }
        XCTAssertEqual(reward?.rankedUp, true)
        XCTAssertEqual(reward?.rankAfter.title, "Test Pilot")
        XCTAssertEqual(stars.blueStars, before + PilotProgress.blueStarsPerPromotion)
    }
}
