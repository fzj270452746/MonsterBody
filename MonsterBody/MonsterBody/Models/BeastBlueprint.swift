import Foundation

// MARK: - Monster Blueprint (definition)
struct BeastBlueprint: Equatable {
    let identifier: String              // e.g. "normal-monster-1"
    let rarity: BeastRarity
    let partFormula: [BodyPartCategory: Int]  // part -> required style index
    let displayName: String

    var assetName: String { identifier }
}

// MARK: - Monster Roster (all 16 monsters)
enum BeastRoster {
    static let allBeasts: [BeastBlueprint] = ordinaryBeasts + scarceBeasts + prizableBeasts

    // MARK: Normal (7)
    static let ordinaryBeasts: [BeastBlueprint] = (1...7).map { idx in
        BeastBlueprint(
            identifier: "normal-monster-\(idx)",
            rarity: .ordinary,
            partFormula: Dictionary(uniqueKeysWithValues: BodyPartCategory.allCases.map { ($0, idx) }),
            displayName: "Monster #\(idx)"
        )
    }

    // MARK: Rare (5)
    static let scarceBeasts: [BeastBlueprint] = [
        BeastBlueprint(identifier: "rare-monster-1", rarity: .scarce,
                       partFormula: [.accesories:9,.arms:9,.body:9,.eyes:9,.legs:9,.mouth:9],
                       displayName: "Rare Beast I"),
        BeastBlueprint(identifier: "rare-monster-2", rarity: .scarce,
                       partFormula: [.accesories:1,.arms:2,.body:1,.eyes:2,.legs:9,.mouth:6],
                       displayName: "Rare Beast II"),
        BeastBlueprint(identifier: "rare-monster-3", rarity: .scarce,
                       partFormula: [.accesories:3,.arms:6,.body:5,.eyes:7,.legs:7,.mouth:8],
                       displayName: "Rare Beast III"),
        BeastBlueprint(identifier: "rare-monster-4", rarity: .scarce,
                       partFormula: [.accesories:6,.arms:7,.body:1,.eyes:8,.legs:2,.mouth:4],
                       displayName: "Rare Beast IV"),
        BeastBlueprint(identifier: "rare-monster-5", rarity: .scarce,
                       partFormula: [.accesories:6,.arms:5,.body:9,.eyes:6,.legs:5,.mouth:9],
                       displayName: "Rare Beast V"),
    ]

    // MARK: Treasure (4)
    static let prizableBeasts: [BeastBlueprint] = [
        BeastBlueprint(identifier: "treasure-monster-1", rarity: .prized,
                       partFormula: [.accesories:8,.arms:8,.body:8,.eyes:8,.legs:8,.mouth:8],
                       displayName: "Treasure Beast I"),
        BeastBlueprint(identifier: "treasure-monster-2", rarity: .prized,
                       partFormula: [.accesories:9,.arms:9,.body:6,.eyes:9,.legs:9,.mouth:8],
                       displayName: "Treasure Beast II"),
        BeastBlueprint(identifier: "treasure-monster-3", rarity: .prized,
                       partFormula: [.accesories:7,.arms:4,.body:7,.eyes:4,.legs:4,.mouth:7],
                       displayName: "Treasure Beast III"),
        BeastBlueprint(identifier: "treasure-monster-4", rarity: .prized,
                       partFormula: [.accesories:4,.arms:3,.body:2,.eyes:6,.legs:8,.mouth:5],
                       displayName: "Treasure Beast IV"),
    ]

    // Check if a combo of part→styleIndex matches any monster
    static func scrutinizeCombo(_ combo: [BodyPartCategory: Int]) -> BeastBlueprint? {
        return allBeasts.first { beast in
            beast.partFormula == combo
        }
    }
}
