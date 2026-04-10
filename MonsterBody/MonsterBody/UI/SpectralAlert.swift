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
        msgNode.zPosition = 3
        panel.addChild(msgNode)

        // Dynamic stack layout to avoid overlaps on iPad compatibility mode
        layoutText(icon: icon, titleNode: titleNode, msgNode: msgNode)

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

    // Dynamically stack title/message and keep a safe gap above the button
    private func layoutText(icon: SKNode, titleNode: SKLabelNode, msgNode: SKLabelNode) {
        let iconBounds = icon.calculateAccumulatedFrame()
        let topLimit = panelSize.height / 2 - 18                   // below glow bar
        let buttonCenterY = -panelSize.height / 2 + 52              // from buildAlert
        let buttonTopY = buttonCenterY + 25                         // 50pt button height
        let requiredGap: CGFloat = 16

        func performStackLayout() {
            let titleH = max(titleNode.frame.height, 1)
            let msgH = max(msgNode.frame.height, 1)
            var cursorY = icon.position.y - iconBounds.height / 2 - 12
            titleNode.position = CGPoint(x: 0, y: cursorY - titleH / 2)
            cursorY = titleNode.position.y - titleH / 2 - 8
            msgNode.position = CGPoint(x: 0, y: cursorY - msgH / 2)
        }

        // Initial layout with current sizes
        performStackLayout()

        // Ensure minimum gap above the button
        func ensureGap() {
            let msgBottom = msgNode.position.y - msgNode.frame.height / 2
            let needLift = (buttonTopY + requiredGap) - msgBottom
            if needLift > 0 {
                // Try shifting the whole content group upward
                let currentTopOfIcon = icon.position.y + iconBounds.height / 2
                let headroom = topLimit - currentTopOfIcon
                let shift = min(needLift, max(headroom, 0))
                if shift > 0 {
                    icon.position.y += shift
                    titleNode.position.y += shift
                    msgNode.position.y += shift
                }
            }
        }

        ensureGap()

        // If still overlapping or too tight, reduce message height and re-layout once
        let msgBottomAfter = msgNode.position.y - msgNode.frame.height / 2
        if msgBottomAfter < buttonTopY + requiredGap {
            // Widen wrap to reduce line count and allow unlimited lines
            msgNode.numberOfLines = 0
            msgNode.preferredMaxLayoutWidth = panelSize.width - 24
            // Small font nudge if still tight later
            performStackLayout()
            ensureGap()
            let msgBottomAfter2 = msgNode.position.y - msgNode.frame.height / 2
            if msgBottomAfter2 < buttonTopY + requiredGap {
                msgNode.fontSize = max(msgNode.fontSize - 1, 12)
                titleNode.fontSize = max(titleNode.fontSize - 1, 20)
                performStackLayout()
                ensureGap()
            }
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
