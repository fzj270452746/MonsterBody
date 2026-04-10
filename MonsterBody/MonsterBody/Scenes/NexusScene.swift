import SpriteKit
import UIKit

// MARK: - NexusScene: Main Hub / Home Screen
final class NexusScene: SKScene {
    private var vaultHUD: VaultCounter!
    private var logoNode: SKNode!
    private var buttonContainer: SKNode!

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        TroveKeeper.shared.bootstrapIfNeeded()
        backgroundColor = UIColor(hex: "#1A1A2E")
        buildBackground()
        buildLogo()
        buildMenuButtons()
        buildHUD()
        buildFooterNote()
        animateEntrance()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard let view = view else { return }
        removeAllChildren()
        didMove(to: view)
    }

    // MARK: - Build Background
    private func buildBackground() {
        let aurora = AuroraLayer(size: size,
                                 topColor: UIColor(hex: "#1A1A2E"),
                                 bottomColor: UIColor(hex: "#0D0D1A"))
        aurora.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(aurora)

        // Decorative gradient orbs
        addOrbDecor()
    }

    private func addOrbDecor() {
        let orb1 = buildOrbNode(radius: size.width * 0.35, color: UIColor(hex: "#667EEA"))
        orb1.position = CGPoint(x: size.width * 0.1, y: size.height * 0.75)
        addChild(orb1)

        let orb2 = buildOrbNode(radius: size.width * 0.28, color: UIColor(hex: "#FF6B6B"))
        orb2.position = CGPoint(x: size.width * 0.9, y: size.height * 0.3)
        addChild(orb2)

        let orb3 = buildOrbNode(radius: size.width * 0.2, color: UIColor(hex: "#4ECDC4"))
        orb3.position = CGPoint(x: size.width * 0.5, y: size.height * 0.88)
        addChild(orb3)
    }

    private func buildOrbNode(radius: CGFloat, color: UIColor) -> SKNode {
        let tex = SKTexture.radialGlow(size: CGSize(width: radius * 2, height: radius * 2), color: color)
        let node = SKSpriteNode(texture: tex, size: CGSize(width: radius * 2, height: radius * 2))
        node.alpha = 0.18
        node.zPosition = GlyphVault.zBackground + 2
        node.run(SKAction.hoverFloat(amount: 8, duration: 3.5))
        return node
    }

    // MARK: - Logo
    private func buildLogo() {
        logoNode = SKNode()
        logoNode.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        logoNode.zPosition = GlyphVault.zContent
        addChild(logoNode)

        // Main title
        let title = SKLabelNode(text: "MONSTER")
        title.fontName = GlyphVault.fontHeavy
        title.fontSize = adaptiveFontSize(base: 46)
        title.fontColor = .white
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: 24)
        logoNode.addChild(title)

        let subtitle = SKLabelNode(text: "BODY SLOT")
        subtitle.fontName = GlyphVault.fontBold
        subtitle.fontSize = adaptiveFontSize(base: 26)
        subtitle.fontColor = UIColor(hex: "#667EEA")
        subtitle.horizontalAlignmentMode = .center
        subtitle.position = CGPoint(x: 0, y: -16)
        logoNode.addChild(subtitle)

        // Decorative underline
        let line = SKShapeNode(rectOf: CGSize(width: 180, height: 3), cornerRadius: 1.5)
        line.fillColor = UIColor(hex: "#FFD700")
        line.strokeColor = .clear
        line.position = CGPoint(x: 0, y: -40)
        logoNode.addChild(line)

        // Floating emojis
        let emojis = ["👾", "🎰", "💎", "✨"]
        let xOffsets: [CGFloat] = [-110, -55, 55, 110]
        for (i, emoji) in emojis.enumerated() {
            let lbl = SKLabelNode(text: emoji)
            lbl.fontSize = 22
            lbl.position = CGPoint(x: xOffsets[i], y: -60)
            lbl.run(SKAction.hoverFloat(amount: 5, duration: 2.0 + Double(i) * 0.3))
            logoNode.addChild(lbl)
        }
    }

    // MARK: - Menu Buttons
    private func buildMenuButtons() {
        buttonContainer = SKNode()
        buttonContainer.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        buttonContainer.zPosition = GlyphVault.zContent
        addChild(buttonContainer)

        let btnWidth = min(size.width * 0.82, 320)
        let btnHeight: CGFloat = adaptiveBtnHeight()
        let gap: CGFloat = adaptiveBtnGap()

        let modes: [(title: String, subtitle: String, emoji: String, variant: LuminesButton.Variant, action: () -> Void)] = [
            ("Body Part Slot",    "3-reel • Match symbols to win",    "🎯", .primary,   { [weak self] in self?.navigateToPartSlot() }),
            ("Combo Slot",        "6-reel • Unlock Monsters",         "🌀", .secondary, { [weak self] in self?.navigateToComboSlot() }),
            ("Monster Slot",      "3-reel • Use your monsters",       "👾", .gold,      { [weak self] in self?.navigateToBeastSlot() }),
            ("My Collection",     "View unlocked monsters",           "📚", .ghost,     { [weak self] in self?.navigateToCodex() }),
            ("Achievements",      "Track your milestones",            "🏆", .ghost,     { [weak self] in self?.navigateToTrophyHall() }),
        ]

        for (i, mode) in modes.enumerated() {
            let y = CGFloat(modes.count / 2 - i) * (btnHeight + gap)
            let card = buildMenuCard(title: mode.title, subtitle: mode.subtitle,
                                     emoji: mode.emoji, variant: mode.variant,
                                     size: CGSize(width: btnWidth, height: btnHeight))
            card.position = CGPoint(x: 0, y: y)
            card.zPosition = GlyphVault.zContent + CGFloat(i)
            let idx = i
            card.onTap = {
                mode.action()
            }
            buttonContainer.addChild(card)
        }
    }

    private func buildMenuCard(title: String, subtitle: String, emoji: String,
                                variant: LuminesButton.Variant,
                                size: CGSize) -> LuminesButton {
        let card = LuminesButton(title: "", size: size, variant: variant)

        // Emoji
        let emNode = SKLabelNode(text: emoji)
        emNode.fontSize = size.height * 0.44
        emNode.verticalAlignmentMode = .center
        emNode.position = CGPoint(x: -size.width / 2 + size.height * 0.5, y: 4)
        emNode.zPosition = 3
        emNode.isUserInteractionEnabled = false
        card.addChild(emNode)

        // Title
        let titleNode = SKLabelNode(text: title)
        titleNode.fontName = GlyphVault.fontBold
        titleNode.fontSize = adaptiveFontSize(base: 17)
        titleNode.fontColor = .white
        titleNode.horizontalAlignmentMode = .left
        titleNode.verticalAlignmentMode = .center
        titleNode.position = CGPoint(x: -size.width / 2 + size.height + 8, y: 8)
        titleNode.zPosition = 3
        titleNode.isUserInteractionEnabled = false
        card.addChild(titleNode)

        let subNode = SKLabelNode(text: subtitle)
        subNode.fontName = GlyphVault.fontRegular
        subNode.fontSize = adaptiveFontSize(base: 12)
        subNode.fontColor = SKColor(white: 1, alpha: 0.6)
        subNode.horizontalAlignmentMode = .left
        subNode.verticalAlignmentMode = .center
        subNode.position = CGPoint(x: -size.width / 2 + size.height + 8, y: -10)
        subNode.zPosition = 3
        subNode.isUserInteractionEnabled = false
        card.addChild(subNode)

        // Arrow
        let arrow = SKLabelNode(text: "›")
        arrow.fontName = GlyphVault.fontBold
        arrow.fontSize = 22
        arrow.fontColor = SKColor(white: 1, alpha: 0.5)
        arrow.horizontalAlignmentMode = .center
        arrow.verticalAlignmentMode = .center
        arrow.position = CGPoint(x: size.width / 2 - 24, y: 0)
        arrow.zPosition = 3
        arrow.isUserInteractionEnabled = false
        card.addChild(arrow)

        return card
    }

    // MARK: - HUD
    private func buildHUD() {
        let hudWidth: CGFloat = min(size.width * 0.48, 160)
        vaultHUD = VaultCounter(width: hudWidth)
        vaultHUD.position = CGPoint(x: size.width / 2, y: size.height - safeAreaTop() - 30)
        vaultHUD.zPosition = GlyphVault.zHUD
        addChild(vaultHUD)
        vaultHUD.refreshBalance(TroveKeeper.shared.vaultBalance, animated: false)
    }

    private func buildFooterNote() {
        let note = SKLabelNode(text: "For entertainment purposes only • No real money involved")
        note.fontName = GlyphVault.fontRegular
        note.fontSize = 10
        note.fontColor = SKColor(white: 1, alpha: 0.3)
        note.horizontalAlignmentMode = .center
        note.position = CGPoint(x: size.width / 2, y: safeAreaBottom() + 12)
        note.zPosition = GlyphVault.zHUD
        addChild(note)
    }

    // MARK: - Entrance Animation
    private func animateEntrance() {
        guard let logo = logoNode, let btns = buttonContainer else { return }

        logo.alpha = 0
        logo.run(SKAction.fadeIn(withDuration: 0.5))

        btns.alpha = 0
        btns.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
    }

    // MARK: - Navigation
    private func navigateToPartSlot() {
        let scene = PartSelectScene(size: size)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .push(with: .left, duration: GlyphVault.sceneTransitionDuration))
    }

    private func navigateToComboSlot() {
        let scene = ComboSlotScene(size: size)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .push(with: .left, duration: GlyphVault.sceneTransitionDuration))
    }

    private func navigateToBeastSlot() {
        let trove = TroveKeeper.shared
        guard trove.enshrineCount >= GlyphVault.beastSlotMinimumBeasts else {
            let alert = SpectralAlert(
                style: .info,
                title: "Monster Slot Locked",
                message: "You need to unlock at least \(GlyphVault.beastSlotMinimumBeasts) monsters first!\n\nTry the Combo Slot to find them.",
                buttonTitle: "Got it!",
                sceneSize: size
            )
            addChild(alert)
            return
        }
        let scene = BeastSlotScene(size: size)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .push(with: .left, duration: GlyphVault.sceneTransitionDuration))
    }

    private func navigateToCodex() {
        guard let view = view else { return }
        let vc = CodexGallery()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        view.window?.rootViewController?.present(vc, animated: true)
    }

    private func navigateToTrophyHall() {
        guard let view = view else { return }
        let vc = TrophyHall()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        view.window?.rootViewController?.present(vc, animated: true)
    }

    // MARK: - Adaptive layout helpers
    private func adaptiveFontSize(base: CGFloat) -> CGFloat {
        let scale = size.width / 390.0
        return max(base * scale, base * 0.75)
    }

    private func adaptiveBtnHeight() -> CGFloat {
        let h = size.height
        if h > 900 { return 70 }
        if h > 750 { return 64 }
        return 58
    }

    private func adaptiveBtnGap() -> CGFloat {
        let h = size.height
        if h > 900 { return 14 }
        if h > 750 { return 10 }
        return 8
    }

    private func safeAreaTop() -> CGFloat {
        view?.safeAreaInsets.top ?? 44
    }

    private func safeAreaBottom() -> CGFloat {
        view?.safeAreaInsets.bottom ?? 34
    }

    // MARK: - Scene will appear: refresh balance
    override func sceneDidLoad() {
        super.sceneDidLoad()
    }
}
