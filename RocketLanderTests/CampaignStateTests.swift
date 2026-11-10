import XCTest
@testable import RocketLander

final class CampaignStateTests: XCTestCase {

    private let storageKey = "campaignState"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        super.tearDown()
    }

    func testInitialState() {
        let state = CampaignState()
        XCTAssertTrue(state.unlockedLevels.contains(1))
        XCTAssertEqual(state.unlockedLevels.count, 1)
        XCTAssertEqual(state.totalStars, 0)
    }

    func testDefaultScoresSeeded() {
        let state = CampaignState()
        for levelId in 1...15 {
            let scores = state.scoresByLevel[levelId] ?? []
            XCTAssertEqual(scores.count, 1, "Level \(levelId) should have 1 default score")
            XCTAssertEqual(scores.first?.score, 1000, "Default score should be 1000")
        }
    }

    func testCompleteLevelUnlocksNext() {
        let state = CampaignState()
        state.completedLevel(1, stars: 1, score: 2000, name: "Test")
        XCTAssertTrue(state.unlockedLevels.contains(2), "Level 2 should be unlocked")
    }

    func testRecordCompletionWithoutNamedScoreUnlocksAndPersistsProgress() {
        let state = CampaignState()
        state.recordCompletion(1, stars: 2, score: 4000)

        XCTAssertTrue(state.unlockedLevels.contains(2), "Level 2 should unlock even when score sheet is skipped")
        XCTAssertEqual(state.bestStars(for: 1), 2)
        XCTAssertEqual(state.bestScore(for: 1), 4000)
        XCTAssertEqual(state.scoresByLevel[1]?.first?.name, "Armstrong", "Named leaderboard should not be polluted by anonymous progress")
    }

    func testNamedScoreIsSeparateFromProgressRecording() {
        let state = CampaignState()
        state.recordCompletion(1, stars: 3, score: 7000)
        state.addNamedScore(levelId: 1, stars: 3, score: 7000, name: "Pilot")

        XCTAssertEqual(state.bestStars(for: 1), 3)
        XCTAssertEqual(state.bestScore(for: 1), 7000)
        XCTAssertEqual(state.scoresByLevel[1]?.first?.name, "Pilot")
    }

    func testCompleteLastLevel() {
        let state = CampaignState()
        // Unlock all levels first
        for i in 1...9 {
            state.completedLevel(i, stars: 1, score: 2000, name: "Test")
        }
        // Completing level 10 should not crash
        state.completedLevel(10, stars: 3, score: 5000, name: "Test")
        XCTAssertEqual(state.bestStars(for: 10), 3)
    }

    func testStarsKeepBest() {
        let state = CampaignState()
        state.completedLevel(1, stars: 2, score: 3000, name: "First")
        XCTAssertEqual(state.bestStars(for: 1), 2)

        // Lower stars should not overwrite
        state.completedLevel(1, stars: 1, score: 2000, name: "Second")
        XCTAssertEqual(state.bestStars(for: 1), 2, "Stars should keep best (2, not 1)")
    }

    func testStarsUpgrade() {
        let state = CampaignState()
        state.completedLevel(1, stars: 1, score: 2000, name: "First")
        state.completedLevel(1, stars: 3, score: 8000, name: "Better")
        XCTAssertEqual(state.bestStars(for: 1), 3, "Stars should upgrade to 3")
    }

    func testTotalStars() {
        let state = CampaignState()
        state.completedLevel(1, stars: 2, score: 3000, name: "A")
        state.completedLevel(2, stars: 3, score: 5000, name: "B")
        state.completedLevel(3, stars: 1, score: 1500, name: "C")
        XCTAssertEqual(state.totalStars, 6, "Total stars should be 2+3+1=6")
    }

    func testScoreTop3() {
        let state = CampaignState()
        // Default has 1 score (astronaut). Add 3 more → should keep top 3.
        state.completedLevel(1, stars: 1, score: 5000, name: "A")
        state.completedLevel(1, stars: 2, score: 3000, name: "B")
        state.completedLevel(1, stars: 1, score: 2000, name: "C")

        let scores = state.scoresByLevel[1] ?? []
        XCTAssertEqual(scores.count, 3, "Should keep only top 3")
        XCTAssertEqual(scores.first?.score, 5000, "Highest should be first")
    }

    func testIsHighScore() {
        let state = CampaignState()
        // Initially has 1 default score (1000), so < 3 entries → any score > 0 qualifies
        XCTAssertTrue(state.isHighScore(for: 1, score: 500))
        XCTAssertFalse(state.isHighScore(for: 1, score: 0))

        // Fill up to 3 entries
        state.completedLevel(1, stars: 1, score: 5000, name: "A")
        state.completedLevel(1, stars: 1, score: 3000, name: "B")
        // Now 3 entries: 5000, 3000, 1000
        XCTAssertTrue(state.isHighScore(for: 1, score: 2000))
        XCTAssertFalse(state.isHighScore(for: 1, score: 500))
    }

    func testPersistence() {
        let state1 = CampaignState()
        state1.completedLevel(1, stars: 3, score: 9000, name: "Persisted")

        let state2 = CampaignState()
        XCTAssertTrue(state2.unlockedLevels.contains(2))
        XCTAssertEqual(state2.bestStars(for: 1), 3)
        let topScore = state2.scoresByLevel[1]?.first
        XCTAssertEqual(topScore?.score, 9000)
        XCTAssertEqual(topScore?.name, "Persisted")
    }
}
