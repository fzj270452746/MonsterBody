import SpriteKit
import UIKit

// MARK: - LuminesButton: styled SKNode button
final class LuminesButton: SKNode {
    enum Variant { case primary, secondary, danger, ghost, gold }

    private let backgroundNode: SKShapeNode
    private let labelNode: SKLabelNode
    private let size: CGSize
    var onTap: (() -> Void)?
    var isEnabled: Bool = true {
        didSet { refreshAppearance() }
    }

    init(title: String, size: CGSize = CGSize(width: 200, height: 52),
         variant: Variant = .primary, fontSize: CGFloat = 17) {
        self.size = size
        backgroundNode = SKShapeNode(rectOf: size, cornerRadius: size.height / 2)
        labelNode = SKLabelNode(text: title)
        super.init()

        // Background gradient simulation via color
        applyVariant(variant)

        labelNode.fontName = GlyphVault.fontBold
        labelNode.fontSize = fontSize
        labelNode.fontColor = .white
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        labelNode.zPosition = 2

        addChild(backgroundNode)
        addChild(labelNode)
        isUserInteractionEnabled = true
        backgroundNode.isUserInteractionEnabled = false
        labelNode.isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) { fatalError() }

    private func applyVariant(_ variant: Variant) {
        switch variant {
        case .primary:
            backgroundNode.fillColor = UIColor(hex: "#667EEA")
            backgroundNode.strokeColor = UIColor(hex: "#764BA2")
        case .secondary:
            backgroundNode.fillColor = UIColor(hex: "#4ECDC4")
            backgroundNode.strokeColor = UIColor(hex: "#2BA8A0")
        case .danger:
            backgroundNode.fillColor = UIColor(hex: "#FF6B6B")
            backgroundNode.strokeColor = UIColor(hex: "#E05252")
        case .ghost:
            backgroundNode.fillColor = SKColor(white: 1, alpha: 0.12)
            backgroundNode.strokeColor = SKColor(white: 1, alpha: 0.35)
        case .gold:
            backgroundNode.fillColor = UIColor(hex: "#FFA500")
            backgroundNode.strokeColor = UIColor(hex: "#FFD700")
        }
        backgroundNode.lineWidth = 1.5
        backgroundNode.zPosition = 1
    }

    private func refreshAppearance() {
        alpha = isEnabled ? 1.0 : 0.45
    }

    func updateTitle(_ text: String) { labelNode.text = text }

    // MARK: Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        run(SKAction.scale(to: 0.94, duration: 0.08))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        run(SKAction.sequence([
            SKAction.scale(to: 1.04, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.06)
        ])) { [weak self] in
            self?.onTap?()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(SKAction.scale(to: 1.0, duration: 0.08))
    }

    // Hit test
    override func contains(_ p: CGPoint) -> Bool {
        return abs(p.x) <= size.width / 2 && abs(p.y) <= size.height / 2
    }
}

// MARK: - IconButton: small circular icon button
final class IconButton: SKNode {
    private let circle: SKShapeNode
    private let label: SKLabelNode
    var onTap: (() -> Void)?
    private let radius: CGFloat

    init(sfSymbol: String, radius: CGFloat = 26, fillColor: SKColor = .cardFill) {
        self.radius = radius
        circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = fillColor
        circle.strokeColor = .cardStroke
        circle.lineWidth = 1.5

        label = SKLabelNode(text: sfSymbol)
        label.fontSize = radius * 0.9
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 2

        super.init()
        addChild(circle)
        addChild(label)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(SKAction.scale(to: 0.9, duration: 0.07))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.07),
            SKAction.scale(to: 1.0, duration: 0.05)
        ])) { [weak self] in self?.onTap?() }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(SKAction.scale(to: 1.0, duration: 0.07))
    }
}
