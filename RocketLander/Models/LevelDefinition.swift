import SpriteKit

// MARK: - Special Mechanics
enum SpecialMechanic: String, Codable {
    case none
    case lightWind           // Mars: light dust wind
    case denseAtmosphere     // Titan: higher damping
    case cryogeysers         // Europa: cryogeyser eruptions
    case movingPlatform      // Earth: moving barge
    case heavyTurbulence     // Venus: variable wind
    case heatShimmer         // Mercury: visual effect
    case deepCraters         // Ganymede: deep terrain
    case volcanicEruptions   // Io: volcanic particles
    case extremeWind         // Jupiter: extreme wind gusts
    case towerCatch          // Starbase: caught by the tower's chopstick arms (pad C)
    case bellyFlop           // Earth high altitude: start horizontal, flip and burn
    case lowFuel             // Phobos: start with a fraction of the propellant
    case meteorShower        // Ceres: meteors fall from the sky
    case nightLanding        // Mars night: land by the ship's own landing light

    var displayName: String {
        switch self {
        case .none: return "None"
        case .lightWind: return "Light Wind"
        case .denseAtmosphere: return "Dense Atmosphere"
        case .cryogeysers: return "Cryogeysers"
        case .movingPlatform: return "Moving Platform"
        case .heavyTurbulence: return "Vertical Updrafts"
        case .heatShimmer: return "Heat Shimmer"
        case .deepCraters: return "Deep Craters"
        case .volcanicEruptions: return "Volcanic Eruptions"
        case .extremeWind: return "Extreme Wind"
        case .towerCatch: return "Tower Catch"
        case .bellyFlop: return "Belly Flop"
        case .lowFuel: return "Low Fuel"
        case .meteorShower: return "Meteor Shower"
        case .nightLanding: return "Night Landing"
        }
    }
}

// MARK: - Celestial Body
struct CelestialBody {
    let name: String
    let radius: CGFloat
    let color: SKColor
    let hasRings: Bool
    let craterCount: Int

    // What you see from each landing location
    static let earth = CelestialBody(name: "Earth", radius: 50, color: SKColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0), hasRings: false, craterCount: 0)          // from Moon
    static let sunSmall = CelestialBody(name: "Sun", radius: 30, color: SKColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 1.0), hasRings: false, craterCount: 0)          // from Mars (distant)
    static let saturn = CelestialBody(name: "Saturn", radius: 50, color: SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 1.0), hasRings: true, craterCount: 0)          // from Titan
    static let jupiter = CelestialBody(name: "Jupiter", radius: 55, color: SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1.0), hasRings: false, craterCount: 0)       // from Europa, Ganymede, Io
    static let moon = CelestialBody(name: "Moon", radius: 40, color: SKColor(red: 0.85, green: 0.85, blue: 0.8, alpha: 1.0), hasRings: false, craterCount: 5)           // from Earth
    static let sunMedium = CelestialBody(name: "Sun", radius: 45, color: SKColor(red: 1.0, green: 0.95, blue: 0.6, alpha: 1.0), hasRings: false, craterCount: 0)        // from Venus
    static let sunLarge = CelestialBody(name: "Sun", radius: 70, color: SKColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0), hasRings: false, craterCount: 0)         // from Mercury (closest)
    static let marsLarge = CelestialBody(name: "Mars", radius: 115, color: SKColor(red: 0.78, green: 0.38, blue: 0.22, alpha: 1.0), hasRings: false, craterCount: 4)       // from Phobos (huge)
    static let sunTiny = CelestialBody(name: "Sun", radius: 16, color: SKColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0), hasRings: false, craterCount: 0)           // from Ceres (far)
    static let phobosSmall = CelestialBody(name: "Phobos", radius: 14, color: SKColor(red: 0.55, green: 0.5, blue: 0.45, alpha: 1.0), hasRings: false, craterCount: 3)  // from Mars at night
    static let europaSmall = CelestialBody(name: "Europa", radius: 25, color: SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1.0), hasRings: false, craterCount: 0)    // from Jupiter
}

