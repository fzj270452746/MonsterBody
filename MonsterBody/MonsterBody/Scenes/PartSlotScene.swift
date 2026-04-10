import SpriteKit
import UIKit

// MARK: - PartSelectScene: Choose a body part to play
final class PartSelectScene: SKScene {
    private var vaultHUD: VaultCounter!

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#1A1A2E")
        buildBackground()
        buildHeader()
        buildPartGrid()
        buildHUD()
        buildBackButton()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard let view = view else { return }
        removeAllChildren()
        didMove(to: view)
    }

    private func buildBackground() {
        let aurora = AuroraLayer(size: size,
                                 topColor: UIColor(hex: "#1A1A2E"),
                                 bottomColor: UIColor(hex: "#0D0D1A"))
        aurora.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(aurora)
    }

    private func buildHeader() {
        let titleNode = SKLabelNode(text: "Choose a Part")
        titleNode.fontName = GlyphVault.fontHeavy
        titleNode.fontSize = adaptiveFont(28)
        titleNode.fontColor = .white
        titleNode.horizontalAlignmentMode = .center
        titleNode.position = CGPoint(x: size.width / 2, y: size.height - safeTop() - 80)
        titleNode.zPosition = GlyphVault.zContent
        addChild(titleNode)

        let sub = SKLabelNode(text: "Match 3 symbols to win big!")
        sub.fontName = GlyphVault.fontRegular
        sub.fontSize = adaptiveFont(13)
        sub.fontColor = SKColor(white: 1, alpha: 0.55)
        sub.horizontalAlignmentMode = .center
        sub.position = CGPoint(x: size.width / 2, y: size.height - safeTop() - 112)
        sub.zPosition = GlyphVault.zContent
        addChild(sub)
    }

    private func buildPartGrid() {
        let parts = BodyPartCategory.allCases
        let cols = 2
        let rows = Int(ceil(Double(parts.count) / Double(cols)))

        let cardW = (size.width - 56) / CGFloat(cols)
        let cardH: CGFloat = adaptiveCardH()
        let startX = 28 + cardW / 2
        let topY = size.height - safeTop() - 210
        let gapY: CGFloat = 14

        let trove = TroveKeeper.shared

        for (i, part) in parts.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = startX + CGFloat(col) * (cardW + 12)
            let y = topY - CGFloat(row) * (cardH + gapY)

            let isUnlocked = trove.isPartUnlocked(part)
            let card = buildPartCard(part: part, size: CGSize(width: cardW - 8, height: cardH),
                                     unlocked: isUnlocked)
            card.position = CGPoint(x: x, y: y)
            card.zPosition = GlyphVault.zContent
            addChild(card)

            if isUnlocked {
                card.onTap = { [weak self] in self?.navigateToSlot(part: part) }
            } else {
                card.onTap = { [weak self] in self?.showUnlockPrompt(for: part) }
            }
        }
    }

    private func buildPartCard(part: BodyPartCategory, size: CGSize, unlocked: Bool) -> LuminesButton {
        let variant: LuminesButton.Variant = unlocked ? .primary : .ghost
        let card = LuminesButton(title: "", size: size, variant: variant)

        // Sample image: first symbol of the part
        let assetName = "\(part.rawValue)-1"
        if let img = UIImage(named: assetName) {
            let imgNode = SKSpriteNode(texture: SKTexture(image: img),
                                       size: CGSize(width: size.height * 0.38, height: size.height * 0.38))
            imgNode.position = CGPoint(x: 0, y: size.height * 0.2)
            imgNode.zPosition = 3
            imgNode.isUserInteractionEnabled = false
            card.addChild(imgNode)
        }

        // Part name
        let nameLabel = SKLabelNode(text: part.displayName.uppercased())
        nameLabel.fontName = GlyphVault.fontBold
        nameLabel.fontSize = adaptiveFont(13)
        nameLabel.fontColor = unlocked ? .white : SKColor(white: 1, alpha: 0.4)
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: 0, y: -size.height * 0.12)
        nameLabel.zPosition = 3
        nameLabel.isUserInteractionEnabled = false
        card.addChild(nameLabel)

        // Multiplier badge
        let multLabel = SKLabelNode(text: "×\(part.rewardMultiplier)")
        multLabel.fontName = GlyphVault.fontBold
        multLabel.fontSize = adaptiveFont(12)
        multLabel.fontColor = UIColor(hex: "#FFD700")
        multLabel.horizontalAlignmentMode = .center
        multLabel.verticalAlignmentMode = .center
        multLabel.position = CGPoint(x: 0, y: -size.height * 0.30)
        multLabel.zPosition = 3
        multLabel.isUserInteractionEnabled = false
        card.addChild(multLabel)

        // Lock overlay
        if !unlocked {
            let lockLabel = SKLabelNode(text: "🔒")
            lockLabel.fontSize = 20
            lockLabel.verticalAlignmentMode = .center
            lockLabel.horizontalAlignmentMode = .center
            lockLabel.position = CGPoint(x: size.width * 0.32, y: size.height * 0.32)
            lockLabel.zPosition = 4
            lockLabel.isUserInteractionEnabled = false
            card.addChild(lockLabel)

            let costLabel = SKLabelNode(text: "\(part.unlockThreshold) 🪙")
            costLabel.fontName = GlyphVault.fontMedium
            costLabel.fontSize = adaptiveFont(11)
            costLabel.fontColor = UIColor(hex: "#FFD700")
            costLabel.horizontalAlignmentMode = .center
            costLabel.verticalAlignmentMode = .center
            costLabel.position = CGPoint(x: 0, y: -size.height * 0.44)
            costLabel.zPosition = 4
            costLabel.isUserInteractionEnabled = false
            card.addChild(costLabel)
        }

        return card
    }

    private func showUnlockPrompt(for part: BodyPartCategory) {
        let trove = TroveKeeper.shared
        let cost = part.unlockThreshold
        let balance = trove.vaultBalance

        if balance >= cost {
            let alert = SpectralAlert(
                style: .info,
                title: "Unlock \(part.displayName)?",
                message: "Spend \(cost) coins to unlock the \(part.displayName) slot?\n\nYour balance: \(balance) coins",
                buttonTitle: "Unlock! (-\(cost) 🪙)",
                sceneSize: size
            )
            alert.onDismiss = { [weak self] in
                if trove.burnWager(cost) {
                    trove.inscribePartUnlock(part)
                    CipherEngine.shared.auguryCheck(event: .partUnlocked(part: part))
                    CipherEngine.shared.auguryCheck(event: .balanceChanged(newBalance: trove.vaultBalance))
                    self?.vaultHUD.refreshBalance(trove.vaultBalance)
                    self?.removeAllChildren()
                    self?.didMove(to: (self?.view)!)
                }
            }
            addChild(alert)
        } else {
            let needed = cost - balance
            let alert = SpectralAlert(
                style: .warning,
                title: "Not Enough Coins",
                message: "You need \(needed) more coins to unlock \(part.displayName).\n\nKeep spinning to earn more!",
                buttonTitle: "OK",
                sceneSize: size
            )
            addChild(alert)
        }
    }

    private func buildHUD() {
        vaultHUD = VaultCounter(width: min(size.width * 0.45, 155))
        vaultHUD.position = CGPoint(x: size.width / 2, y: size.height - safeTop() - 22)
        vaultHUD.zPosition = GlyphVault.zHUD
        addChild(vaultHUD)
        vaultHUD.refreshBalance(TroveKeeper.shared.vaultBalance, animated: false)
    }

    private func buildBackButton() {
        let btn = LuminesButton(title: "‹  Back", size: CGSize(width: 100, height: 40), variant: .ghost, fontSize: 16)
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

    private func navigateToSlot(part: BodyPartCategory) {
        let scene = PartSlotScene(size: size, part: part)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .push(with: .left, duration: GlyphVault.sceneTransitionDuration))
    }

    private func adaptiveFont(_ base: CGFloat) -> CGFloat { max(base * size.width / 390, base * 0.75) }
    private func adaptiveCardH() -> CGFloat {
        let h = size.height
        if h > 900 { return 150 }
        if h > 750 { return 130 }
        return 115
    }
    private func safeTop() -> CGFloat { view?.safeAreaInsets.top ?? 44 }
}

