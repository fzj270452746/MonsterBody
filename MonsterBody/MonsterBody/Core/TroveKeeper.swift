import Foundation

// MARK: - TroveKeeper: Persistence Manager
final class TroveKeeper {
    static let shared = TroveKeeper()
    private let store = UserDefaults.standard
    private init() {}

    // MARK: - Daily missions
    struct DailyMission: Codable {
        let id: String
        let title: String
        var progress: Int
        var target: Int
        var claimed: Bool
        var reward: Int
    }

    private var lastDailyResetKey: String { "gv_daily_reset_v1" }
    private var dailyMissionsKey: String { "gv_daily_missions_v1" }

    var dailyMissions: [DailyMission] {
        get {
            guard let data = store.data(forKey: dailyMissionsKey),
                  let arr = try? JSONDecoder().decode([DailyMission].self, from: data) else { return [] }
            return arr
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) { store.set(data, forKey: dailyMissionsKey) }
        }
    }

    func resetDailyIfNeeded() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        if let last = store.object(forKey: lastDailyResetKey) as? Date, cal.isDate(last, inSameDayAs: today) {
            // Migration: if previous schema had fewer than 5 missions, reseed today
            if dailyMissions.count < 5 {
                dailyMissions = [
                    DailyMission(id: "login",      title: "Log in today",               progress: 0, target: 1,  claimed: false, reward: 100),
                    DailyMission(id: "spin_20",    title: "Spin any slot 20 times",    progress: 0, target: 20, claimed: false, reward: 150),
                    DailyMission(id: "combo_1",    title: "Win once in Combo",         progress: 0, target: 1,  claimed: false, reward: 200),
                    DailyMission(id: "collect_1",  title: "Unlock 1 monster",          progress: 0, target: 1,  claimed: false, reward: 250),
                    DailyMission(id: "balance_5k", title: "Reach 5,000 coins balance", progress: 0, target: 1,  claimed: false, reward: 200)
                ]
                bumpDailyManual(id: "login")
                store.set(today, forKey: lastDailyResetKey)
            }
            return
        }
        // five lightweight dailies
        dailyMissions = [
            DailyMission(id: "login",      title: "Log in today",               progress: 0, target: 1,  claimed: false, reward: 100),
            DailyMission(id: "spin_20",    title: "Spin any slot 20 times",    progress: 0, target: 20, claimed: false, reward: 150),
            DailyMission(id: "combo_1",    title: "Win once in Combo",         progress: 0, target: 1,  claimed: false, reward: 200),
            DailyMission(id: "collect_1",  title: "Unlock 1 monster",          progress: 0, target: 1,  claimed: false, reward: 250),
            DailyMission(id: "balance_5k", title: "Reach 5,000 coins balance", progress: 0, target: 1,  claimed: false, reward: 200)
        ]
        store.set(today, forKey: lastDailyResetKey)
        // set login progress
        bumpDailyManual(id: "login")
    }

    func bumpDailyProgress(event: AchievementTriggerEvent) {
        var arr = dailyMissions
        switch event {
        case .spinPerformed:
            if let i = arr.firstIndex(where: { $0.id == "spin_20" }) { arr[i].progress = min(arr[i].progress + 1, arr[i].target) }
        case .comboWon:
            if let i = arr.firstIndex(where: { $0.id == "combo_1" }) { arr[i].progress = min(arr[i].progress + 1, arr[i].target) }
        case .beastEnshrined:
            if let i = arr.firstIndex(where: { $0.id == "collect_1" }) { arr[i].progress = min(arr[i].progress + 1, arr[i].target) }
        case .balanceChanged(let newBalance):
            if newBalance >= 5000, let i = arr.firstIndex(where: { $0.id == "balance_5k" }) { arr[i].progress = arr[i].target }
        default: break
        }
        dailyMissions = arr
    }

    func bumpDailyManual(id: String) {
        var arr = dailyMissions
        if let i = arr.firstIndex(where: { $0.id == id }) {
            arr[i].progress = min(arr[i].progress + 1, arr[i].target)
            dailyMissions = arr
        }
    }

    func claimDaily(_ id: String) -> Int {
        var arr = dailyMissions
        guard let i = arr.firstIndex(where: { $0.id == id }) else { return 0 }
        var m = arr[i]
        guard !m.claimed, m.progress >= m.target else { return 0 }
        m.claimed = true
        arr[i] = m
        dailyMissions = arr
        harvestTokens(m.reward)
        return m.reward
    }

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
