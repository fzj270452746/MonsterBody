import SpriteKit
import UIKit

// MARK: - VaultCounter: coin HUD node
final class VaultCounter: SKNode {
    private let coinIcon: SKLabelNode
    private let amountLabel: SKLabelNode
    private let panel: SKShapeNode
    private var displayedBalance: Int = 0

    init(width: CGFloat = 150) {
        let panelSize = CGSize(width: width, height: 44)
        panel = SKShapeNode(rectOf: panelSize, cornerRadius: 22)
        panel.fillColor = SKColor(white: 0, alpha: 0.45)
        panel.strokeColor = UIColor(hex: "#FFD700").withAlphaComponent(0.5)
        panel.lineWidth = 1.5

        coinIcon = SKLabelNode(text: "🪙")
        coinIcon.fontSize = 20
        coinIcon.verticalAlignmentMode = .center
        coinIcon.horizontalAlignmentMode = .center
        coinIcon.position = CGPoint(x: -width/2 + 26, y: 0)

        amountLabel = SKLabelNode(text: "0")
        amountLabel.fontName = GlyphVault.fontBold
        amountLabel.fontSize = 18
        amountLabel.fontColor = UIColor(hex: "#FFD700")
        amountLabel.verticalAlignmentMode = .center
        amountLabel.horizontalAlignmentMode = .left
        amountLabel.position = CGPoint(x: -width/2 + 46, y: -1)

        super.init()
        addChild(panel)
        addChild(coinIcon)
        addChild(amountLabel)
    }

    required init?(coder: NSCoder) { fatalError() }

    func refreshBalance(_ balance: Int, animated: Bool = true) {
        amountLabel.text = formatTokens(balance)
        if animated && balance > displayedBalance {
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 0.12),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
            amountLabel.run(pulse)
            panel.strokeColor = UIColor(hex: "#FFD700")
            panel.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run { [weak self] in
                    self?.panel.strokeColor = UIColor(hex: "#FFD700").withAlphaComponent(0.5)
                }
            ]))
        }
        displayedBalance = balance
    }

    private func formatTokens(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n) / 1_000_000) }
        if n >= 1_000     { return String(format: "%.1fK", Double(n) / 1_000) }
        return "\(n)"
    }
}

// MARK: - WagerPicker: bet selector node
final class WagerPicker: SKNode {
    private let minWager: Int
    private let maxWager: Int
    private let step: Int
    private(set) var currentWager: Int
    private var wagerLabel: SKLabelNode!
    var onWagerChanged: ((Int) -> Void)?

    init(min: Int = GlyphVault.initialWager,
         max: Int = GlyphVault.maximumWager,
         step: Int = GlyphVault.wagerStep) {
        self.minWager = min
        self.maxWager = max
        self.step = step
        self.currentWager = min
        super.init()
        buildPicker()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildPicker() {
        // minus button
        let minusBtn = buildArrowButton(symbol: "−", isLeft: true)
        minusBtn.position = CGPoint(x: -70, y: 0)
        minusBtn.onTap = { [weak self] in self?.decrementWager() }
        addChild(minusBtn)

        // center label
        let panel = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 12)
        panel.fillColor = SKColor(white: 0, alpha: 0.35)
        panel.strokeColor = SKColor(white: 1, alpha: 0.2)
        panel.lineWidth = 1
        addChild(panel)

        let topLabel = SKLabelNode(text: "BET")
        topLabel.fontName = GlyphVault.fontMedium
        topLabel.fontSize = 9
        topLabel.fontColor = SKColor(white: 1, alpha: 0.5)
        topLabel.verticalAlignmentMode = .center
        topLabel.position = CGPoint(x: 0, y: 10)
        panel.addChild(topLabel)

        wagerLabel = SKLabelNode(text: "\(currentWager)")
        wagerLabel.fontName = GlyphVault.fontBold
        wagerLabel.fontSize = 18
        wagerLabel.fontColor = UIColor(hex: "#FFD700")
        wagerLabel.verticalAlignmentMode = .center
        wagerLabel.position = CGPoint(x: 0, y: -7)
        panel.addChild(wagerLabel)

        // plus button
        let plusBtn = buildArrowButton(symbol: "+", isLeft: false)
        plusBtn.position = CGPoint(x: 70, y: 0)
        plusBtn.onTap = { [weak self] in self?.incrementWager() }
        addChild(plusBtn)
    }

    private func buildArrowButton(symbol: String, isLeft: Bool) -> LuminesButton {
        let btn = LuminesButton(title: symbol, size: CGSize(width: 44, height: 40), variant: .ghost, fontSize: 22)
        return btn
    }

    private func incrementWager() {
        guard currentWager < maxWager else { return }
        currentWager = min(currentWager + step, maxWager)
        wagerLabel.text = "\(currentWager)"
        wagerLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.06)
        ]))
        onWagerChanged?(currentWager)
    }

    private func decrementWager() {
        guard currentWager > minWager else { return }
        currentWager = max(currentWager - step, minWager)
        wagerLabel.text = "\(currentWager)"
        wagerLabel.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.06)
        ]))
        onWagerChanged?(currentWager)
    }
}
