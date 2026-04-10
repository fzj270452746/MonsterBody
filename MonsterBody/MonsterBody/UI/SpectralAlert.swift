import SpriteKit
import UIKit

// MARK: - SpectralAlert: custom animated popup overlay
final class SpectralAlert: SKNode {
    enum AlertStyle { case win, beastUnlock, achievement, info, warning }

    private let panelSize: CGSize
    private var dimOverlay: SKSpriteNode!
    private var panel: SKShapeNode!
    var onDismiss: (() -> Void)?

    init(style: AlertStyle, title: String, message: String,
         subview: SKNode? = nil, buttonTitle: String = "Awesome!",
         sceneSize: CGSize) {
        let w = min(sceneSize.width * 0.85, 340)
        let h: CGFloat = subview != nil ? 460 : 280
        panelSize = CGSize(width: w, height: h)
        super.init()
        position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        zPosition = GlyphVault.zAlert
        isUserInteractionEnabled = true
        buildAlert(style: style, title: title, message: message,
                   subview: subview, buttonTitle: buttonTitle, sceneSize: sceneSize)
        entranceAnimation()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build
    private func buildAlert(style: AlertStyle, title: String, message: String,
                            subview: SKNode?, buttonTitle: String, sceneSize: CGSize) {
        // Dim background
        dimOverlay = SKSpriteNode(color: SKColor(white: 0, alpha: 0.65), size: sceneSize)
        dimOverlay.zPosition = -1
        addChild(dimOverlay)

        // Panel
        panel = SKShapeNode(rectOf: panelSize, cornerRadius: 24)
        panel.fillColor = UIColor(hex: "#1E1E3A")
        panel.strokeColor = accentColor(style)
        panel.lineWidth = 2.5
        panel.zPosition = 1
        addChild(panel)

        // Top glow bar
        let glowBar = SKShapeNode(rectOf: CGSize(width: panelSize.width, height: 6))
        glowBar.fillColor = accentColor(style)
        glowBar.strokeColor = .clear
        glowBar.position = CGPoint(x: 0, y: panelSize.height / 2 - 3)
        glowBar.zPosition = 2
        panel.addChild(glowBar)

        // Icon
        let icon = buildIcon(style: style)
        icon.position = CGPoint(x: 0, y: panelSize.height / 2 - 70)
        icon.zPosition = 3
        panel.addChild(icon)

        // Title
        let titleNode = SKLabelNode(text: title)
        titleNode.fontName = GlyphVault.fontHeavy
        titleNode.fontSize = 22
        titleNode.fontColor = .white
        titleNode.horizontalAlignmentMode = .center
        titleNode.verticalAlignmentMode = .center
        titleNode.numberOfLines = 2
        titleNode.preferredMaxLayoutWidth = panelSize.width - 40
        titleNode.position = CGPoint(x: 0, y: panelSize.height / 2 - 120)
        titleNode.zPosition = 3
        panel.addChild(titleNode)

        // Message
        let msgNode = SKLabelNode(text: message)
        msgNode.fontName = GlyphVault.fontRegular
        msgNode.fontSize = 14
        msgNode.fontColor = SKColor(white: 1, alpha: 0.75)
        msgNode.horizontalAlignmentMode = .center
        msgNode.verticalAlignmentMode = .center
        msgNode.numberOfLines = 3
        msgNode.preferredMaxLayoutWidth = panelSize.width - 48
        msgNode.position = CGPoint(x: 0, y: panelSize.height / 2 - 155)
        msgNode.zPosition = 3
        panel.addChild(msgNode)

        // Subview (monster image or custom content)
        if let sub = subview {
            sub.position = CGPoint(x: 0, y: 0)
            sub.zPosition = 3
            panel.addChild(sub)
        }

        // Dismiss button
        let btnY = -panelSize.height / 2 + 52
        let btn = LuminesButton(title: buttonTitle,
                                size: CGSize(width: panelSize.width - 60, height: 50),
                                variant: variantForStyle(style))
        btn.position = CGPoint(x: 0, y: btnY)
        btn.zPosition = 4
        btn.onTap = { [weak self] in self?.quellAlert() }
        panel.addChild(btn)

        // Particles for win/unlock
        if style == .win || style == .beastUnlock {
            addConfetti(sceneSize: sceneSize)
        }
    }

    private func buildIcon(style: AlertStyle) -> SKNode {
        let circle = SKShapeNode(circleOfRadius: 28)
        circle.fillColor = accentColor(style).withAlphaComponent(0.25)
        circle.strokeColor = accentColor(style)
        circle.lineWidth = 2
        let lbl = SKLabelNode(text: iconEmoji(style))
        lbl.fontSize = 28
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .center
        circle.addChild(lbl)
        return circle
    }

    private func iconEmoji(_ style: AlertStyle) -> String {
        switch style {
        case .win:         return "🏆"
        case .beastUnlock: return "✨"
        case .achievement: return "🎖"
        case .info:        return "ℹ️"
        case .warning:     return "⚠️"
        }
    }

    private func accentColor(_ style: AlertStyle) -> SKColor {
        switch style {
        case .win:         return .luminesGold
        case .beastUnlock: return .luminesOrange
        case .achievement: return .luminesViolet
        case .info:        return .luminesTeal
        case .warning:     return .luminesCrimson
        }
    }

    private func variantForStyle(_ style: AlertStyle) -> LuminesButton.Variant {
        switch style {
        case .win:         return .gold
        case .beastUnlock: return .primary
        case .achievement: return .secondary
        default:           return .ghost
        }
    }

    private func addConfetti(sceneSize: CGSize) {
        let colors: [UIColor] = [
            UIColor(hex: "#FFD700"), UIColor(hex: "#FF6B6B"),
            UIColor(hex: "#4ECDC4"), UIColor(hex: "#667EEA"),
            UIColor(hex: "#FFA500")
        ]
        for i in 0..<25 {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...7))
            dot.fillColor = colors.randomElement()!
            dot.strokeColor = .clear
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let radius = CGFloat.random(in: 40...180)
            dot.position = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            dot.zPosition = 5
            dot.alpha = 0
            panel.addChild(dot)
            let delay = Double(i) * 0.04
            dot.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.2),
                    SKAction.moveBy(x: CGFloat.random(in: -30...30),
                                   y: CGFloat.random(in: 20...80),
                                   duration: 1.0)
                ]),
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))
        }
    }

    // MARK: - Animations
    private func entranceAnimation() {
        panel.setScale(0.6)
        panel.alpha = 0
        dimOverlay.alpha = 0
        dimOverlay.run(SKAction.fadeIn(withDuration: 0.2))
        panel.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 0.25),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
        ]))
    }

    func quellAlert() {
        let exit = SKAction.group([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.scale(to: 0.8, duration: 0.2)
        ])
        panel.run(exit)
        dimOverlay.run(SKAction.fadeOut(withDuration: 0.2)) { [weak self] in
            self?.removeFromParent()
            self?.onDismiss?()
        }
    }

    // Block touch pass-through on dim area
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
}
