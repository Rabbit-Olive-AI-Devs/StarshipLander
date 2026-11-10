import XCTest
@testable import RocketLander

final class LevelDefinitionTests: XCTestCase {

    private var chapterOne: [LevelDefinition] { LevelDefinition.levels.filter { $0.chapter == 1 } }

    func testLevelCount() {
        XCTAssertEqual(LevelDefinition.levels.count, 15)
        XCTAssertEqual(chapterOne.count, 10)
        XCTAssertEqual(LevelDefinition.maxStars, 45)
    }

    func testLevelIdsSequential() {
        let ids = LevelDefinition.levels.map { $0.id }
        XCTAssertEqual(ids, Array(1...15))
        XCTAssertEqual(LevelDefinition.chapters, [1, 2])
    }

    func testChapterOneUnchangedByChapterTwoFields() {
        for level in chapterOne {
            XCTAssertEqual(level.atmosphere, 0, "\(level.name) must keep its original vacuum flight model")
            XCTAssertNil(level.initialTilt)
            XCTAssertEqual(level.initialFuel, 100)
        }
    }

    func testChapterTwoSetup() {
        XCTAssertEqual(LevelDefinition.level(for: 12)?.initialTilt ?? 0, .pi / 2, accuracy: 0.001)
        XCTAssertLessThan(LevelDefinition.level(for: 13)?.initialFuel ?? 100, 100)
        XCTAssertGreaterThan(LevelDefinition.level(for: 12)?.atmosphere ?? 0, 0)
        for level in LevelDefinition.levels where level.chapter == 2 {
            XCTAssertNotNil(level.briefing, "\(level.name) needs a mission briefing")
        }
    }

    func testGravityIncreasing() {
        let gravities = chapterOne.map { abs($0.gravity) }
        for i in 1..<gravities.count {
            XCTAssertGreaterThan(gravities[i], gravities[i - 1],
                "Level \(i + 1) gravity should exceed level \(i)")
        }
    }

    func testThrustIncreasing() {
        let thrusts = chapterOne.map { $0.thrustPower }
        for i in 1..<thrusts.count {
            XCTAssertGreaterThan(thrusts[i], thrusts[i - 1],
                "Level \(i + 1) thrust should exceed level \(i)")
        }
    }

    func testThrustGravityRatio() {
        for level in LevelDefinition.levels {
            let ratio = level.thrustPower / abs(level.gravity)
            XCTAssertGreaterThan(ratio, 3.0,
                "\(level.name) thrust/gravity ratio \(ratio) should be > 3.0 (landable)")
        }
    }

    func testLevelLookup() {
        let earth = LevelDefinition.level(for: 5)
        XCTAssertNotNil(earth)
        XCTAssertEqual(earth?.name, "Earth")
    }

    func testInvalidLookup() {
        XCTAssertNil(LevelDefinition.level(for: 0))
        XCTAssertNil(LevelDefinition.level(for: 16))
    }

    func testEachLevelHasMechanic() {
        let expectedMechanics: [Int: SpecialMechanic] = [
            1: .none,
            2: .lightWind,
            3: .denseAtmosphere,
            4: .cryogeysers,
            5: .movingPlatform,
            6: .heavyTurbulence,
            7: .heatShimmer,
            8: .deepCraters,
            9: .volcanicEruptions,
            10: .extremeWind,
            11: .towerCatch,
            12: .bellyFlop,
            13: .lowFuel,
            14: .meteorShower,
            15: .nightLanding,
        ]

        for (levelId, expectedMechanic) in expectedMechanics {
            let level = LevelDefinition.level(for: levelId)
            XCTAssertEqual(level?.specialMechanic, expectedMechanic,
                "Level \(levelId) should have mechanic \(expectedMechanic)")
        }
    }
}
