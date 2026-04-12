import SpriteKit
import UIKit

// MARK: - NexusScene: Main Hub / Home Screen
final class NexusScene: SKScene {
    private var vaultHUD: VaultCounter!
    private var logoNode: SKNode!
    private var buttonContainer: SKNode!
    private var modePickerOverlay: SKNode?
    private var dailyOverlay: SKNode?

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        TroveKeeper.shared.bootstrapIfNeeded()
        TroveKeeper.shared.resetDailyIfNeeded()
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

    // Close overlays by tapping dim/close
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let p = t.location(in: self)
        let nodes = nodes(at: p)
        if nodes.contains(where: { $0.name == "dim" || $0.name == "close" }) {
            dismissModePicker()
        }
        if nodes.contains(where: { $0.name == "daily_dim" || $0.name == "daily_close" }) {
            dailyOverlay?.removeFromParent()
            dailyOverlay = nil
        }
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
        buttonContainer.zPosition = GlyphVault.zContent
        addChild(buttonContainer)

        // Vertical stack for consistency across devices, positioned lower to avoid top overlap
        let btnHeight: CGFloat = adaptiveBtnHeight()
        let gap: CGFloat = adaptiveBtnGap()
        let btnWidth = min(size.width * 0.82, 360)

        // Daily above Play
        let cards: [(title: String, subtitle: String, emoji: String, variant: LuminesButton.Variant, action: () -> Void)] = [
            ("Daily",        "5 missions • claim rewards", "📅", .secondary, { [weak self] in self?.showDailyMissions() }),
            ("Play",         "Slots & Trial modes",        "🎮", .primary,   { [weak self] in self?.presentModePicker() }),
            ("My Collection","Unlocked monsters",          "📚", .ghost,     { [weak self] in self?.navigateToCodex() }),
            ("Achievements", "Milestones & rewards",       "🏆", .ghost,     { [weak self] in self?.navigateToTrophyHall() })
        ]

        let topY = size.height * 0.52  // move down overall
        for (i, c) in cards.enumerated() {
            let y = topY - CGFloat(i) * (btnHeight + gap)
            let card = buildMenuCard(title: c.title, subtitle: c.subtitle, emoji: c.emoji, variant: c.variant, size: CGSize(width: btnWidth, height: btnHeight))
            card.position = CGPoint(x: size.width/2, y: y)
            card.onTap = { c.action() }
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

    private func buildTopRightButtons() { }

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

    private func showDailyMissions() {
        TroveKeeper.shared.resetDailyIfNeeded()
        dailyOverlay?.removeFromParent()
        let overlay = SKNode()
        overlay.zPosition = GlyphVault.zOverlay
        dailyOverlay = overlay

        // Daily overlay uses fully opaque background for maximum readability
        let dim = SKSpriteNode(color: SKColor(white: 0, alpha: 1.0), size: size)
        dim.position = CGPoint(x: size.width/2, y: size.height/2)
        dim.name = "daily_dim"
        overlay.addChild(dim)

        let panelW = min(size.width*0.86, 440)
        let panelH: CGFloat = 340
        let panel = GlassPanel(size: CGSize(width: panelW, height: panelH))
        panel.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.addChild(panel)

        let title = SKLabelNode(text: "Daily Missions")
        title.fontName = GlyphVault.fontBold
        title.fontSize = 18
        title.position = CGPoint(x: panel.position.x, y: panel.position.y + panelH/2 - 34)
        overlay.addChild(title)

        let listStartY = panel.position.y + panelH/2 - 84
        let missions = TroveKeeper.shared.dailyMissions
        let rowH: CGFloat = 40
        for (i, m) in missions.enumerated() {
            let y = listStartY - CGFloat(i) * rowH
            let text = "\(m.title)  \(m.progress)/\(m.target)  (+\(m.reward)🪙)"
            let lbl = SKLabelNode(text: text)
            lbl.fontName = GlyphVault.fontRegular
            lbl.fontSize = 13
            lbl.horizontalAlignmentMode = .left
            lbl.position = CGPoint(x: panel.position.x - panelW/2 + 16, y: y)
            overlay.addChild(lbl)

            if !m.claimed, m.progress >= m.target {
                let claim = LuminesButton(title: "Claim", size: CGSize(width: 76, height: 32), variant: .primary, fontSize: 14)
                claim.position = CGPoint(x: panel.position.x + panelW/2 - 56, y: y)
                claim.onTap = { [weak self] in
                    let reward = TroveKeeper.shared.claimDaily(m.id)
                    self?.vaultHUD.refreshBalance(TroveKeeper.shared.vaultBalance, animated: true)
                    self?.showDailyMissions() // refresh overlay
                    if reward > 0 {
                        let alert = SpectralAlert(style: .win, title: "Reward", message: "+\(reward) coins", buttonTitle: "OK", sceneSize: self?.size ?? .zero)
                        self?.addChild(alert)
                    }
                }
                overlay.addChild(claim)
            } else {
                let state = SKLabelNode(text: m.claimed ? "✅" : "•")
                state.fontName = GlyphVault.fontBold
                state.fontSize = 14
                state.horizontalAlignmentMode = .center
                state.position = CGPoint(x: panel.position.x + panelW/2 - 48, y: y)
                overlay.addChild(state)
            }
        }

        // close button
        let close = SKLabelNode(text: "OK")
        close.fontName = GlyphVault.fontBold
        close.fontSize = 16
        close.position = CGPoint(x: panel.position.x, y: panel.position.y - panelH/2 + 30)
        close.name = "daily_close"
        overlay.addChild(close)

        addChild(overlay)
    }

    private func navigateToTrial() {
        let scene = TrialScene(size: size)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .push(with: .left, duration: GlyphVault.sceneTransitionDuration))
    }

