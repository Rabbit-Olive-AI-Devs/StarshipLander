import SpriteKit
import Combine

// MARK: - Ship Skin
// Cosmetic paint schemes for the Starship. Purely visual: physics and collision
// dimensions are identical for every skin. Unlocked with Blue Stars or Pilot Rank.

enum ShipSkin: String, CaseIterable, Identifiable {
    case stainless
    case nightOps
    case redPlanet
    case lunarGold
    case europaIce
    case synthwave
    case legend

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .stainless: return "Stainless"
        case .nightOps: return "Night Ops"
        case .redPlanet: return "Red Planet"
        case .lunarGold: return "Lunar Gold"
        case .europaIce: return "Europa Ice"
        case .synthwave: return "Synthwave"
        case .legend: return "Legend"
        }
    }

    var tagline: String {
        switch self {
        case .stainless: return "Factory-fresh 30X steel."
        case .nightOps: return "Full heat-shield wrap."
        case .redPlanet: return "Dusted by a Martian storm."
        case .lunarGold: return "Gold-foil Apollo homage."
        case .europaIce: return "Frosted for the outer moons."
        case .synthwave: return "Neon trim, green-plasma engines."
        case .legend: return "Reserved for Starship Legends."
        }
    }

    /// Blue Star price. Zero means free.
    var price: Int {
        switch self {
        case .stainless: return 0
        case .nightOps: return 10
        case .redPlanet: return 20
        case .lunarGold: return 35
        case .europaIce: return 50
        case .synthwave: return 80
        case .legend: return 150
        }
    }

    /// Pilot Rank index that unlocks this skin for free (nil = Blue Stars only).
    var unlockRank: Int? {
        switch self {
        case .stainless: return 0
        case .nightOps: return 2
        case .redPlanet: return 4
        case .lunarGold: return 6
        case .europaIce: return nil
        case .synthwave: return nil
        case .legend: return PilotRank.all.count - 1
        }
    }

    // MARK: Palette

    struct Palette {
        let body: SKColor
        let highlight: SKColor
        let shadow: SKColor
        let stroke: SKColor
        let flap: SKColor
        let flapHighlight: SKColor
        let heatShield: SKColor
        let accent: SKColor?
        let flameCore: SKColor
        let flameOuter: SKColor
    }

    var palette: Palette {
        switch self {
        case .stainless:
            return Palette(
                body: SKColor(red: 0.82, green: 0.83, blue: 0.85, alpha: 1),
                highlight: SKColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1),
                shadow: SKColor(red: 0.45, green: 0.47, blue: 0.52, alpha: 0.55),
                stroke: SKColor(red: 0.6, green: 0.6, blue: 0.63, alpha: 1),
                flap: SKColor(red: 0.18, green: 0.18, blue: 0.2, alpha: 1),
                flapHighlight: SKColor(red: 0.34, green: 0.34, blue: 0.38, alpha: 0.9),
                heatShield: SKColor(red: 0.07, green: 0.075, blue: 0.085, alpha: 0.9),
                accent: nil,
                flameCore: SKColor(red: 1.0, green: 0.95, blue: 0.75, alpha: 1),
                flameOuter: SKColor(red: 1.0, green: 0.45, blue: 0.1, alpha: 1)
            )
        case .nightOps:
            return Palette(
                body: SKColor(red: 0.16, green: 0.17, blue: 0.19, alpha: 1),
                highlight: SKColor(red: 0.3, green: 0.31, blue: 0.34, alpha: 1),
                shadow: SKColor(red: 0.02, green: 0.02, blue: 0.03, alpha: 0.6),
                stroke: SKColor(red: 0.36, green: 0.37, blue: 0.4, alpha: 1),
                flap: SKColor(red: 0.08, green: 0.08, blue: 0.09, alpha: 1),
                flapHighlight: SKColor(red: 0.28, green: 0.28, blue: 0.3, alpha: 0.9),
                heatShield: SKColor(red: 0.03, green: 0.03, blue: 0.035, alpha: 0.95),
                accent: SKColor(red: 1.0, green: 0.55, blue: 0.1, alpha: 0.9),
                flameCore: SKColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 1),
                flameOuter: SKColor(red: 1.0, green: 0.35, blue: 0.05, alpha: 1)
            )
        case .redPlanet:
            return Palette(
                body: SKColor(red: 0.72, green: 0.38, blue: 0.26, alpha: 1),
                highlight: SKColor(red: 0.86, green: 0.56, blue: 0.4, alpha: 1),
                shadow: SKColor(red: 0.35, green: 0.14, blue: 0.08, alpha: 0.6),
                stroke: SKColor(red: 0.5, green: 0.24, blue: 0.15, alpha: 1),
                flap: SKColor(red: 0.25, green: 0.12, blue: 0.08, alpha: 1),
                flapHighlight: SKColor(red: 0.45, green: 0.25, blue: 0.16, alpha: 0.9),
                heatShield: SKColor(red: 0.12, green: 0.06, blue: 0.04, alpha: 0.9),
                accent: SKColor(red: 0.95, green: 0.85, blue: 0.7, alpha: 0.8),
                flameCore: SKColor(red: 1.0, green: 0.92, blue: 0.7, alpha: 1),
                flameOuter: SKColor(red: 1.0, green: 0.3, blue: 0.08, alpha: 1)
            )
        case .lunarGold:
            return Palette(
                body: SKColor(red: 0.88, green: 0.7, blue: 0.3, alpha: 1),
                highlight: SKColor(red: 1.0, green: 0.9, blue: 0.55, alpha: 1),
                shadow: SKColor(red: 0.55, green: 0.38, blue: 0.08, alpha: 0.6),
                stroke: SKColor(red: 0.68, green: 0.5, blue: 0.16, alpha: 1),
                flap: SKColor(red: 0.2, green: 0.18, blue: 0.16, alpha: 1),
                flapHighlight: SKColor(red: 0.5, green: 0.42, blue: 0.25, alpha: 0.9),
                heatShield: SKColor(red: 0.1, green: 0.09, blue: 0.08, alpha: 0.9),
                accent: SKColor.white.withAlphaComponent(0.85),
                flameCore: SKColor(red: 1.0, green: 1.0, blue: 0.85, alpha: 1),
                flameOuter: SKColor(red: 1.0, green: 0.6, blue: 0.15, alpha: 1)
            )
        case .europaIce:
            return Palette(
                body: SKColor(red: 0.88, green: 0.94, blue: 0.98, alpha: 1),
                highlight: SKColor.white,
                shadow: SKColor(red: 0.45, green: 0.6, blue: 0.75, alpha: 0.55),
                stroke: SKColor(red: 0.55, green: 0.72, blue: 0.85, alpha: 1),
                flap: SKColor(red: 0.2, green: 0.35, blue: 0.5, alpha: 1),
                flapHighlight: SKColor(red: 0.45, green: 0.65, blue: 0.85, alpha: 0.9),
                heatShield: SKColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.9),
                accent: SKColor(red: 0.4, green: 0.9, blue: 1.0, alpha: 0.9),
                flameCore: SKColor(red: 0.85, green: 0.97, blue: 1.0, alpha: 1),
                flameOuter: SKColor(red: 0.25, green: 0.6, blue: 1.0, alpha: 1)
            )
        case .synthwave:
            return Palette(
                body: SKColor(red: 0.2, green: 0.12, blue: 0.3, alpha: 1),
                highlight: SKColor(red: 0.4, green: 0.25, blue: 0.55, alpha: 1),
                shadow: SKColor(red: 0.06, green: 0.02, blue: 0.1, alpha: 0.6),
                stroke: SKColor(red: 1.0, green: 0.3, blue: 0.8, alpha: 1),
                flap: SKColor(red: 0.1, green: 0.05, blue: 0.16, alpha: 1),
                flapHighlight: SKColor(red: 0.2, green: 0.95, blue: 1.0, alpha: 0.95),
                heatShield: SKColor(red: 0.05, green: 0.02, blue: 0.08, alpha: 0.95),
                accent: SKColor(red: 0.2, green: 0.95, blue: 1.0, alpha: 0.95),
                flameCore: SKColor(red: 0.85, green: 1.0, blue: 0.9, alpha: 1),
                flameOuter: SKColor(red: 0.2, green: 1.0, blue: 0.45, alpha: 1)
            )
        case .legend:
            return Palette(
                body: SKColor(red: 0.1, green: 0.1, blue: 0.11, alpha: 1),
                highlight: SKColor(red: 0.26, green: 0.25, blue: 0.22, alpha: 1),
                shadow: SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6),
                stroke: SKColor(red: 0.95, green: 0.75, blue: 0.3, alpha: 1),
                flap: SKColor(red: 0.75, green: 0.56, blue: 0.18, alpha: 1),
                flapHighlight: SKColor(red: 1.0, green: 0.88, blue: 0.5, alpha: 0.95),
                heatShield: SKColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 0.95),
                accent: SKColor(red: 1.0, green: 0.82, blue: 0.35, alpha: 1),
                flameCore: SKColor(red: 1.0, green: 0.95, blue: 1.0, alpha: 1),
                flameOuter: SKColor(red: 0.65, green: 0.35, blue: 1.0, alpha: 1)
            )
        }
    }
}

