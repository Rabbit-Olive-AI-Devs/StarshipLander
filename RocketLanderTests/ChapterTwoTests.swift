import XCTest
@testable import RocketLander

final class ChapterTwoTests: XCTestCase {

    private var defaults: UserDefaults!
    private let suiteName = "ChapterTwoTests"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    // MARK: Drag model

    func testBellyFirstHasMoreDragThanUpright() {
        let upright = GameScene.dragArea(tilt: 0)
        let sideways = GameScene.dragArea(tilt: .pi / 2)
        XCTAssertEqual(sideways / upright, 1.0 / 0.18, accuracy: 0.01)
        XCTAssertEqual(GameScene.dragArea(tilt: -.pi / 2), sideways, accuracy: 0.0001)
    }

    func testBellyFlopTerminalVelocityIsSlow() {
        // Terminal velocity where drag equals gravity: v = sqrt(g / c)
        guard let level = LevelDefinition.level(for: 12) else { return XCTFail("missing level 12") }
        let gravityPtsPerSec2 = abs(level.gravity) * 150
        let c = GameScene.dragCoefficient * level.atmosphere * GameScene.dragArea(tilt: .pi / 2)
        let terminal = sqrt(gravityPtsPerSec2 / c)
        XCTAssertLessThan(terminal, 200, "belly-first fall must be slow enough to set up the flip")
        let cUpright = GameScene.dragCoefficient * level.atmosphere * GameScene.dragArea(tilt: 0)
        XCTAssertGreaterThan(sqrt(gravityPtsPerSec2 / cUpright), terminal * 2)
    }

    // MARK: Ghost replay

    private func run(score: Int, count: Int = 10) -> GhostRun {
        let samples = (0..<count).map { GhostSample(x: Float($0), y: Float(100 - $0), r: 0) }
        return GhostRun(score: score, sceneWidth: 400, samples: samples)
    }

    func testGhostKeys() {
        XCTAssertEqual(GhostStore.key(mode: .classic, levelId: 3), "ghost.classic")
        XCTAssertEqual(GhostStore.key(mode: .campaign, levelId: 12), "ghost.campaign.12")
        XCTAssertNil(GhostStore.key(mode: .dailyChallenge, levelId: 1))
    }

    func testGhostOnlyReplacedByBetterScore() {
        XCTAssertTrue(GhostStore.saveIfBest(run(score: 5000), key: "g", defaults: defaults))
        XCTAssertFalse(GhostStore.saveIfBest(run(score: 4000), key: "g", defaults: defaults))
        XCTAssertEqual(GhostStore.load(key: "g", defaults: defaults)?.score, 5000)
        XCTAssertTrue(GhostStore.saveIfBest(run(score: 6000), key: "g", defaults: defaults))
        XCTAssertEqual(GhostStore.load(key: "g", defaults: defaults)?.score, 6000)
    }

    func testGhostPoseInterpolatesAndScales() {
        let ghost = run(score: 1)
        let pose = ghost.pose(at: GhostRun.sampleInterval * 2.5, width: 800)
        XCTAssertEqual(pose?.x ?? 0, 5.0, accuracy: 0.001)   // 2.5 scaled ×2
        XCTAssertEqual(pose?.y ?? 0, 97.5, accuracy: 0.001)
        XCTAssertNil(ghost.pose(at: 100, width: 400), "ghost ends after its recording")
    }
}