// MARK: - PartSlotScene: 3×1 Body Part Slot Game
final class PartSlotScene: SKScene {
    private let selectedPart: BodyPartCategory
    private var reelSpindles: [ReelSpindle] = []
    private var spinButton: LuminesButton!
    private var wagerPicker: WagerPicker!
    private var vaultHUD: VaultCounter!
    private var resultLabel: SKLabelNode!
    private var isSpinning = false

    init(size: CGSize, part: BodyPartCategory) {
        self.selectedPart = part
        super.init(size: size)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#1A1A2E")
        buildBackground()
        buildHeader()
        buildReelMachine()
        buildControls()
        buildHUD()
        buildBackButton()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard let view = view else { return }
        removeAllChildren()
        reelSpindles.removeAll()
        didMove(to: view)
    }

    // MARK: - Build
    private func buildBackground() {
        let (c1, c2) = selectedPart.gradientColors
        let aurora = AuroraLayer(size: size, topColor: c1.withAlphaComponent(0.2), bottomColor: UIColor(hex: "#0D0D1A"))
        aurora.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(aurora)
    }

    private func buildHeader() {
        let titleNode = SKLabelNode(text: selectedPart.displayName.uppercased())
        titleNode.fontName = GlyphVault.fontHeavy
        titleNode.fontSize = adaptiveFont(28)
        titleNode.fontColor = .white
        titleNode.horizontalAlignmentMode = .center
        titleNode.position = CGPoint(x: size.width / 2, y: size.height - safeTop() - 80)
        titleNode.zPosition = GlyphVault.zContent
        addChild(titleNode)

        let multLabel = SKLabelNode(text: "Match 3 = ×\(selectedPart.rewardMultiplier) your bet!")
        multLabel.fontName = GlyphVault.fontMedium
        multLabel.fontSize = adaptiveFont(13)
        multLabel.fontColor = UIColor(hex: "#FFD700")
        multLabel.horizontalAlignmentMode = .center
        multLabel.position = CGPoint(x: size.width / 2, y: size.height - safeTop() - 103)
        multLabel.zPosition = GlyphVault.zContent
        addChild(multLabel)
    }

