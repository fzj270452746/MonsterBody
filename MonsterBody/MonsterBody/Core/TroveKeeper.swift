import Foundation

// MARK: - TroveKeeper: Persistence Manager
final class TroveKeeper {
    static let shared = TroveKeeper()
    private let store = UserDefaults.standard
    private init() {}

    // MARK: - Vault Balance
    var vaultBalance: Int {
        get { store.integer(forKey: GlyphVault.persistBalanceKey) }
        set { store.set(newValue, forKey: GlyphVault.persistBalanceKey) }
    }

    // MARK: - Enshrined (unlocked) monsters
    var enshrinedsIdentifiers: Set<String> {
        get {
            let arr = store.stringArray(forKey: GlyphVault.persistEnshrinedsKey) ?? []
            return Set(arr)
        }
        set {
            store.set(Array(newValue), forKey: GlyphVault.persistEnshrinedsKey)
        }
    }

    func enshrineBeast(_ blueprint: BeastBlueprint) {
        var current = enshrinedsIdentifiers
        current.insert(blueprint.identifier)
        enshrinedsIdentifiers = current
    }

    func isBeastEnshrined(_ blueprint: BeastBlueprint) -> Bool {
        enshrinedsIdentifiers.contains(blueprint.identifier)
    }

    var enshrineCount: Int { enshrinedsIdentifiers.count }

    // MARK: - Unlocked body parts
    var unlockedPartCategories: Set<BodyPartCategory> {
        get {
            let arr = store.stringArray(forKey: GlyphVault.persistUnlockedPartsKey) ?? []
            let cats = arr.compactMap { BodyPartCategory(rawValue: $0) }
            // Always include first two free ones
            var result = Set(cats)
            result.insert(.accesories)
            result.insert(.arms)
            return result
        }
        set {
            store.set(Array(newValue).map { $0.rawValue }, forKey: GlyphVault.persistUnlockedPartsKey)
        }
    }

    func isPartUnlocked(_ part: BodyPartCategory) -> Bool {
        if part.unlockThreshold == 0 { return true }
        return unlockedPartCategories.contains(part)
    }

    func inscribePartUnlock(_ part: BodyPartCategory) {
        var current = unlockedPartCategories
        current.insert(part)
        unlockedPartCategories = current
    }

    // MARK: - Achievements
    var achievementStates: [String: TrophyState] {
        get {
            guard let data = store.data(forKey: GlyphVault.persistAchievementsKey),
                  let arr = try? JSONDecoder().decode([TrophyState].self, from: data)
            else { return [:] }
            return Dictionary(uniqueKeysWithValues: arr.map { ($0.id, $0) })
        }
        set {
            if let data = try? JSONEncoder().encode(Array(newValue.values)) {
                store.set(data, forKey: GlyphVault.persistAchievementsKey)
            }
        }
    }

    func isAchievementEarned(_ id: String) -> Bool {
        achievementStates[id]?.isEarned ?? false
    }

    func markAchievementEarned(_ id: String) {
        var states = achievementStates
        states[id] = TrophyState(id: id, isEarned: true, earnedAt: Date())
        achievementStates = states
    }

    // MARK: - Spin counters
    var totalSpinCount: Int {
        get { store.integer(forKey: GlyphVault.persistTotalSpinsKey) }
        set { store.set(newValue, forKey: GlyphVault.persistTotalSpinsKey) }
    }

    var totalCoinsWonCount: Int {
        get { store.integer(forKey: GlyphVault.persistTotalWonKey) }
        set { store.set(newValue, forKey: GlyphVault.persistTotalWonKey) }
    }

    var comboSlotWinCount: Int {
        get { store.integer(forKey: "gv_combo_wins_v1") }
        set { store.set(newValue, forKey: "gv_combo_wins_v1") }
    }

    var hasPlayedBeastSlot: Bool {
        get { store.bool(forKey: "gv_played_beast_v1") }
        set { store.set(newValue, forKey: "gv_played_beast_v1") }
    }

    var hasHitSixMatch: Bool {
        get { store.bool(forKey: "gv_six_match_v1") }
        set { store.set(newValue, forKey: "gv_six_match_v1") }
    }

    var hasWonMaxWager: Bool {
        get { store.bool(forKey: "gv_max_wager_win_v1") }
        set { store.set(newValue, forKey: "gv_max_wager_win_v1") }
    }

    // MARK: - First launch bootstrap
    func bootstrapIfNeeded() {
        guard !store.bool(forKey: GlyphVault.persistHasLaunchedKey) else { return }
        vaultBalance = GlyphVault.initialVaultBalance
        store.set(true, forKey: GlyphVault.persistHasLaunchedKey)
    }

    // MARK: - Coin transaction
    func burnWager(_ amount: Int) -> Bool {
        guard vaultBalance >= amount else { return false }
        vaultBalance -= amount
        return true
    }

    func harvestTokens(_ amount: Int) {
        vaultBalance += amount
        totalCoinsWonCount += amount
    }
}
