import UIKit
import SpriteKit

// MARK: - Body Part Category
enum BodyPartCategory: String, CaseIterable, Codable {
    case accesories = "accesories"
    case arms       = "arms"
    case body       = "body"
    case eyes       = "eyes"
    case legs       = "legs"
    case mouth      = "mouth"

    var displayName: String {
        switch self {
        case .accesories: return "Accessories"
        case .arms:        return "Arms"
        case .body:        return "Body"
        case .eyes:        return "Eyes"
        case .legs:        return "Legs"
        case .mouth:       return "Mouth"
        }
    }

    // Reward multiplier when 3-match happens in BodyPart Slot
    var rewardMultiplier: Int {
        switch self {
        case .accesories: return 2
        case .arms:        return 3
        case .body:        return 5
        case .eyes:        return 6
        case .legs:        return 8
        case .mouth:       return 10
        }
    }

    // Coins needed to unlock (0 = free)
    var unlockThreshold: Int {
        switch self {
        case .accesories: return 0
        case .arms:        return 0
        case .body:        return 800
        case .eyes:        return 3000
        case .legs:        return 9000
        case .mouth:       return 25000
        }
    }

    var partIndex: Int { BodyPartCategory.allCases.firstIndex(of: self) ?? 0 }

    var gradientColors: (SKColor, SKColor) {
        switch self {
        case .accesories: return (.luminesViolet, .luminesIndigo)
        case .arms:        return (UIColor(hex: "#f093fb"), UIColor(hex: "#f5576c"))
        case .body:        return (UIColor(hex: "#4facfe"), UIColor(hex: "#00f2fe"))
        case .eyes:        return (UIColor(hex: "#43e97b"), UIColor(hex: "#38f9d7"))
        case .legs:        return (UIColor(hex: "#fa709a"), UIColor(hex: "#fee140"))
        case .mouth:       return (UIColor(hex: "#a18cd1"), UIColor(hex: "#fbc2eb"))
        }
    }
}

// MARK: - Beast Rarity
enum BeastRarity: String, Codable, CaseIterable {
    case ordinary = "normal"
    case scarce   = "rare"
    case prized   = "treasure"

    var displayName: String {
        switch self {
        case .ordinary: return "Normal"
        case .scarce:   return "Rare"
        case .prized:   return "Treasure"
        }
    }

    var firstUnlockBounty: Int {
        switch self {
        case .ordinary: return 600
        case .scarce:   return 2500
        case .prized:   return 10000
        }
    }

    var repeatUnlockBounty: Int {
        switch self {
        case .ordinary: return 60
        case .scarce:   return 250
        case .prized:   return 1000
        }
    }

    var glowColor: SKColor {
        switch self {
        case .ordinary: return .luminesGreen
        case .scarce:   return .luminesBlue
        case .prized:   return .luminesOrange
        }
    }

    var badgeText: String {
        switch self {
        case .ordinary: return "NORMAL"
        case .scarce:   return "✦ RARE"
        case .prized:   return "✦✦ TREASURE"
        }
    }
}

// MARK: - Game Constants Vault
enum GlyphVault {
    // Slot wager
    static let initialWager      = 20
    static let wagerStep         = 10
    static let maximumWager      = 100
    static let comboSlotCost     = 100
    static let beastSlotBaseWager = 200
    static let beastSlotMultiplierChoices = [1, 2, 5, 10, 20]

    // Starting coins on first launch
    static let initialVaultBalance = 3000

    // Six-match fixed bonus
    static let hexMatchBounty = 500

    // Minimum monsters to unlock Beast Slot
    static let beastSlotMinimumBeasts = 3

    // Symbol count per body part
    static let glyphsPerPart = 9

    // Persistence keys
    static let persistBalanceKey      = "gv_vault_balance_v1"
    static let persistEnshrinedsKey   = "gv_enshrined_v1"
    static let persistUnlockedPartsKey = "gv_unlocked_parts_v1"
    static let persistAchievementsKey  = "gv_achievements_v1"
    static let persistHasLaunchedKey   = "gv_launched_v1"
    static let persistTotalSpinsKey    = "gv_total_spins_v1"
    static let persistTotalWonKey      = "gv_total_won_v1"

    // Scene transition duration
    static let sceneTransitionDuration: TimeInterval = 0.4

    // Reel animation
    static let reelSpinDuration: TimeInterval = 2.0
    static let reelStaggerDelay: TimeInterval = 0.25

    // Font names (system fallbacks)
    static let fontHeavy   = "AvenirNext-Heavy"
    static let fontBold    = "AvenirNext-Bold"
    static let fontMedium  = "AvenirNext-Medium"
    static let fontRegular = "AvenirNext-Regular"

    // Z-positions
    static let zBackground: CGFloat = -10
    static let zCard:       CGFloat = 0
    static let zContent:    CGFloat = 10
    static let zHUD:        CGFloat = 20
    static let zOverlay:    CGFloat = 30
    static let zAlert:      CGFloat = 40
    static let zParticle:   CGFloat = 50
}