    private func buildReelMachine() {
        let reelCount = 3
        let machineW = min(size.width * 0.88, 340)
        let reelW = (machineW - CGFloat(reelCount + 1) * 10) / CGFloat(reelCount)
        let reelH = reelW * 1.05

        let machineH = reelH + 32
        let machineY = size.height * 0.54
        let machineX = size.width / 2

        // Machine background panel
        let machinePanel = GlassPanel(size: CGSize(width: machineW + 20, height: machineH))
        machinePanel.position = CGPoint(x: machineX, y: machineY)
        machinePanel.zPosition = GlyphVault.zCard
        addChild(machinePanel)

        // Win line indicator
        let winLine = SKShapeNode(rectOf: CGSize(width: machineW, height: 2))
        winLine.fillColor = UIColor(hex: "#FFD700").withAlphaComponent(0.4)
        winLine.strokeColor = .clear
        winLine.position = CGPoint(x: machineX, y: machineY)
        winLine.zPosition = GlyphVault.zContent - 1
        addChild(winLine)

        let startX = machineX - machineW / 2 + reelW / 2 + 5
        for i in 0..<reelCount {
            let x = startX + CGFloat(i) * (reelW + 10)
            let symbolSize = CGSize(width: reelW, height: reelH)
            let reel = ReelSpindle(symbolSize: symbolSize, part: selectedPart)
            reel.position = CGPoint(x: x, y: machineY)
            reel.zPosition = GlyphVault.zContent
            addChild(reel)
            reelSpindles.append(reel)
        }

        // Result label
        resultLabel = SKLabelNode(text: "")
        resultLabel.fontName = GlyphVault.fontBold
        resultLabel.fontSize = adaptiveFont(18)
        resultLabel.fontColor = UIColor(hex: "#FFD700")
        resultLabel.horizontalAlignmentMode = .center
        resultLabel.position = CGPoint(x: size.width / 2, y: machineY - machineH / 2 - 32)
        resultLabel.zPosition = GlyphVault.zContent
        addChild(resultLabel)
    }

    private func buildControls() {
        let controlY = size.height * 0.22
        let btnW = min(size.width * 0.7, 260)

        wagerPicker = WagerPicker()
        wagerPicker.position = CGPoint(x: size.width / 2, y: controlY + 55)
        wagerPicker.zPosition = GlyphVault.zContent
        addChild(wagerPicker)

        spinButton = LuminesButton(title: "SPIN", size: CGSize(width: btnW, height: 58),
                                   variant: .primary, fontSize: 22)
        spinButton.position = CGPoint(x: size.width / 2, y: controlY)
        spinButton.zPosition = GlyphVault.zContent
        spinButton.onTap = { [weak self] in self?.initiateSpinSequence() }
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
        let btn = LuminesButton(title: "‹  Parts", size: CGSize(width: 110, height: 40), variant: .ghost, fontSize: 15)
        btn.position = CGPoint(x: 66, y: size.height - safeTop() - 22)
        btn.zPosition = GlyphVault.zHUD
        btn.onTap = { [weak self] in
            guard let self = self else { return }
            let scene = PartSelectScene(size: self.size)
            scene.scaleMode = self.scaleMode
            self.view?.presentScene(scene, transition: .push(with: .right, duration: GlyphVault.sceneTransitionDuration))
        }
        addChild(btn)
    }

