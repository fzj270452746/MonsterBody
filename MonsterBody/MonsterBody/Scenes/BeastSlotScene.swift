import SpriteKit
import UIKit

// MARK: - BeastSlotScene: 3×1 Monster Slot
final class BeastSlotScene: SKScene {
    private var reelSpindles: [BeastReelSpindle] = []
    private var spinButton: LuminesButton!
    private var multiplierPicker: MultiplierPicker!
    private var vaultHUD: VaultCounter!
    private var resultLabel: SKLabelNode!
    private var costLabel: SKLabelNode!
    private var isSpinning = false
    private var unlockedBeasts: [BeastBlueprint] = []

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#1A1A2E")
        unlockedBeasts = BeastRoster.allBeasts.filter {
            TroveKeeper.shared.isBeastEnshrined($0)
        }
        buildBackground()
        buildHeader()
        buildMonsterMachine()
        buildControls()
        buildHUD()
        buildBackButton()
        TroveKeeper.shared.hasPlayedBeastSlot = true
        CipherEngine.shared.auguryCheck(event: .beastSlotPlayed)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard let view = view else { return }
        removeAllChildren()
        reelSpindles.removeAll()
        didMove(to: view)
    }

    private func buildBackground() {
        let aurora = AuroraLayer(size: size,
                                 topColor: UIColor(hex: "#1A0A2E"),
                                 bottomColor: UIColor(hex: "#0D0D1A"))
        aurora.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(aurora)

        let orb = SKSpriteNode(texture: .radialGlow(size: CGSize(width: 280, height: 280),
                                                    color: UIColor(hex: "#FFA500")),
                               size: CGSize(width: 280, height: 280))
        orb.alpha = 0.12
        orb.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        orb.zPosition = GlyphVault.zBackground + 1
        addChild(orb)
    }

    private func buildHeader() {
        let titleNode = SKLabelNode(text: "MONSTER SLOT")
        titleNode.fontName = GlyphVault.fontHeavy
        titleNode.fontSize = adaptiveFont(28)
        titleNode.fontColor = .white
        titleNode.horizontalAlignmentMode = .center
        titleNode.position = CGPoint(x: size.width / 2, y: size.height - safeTop() - 80)
        titleNode.zPosition = GlyphVault.zContent
        addChild(titleNode)

        let sub = SKLabelNode(text: "\(unlockedBeasts.count) monsters unlocked")
        sub.fontName = GlyphVault.fontRegular
        sub.fontSize = adaptiveFont(13)
        sub.fontColor = UIColor(hex: "#FFD700")
        sub.horizontalAlignmentMode = .center
        sub.position = CGPoint(x: size.width / 2, y: size.height - safeTop() - 103)
        sub.zPosition = GlyphVault.zContent
        addChild(sub)
    }

    private func buildMonsterMachine() {
        let reelCount = 3
        let machineW = min(size.width * 0.92, 355)
        let reelW = (machineW - CGFloat(reelCount + 1) * 10) / CGFloat(reelCount)
        let reelH = reelW * 1.1
        let machineH = reelH + 32
        let machineY = size.height * 0.55
        let machineX = size.width / 2

        let panel = GlassPanel(size: CGSize(width: machineW + 20, height: machineH))
        panel.position = CGPoint(x: machineX, y: machineY)
        panel.zPosition = GlyphVault.zCard
        addChild(panel)

        let startX = machineX - machineW / 2 + reelW / 2 + 5
        for i in 0..<reelCount {
            let x = startX + CGFloat(i) * (reelW + 10)
            let sz = CGSize(width: reelW, height: reelH)
            let reel = BeastReelSpindle(symbolSize: sz, beasts: unlockedBeasts)
            reel.position = CGPoint(x: x, y: machineY)
            reel.zPosition = GlyphVault.zContent
            addChild(reel)
            reelSpindles.append(reel)
        }

        resultLabel = SKLabelNode(text: "")
        resultLabel.fontName = GlyphVault.fontBold
        resultLabel.fontSize = adaptiveFont(17)
        resultLabel.fontColor = UIColor(hex: "#FFD700")
        resultLabel.horizontalAlignmentMode = .center
        resultLabel.position = CGPoint(x: size.width / 2, y: machineY - machineH / 2 - 32)
        resultLabel.zPosition = GlyphVault.zContent
        addChild(resultLabel)
    }

    private func buildControls() {
        let controlY = size.height * 0.22

        multiplierPicker = MultiplierPicker(choices: GlyphVault.beastSlotMultiplierChoices)
        multiplierPicker.position = CGPoint(x: size.width / 2, y: controlY + 58)
        multiplierPicker.zPosition = GlyphVault.zContent
        addChild(multiplierPicker)

        costLabel = SKLabelNode(text: "Cost: 200 🪙")
        costLabel.fontName = GlyphVault.fontMedium
        costLabel.fontSize = adaptiveFont(13)
        costLabel.fontColor = UIColor(hex: "#FFD700")
        costLabel.horizontalAlignmentMode = .center
        costLabel.position = CGPoint(x: size.width / 2, y: controlY + 28)
        costLabel.zPosition = GlyphVault.zContent
        addChild(costLabel)

        multiplierPicker.onMultiplierChanged = { [weak self] mult in
            guard let self = self else { return }
            let cost = GlyphVault.beastSlotBaseWager * mult
            self.costLabel.text = "Cost: \(cost) 🪙"
        }

        let btnW = min(size.width * 0.7, 260)
        spinButton = LuminesButton(title: "SPIN", size: CGSize(width: btnW, height: 58),
                                   variant: .gold, fontSize: 22)
        spinButton.position = CGPoint(x: size.width / 2, y: controlY - 12)
        spinButton.zPosition = GlyphVault.zContent
        spinButton.onTap = { [weak self] in self?.initiateMonsterSpin() }
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
    private func initiateMonsterSpin() {
        guard !isSpinning else { return }
        let mult = multiplierPicker.currentMultiplier
        let wager = GlyphVault.beastSlotBaseWager * mult
        let trove = TroveKeeper.shared

        guard trove.burnWager(wager) else {
            let alert = SpectralAlert(style: .warning, title: "Not Enough Coins",
                                      message: "You need \(wager) coins to spin.\nLower your multiplier or earn more coins!",
                                      buttonTitle: "OK", sceneSize: size)
            addChild(alert)
            return
        }

        isSpinning = true
        spinButton.isEnabled = false
        resultLabel.text = ""
        vaultHUD.refreshBalance(trove.vaultBalance)

        let (beastResults, outcome) = CipherEngine.shared.detonateBeastReel(
            availableBeasts: unlockedBeasts, wager: wager)

        trove.totalSpinCount += 1
        CipherEngine.shared.auguryCheck(event: .spinPerformed)

        var completedCount = 0
        for (i, reel) in reelSpindles.enumerated() {
            let targetBeast = beastResults.count > i ? beastResults[i] : unlockedBeasts[0]
            let delay = Double(i) * GlyphVault.reelStaggerDelay
            reel.igniteSpindle(targetBeast: targetBeast, delay: delay) { [weak self] in
                completedCount += 1
                if completedCount == self?.reelSpindles.count {
                    self?.processMonsterOutcome(outcome, wager: wager)
                }
            }
        }
    }

    private func processMonsterOutcome(_ outcome: BeastSlotOutcome, wager: Int) {
        let trove = TroveKeeper.shared

        switch outcome {
        case .tripleMatch(let beast, _, let reward):
            trove.harvestTokens(reward)
            vaultHUD.refreshBalance(trove.vaultBalance)
            reelSpindles.forEach { $0.celebrateWin() }
            resultLabel.text = "\(beast.displayName) ×3!\n+\(reward) coins!"
            resultLabel.fontColor = UIColor(hex: "#FFD700")
            CipherEngine.shared.auguryCheck(event: .coinHarvested(amount: reward))
            CipherEngine.shared.auguryCheck(event: .balanceChanged(newBalance: trove.vaultBalance))
            spawnGoldRain()

            let alert = SpectralAlert(style: .win, title: "🏆 Triple Match!",
                                      message: "\(beast.displayName) × 3!\nYou won \(reward) coins!",
                                      buttonTitle: "Collect \(reward) 🪙", sceneSize: size)
            addChild(alert)
            if #available(iOS 13.0, *) { UINotificationFeedbackGenerator().notificationOccurred(.success) }

        case .noMatch:
            resultLabel.text = "No match. Try again!"
            resultLabel.fontColor = SKColor(white: 1, alpha: 0.5)
            if #available(iOS 13.0, *) { UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.6) }
        }

        isSpinning = false
        spinButton.isEnabled = true
    }

    private func spawnGoldRain() {
        for i in 0..<18 {
            let coin = SKLabelNode(text: ["🪙", "💰", "💎", "⭐"].randomElement()!)
            coin.fontSize = CGFloat.random(in: 20...34)
            coin.position = CGPoint(x: CGFloat.random(in: 40...(size.width - 40)), y: size.height * 0.7)
            coin.zPosition = GlyphVault.zParticle
            addChild(coin)
            coin.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.06),
                SKAction.group([
                    SKAction.moveBy(x: CGFloat.random(in: -50...50), y: -CGFloat.random(in: 200...450), duration: 1.5),
                    SKAction.fadeOut(withDuration: 1.5)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }

    private func adaptiveFont(_ base: CGFloat) -> CGFloat { max(base * size.width / 390, base * 0.75) }
    private func safeTop() -> CGFloat { view?.safeAreaInsets.top ?? 44 }
}

// MARK: - BeastReelSpindle: Monster-image reel
final class BeastReelSpindle: SKNode {
    private let symbolSize: CGSize
    private var beasts: [BeastBlueprint]
    private var stripContainer: SKNode!
    private var maskNode: SKCropNode!
    private(set) var currentBeast: BeastBlueprint?
    var isSpinning = false

    init(symbolSize: CGSize, beasts: [BeastBlueprint]) {
        self.symbolSize = symbolSize
        self.beasts = beasts.isEmpty ? BeastRoster.allBeasts : beasts
        super.init()
        buildReel()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildReel() {
        let maskShape = SKShapeNode(rectOf: CGSize(width: symbolSize.width + 4,
                                                   height: symbolSize.height + 4),
                                    cornerRadius: 16)
        maskShape.fillColor = .white
        let mask = SKCropNode()
        mask.maskNode = maskShape
        maskNode = mask
        addChild(mask)

        let border = SKShapeNode(rectOf: CGSize(width: symbolSize.width + 8,
                                                height: symbolSize.height + 8),
                                 cornerRadius: 18)
        border.fillColor = .clear
        border.strokeColor = SKColor(white: 1, alpha: 0.25)
        border.lineWidth = 2
        addChild(border)

        let bg = SKShapeNode(rectOf: CGSize(width: symbolSize.width + 4, height: symbolSize.height + 4),
                             cornerRadius: 16)
        bg.fillColor = UIColor(hex: "#0D1117")
        bg.strokeColor = .clear
        bg.zPosition = -1
        mask.addChild(bg)

        stripContainer = SKNode()
        mask.addChild(stripContainer)
        populateStrip()
    }

    private func populateStrip() {
        stripContainer.removeAllChildren()
        let loopedBeasts = beasts + beasts + beasts
        let startY = CGFloat(loopedBeasts.count / 2) * symbolSize.height

        for (i, beast) in loopedBeasts.enumerated() {
            let node = buildBeastNode(beast: beast)
            node.position = CGPoint(x: 0, y: startY - CGFloat(i) * symbolSize.height)
            stripContainer.addChild(node)
        }
    }

    private func buildBeastNode(beast: BeastBlueprint) -> SKSpriteNode {
        let sz = CGSize(width: symbolSize.width - 12, height: symbolSize.height - 12)
        if let img = UIImage(named: beast.assetName) {
            return SKSpriteNode(texture: SKTexture(image: img), size: sz)
        }
        let placeholder = SKSpriteNode(color: beast.rarity.glowColor.withAlphaComponent(0.3), size: sz)
        let lbl = SKLabelNode(text: "👾")
        lbl.fontSize = 32
        lbl.verticalAlignmentMode = .center
        placeholder.addChild(lbl)
        return placeholder
    }

    func igniteSpindle(targetBeast: BeastBlueprint, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        guard !isSpinning else { return }
        isSpinning = true
        currentBeast = targetBeast

        let totalItems = beasts.count * 3
        let totalHeight = CGFloat(totalItems) * symbolSize.height
        let targetIdx = (beasts.count) + (beasts.firstIndex(where: { $0.identifier == targetBeast.identifier }) ?? 0)
        let landingY = CGFloat(totalItems / 2) * symbolSize.height
                       - CGFloat(targetIdx) * symbolSize.height + symbolSize.height / 2
        let spinDuration = GlyphVault.reelSpinDuration + delay * 0.3

        let fullSpin = SKAction.moveBy(x: 0, y: -totalHeight * 1.5, duration: spinDuration * 0.65)
        fullSpin.timingMode = .easeIn
        let slowDown = SKAction.move(to: CGPoint(x: 0, y: landingY), duration: spinDuration * 0.35)
        slowDown.timingMode = .easeOut
        let reset = SKAction.move(to: CGPoint(x: 0, y: CGFloat(totalItems / 2) * symbolSize.height / 2), duration: 0)

        stripContainer.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            reset,
            fullSpin,
            slowDown
        ])) { [weak self] in
            self?.isSpinning = false
            completion?()
        }
    }

    func celebrateWin() {
        let jitter = SKAction.sequence([
            SKAction.moveBy(x: -3, y: 0, duration: 0.04),
            SKAction.moveBy(x: 6,  y: 0, duration: 0.04),
            SKAction.moveBy(x: -6, y: 0, duration: 0.04),
            SKAction.moveBy(x: 3,  y: 0, duration: 0.04)
        ])
        run(SKAction.repeat(jitter, count: 3))
    }
}

