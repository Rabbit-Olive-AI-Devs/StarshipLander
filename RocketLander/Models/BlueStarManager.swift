import Foundation
import Combine

// MARK: - Blue Star Manager
// Tracks blue stars (premium currency) earned from Daily Challenges and Campaign milestones.
// Blue stars will be used in a future Starship Store for cosmetic skins.

class BlueStarManager: ObservableObject {
    static let shared = BlueStarManager()

    // MARK: - Published State

    @Published private(set) var blueStars: Int = 0
    @Published private(set) var currentStreak: Int = 0

    // MARK: - Keys

    private let blueStarsKey = "blueStars"
    private let streakCountKey = "dailyStreak"
    private let lastCompletionDateKey = "lastDailyChallengeDate"
    private let claimedMilestonesKey = "claimedCampaignMilestones"

    // MARK: - Reward Constants

    /// Blue stars earned for completing a daily challenge (landing on target platform)
    static let dailyChallengeReward = 1

    /// Bonus blue stars for reaching a 5-day streak
    static let streakBonusReward = 3

    /// Days required for a streak bonus
    static let streakBonusThreshold = 5

    /// Campaign star milestones and their blue star rewards
    static let campaignMilestones: [(requiredStars: Int, blueStarReward: Int)] = [
        (10, 10),   // 10 campaign stars → 10 blue stars
        (20, 50),   // 20 campaign stars → 50 blue stars
        (30, 150),  // 30 campaign stars → 150 blue stars (mastery!)
    ]

    // MARK: - Init

    init() {
        load()
    }

    // MARK: - Daily Challenge Rewards

    /// Called when the player completes a daily challenge (lands on target platform).
    /// Awards blue stars and updates streak. Returns the reward summary.
    @discardableResult
    func recordDailyChallengeCompletion() -> DailyRewardResult {
        let today = todayString()

        // Prevent double-claiming for the same day
        let lastDate = UserDefaults.standard.string(forKey: lastCompletionDateKey) ?? ""
        guard lastDate != today else {
            return DailyRewardResult(baseReward: 0, streakBonus: 0, newStreak: currentStreak)
        }

        // Update streak
        let yesterday = dateString(daysAgo: 1)
        if lastDate == yesterday {
            currentStreak += 1
        } else {
            currentStreak = 1
        }

        // Base reward
        var totalEarned = BlueStarManager.dailyChallengeReward

        // Streak bonus
        var streakBonus = 0
        if currentStreak > 0 && currentStreak % BlueStarManager.streakBonusThreshold == 0 {
            streakBonus = BlueStarManager.streakBonusReward
            totalEarned += streakBonus
        }

        blueStars += totalEarned
        UserDefaults.standard.set(today, forKey: lastCompletionDateKey)
        save()

        return DailyRewardResult(
            baseReward: BlueStarManager.dailyChallengeReward,
            streakBonus: streakBonus,
            newStreak: currentStreak
        )
    }

    // MARK: - Campaign Milestone Rewards

    /// Check and claim any unclaimed campaign milestones based on current total stars.
    /// Returns array of newly claimed milestones.
    @discardableResult
    func checkCampaignMilestones(totalCampaignStars: Int) -> [CampaignMilestoneReward] {
        var claimed = claimedMilestones()
        var newRewards: [CampaignMilestoneReward] = []

        for milestone in BlueStarManager.campaignMilestones {
            if totalCampaignStars >= milestone.requiredStars && !claimed.contains(milestone.requiredStars) {
                blueStars += milestone.blueStarReward
                claimed.insert(milestone.requiredStars)
                newRewards.append(CampaignMilestoneReward(
                    requiredStars: milestone.requiredStars,
                    blueStarsAwarded: milestone.blueStarReward
                ))
            }
        }

        if !newRewards.isEmpty {
            UserDefaults.standard.set(Array(claimed), forKey: claimedMilestonesKey)
            save()
        }

        return newRewards
    }

    // MARK: - Spending & Awards

    /// Spends Blue Stars (Hangar purchases). Returns false when the balance is too low.
    @discardableResult
    func spend(_ amount: Int) -> Bool {
        guard amount > 0, blueStars >= amount else { return false }
        blueStars -= amount
        save()
        return true
    }

    /// Awards Blue Stars outside Daily Challenge / campaign milestones (Pilot Rank promotions).
    func award(_ amount: Int) {
        guard amount > 0 else { return }
        blueStars += amount
        save()
    }

    // MARK: - Streak Info

    /// Whether the streak is still active (completed yesterday or today)
    var isStreakActive: Bool {
        let lastDate = UserDefaults.standard.string(forKey: lastCompletionDateKey) ?? ""
        return lastDate == todayString() || lastDate == dateString(daysAgo: 1)
    }

    /// Days until next streak bonus
    var daysUntilStreakBonus: Int {
        guard currentStreak > 0 else { return BlueStarManager.streakBonusThreshold }
        let remaining = BlueStarManager.streakBonusThreshold - (currentStreak % BlueStarManager.streakBonusThreshold)
        return remaining == BlueStarManager.streakBonusThreshold ? BlueStarManager.streakBonusThreshold : remaining
    }

    /// Whether today's daily challenge has already been completed (blue star claimed)
    var todayAlreadyClaimed: Bool {
        let lastDate = UserDefaults.standard.string(forKey: lastCompletionDateKey) ?? ""
        return lastDate == todayString()
    }

    // MARK: - Persistence

    private func save() {
        UserDefaults.standard.set(blueStars, forKey: blueStarsKey)
        UserDefaults.standard.set(currentStreak, forKey: streakCountKey)
    }

    private func load() {
        blueStars = UserDefaults.standard.integer(forKey: blueStarsKey)
        currentStreak = UserDefaults.standard.integer(forKey: streakCountKey)

        // Validate streak — if last completion was more than 1 day ago, reset
        if !isStreakActive {
            currentStreak = 0
            save()
        }
    }

    private func claimedMilestones() -> Set<Int> {
        let array = UserDefaults.standard.array(forKey: claimedMilestonesKey) as? [Int] ?? []
        return Set(array)
    }

    // MARK: - Date Helpers

    private func todayString() -> String {
        dateString(daysAgo: 0)
    }

    private func dateString(daysAgo: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

// MARK: - Reward Result Types

struct DailyRewardResult {
    let baseReward: Int
    let streakBonus: Int
    let newStreak: Int

    var totalReward: Int { baseReward + streakBonus }
    var hasStreakBonus: Bool { streakBonus > 0 }
}

struct CampaignMilestoneReward {
    let requiredStars: Int
    let blueStarsAwarded: Int
}
