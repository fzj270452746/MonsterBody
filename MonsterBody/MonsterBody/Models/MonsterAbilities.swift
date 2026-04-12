import Foundation

// Derive a lightweight passive profile from a collected beast
struct PassiveProfile {
    var extraTime: TimeInterval = 0
    var scorePerHitBonus: Int = 0
    var targetReduction: Int = 0
    var spawnInterval: TimeInterval = 0.8
    var doubleTargetChance: Double = 0
}

enum MonsterAbilities {
    static func profileFromCollection() -> PassiveProfile {
        let trove = TroveKeeper.shared
        guard let firstId = trove.enshrinedsIdentifiers.first,
              let beast = BeastRoster.allBeasts.first(where: { $0.identifier == firstId })
        else { return PassiveProfile() }

        var p = PassiveProfile()
        let f = beast.partFormula
        if (f[.eyes] ?? 1) >= 7 { p.extraTime += 3 }
        if (f[.mouth] ?? 1) >= 7 { p.extraTime += 5 }
        if (f[.arms] ?? 1) >= 6 { p.scorePerHitBonus += 2 }
        if (f[.body] ?? 1) >= 8 { p.targetReduction += 1 }
        if (f[.legs] ?? 1) >= 6 { p.spawnInterval = 0.7 }
        if (f[.accesories] ?? 1) >= 8 { p.doubleTargetChance = 0.15 }
        return p
    }
}