// MARK: - MultiplierPicker: Select bet multiplier
final class MultiplierPicker: SKNode {
    private var buttons: [LuminesButton] = []
    private var selectedIndex = 0
    private let choices: [Int]
    private(set) var currentMultiplier: Int
    var onMultiplierChanged: ((Int) -> Void)?

    init(choices: [Int]) {
        self.choices = choices
        self.currentMultiplier = choices.first ?? 1
        super.init()
        buildPicker()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildPicker() {
        let btnW: CGFloat = 58
        let gap: CGFloat = 8
        let totalW = CGFloat(choices.count) * btnW + CGFloat(choices.count - 1) * gap
        let startX = -totalW / 2 + btnW / 2

        // Label
        let lbl = SKLabelNode(text: "MULTIPLIER")
        lbl.fontName = GlyphVault.fontMedium
        lbl.fontSize = 10
        lbl.fontColor = SKColor(white: 1, alpha: 0.5)
        lbl.horizontalAlignmentMode = .center
        lbl.position = CGPoint(x: 0, y: 28)
        addChild(lbl)

        for (i, mult) in choices.enumerated() {
            let x = startX + CGFloat(i) * (btnW + gap)
            let variant: LuminesButton.Variant = i == 0 ? .gold : .ghost
            let btn = LuminesButton(title: "×\(mult)", size: CGSize(width: btnW, height: 38),
                                    variant: variant, fontSize: 14)
            btn.position = CGPoint(x: x, y: 0)
            btn.onTap = { [weak self] in self?.selectMultiplier(index: i) }
            addChild(btn)
            buttons.append(btn)
        }
    }

    private func selectMultiplier(index: Int) {
        selectedIndex = index
        currentMultiplier = choices[index]

        for (i, btn) in buttons.enumerated() {
            // Recreate button style
            _ = i == index  // visual feedback via scale
            btn.run(i == index ?
                SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.08), SKAction.scale(to: 1.0, duration: 0.06)]) :
                SKAction.scale(to: 1.0, duration: 0.05)
            )
        }
        onMultiplierChanged?(currentMultiplier)
    }
}