// MARK: - Hangar (ownership + selection)

final class HangarManager: ObservableObject {
    static let shared = HangarManager()

    @Published private(set) var ownedSkins: Set<ShipSkin> = [.stainless]
    @Published private(set) var selectedSkin: ShipSkin = .stainless

    private let ownedKey = "hangarOwnedSkins"
    private let selectedKey = "hangarSelectedSkin"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    enum Availability: Equatable {
        case owned
        case unlockedByRank
        case purchasable(price: Int)
        case locked(price: Int?, rankIndex: Int?)
    }

    func availability(of skin: ShipSkin, rankIndex: Int, blueStars: Int) -> Availability {
        if ownedSkins.contains(skin) { return .owned }
        if let required = skin.unlockRank, rankIndex >= required { return .unlockedByRank }
        if skin.price > 0 && blueStars >= skin.price { return .purchasable(price: skin.price) }
        return .locked(price: skin.price > 0 ? skin.price : nil, rankIndex: skin.unlockRank)
    }

    /// Claims rank-unlocked skins or buys with Blue Stars. Returns true when the skin is now owned.
    @discardableResult
    func acquire(_ skin: ShipSkin, rankIndex: Int, blueStarManager: BlueStarManager) -> Bool {
        switch availability(of: skin, rankIndex: rankIndex, blueStars: blueStarManager.blueStars) {
        case .owned:
            return true
        case .unlockedByRank:
            ownedSkins.insert(skin)
        case .purchasable(let price):
            guard blueStarManager.spend(price) else { return false }
            ownedSkins.insert(skin)
        case .locked:
            return false
        }
        save()
        return true
    }

    func select(_ skin: ShipSkin) {
        guard ownedSkins.contains(skin) else { return }
        selectedSkin = skin
        save()
    }

    private func save() {
        defaults.set(ownedSkins.map(\.rawValue), forKey: ownedKey)
        defaults.set(selectedSkin.rawValue, forKey: selectedKey)
    }

    private func load() {
        let owned = (defaults.stringArray(forKey: ownedKey) ?? []).compactMap(ShipSkin.init(rawValue:))
        ownedSkins = Set(owned).union([.stainless])
        if let raw = defaults.string(forKey: selectedKey),
           let skin = ShipSkin(rawValue: raw),
           ownedSkins.contains(skin) {
            selectedSkin = skin
        }
    }
}