// MARK: - Level Definition
struct LevelDefinition {
    let id: Int
    let name: String
    let gravity: CGFloat
    let thrustPower: CGFloat      // Per-level thrust (velocity delta per frame)
    let skyColorTop: SKColor
    let skyColorBottom: SKColor
    let terrainColor: SKColor
    let terrainStrokeColor: SKColor
    let celestialBody: CelestialBody
    let specialMechanic: SpecialMechanic
    let description: String

    // Chapter 2 ("Starship Program") extensions. Defaults keep chapter 1 unchanged.
    var chapter: Int = 1
    /// Air density for the drag model (0 = vacuum). Drag depends on attitude:
    /// a ship falling sideways (belly first) presents ~5x the area of an upright one.
    var atmosphere: CGFloat = 0
    /// Spawn attitude in radians (nil = standard campaign reentry tilt).
    var initialTilt: CGFloat? = nil
    /// Starting propellant (percent).
    var initialFuel: Double = 100
    /// Mission briefing shown on the level card.
    var briefing: String? = nil

    // MARK: - All 10 Levels
    static let levels: [LevelDefinition] = [
        // Level 1: Moon — floaty, gentle (ratio 5.0x)
        LevelDefinition(
            id: 1, name: "Moon",
            gravity: -1.6, thrustPower: 8.0,
            skyColorTop: SKColor(red: 0.0, green: 0.0, blue: 0.05, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0),
            terrainColor: SKColor(red: 0.6, green: 0.6, blue: 0.55, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.7, green: 0.7, blue: 0.65, alpha: 1.0),
            celestialBody: .earth,  // You see Earth from the Moon
            specialMechanic: .none,
            description: "Low gravity training. No hazards."
        ),
        // Level 2: Mars — light wind adds challenge (ratio 4.75x)
        LevelDefinition(
            id: 2, name: "Mars",
            gravity: -2.0, thrustPower: 9.5,
            skyColorTop: SKColor(red: 0.15, green: 0.05, blue: 0.02, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1.0),
            terrainColor: SKColor(red: 0.6, green: 0.25, blue: 0.15, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.7, green: 0.35, blue: 0.2, alpha: 1.0),
            celestialBody: .sunSmall,  // You see the Sun from Mars (distant)
            specialMechanic: .lightWind,
            description: "Light dust winds push your craft."
        ),
        // Level 3: Titan — dense atmo damping helps (ratio 4.5x)
        LevelDefinition(
            id: 3, name: "Titan",
            gravity: -2.2, thrustPower: 10.0,
            skyColorTop: SKColor(red: 0.2, green: 0.15, blue: 0.05, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.5, green: 0.4, blue: 0.2, alpha: 1.0),
            terrainColor: SKColor(red: 0.4, green: 0.35, blue: 0.2, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.5, green: 0.45, blue: 0.3, alpha: 1.0),
            celestialBody: .saturn,  // You see Saturn from Titan (with rings!)
            specialMechanic: .denseAtmosphere,
            description: "Dense atmosphere reduces thrust efficiency."
        ),
        // Level 4: Europa — cryogeysers disrupt descent (ratio 4.4x)
        LevelDefinition(
            id: 4, name: "Europa",
            gravity: -2.5, thrustPower: 11.0,
            skyColorTop: SKColor(red: 0.0, green: 0.0, blue: 0.1, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.1, green: 0.15, blue: 0.3, alpha: 1.0),
            terrainColor: SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0),
            celestialBody: .jupiter,  // You see Jupiter from Europa
            specialMechanic: .cryogeysers,
            description: "Cryogeysers erupt from the ice — time your descent."
        ),
        // Level 5: Earth — familiar feel like classic (ratio 4.3x)
        LevelDefinition(
            id: 5, name: "Earth",
            gravity: -2.8, thrustPower: 12.0,
            skyColorTop: SKColor(red: 0.1, green: 0.15, blue: 0.3, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0),
            terrainColor: SKColor(red: 0.2, green: 0.35, blue: 0.5, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.25, green: 0.4, blue: 0.55, alpha: 1.0),
            celestialBody: .moon,
            specialMechanic: .movingPlatform,
            description: "Barge landing — platform moves!"
        ),
        // Level 6: Venus — heavier, turbulence adds chaos (ratio 4.1x)
        LevelDefinition(
            id: 6, name: "Venus",
            gravity: -3.2, thrustPower: 13.0,
            skyColorTop: SKColor(red: 0.4, green: 0.25, blue: 0.1, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.7, green: 0.5, blue: 0.2, alpha: 1.0),
            terrainColor: SKColor(red: 0.5, green: 0.4, blue: 0.25, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.6, green: 0.5, blue: 0.35, alpha: 1.0),
            celestialBody: .sunMedium,  // You see the Sun from Venus
            specialMechanic: .heavyTurbulence,
            description: "Vertical updrafts disrupt your descent."
        ),
        // Level 7: Mercury — strong gravity, heat shimmer (ratio 4.0x)
        LevelDefinition(
            id: 7, name: "Mercury",
            gravity: -3.5, thrustPower: 14.0,
            skyColorTop: SKColor(red: 0.0, green: 0.0, blue: 0.02, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.1, green: 0.08, blue: 0.05, alpha: 1.0),
            terrainColor: SKColor(red: 0.45, green: 0.4, blue: 0.35, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.55, green: 0.5, blue: 0.45, alpha: 1.0),
            celestialBody: .sunLarge,  // You see the Sun from Mercury (very large!)
            specialMechanic: .heatShimmer,
            description: "Heat shimmer disrupts thrust control."
        ),
        // Level 8: Ganymede — craters demand precision (ratio 3.9x)
        LevelDefinition(
            id: 8, name: "Ganymede",
            gravity: -3.8, thrustPower: 15.0,
            skyColorTop: SKColor(red: 0.0, green: 0.02, blue: 0.08, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0),
            terrainColor: SKColor(red: 0.35, green: 0.3, blue: 0.25, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.45, green: 0.4, blue: 0.35, alpha: 1.0),
            celestialBody: .jupiter,  // You see Jupiter from Ganymede
            specialMechanic: .deepCraters,
            description: "Deep craters make terrain deadly."
        ),
        // Level 9: Io — volcanic hazards, heavy gravity (ratio 3.9x)
        LevelDefinition(
            id: 9, name: "Io",
            gravity: -4.2, thrustPower: 16.5,
            skyColorTop: SKColor(red: 0.1, green: 0.05, blue: 0.0, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.3, green: 0.2, blue: 0.05, alpha: 1.0),
            terrainColor: SKColor(red: 0.7, green: 0.6, blue: 0.2, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.8, green: 0.7, blue: 0.3, alpha: 1.0),
            celestialBody: .jupiter,  // You see Jupiter from Io
            specialMechanic: .volcanicEruptions,
            description: "Volcanic debris is deadly — time it."
        ),
        // Level 10: Jupiter — extreme gravity + wind (ratio 3.6x)
        LevelDefinition(
            id: 10, name: "Jupiter",
            gravity: -5.2, thrustPower: 18.5,
            skyColorTop: SKColor(red: 0.2, green: 0.15, blue: 0.05, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.6, green: 0.45, blue: 0.2, alpha: 1.0),
            terrainColor: SKColor(red: 0.5, green: 0.4, blue: 0.25, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 1.0),
            celestialBody: .europaSmall,  // You see Europa (a moon) from Jupiter
            specialMechanic: .extremeWind,
            description: "Sudden gusts between calm windows."
        ),

