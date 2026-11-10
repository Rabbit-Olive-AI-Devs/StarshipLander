import Foundation

// MARK: - Ghost Run
// The best landing on each level is recorded (position + attitude every 1/20 s)
// and replayed as a translucent "ghost" ship on later attempts.

struct GhostSample: Codable, Equatable {
    let x: Float
    let y: Float
    let r: Float
}

struct GhostRun: Codable, Equatable {
    static let sampleInterval: Double = 0.05
    static let maxSamples = 1800 // 90 seconds

    let score: Int
    let sceneWidth: Float
    let samples: [GhostSample]

    /// Interpolated pose at `time` seconds after flight start, scaled to `width`.
    /// Returns nil once the recording has ended.
    func pose(at time: Double, width: Float) -> GhostSample? {
        guard !samples.isEmpty, time >= 0 else { return nil }
        let position = time / GhostRun.sampleInterval
        let i = Int(position)
        guard i < samples.count - 1 else { return nil }
        let f = Float(position - Double(i))
        let a = samples[i], b = samples[i + 1]
        let scale = sceneWidth > 0 ? width / sceneWidth : 1
        return GhostSample(
            x: (a.x + (b.x - a.x) * f) * scale,
            y: a.y + (b.y - a.y) * f,
            r: a.r + (b.r - a.r) * f
        )
    }
}

enum GhostStore {
    /// Storage key per mode/level. Daily challenges change every day, so they have no ghost.
    static func key(mode: GameMode, levelId: Int) -> String? {
        switch mode {
        case .classic: return "ghost.classic"
        case .campaign: return "ghost.campaign.\(levelId)"
        case .dailyChallenge: return nil
        }
    }

    static func load(key: String, defaults: UserDefaults = .standard) -> GhostRun? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(GhostRun.self, from: data)
    }

    /// Saves the run when it beats the stored ghost. Returns true when saved.
    @discardableResult
    static func saveIfBest(_ run: GhostRun, key: String, defaults: UserDefaults = .standard) -> Bool {
        guard run.samples.count >= 2 else { return false }
        if let existing = load(key: key, defaults: defaults), existing.score >= run.score { return false }
        guard let data = try? JSONEncoder().encode(run) else { return false }
        defaults.set(data, forKey: key)
        return true
    }
}
