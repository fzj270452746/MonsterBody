import Foundation

// MARK: - Achievement Definition
struct TrophyScroll: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String        // SF Symbol name
    let tokenReward: Int
    let condition: AchievementCondition
}

enum AchievementCondition {
    case firstSpin
    case totalSpins(Int)
    case totalCoinsWon(Int)
    case totalCoinsEarned(Int)
    case unlockMonster(count: Int)
    case unlockRareMonster
    case unlockTreasureMonster
    case unlockAllNormal
    case unlockAllRare
    case unlockAllTreasure
    case unlockAllMonsters
    case unlockBodyPart(BodyPartCategory)
    case unlockAllParts
    case winPartSlot(count: Int)
    case winComboSlot(count: Int)
    case winBeastSlot(count: Int)
    case reachBalance(Int)
    case spinBeastSlot
    case sixMatchCombo
    case maxWagerWin
}

// MARK: - Achievement State (saved)
struct TrophyState: Codable {
    let id: String
    var isEarned: Bool
    var earnedAt: Date?
}

// MARK: - Full Trophy Catalogue (25 achievements)
enum TrophyCatalogue {
    static let allScrolls: [TrophyScroll] = [
        // Spinning
        TrophyScroll(id: "first_spin", title: "First Spin",
                     description: "Perform your very first spin.",
                     iconName: "arrow.clockwise.circle.fill", tokenReward: 50,
                     condition: .firstSpin),
        TrophyScroll(id: "spin_10", title: "Getting Warmed Up",
                     description: "Spin 10 times total.",
                     iconName: "arrow.2.circlepath", tokenReward: 100,
                     condition: .totalSpins(10)),
        TrophyScroll(id: "spin_50", title: "Reel Enthusiast",
                     description: "Spin 50 times total.",
                     iconName: "arrow.2.circlepath.circle.fill", tokenReward: 200,
                     condition: .totalSpins(50)),
        TrophyScroll(id: "spin_200", title: "Spin Veteran",
                     description: "Spin 200 times total.",
                     iconName: "tornado", tokenReward: 500,
                     condition: .totalSpins(200)),
        TrophyScroll(id: "spin_1000", title: "Spinning Legend",
                     description: "Spin 1000 times total.",
                     iconName: "tornado.circle.fill", tokenReward: 2000,
                     condition: .totalSpins(1000)),

        // Coins
        TrophyScroll(id: "coins_1000", title: "Pocket Change",
                     description: "Win 1,000 coins in total.",
                     iconName: "dollarsign.circle", tokenReward: 100,
                     condition: .totalCoinsWon(1000)),
        TrophyScroll(id: "coins_10000", title: "Big Earner",
                     description: "Win 10,000 coins in total.",
                     iconName: "dollarsign.circle.fill", tokenReward: 500,
                     condition: .totalCoinsWon(10000)),
        TrophyScroll(id: "coins_100000", title: "Treasure Hunter",
                     description: "Win 100,000 coins in total.",
                     iconName: "bag.fill", tokenReward: 2000,
                     condition: .totalCoinsWon(100000)),
        TrophyScroll(id: "balance_5000", title: "Comfortable",
                     description: "Reach a balance of 5,000 coins.",
                     iconName: "creditcard", tokenReward: 200,
                     condition: .reachBalance(5000)),
        TrophyScroll(id: "balance_50000", title: "Wealthy",
                     description: "Reach a balance of 50,000 coins.",
                     iconName: "creditcard.fill", tokenReward: 1000,
                     condition: .reachBalance(50000)),

        // Monster Collection
        TrophyScroll(id: "first_monster", title: "First Encounter",
                     description: "Unlock your first monster.",
                     iconName: "star.circle", tokenReward: 200,
                     condition: .unlockMonster(count: 1)),
        TrophyScroll(id: "monsters_5", title: "Collector",
                     description: "Unlock 5 different monsters.",
                     iconName: "star.circle.fill", tokenReward: 500,
                     condition: .unlockMonster(count: 5)),
        TrophyScroll(id: "monsters_10", title: "Dedicated Collector",
                     description: "Unlock 10 different monsters.",
                     iconName: "star.fill", tokenReward: 1000,
                     condition: .unlockMonster(count: 10)),
        TrophyScroll(id: "first_rare", title: "Rare Find",
                     description: "Unlock your first Rare monster.",
                     iconName: "sparkles", tokenReward: 1000,
                     condition: .unlockRareMonster),
        TrophyScroll(id: "first_treasure", title: "Hidden Treasure",
                     description: "Unlock your first Treasure monster.",
                     iconName: "crown.fill", tokenReward: 3000,
                     condition: .unlockTreasureMonster),
        TrophyScroll(id: "all_normal", title: "Normal Complete",
                     description: "Unlock all 7 Normal monsters.",
                     iconName: "checkmark.seal", tokenReward: 2000,
                     condition: .unlockAllNormal),
        TrophyScroll(id: "all_rare", title: "Rare Complete",
                     description: "Unlock all 5 Rare monsters.",
                     iconName: "checkmark.seal.fill", tokenReward: 5000,
                     condition: .unlockAllRare),
        TrophyScroll(id: "all_treasure", title: "Treasure Complete",
                     description: "Unlock all 4 Treasure monsters.",
                     iconName: "crown", tokenReward: 15000,
                     condition: .unlockAllTreasure),
        TrophyScroll(id: "all_monsters", title: "Master Collector",
                     description: "Unlock every single monster.",
                     iconName: "trophy.fill", tokenReward: 30000,
                     condition: .unlockAllMonsters),

        // Part unlocks
        TrophyScroll(id: "unlock_body", title: "Body Unlocked",
                     description: "Unlock the Body part slot.",
                     iconName: "figure.stand", tokenReward: 100,
                     condition: .unlockBodyPart(.body)),
        TrophyScroll(id: "unlock_all_parts", title: "Full Roster",
                     description: "Unlock all body part slots.",
                     iconName: "person.3.fill", tokenReward: 1000,
                     condition: .unlockAllParts),

        // Special spins
        TrophyScroll(id: "six_match", title: "Perfect Harmony",
                     description: "Hit all 6 matching symbols in Combo Slot.",
                     iconName: "hexagon.fill", tokenReward: 500,
                     condition: .sixMatchCombo),
        TrophyScroll(id: "beast_slot_open", title: "Monster Arena",
                     description: "Unlock and play the Monster Slot.",
                     iconName: "gamecontroller.fill", tokenReward: 300,
                     condition: .spinBeastSlot),
        TrophyScroll(id: "max_wager_win", title: "High Roller",
                     description: "Win with maximum wager (100 coins) in Body Part Slot.",
                     iconName: "flame.fill", tokenReward: 800,
                     condition: .maxWagerWin),
        TrophyScroll(id: "combo_win_5", title: "Combo Master",
                     description: "Win a monster match in Combo Slot 5 times.",
                     iconName: "bolt.fill", tokenReward: 1500,
                     condition: .winComboSlot(count: 5)),
    ]
}
