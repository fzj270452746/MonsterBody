import SpriteKit
import UIKit
import ReplayKit

// MARK: - TrialScene: lightweight skill challenge using collection
final class TrialScene: SKScene {
    private var targetLabel: SKLabelNode!
    private var timerLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var vaultHUD: VaultCounter!

    private var timeLeft: TimeInterval = 30
    private var targetCount: Int = 10
    private var passives: PassiveProfile = MonsterAbilities.profileFromCollection()
    private var score: Int = 0
    private var lastSpawn: TimeInterval = 0
    private var recNode: SKLabelNode!
    private var isRecording = false
    private var hasEnded = false

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#121626")
        buildHUD()
        buildLabels()
        spawnBuffBadges()
        // apply passives
        timeLeft += passives.extraTime
        buildRecordToggle()
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if hasEnded { return }
        timeLeft -= min(1/60.0, max(0, view?.preferredFramesPerSecond == 120 ? 1/120.0 : 1/60.0))
        timerLabel.text = String(format: "⏱ %.0f s", max(0, timeLeft))
        if timeLeft <= 0 { finishTrial() }

        if currentTime - lastSpawn > passives.spawnInterval {
            lastSpawn = currentTime
            spawnTarget()
        }
    }

    private func buildHUD() {
        vaultHUD = VaultCounter(width: min(size.width * 0.45, 155))
        vaultHUD.position = CGPoint(x: size.width / 2, y: size.height - (view?.safeAreaInsets.top ?? 44) - 22)
        vaultHUD.zPosition = GlyphVault.zHUD
        addChild(vaultHUD)
        vaultHUD.refreshBalance(TroveKeeper.shared.vaultBalance, animated: false)
    }

    private func buildLabels() {
        targetLabel = SKLabelNode(text: "🎯 Targets: 0/\(targetCount)")
        targetLabel.fontName = GlyphVault.fontBold
        targetLabel.fontSize = 16
        targetLabel.position = CGPoint(x: size.width/2, y: size.height*0.78)
        addChild(targetLabel)

        timerLabel = SKLabelNode(text: "⏱ 30 s")
        timerLabel.fontName = GlyphVault.fontMedium
        timerLabel.fontSize = 14
        timerLabel.fontColor = SKColor(white: 1, alpha: 0.8)
        timerLabel.position = CGPoint(x: size.width/2, y: size.height*0.72)
        addChild(timerLabel)

        scoreLabel = SKLabelNode(text: "+0 🪙")
        scoreLabel.fontName = GlyphVault.fontBold
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = UIColor(hex: "#FFD700")
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height*0.66)
        addChild(scoreLabel)

        let back = LuminesButton(title: "‹  Home", size: CGSize(width: 110, height: 40), variant: .ghost, fontSize: 15)
        back.position = CGPoint(x: 66, y: size.height - (view?.safeAreaInsets.top ?? 44) - 22)
        back.zPosition = GlyphVault.zHUD
        back.onTap = { [weak self] in
            guard let self = self else { return }
            let scene = NexusScene(size: self.size)
            scene.scaleMode = self.scaleMode
            self.view?.presentScene(scene, transition: .push(with: .right, duration: GlyphVault.sceneTransitionDuration))
        }
        addChild(back)
    }

    private func spawnTarget() {
        let emoji = ["⭐","💫","✨","🌟"].randomElement()!
        let node = SKLabelNode(text: emoji)
        node.fontSize = CGFloat.random(in: 22...34)
        node.position = CGPoint(x: CGFloat.random(in: 40...(size.width-40)), y: CGFloat.random(in: 140...(size.height-160)))
        node.alpha = 0
        node.name = "target"
        node.zPosition = GlyphVault.zContent
        addChild(node)
        let life: TimeInterval = 1.8
        node.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.12),
            SKAction.wait(forDuration: life),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        // chance to spawn double
        if Double.random(in: 0...1) < passives.doubleTargetChance {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in self?.spawnTarget() }
        }
    }

    private func spawnBuffBadges() {
        // Read collection strength to modify rules (simple, deterministic):
        let count = TroveKeeper.shared.enshrineCount
        // Each 3 monsters grants -1 required target, min 6; plus passive reduction
        targetCount = max(6, 10 - count/3 - passives.targetReduction)
        targetLabel.text = "🎯 Targets: 0/\(targetCount)"
    }

    private func buildRecordToggle() {
        recNode = SKLabelNode(text: "● REC")
        recNode.fontName = GlyphVault.fontBold
        recNode.fontSize = 13
        recNode.fontColor = UIColor(hex: "#FF3B30")
        recNode.horizontalAlignmentMode = .right
        recNode.position = CGPoint(x: size.width - 16, y: size.height - (view?.safeAreaInsets.top ?? 44) - 26)
        recNode.name = "rec"
        addChild(recNode)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let p = t.location(in: self)
        let nodes = nodes(at: p)
        if let target = nodes.first(where: { $0.name == "target" }) {
            target.removeAllActions()
            target.run(SKAction.sequence([SKAction.scale(to: 1.4, duration: 0.08), SKAction.fadeOut(withDuration: 0.1), SKAction.removeFromParent()]))
            if #available(iOS 13.0, *) { UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.8) }
            score += 1 + passives.scorePerHitBonus
            targetLabel.text = "🎯 Targets: \(score)/\(targetCount)"
            if score >= targetCount { finishTrial() }
        } else if let rec = nodes.first(where: { $0.name == "rec" }) {
            toggleRecording()
        }
    }

    private func finishTrial() {
        if hasEnded { return }
        hasEnded = true
        isUserInteractionEnabled = false
        let reward = 100 + score * 10
        TroveKeeper.shared.harvestTokens(reward)
        vaultHUD.refreshBalance(TroveKeeper.shared.vaultBalance)
        let alert = SpectralAlert(style: .win, title: "Trial Complete", message: "Score: \(score)\nReward: \(reward) 🪙", buttonTitle: "OK", sceneSize: size)
        addChild(alert)
        if #available(iOS 13.0, *) { UINotificationFeedbackGenerator().notificationOccurred(.success) }
        // Stop recording if still on
        if isRecording { stopRecording() }
    }

    // MARK: - ReplayKit
    private func toggleRecording() {
        if isRecording { stopRecording() } else { startRecording() }
    }

    private func startRecording() {
        let rec = RPScreenRecorder.shared()
        guard rec.isAvailable else { return }
        rec.startRecording { [weak self] error in
            DispatchQueue.main.async {
                if error == nil { self?.isRecording = true; self?.recNode.text = "● LIVE" }
            }
        }
    }

    private func stopRecording() {
        let rec = RPScreenRecorder.shared()
        rec.stopRecording { [weak self] preview, error in
            guard let self = self else { return }
            self.isRecording = false
            self.recNode.text = "● REC"
            if let vc = preview {
                vc.modalPresentationStyle = .overFullScreen
                self.view?.window?.rootViewController?.present(vc, animated: true)
            }
        }
    }
}
