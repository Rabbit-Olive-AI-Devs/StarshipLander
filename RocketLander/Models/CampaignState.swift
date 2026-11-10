import Foundation

class CampaignState: ObservableObject {
    @Published var unlockedLevels: Set<Int> = [1]
    @Published var starsByLevel: [Int: Int] = [:]
    @Published var scoresByLevel: [Int: [HighScoreEntry]] = [:]
    @Published var personalBestScoresByLevel: [Int: Int] = [:]

    private let storageKey = "campaignState"

    var totalStars: Int {
        starsByLevel.values.reduce(0, +)
    }

    // Easter egg: astronaut/scientist names relevant to each celestial body
    private static let defaultScoreNames: [Int: String] = [
        1: "Armstrong",   // Moon — Neil Armstrong, first moonwalker
        2: "Aldrin",      // Mars — Buzz Aldrin, Mars mission advocate
        3: "Huygens",     // Titan — Christiaan Huygens, discovered Titan
        4: "Galileo",     // Europa — Galileo Galilei, discovered Europa
        5: "Gagarin",     // Earth — Yuri Gagarin, first human in space
        6: "Shepard",     // Venus — Alan Shepard, first American in space
        7: "Glenn",       // Mercury — John Glenn, Project Mercury astronaut
        8: "Marius",      // Ganymede — Simon Marius, named Galilean moons
        9: "Collins",     // Io — Michael Collins, Apollo 11 pilot
        10: "Shoemaker",  // Jupiter — Eugene Shoemaker, Shoemaker-Levy 9
        11: "Ride",       // Starbase — Sally Ride, first American woman in space
        12: "Lovell",     // Belly Flop — Jim Lovell, Apollo 13 reentry
        13: "Hall",       // Phobos — Asaph Hall, discovered Phobos
        14: "Piazzi",     // Ceres — Giuseppe Piazzi, discovered Ceres
        15: "Tereshkova", // Mars Night — Valentina Tereshkova, first woman in space
    ]

    init() {
        load()
        seedDefaultScoresIfNeeded()
    }

    private func seedDefaultScoresIfNeeded() {
        var changed = false
        for (levelId, name) in CampaignState.defaultScoreNames {
            if (scoresByLevel[levelId] ?? []).isEmpty {
                scoresByLevel[levelId] = [HighScoreEntry(name: name, score: 1000)]
                changed = true
            }
        }
        if changed { save() }
    }

    // MARK: - Level Management

    func isUnlocked(_ levelId: Int) -> Bool {
        return unlockedLevels.contains(levelId)
    }

    func bestStars(for levelId: Int) -> Int {
        return starsByLevel[levelId] ?? 0
    }

    func bestScore(for levelId: Int) -> Int {
        return max(personalBestScoresByLevel[levelId] ?? 0, scoresByLevel[levelId]?.first?.score ?? 0)
    }

    func isHighScore(for levelId: Int, score: Int) -> Bool {
        guard score > 0 else { return false }
        let levelScores = scoresByLevel[levelId] ?? []
        if levelScores.count < 3 { return true }
        return score > (levelScores.last?.score ?? 0)
    }

    func completedLevel(_ levelId: Int, stars: Int, score: Int, name: String) {
        recordCompletion(levelId, stars: stars, score: score)
        addNamedScore(levelId: levelId, stars: stars, score: score, name: name)
    }

    func recordCompletion(_ levelId: Int, stars: Int, score: Int) {
        // Update stars (keep best)
        let currentBest = starsByLevel[levelId] ?? 0
        if stars > currentBest {
            starsByLevel[levelId] = stars
        }

        // Track personal best even when the player skips the name entry sheet.
        if score > (personalBestScoresByLevel[levelId] ?? 0) {
            personalBestScoresByLevel[levelId] = score
        }

        // Unlock next level
        let nextLevel = levelId + 1
        if nextLevel <= LevelDefinition.levels.count {
            unlockedLevels.insert(nextLevel)
        }

        save()
    }

    func addNamedScore(levelId: Int, stars: Int, score: Int, name: String) {
        // Add score entry with star metadata
        let entry = HighScoreEntry(name: name, score: score, stars: stars)
        var levelScores = scoresByLevel[levelId] ?? []
        levelScores.append(entry)
        levelScores.sort { $0.score > $1.score }
        if levelScores.count > 3 {
            levelScores = Array(levelScores.prefix(3))
        }
        scoresByLevel[levelId] = levelScores

        save()
    }

    // MARK: - Persistence

    private func save() {
        let data = CampaignSaveData(
            unlockedLevels: Array(unlockedLevels),
            starsByLevel: starsByLevel,
            scoresByLevel: scoresByLevel,
            personalBestScoresByLevel: personalBestScoresByLevel
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(CampaignSaveData.self, from: data) else {
            return
        }
        unlockedLevels = Set(decoded.unlockedLevels)
        starsByLevel = decoded.starsByLevel
        scoresByLevel = decoded.scoresByLevel
        personalBestScoresByLevel = decoded.personalBestScoresByLevel ?? [:]
    }
}

// MARK: - Codable Save Data
private struct CampaignSaveData: Codable {
    let unlockedLevels: [Int]
    let starsByLevel: [Int: Int]
    let scoresByLevel: [Int: [HighScoreEntry]]
    let personalBestScoresByLevel: [Int: Int]?
}
