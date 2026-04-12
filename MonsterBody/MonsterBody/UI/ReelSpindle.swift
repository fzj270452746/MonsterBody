import SpriteKit
import UIKit
import CoreHaptics

// MARK: - ReelSpindle: Single slot reel node
final class ReelSpindle: SKNode {
    private let symbolSize: CGSize
    private let visibleCount = 1          // symbols visible in window
    private var symbols: [Int] = []
    private var symbolNodes: [SKSpriteNode] = []
    private var stripContainer: SKNode!
    private var maskNode: SKCropNode!
    private var partCategory: BodyPartCategory = .accesories
    var currentSymbolIndex: Int = 0       // result symbol (1-9)
    var isSpinning = false

    init(symbolSize: CGSize, part: BodyPartCategory) {
        self.symbolSize = symbolSize
        self.partCategory = part
        super.init()
        buildReel()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build
    private func buildReel() {
        // Mask to clip overflow
        let maskShape = SKShapeNode(rectOf: CGSize(width: symbolSize.width + 4,
                                                    height: symbolSize.height * CGFloat(visibleCount) + 4),
                                   cornerRadius: 16)
        maskShape.fillColor = .white
        let mask = SKCropNode()
        mask.maskNode = maskShape
        self.maskNode = mask
        addChild(mask)

        // Frame border
        let border = SKShapeNode(rectOf: CGSize(width: symbolSize.width + 8,
                                                height: symbolSize.height * CGFloat(visibleCount) + 8),
                                 cornerRadius: 18)
        border.fillColor = .clear
        border.strokeColor = SKColor(white: 1, alpha: 0.25)
        border.lineWidth = 2
        addChild(border)

        // Background fill
        let bg = SKShapeNode(rectOf: CGSize(width: symbolSize.width + 4,
                                            height: symbolSize.height * CGFloat(visibleCount) + 4),
                             cornerRadius: 16)
        bg.fillColor = UIColor(hex: "#0D1117")
        bg.strokeColor = .clear
        bg.zPosition = -1
        mask.addChild(bg)

        // Strip container
        stripContainer = SKNode()
        mask.addChild(stripContainer)

        buildSymbolStrip()
    }

    private func buildSymbolStrip() {
        stripContainer.removeAllChildren()
        symbolNodes.removeAll()

        // Build extended strip: 3 loops of all 9 symbols for smooth spin
        let allIndices = (1...GlyphVault.glyphsPerPart).map { $0 }
        symbols = allIndices + allIndices + allIndices   // 27 items

        let startY = CGFloat(symbols.count / 2) * symbolSize.height

        for (i, idx) in symbols.enumerated() {
            let node = buildSymbolNode(idx: idx)
            let y = startY - CGFloat(i) * symbolSize.height
            node.position = CGPoint(x: 0, y: y)
            stripContainer.addChild(node)
            symbolNodes.append(node)
        }
    }

    private func buildSymbolNode(idx: Int) -> SKSpriteNode {
        let assetName = "\(partCategory.rawValue)-\(idx)"
        let node: SKSpriteNode
        if let img = UIImage(named: assetName) {
            node = SKSpriteNode(texture: SKTexture(image: img),
                                size: CGSize(width: symbolSize.width - 12,
                                             height: symbolSize.height - 12))
        } else {
            // Fallback placeholder
            node = SKSpriteNode(color: SKColor(white: 0.2, alpha: 1), size: symbolSize)
            let lbl = SKLabelNode(text: "\(idx)")
            lbl.fontSize = 24
            lbl.verticalAlignmentMode = .center
            node.addChild(lbl)
        }
        node.zPosition = 1
        return node
    }

    // MARK: - Spin
    func igniteSpindle(targetIndex: Int, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        guard !isSpinning else { return }
        isSpinning = true
        currentSymbolIndex = targetIndex

        let totalSymbols = symbols.count
        let stripHeight = CGFloat(totalSymbols) * symbolSize.height

        // Pick a stop position: land on targetIndex in the middle loop (indices 9..17)
        let targetArrayPos = 9 + (targetIndex - 1)  // middle loop
        let startY = stripContainer.position.y
        let landingY = CGFloat(targetArrayPos) * symbolSize.height
                       - CGFloat(totalSymbols / 2) * symbolSize.height

        let totalDistance = abs(landingY - startY) + stripHeight * 1.5
        let spinDuration = GlyphVault.reelSpinDuration + delay * 0.3

        // Fast spin then ease to stop
        let fullSpin = SKAction.moveBy(x: 0, y: -stripHeight * 1.5, duration: spinDuration * 0.65)
        fullSpin.timingMode = .easeIn

        let slowDown = SKAction.move(to: CGPoint(x: 0, y: landingY), duration: spinDuration * 0.35)
        slowDown.timingMode = .easeOut

        // Reset strip to top before spin
        let reset = SKAction.move(to: CGPoint(x: 0, y: CGFloat(totalSymbols / 2) * symbolSize.height / 2), duration: 0)

        let seq = SKAction.sequence([
            SKAction.wait(forDuration: delay),
            reset,
            fullSpin,
            slowDown
        ])

        stripContainer.run(seq) { [weak self] in
            self?.isSpinning = false
            if #available(iOS 13.0, *) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.9)
            }
            completion?()
        }
    }

    // Quick jitter on win
    func celebrateWin() {
        let jitter = SKAction.sequence([
            SKAction.moveBy(x: -3, y: 0, duration: 0.04),
            SKAction.moveBy(x: 6,  y: 0, duration: 0.04),
            SKAction.moveBy(x: -6, y: 0, duration: 0.04),
            SKAction.moveBy(x: 3,  y: 0, duration: 0.04)
        ])
        run(SKAction.repeat(jitter, count: 3))

        if #available(iOS 13.0, *) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        let glow = SKShapeNode(rectOf: CGSize(width: symbolSize.width + 8,
                                              height: symbolSize.height + 8),
                               cornerRadius: 18)
        glow.fillColor = .clear
        glow.strokeColor = .luminesGold
        glow.lineWidth = 3
        glow.alpha = 0
        addChild(glow)
        glow.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.15),
            SKAction.repeat(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 0.2),
                SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            ]), count: 4),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    // Show win highlight line
    func highlightCenter() {
        let line = SKShapeNode(rectOf: CGSize(width: symbolSize.width + 6, height: 3),
                               cornerRadius: 1.5)
        line.fillColor = .luminesGold
        line.strokeColor = .clear
        line.alpha = 0
        addChild(line)
        line.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
}
