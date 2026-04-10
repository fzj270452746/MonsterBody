import SpriteKit
import UIKit

// MARK: - ComboSlotScene: 6×1 Combination Slot
final class ComboSlotScene: SKScene {
    private var reelSpindles: [ReelSpindle] = []
    private var spinButton: LuminesButton!
    private var vaultHUD: VaultCounter!
    private var resultLabel: SKLabelNode!
    private var partLabels: [SKLabelNode] = []
    private var isSpinning = false

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#1A1A2E")
        buildBackground()
        buildHeader()
        buildHexReelMachine()
        buildControls()
        buildHUD()
        buildBackButton()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard let view = view else { return }
        removeAllChildren()
        reelSpindles.removeAll()
        partLabels.removeAll()
        didMove(to: view)
    }

    // MARK: - Background
    private func buildBackground() {
        let aurora = AuroraLayer(size: size,
                                 topColor: UIColor(hex: "#16213E"),
                                 bottomColor: UIColor(hex: "#0D0D1A"))
        aurora.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(aurora)

        let orb = SKSpriteNode(texture: .radialGlow(size: CGSize(width: 300, height: 300),
                                                    color: UIColor(hex: "#764BA2")),
                               size: CGSize(width: 300, height: 300))
        orb.alpha = 0.15
        orb.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        orb.zPosition = GlyphVault.zBackground + 1
        addChild(orb)
    }

    // MARK: - Header
    private func buildHeader() {
        let titleNode = SKLabelNode(text: "COMBO SLOT")
        titleNode.fontName = GlyphVault.fontHeavy
        titleNode.fontSize = adaptiveFont(28)
        titleNode.fontColor = .white
        titleNode.horizontalAlignmentMode = .center
        titleNode.position = CGPoint(x: size.width / 2, y: size.height - safeTop() - 80)
        titleNode.zPosition = GlyphVault.zContent
        addChild(titleNode)

        let sub = SKLabelNode(text: "Cost: 100 🪙  •  Match a Monster to win!")
        sub.fontName = GlyphVault.fontRegular
        sub.fontSize = adaptiveFont(12)
        sub.fontColor = UIColor(hex: "#FFD700")
        sub.horizontalAlignmentMode = .center
        sub.position = CGPoint(x: size.width / 2, y: size.height - safeTop() - 103)
        sub.zPosition = GlyphVault.zContent
        addChild(sub)
    }

    // MARK: - 6-Reel Machine
    private func buildHexReelMachine() {
        let parts = BodyPartCategory.allCases
        let cols = 3
        let rows = 2

        let machineW = min(size.width * 0.92, 350)
        let cellW = (machineW - CGFloat(cols + 1) * 8) / CGFloat(cols)
        let cellH = cellW * 0.95
        let machineH = CGFloat(rows) * (cellH + 30) + 20

        let machineY = size.height * 0.56
        let machineX = size.width / 2

        // Machine panel
        let panel = GlassPanel(size: CGSize(width: machineW + 24, height: machineH + 16))
        panel.position = CGPoint(x: machineX, y: machineY)
        panel.zPosition = GlyphVault.zCard
        addChild(panel)

        let startX = machineX - machineW / 2 + cellW / 2 + 4
        let topY = machineY + machineH / 2 - cellH / 2 - 16

        for (i, part) in parts.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = startX + CGFloat(col) * (cellW + 8)
            let y = topY - CGFloat(row) * (cellH + 30)

            // Part label above reel
            let partLbl = SKLabelNode(text: part.displayName)
            partLbl.fontName = GlyphVault.fontMedium
            partLbl.fontSize = adaptiveFont(10)
            partLbl.fontColor = SKColor(white: 1, alpha: 0.6)
            partLbl.horizontalAlignmentMode = .center
            partLbl.position = CGPoint(x: x, y: y + cellH / 2 + 12)
            partLbl.zPosition = GlyphVault.zContent + 1
            addChild(partLbl)
            partLabels.append(partLbl)

            // Reel
            let symbolSz = CGSize(width: cellW, height: cellH)
            let reel = ReelSpindle(symbolSize: symbolSz, part: part)
            reel.position = CGPoint(x: x, y: y)
            reel.zPosition = GlyphVault.zContent
            addChild(reel)
            reelSpindles.append(reel)
        }

        // Result label
        resultLabel = SKLabelNode(text: "")
        resultLabel.fontName = GlyphVault.fontBold
        resultLabel.fontSize = adaptiveFont(17)
        resultLabel.fontColor = UIColor(hex: "#FFD700")
        resultLabel.horizontalAlignmentMode = .center
        resultLabel.numberOfLines = 2
        resultLabel.preferredMaxLayoutWidth = size.width - 40
        resultLabel.position = CGPoint(x: size.width / 2, y: machineY - machineH / 2 - 34)
        resultLabel.zPosition = GlyphVault.zContent
        addChild(resultLabel)
    }

    // MARK: - Controls
    private func buildControls() {
        let btnW = min(size.width * 0.75, 280)
        spinButton = LuminesButton(title: "SPIN  (-100 🪙)",
                                   size: CGSize(width: btnW, height: 58),
                                   variant: .secondary, fontSize: 20)
        spinButton.position = CGPoint(x: size.width / 2, y: safeBottom() + 60)
        spinButton.zPosition = GlyphVault.zContent
        spinButton.onTap = { [weak self] in self?.initiateComboSpin() }
        addChild(spinButton)
    }

    private func buildHUD() {
        vaultHUD = VaultCounter(width: min(size.width * 0.45, 155))
        vaultHUD.position = CGPoint(x: size.width / 2, y: size.height - safeTop() - 22)
        vaultHUD.zPosition = GlyphVault.zHUD
        addChild(vaultHUD)
        vaultHUD.refreshBalance(TroveKeeper.shared.vaultBalance, animated: false)
    }

    private func buildBackButton() {
        let btn = LuminesButton(title: "‹  Back", size: CGSize(width: 100, height: 40), variant: .ghost, fontSize: 15)
        btn.position = CGPoint(x: 64, y: size.height - safeTop() - 22)
        btn.zPosition = GlyphVault.zHUD
        btn.onTap = { [weak self] in
            guard let self = self else { return }
            let scene = NexusScene(size: self.size)
            scene.scaleMode = self.scaleMode
            self.view?.presentScene(scene, transition: .push(with: .right, duration: GlyphVault.sceneTransitionDuration))
        }
        addChild(btn)
    }

    // MARK: - Spin Logic
    private func initiateComboSpin() {
        guard !isSpinning else { return }
        let trove = TroveKeeper.shared
        guard trove.burnWager(GlyphVault.comboSlotCost) else {
            showAlert(style: .warning, title: "Not Enough Coins",
                      message: "You need 100 coins to spin the Combo Slot.\nEarn more in Body Part Slot!")
            return
        }

        isSpinning = true
        spinButton.isEnabled = false
        resultLabel.text = ""
        vaultHUD.refreshBalance(trove.vaultBalance)

        let (combo, outcome) = CipherEngine.shared.detonateComboReel()
        trove.totalSpinCount += 1
        CipherEngine.shared.auguryCheck(event: .spinPerformed)

        // Animate each reel with stagger
        let parts = BodyPartCategory.allCases
        var completedCount = 0
        for (i, part) in parts.enumerated() {
            let targetSymbol = combo[part] ?? 1
            let delay = Double(i) * GlyphVault.reelStaggerDelay
            reelSpindles[i].igniteSpindle(targetIndex: targetSymbol, delay: delay) { [weak self] in
                completedCount += 1
                if completedCount == parts.count {
                    self?.processComboOutcome(outcome, combo: combo)
                }
            }
        }
    }

    private func processComboOutcome(_ outcome: ComboSlotOutcome, combo: [BodyPartCategory: Int]) {
        let trove = TroveKeeper.shared

        switch outcome {
        case .beastUnlocked(let beast, let isFirstTime, let reward):
            trove.harvestTokens(reward)
            vaultHUD.refreshBalance(trove.vaultBalance)

            if isFirstTime {
                trove.enshrineBeast(beast)
                let newlyEarned = CipherEngine.shared.auguryCheck(event: .beastEnshrined(beast: beast))
                trove.comboSlotWinCount += 1
                CipherEngine.shared.auguryCheck(event: .comboWon)
                showBeastUnlockAlert(beast: beast, reward: reward, isFirst: true, achievements: newlyEarned)
            } else {
                trove.comboSlotWinCount += 1
                CipherEngine.shared.auguryCheck(event: .comboWon)
                resultLabel.text = "\(beast.displayName) again!\n+\(reward) coins"
                resultLabel.fontColor = UIColor(hex: "#FFD700")
                reelSpindles.forEach { $0.celebrateWin() }
                spawnCelebrationParticles()
            }
            CipherEngine.shared.auguryCheck(event: .coinHarvested(amount: reward))
            CipherEngine.shared.auguryCheck(event: .balanceChanged(newBalance: trove.vaultBalance))

        case .sixMatchBonus(let reward):
            trove.harvestTokens(reward)
            trove.hasHitSixMatch = true
            vaultHUD.refreshBalance(trove.vaultBalance)
            CipherEngine.shared.auguryCheck(event: .sixMatchOccurred)
            CipherEngine.shared.auguryCheck(event: .coinHarvested(amount: reward))
            CipherEngine.shared.auguryCheck(event: .balanceChanged(newBalance: trove.vaultBalance))
            reelSpindles.forEach { $0.celebrateWin() }
            spawnCelebrationParticles()
            showAlert(style: .win, title: "🎉 Six Match Bonus!",
                      message: "All 6 reels matched!\nYou won \(reward) bonus coins!")

        case .noMatch:
            resultLabel.text = "No match. Keep spinning!"
            resultLabel.fontColor = SKColor(white: 1, alpha: 0.5)
        }

        isSpinning = false
        spinButton.isEnabled = true
    }

    private func showBeastUnlockAlert(beast: BeastBlueprint, reward: Int, isFirst: Bool, achievements: [TrophyScroll]) {
        // Build monster preview node
        let previewNode = SKNode()
        if let img = UIImage(named: beast.assetName) {
            let tex = SKTexture(image: img)
            let imgNode = SKSpriteNode(texture: tex, size: CGSize(width: 120, height: 120))
            imgNode.position = .zero
            previewNode.addChild(imgNode)
        }

        // Rarity badge
        let badge = SKLabelNode(text: beast.rarity.badgeText)
        badge.fontName = GlyphVault.fontBold
        badge.fontSize = 14
        badge.fontColor = beast.rarity.glowColor
        badge.horizontalAlignmentMode = .center
        badge.position = CGPoint(x: 0, y: -70)
        previewNode.addChild(badge)

        let rewardLbl = SKLabelNode(text: "+\(reward) 🪙")
        rewardLbl.fontName = GlyphVault.fontBold
        rewardLbl.fontSize = 18
        rewardLbl.fontColor = UIColor(hex: "#FFD700")
        rewardLbl.horizontalAlignmentMode = .center
        rewardLbl.position = CGPoint(x: 0, y: -92)
        previewNode.addChild(rewardLbl)

        let alert = SpectralAlert(
            style: .beastUnlock,
            title: "✨ \(beast.displayName) Unlocked!",
            message: "A new monster joins your collection!\nRarity: \(beast.rarity.displayName)",
            subview: previewNode,
            buttonTitle: "Amazing! (\(reward) coins)",
            sceneSize: size
        )
        addChild(alert)
        spawnCelebrationParticles()

        // Show achievement alerts after dismiss
        if !achievements.isEmpty {
            alert.onDismiss = { [weak self] in
                self?.showAchievementChain(achievements)
            }
        }
    }

    private func showAchievementChain(_ achievements: [TrophyScroll]) {
        guard !achievements.isEmpty else { return }
        var remaining = achievements
        let first = remaining.removeFirst()

        let alert = SpectralAlert(
            style: .achievement,
            title: "🎖 Achievement Unlocked!",
            message: "\(first.title)\n\(first.description)\n+\(first.tokenReward) bonus coins!",
            buttonTitle: "Claim!",
            sceneSize: size
        )
        alert.onDismiss = { [weak self] in
            self?.showAchievementChain(remaining)
        }
        addChild(alert)
    }

    private func showAlert(style: SpectralAlert.AlertStyle, title: String, message: String) {
        let alert = SpectralAlert(style: style, title: title, message: message,
                                  buttonTitle: "OK", sceneSize: size)
        addChild(alert)
    }

    private func spawnCelebrationParticles() {
        for i in 0..<20 {
            let shapes = ["⭐", "💫", "✨", "🌟", "💎"]
            let lbl = SKLabelNode(text: shapes.randomElement()!)
            lbl.fontSize = CGFloat.random(in: 16...28)
            lbl.position = CGPoint(x: CGFloat.random(in: 40...(size.width - 40)),
                                   y: size.height * 0.5)
            lbl.zPosition = GlyphVault.zParticle
            addChild(lbl)
            lbl.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.06),
                SKAction.group([
                    SKAction.moveBy(x: CGFloat.random(in: -60...60),
                                    y: CGFloat.random(in: 80...200), duration: 1.4),
                    SKAction.sequence([
                        SKAction.scale(to: 1.5, duration: 0.3),
                        SKAction.scale(to: 1.0, duration: 0.3),
                        SKAction.fadeOut(withDuration: 0.8)
                    ])
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }

    private func adaptiveFont(_ base: CGFloat) -> CGFloat { max(base * size.width / 390, base * 0.75) }
    private func safeTop() -> CGFloat { view?.safeAreaInsets.top ?? 44 }
    private func safeBottom() -> CGFloat { view?.safeAreaInsets.bottom ?? 34 }
}

// MARK: - AchievementTriggerEvent unlockMonster overload
extension CipherEngine {
    func auguryCheck(event: AchievementTriggerEvent, trove: TroveKeeper) -> [TrophyScroll] {
        return auguryCheck(event: event)
    }
}

// Convenience overload to accept monster count directly
private extension CipherEngine {
    // no-op: count is derived from TroveKeeper inside satisfiesCondition
}