    // MARK: - Spin Logic
    private func initiateSpinSequence() {
        guard !isSpinning else { return }
        let wager = wagerPicker.currentWager
        let trove = TroveKeeper.shared

        guard trove.burnWager(wager) else {
            showInsufficientCoinsAlert()
            return
        }

        isSpinning = true
        spinButton.isEnabled = false
        resultLabel.text = ""
        vaultHUD.refreshBalance(trove.vaultBalance)

        // Run game logic
        let (symbols, outcome) = CipherEngine.shared.detonatePartReel(part: selectedPart, wager: wager)
        trove.totalSpinCount += 1
        CipherEngine.shared.auguryCheck(event: .spinPerformed)

        // Animate reels
        for (i, reel) in reelSpindles.enumerated() {
            let target = symbols[i]
            let delay = Double(i) * GlyphVault.reelStaggerDelay
            reel.igniteSpindle(targetIndex: target, delay: delay) { [weak self] in
                if i == self!.reelSpindles.count - 1 {
                    self?.processSpinOutcome(outcome, wager: wager)
                }
            }
        }
    }

    private func processSpinOutcome(_ outcome: PartSlotOutcome, wager: Int) {
        let trove = TroveKeeper.shared

        switch outcome {
        case .tripleMatch(let part, _, let reward):
            trove.harvestTokens(reward)
            vaultHUD.refreshBalance(trove.vaultBalance)

            // Win effects
            reelSpindles.forEach { $0.celebrateWin() }
            reelSpindles.forEach { $0.highlightCenter() }

            resultLabel.text = "+\(reward) coins! ×\(part.rewardMultiplier)"
            resultLabel.fontColor = UIColor(hex: "#FFD700")
            resultLabel.run(SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.15),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]))

            // Achievement checks
            if wager == GlyphVault.maximumWager {
                trove.hasWonMaxWager = true
                CipherEngine.shared.auguryCheck(event: .maxWagerWon)
            }
            CipherEngine.shared.auguryCheck(event: .coinHarvested(amount: reward))
            CipherEngine.shared.auguryCheck(event: .balanceChanged(newBalance: trove.vaultBalance))

            // Win coin rain
            spawnCoinRain()

        case .doubleMatch(let part, _, let reward):
            trove.harvestTokens(reward)
            vaultHUD.refreshBalance(trove.vaultBalance)

            reelSpindles.forEach { $0.celebrateWin() }

            resultLabel.text = "2 Match! +\(reward) coins ×\(max(part.rewardMultiplier - 1, 1))"
            resultLabel.fontColor = UIColor(hex: "#A8E6CF")
            resultLabel.run(SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 0.12),
                SKAction.scale(to: 1.0, duration: 0.08)
            ]))

            CipherEngine.shared.auguryCheck(event: .coinHarvested(amount: reward))
            CipherEngine.shared.auguryCheck(event: .balanceChanged(newBalance: trove.vaultBalance))

        case .noMatch:
            resultLabel.text = "Try again!"
            resultLabel.fontColor = SKColor(white: 1, alpha: 0.5)
        }

        isSpinning = false
        spinButton.isEnabled = true
    }

    private func showInsufficientCoinsAlert() {
        let alert = SpectralAlert(
            style: .warning,
            title: "Not Enough Coins",
            message: "You don't have enough coins to spin.\n\nLower your bet or try another mode.",
            buttonTitle: "OK",
            sceneSize: size
        )
        addChild(alert)
    }

    private func spawnCoinRain() {
        for i in 0..<12 {
            let coin = SKLabelNode(text: "🪙")
            coin.fontSize = CGFloat.random(in: 18...30)
            coin.position = CGPoint(x: CGFloat.random(in: 40...(size.width - 40)),
                                    y: size.height * 0.75)
            coin.zPosition = GlyphVault.zParticle
            addChild(coin)
            let fallDist = CGFloat.random(in: 200...400)
            coin.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.07),
                SKAction.group([
                    SKAction.moveBy(x: CGFloat.random(in: -30...30), y: -fallDist, duration: 1.2),
                    SKAction.fadeOut(withDuration: 1.2)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }

    private func adaptiveFont(_ base: CGFloat) -> CGFloat { max(base * size.width / 390, base * 0.75) }
    private func safeTop() -> CGFloat { view?.safeAreaInsets.top ?? 44 }
}