    // MARK: - Mode Picker Overlay
    private func presentModePicker() {
        guard modePickerOverlay == nil else { return }
        let overlay = SKNode()
        overlay.zPosition = GlyphVault.zOverlay
        // dim bg
        // Darker backdrop for readability (alpha 0.90)
        let dim = SKSpriteNode(color: SKColor(white: 0, alpha: 0.90), size: size)
        dim.position = CGPoint(x: size.width/2, y: size.height/2)
        dim.name = "dim"
        overlay.addChild(dim)

        let panelW = min(size.width*0.82, 420)
        let panelH: CGFloat = 260
        let panel = GlassPanel(size: CGSize(width: panelW, height: panelH))
        panel.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.addChild(panel)

        let title = SKLabelNode(text: "Choose Mode")
        title.fontName = GlyphVault.fontBold
        title.fontSize = 18
        title.position = CGPoint(x: panel.position.x, y: panel.position.y + panelH/2 - 34)
        overlay.addChild(title)

        let items: [(String, String, LuminesButton.Variant, ()->Void)] = [
            ("Body Part", "3×1 match", .primary, { [weak self] in self?.navigateToPartSlot() }),
            ("Combo",     "6×1 unlock", .secondary, { [weak self] in self?.navigateToComboSlot() }),
            ("Monster",   "3×1 collection", .gold, { [weak self] in self?.navigateToBeastSlot() }),
            ("Trial",     "30s challenge", .ghost, { [weak self] in self?.navigateToTrial() })
        ]
        let btnW = (panelW - 3*12)/2
        let btnH: CGFloat = 56
        let startX = size.width/2 - btnW/2 - 6
        let topY = panel.position.y + 24

        for (i, it) in items.enumerated() {
            let row = i/2, col = i%2
            let x = startX + CGFloat(col) * (btnW + 12)
            let y = topY - CGFloat(row) * (btnH + 12)
            let btn = LuminesButton(title: it.0, size: CGSize(width: btnW, height: btnH), variant: it.2, fontSize: 16)
            btn.position = CGPoint(x: x, y: y)
            btn.onTap = { [weak self] in
                self?.dismissModePicker()
                it.3()
            }
            overlay.addChild(btn)
        }

        // close label
        let close = SKLabelNode(text: "×")
        close.fontName = GlyphVault.fontBold
        close.fontSize = 22
        close.position = CGPoint(x: panel.position.x + panelW/2 - 16, y: panel.position.y + panelH/2 - 18)
        close.name = "close"
        overlay.addChild(close)

        addChild(overlay)
        modePickerOverlay = overlay
    }

    private func dismissModePicker() {
        modePickerOverlay?.removeFromParent()
        modePickerOverlay = nil
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
