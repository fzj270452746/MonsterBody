import Foundation

// MARK: - Spin outcome types
enum PartSlotOutcome {
    case tripleMatch(part: BodyPartCategory, wager: Int, reward: Int)
    case doubleMatch(part: BodyPartCategory, wager: Int, reward: Int)
    case noMatch(symbols: [Int])
}

enum ComboSlotOutcome {
    case beastUnlocked(beast: BeastBlueprint, isFirstTime: Bool, reward: Int)
    case sixMatchBonus(reward: Int)
    case noMatch(combo: [BodyPartCategory: Int])
}

enum BeastSlotOutcome {
    case tripleMatch(beast: BeastBlueprint, wager: Int, reward: Int)
    case noMatch(beasts: [BeastBlueprint])
}

// MARK: - CipherEngine: Game Logic
final class CipherEngine {
    static let shared = CipherEngine()
    private init() {}

    // MARK: - Body Part Slot Spin
    func detonatePartReel(part: BodyPartCategory, wager: Int) -> (symbols: [Int], outcome: PartSlotOutcome) {
        let s1 = Int.random(in: 1...GlyphVault.glyphsPerPart)
        let s2 = Int.random(in: 1...GlyphVault.glyphsPerPart)
        let s3 = Int.random(in: 1...GlyphVault.glyphsPerPart)
        let symbols = [s1, s2, s3]

        if s1 == s2 && s2 == s3 {
            let reward = wager * part.rewardMultiplier
            return (symbols, .tripleMatch(part: part, wager: wager, reward: reward))
        } else if s1 == s2 || s2 == s3 || s1 == s3 {
            let reward = wager * max(part.rewardMultiplier - 1, 1)
            return (symbols, .doubleMatch(part: part, wager: wager, reward: reward))
        }
        return (symbols, .noMatch(symbols: symbols))
    }

    // MARK: - Combo Slot Spin (6x1)
    func detonateComboReel() -> (combo: [BodyPartCategory: Int], outcome: ComboSlotOutcome) {
        var combo: [BodyPartCategory: Int] = [:]
        for part in BodyPartCategory.allCases {
            combo[part] = Int.random(in: 1...GlyphVault.glyphsPerPart)
        }

        // Check all-same (six-match bonus)
        let values = Set(combo.values)
        if values.count == 1 {
            let reward = GlyphVault.hexMatchBounty
            return (combo, .sixMatchBonus(reward: reward))
        }

        // Check monster match
        if let beast = BeastRoster.scrutinizeCombo(combo) {
            let isFirst = !TroveKeeper.shared.isBeastEnshrined(beast)
            let reward = isFirst ? beast.rarity.firstUnlockBounty : beast.rarity.repeatUnlockBounty
            return (combo, .beastUnlocked(beast: beast, isFirstTime: isFirst, reward: reward))
        }

        return (combo, .noMatch(combo: combo))
    }

    // MARK: - Beast Slot Spin
    func detonateBeastReel(availableBeasts: [BeastBlueprint], wager: Int) -> ([BeastBlueprint], BeastSlotOutcome) {
        guard availableBeasts.count >= 1 else {
            return ([], .noMatch(beasts: []))
        }
        let b1 = availableBeasts.randomElement()!
        let b2 = availableBeasts.randomElement()!
        let b3 = availableBeasts.randomElement()!
        let result = [b1, b2, b3]

        if b1.identifier == b2.identifier && b2.identifier == b3.identifier {
            let reward = wager * 5  // flat 5x for beast slot match
            return (result, .tripleMatch(beast: b1, wager: wager, reward: reward))
        }
        return (result, .noMatch(beasts: result))
    }

    // MARK: - Achievement Evaluation
    @discardableResult
    func auguryCheck(event: AchievementTriggerEvent) -> [TrophyScroll] {
        let trove = TroveKeeper.shared
        // also feed daily missions
        trove.bumpDailyProgress(event: event)
        var newlyEarned: [TrophyScroll] = []

        for scroll in TrophyCatalogue.allScrolls {
            guard !trove.isAchievementEarned(scroll.id) else { continue }
            if satisfiesCondition(scroll.condition, for: event, trove: trove) {
                trove.markAchievementEarned(scroll.id)
                trove.harvestTokens(scroll.tokenReward)
                newlyEarned.append(scroll)
            }
        }
        return newlyEarned
    }

    private func satisfiesCondition(_ condition: AchievementCondition,
                                    for event: AchievementTriggerEvent,
                                    trove: TroveKeeper) -> Bool {
        switch condition {
        case .firstSpin:
            return trove.totalSpinCount >= 1
        case .totalSpins(let n):
            return trove.totalSpinCount >= n
        case .totalCoinsWon(let n):
            return trove.totalCoinsWonCount >= n
        case .totalCoinsEarned(let n):
            return trove.totalCoinsWonCount >= n
        case .unlockMonster(let count):
            return trove.enshrineCount >= count
        case .unlockRareMonster:
            return trove.enshrinedsIdentifiers.contains { id in
                BeastRoster.allBeasts.first { $0.identifier == id }?.rarity == .scarce
            }
        case .unlockTreasureMonster:
            return trove.enshrinedsIdentifiers.contains { id in
                BeastRoster.allBeasts.first { $0.identifier == id }?.rarity == .prized
            }
        case .unlockAllNormal:
            let normalIds = Set(BeastRoster.ordinaryBeasts.map { $0.identifier })
            return normalIds.isSubset(of: trove.enshrinedsIdentifiers)
        case .unlockAllRare:
            let rareIds = Set(BeastRoster.scarceBeasts.map { $0.identifier })
            return rareIds.isSubset(of: trove.enshrinedsIdentifiers)
        case .unlockAllTreasure:
            let tIds = Set(BeastRoster.prizableBeasts.map { $0.identifier })
            return tIds.isSubset(of: trove.enshrinedsIdentifiers)
        case .unlockAllMonsters:
            let allIds = Set(BeastRoster.allBeasts.map { $0.identifier })
            return allIds.isSubset(of: trove.enshrinedsIdentifiers)
        case .unlockBodyPart(let part):
            return trove.isPartUnlocked(part)
        case .unlockAllParts:
            return BodyPartCategory.allCases.allSatisfy { trove.isPartUnlocked($0) }
        case .winPartSlot:
            return false
        case .winComboSlot(let count):
            return trove.comboSlotWinCount >= count
        case .winBeastSlot:
            return false
        case .reachBalance(let n):
            return trove.vaultBalance >= n
        case .spinBeastSlot:
            return trove.hasPlayedBeastSlot
        case .sixMatchCombo:
            return trove.hasHitSixMatch
        case .maxWagerWin:
            return trove.hasWonMaxWager
        }
    }
}

// MARK: - Trigger event (context for achievement check)
enum AchievementTriggerEvent {
    case spinPerformed
    case coinHarvested(amount: Int)
    case beastEnshrined(beast: BeastBlueprint)
    case partUnlocked(part: BodyPartCategory)
    case beastSlotPlayed
    case sixMatchOccurred
    case maxWagerWon
    case balanceChanged(newBalance: Int)
    case comboWon
}
