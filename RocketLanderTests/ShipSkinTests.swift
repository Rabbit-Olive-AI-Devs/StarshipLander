import XCTest
@testable import RocketLander

final class ShipSkinTests: XCTestCase {

    private var defaults: UserDefaults!
    private let suiteName = "ShipSkinTests"
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

    func testDefaultSkinIsFreeAndOwned() {
        let hangar = HangarManager(defaults: defaults)
        XCTAssertEqual(ShipSkin.stainless.price, 0)
        XCTAssertTrue(hangar.ownedSkins.contains(.stainless))
        XCTAssertEqual(hangar.selectedSkin, .stainless)
    }

    func testRankUnlockRanksExist() {
        for skin in ShipSkin.allCases {
            if let rank = skin.unlockRank {
                XCTAssertLessThan(rank, PilotRank.all.count, "\(skin) unlock rank out of range")
            } else {
                XCTAssertGreaterThan(skin.price, 0, "\(skin) must be purchasable if not rank-unlocked")
            }
        }
    }

    func testCannotSelectUnownedSkin() {
        let hangar = HangarManager(defaults: defaults)
        hangar.select(.legend)
        XCTAssertEqual(hangar.selectedSkin, .stainless)
    }

    func testRankUnlockIsFree() {
        let hangar = HangarManager(defaults: defaults)
        let stars = BlueStarManager()
        let rankIndex = ShipSkin.nightOps.unlockRank!
        XCTAssertEqual(hangar.availability(of: .nightOps, rankIndex: rankIndex, blueStars: 0), .unlockedByRank)
        XCTAssertTrue(hangar.acquire(.nightOps, rankIndex: rankIndex, blueStarManager: stars))
        XCTAssertEqual(stars.blueStars, 0)
        hangar.select(.nightOps)
        XCTAssertEqual(HangarManager(defaults: defaults).selectedSkin, .nightOps)
    }

    func testPurchaseSpendsBlueStars() {
        let hangar = HangarManager(defaults: defaults)
        let stars = BlueStarManager()
        XCTAssertFalse(hangar.acquire(.synthwave, rankIndex: 0, blueStarManager: stars))
        stars.award(ShipSkin.synthwave.price + 3)
        XCTAssertTrue(hangar.acquire(.synthwave, rankIndex: 0, blueStarManager: stars))
        XCTAssertEqual(stars.blueStars, 3)
        XCTAssertTrue(hangar.ownedSkins.contains(.synthwave))
    }

    func testSpendRejectsOverdraft() {
        let stars = BlueStarManager()
        XCTAssertFalse(stars.spend(1))
        stars.award(2)
        XCTAssertTrue(stars.spend(2))
        XCTAssertEqual(stars.blueStars, 0)
    }
}