        // MARK: Chapter 2 — Starship Program
        // Level 11: Starbase — the tower catches the ship with its chopstick arms
        LevelDefinition(
            id: 11, name: "Starbase",
            gravity: -2.8, thrustPower: 12.5,
            skyColorTop: SKColor(red: 0.12, green: 0.1, blue: 0.3, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.95, green: 0.5, blue: 0.3, alpha: 1.0),
            terrainColor: SKColor(red: 0.62, green: 0.55, blue: 0.42, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.75, green: 0.68, blue: 0.52, alpha: 1.0),
            celestialBody: .moon,
            specialMechanic: .towerCatch,
            description: "Fly into the tower's chopsticks for the catch.",
            chapter: 2,
            atmosphere: 0.6,
            briefing: "Pad C is the launch tower. Hover into the chopstick arms slowly and upright — they close on contact."
        ),
        // Level 12: Belly Flop — start horizontal, flip and burn before touchdown
        LevelDefinition(
            id: 12, name: "Belly Flop",
            gravity: -2.8, thrustPower: 13.5,
            skyColorTop: SKColor(red: 0.02, green: 0.05, blue: 0.2, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.35, green: 0.6, blue: 0.9, alpha: 1.0),
            terrainColor: SKColor(red: 0.6, green: 0.56, blue: 0.45, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.72, green: 0.68, blue: 0.56, alpha: 1.0),
            celestialBody: .moon,
            specialMechanic: .bellyFlop,
            description: "Fall sideways, then flip and burn at the last moment.",
            chapter: 2,
            atmosphere: 1.0,
            initialTilt: .pi / 2,
            briefing: "Falling belly-first keeps you slow. Flip upright too early and you'll plummet; too late and you won't stop."
        ),
        // Level 13: Phobos — tiny moon, huge Mars, almost no fuel
        LevelDefinition(
            id: 13, name: "Phobos",
            gravity: -0.7, thrustPower: 4.5,
            skyColorTop: SKColor(red: 0.0, green: 0.0, blue: 0.02, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.12, green: 0.05, blue: 0.04, alpha: 1.0),
            terrainColor: SKColor(red: 0.42, green: 0.38, blue: 0.34, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.52, green: 0.47, blue: 0.42, alpha: 1.0),
            celestialBody: .marsLarge,
            specialMechanic: .lowFuel,
            description: "Barely any propellant. Every burn counts.",
            chapter: 2,
            initialFuel: 45,
            briefing: "Tanks at 45%. Let gravity do the work and save one long burn for the end."
        ),
        // Level 14: Ceres — meteor shower from the asteroid belt
        LevelDefinition(
            id: 14, name: "Ceres",
            gravity: -1.1, thrustPower: 6.5,
            skyColorTop: SKColor(red: 0.0, green: 0.0, blue: 0.03, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.06, green: 0.06, blue: 0.1, alpha: 1.0),
            terrainColor: SKColor(red: 0.36, green: 0.36, blue: 0.38, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.5, green: 0.5, blue: 0.53, alpha: 1.0),
            celestialBody: .sunTiny,
            specialMechanic: .meteorShower,
            description: "Meteors rain down. Watch the warnings.",
            chapter: 2,
            briefing: "Red markers at the top show where meteors will fall. Keep moving and don't loiter under them."
        ),
        // Level 15: Mars at Night — dark landing with dust wind
        LevelDefinition(
            id: 15, name: "Mars Night",
            gravity: -2.0, thrustPower: 9.5,
            skyColorTop: SKColor(red: 0.0, green: 0.0, blue: 0.02, alpha: 1.0),
            skyColorBottom: SKColor(red: 0.08, green: 0.03, blue: 0.03, alpha: 1.0),
            terrainColor: SKColor(red: 0.5, green: 0.22, blue: 0.14, alpha: 1.0),
            terrainStrokeColor: SKColor(red: 0.62, green: 0.3, blue: 0.2, alpha: 1.0),
            celestialBody: .phobosSmall,
            specialMechanic: .nightLanding,
            description: "Land in darkness by your own landing light.",
            chapter: 2,
            atmosphere: 0.25,
            briefing: "Only your landing light and the pad beacons are visible. Trust the guide line and the readout."
        ),
    ]

    static var chapters: [Int] { Array(Set(levels.map(\.chapter))).sorted() }

    static func chapterTitle(_ chapter: Int) -> String {
        chapter == 1 ? "CHAPTER 1 · SOLAR SYSTEM" : "CHAPTER 2 · STARSHIP PROGRAM"
    }

    static var maxStars: Int { levels.count * 3 }

    static func level(for id: Int) -> LevelDefinition? {
        return levels.first { $0.id == id }
    }
}
