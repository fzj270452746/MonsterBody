import SpriteKit
import UIKit

// MARK: - AuroraLayer: Full-screen gradient background
final class AuroraLayer: SKNode {
    private var gradientSprite: SKSpriteNode?

    init(size: CGSize, topColor: UIColor = UIColor(hex: "#1A1A2E"),
         bottomColor: UIColor = UIColor(hex: "#0F3460")) {
        super.init()
        zPosition = GlyphVault.zBackground
        renderGradient(size: size, top: topColor, bottom: bottomColor)
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    private func renderGradient(size: CGSize, top: UIColor, bottom: UIColor) {
        let tex = SKTexture.prismGradient(size: size, top: top, bottom: bottom)
        let sprite = SKSpriteNode(texture: tex, size: size)
        sprite.zPosition = GlyphVault.zBackground
        addChild(sprite)
        gradientSprite = sprite

        // Subtle star particles
        let emitter = buildStarField(size: size)
        addChild(emitter)
    }

    private func buildStarField(size: CGSize) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(imageNamed: "spark")
        emitter.particleBirthRate = 1.5
        emitter.particleLifetime = 8
        emitter.particleLifetimeRange = 4
        emitter.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        emitter.particleSpeed = 8
        emitter.particleSpeedRange = 4
        emitter.particleAlpha = 0.6
        emitter.particleAlphaRange = 0.3
        emitter.particleAlphaSpeed = -0.05
        emitter.particleScale = 0.04
        emitter.particleScaleRange = 0.02
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1
        emitter.zPosition = GlyphVault.zBackground + 1
        return emitter
    }
}

// MARK: - GlassPanel: frosted-glass card node
final class GlassPanel: SKNode {
    init(size: CGSize, cornerRadius: CGFloat = 20) {
        super.init()
        let shape = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        // Slightly more opaque to ensure modal readability over busy backgrounds
        shape.fillColor = SKColor(white: 1, alpha: 0.12)
        shape.strokeColor = SKColor(white: 1, alpha: 0.25)
        shape.lineWidth = 1.5
        shape.zPosition = 0
        addChild(shape)
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
}
