import UIKit
import SpriteKit

// MARK: - UIColor hex init
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)
        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgbValue & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }

    func toSKColor() -> SKColor { return self }
}

// MARK: - SKColor palette
extension SKColor {
    static var prismaticDeep: SKColor    { UIColor(hex: "#1A1A2E") }
    static var prismaticMid: SKColor     { UIColor(hex: "#16213E") }
    static var prismaticSurface: SKColor { UIColor(hex: "#0F3460") }
    static var luminesViolet: SKColor    { UIColor(hex: "#667EEA") }
    static var luminesIndigo: SKColor    { UIColor(hex: "#764BA2") }
    static var luminesTeal: SKColor      { UIColor(hex: "#4ECDC4") }
    static var luminesCrimson: SKColor   { UIColor(hex: "#FF6B6B") }
    static var luminesGold: SKColor      { UIColor(hex: "#FFD700") }
    static var luminesAmber: SKColor     { UIColor(hex: "#FFA500") }
    static var luminesGreen: SKColor     { UIColor(hex: "#4CAF50") }
    static var luminesBlue: SKColor      { UIColor(hex: "#2196F3") }
    static var luminesOrange: SKColor    { UIColor(hex: "#FF9800") }
    static var frostedWhite: SKColor     { UIColor(white: 1, alpha: 0.9) }
    static var dimWhite: SKColor         { UIColor(white: 1, alpha: 0.55) }
    static var cardFill: SKColor         { UIColor(white: 1, alpha: 0.07) }
    static var cardStroke: SKColor       { UIColor(white: 1, alpha: 0.18) }
}

// MARK: - Gradient image helper
extension UIColor {
    static func aureateGradientImage(
        size: CGSize,
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 0, y: 1)
    ) -> UIImage {
        let gradLayer = CAGradientLayer()
        gradLayer.frame = CGRect(origin: .zero, size: size)
        gradLayer.colors = colors.map { $0.cgColor }
        gradLayer.startPoint = startPoint
        gradLayer.endPoint = endPoint
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        if let ctx = UIGraphicsGetCurrentContext() {
            gradLayer.render(in: ctx)
        }
        return UIGraphicsGetCurrentImage() ?? UIImage()
    }
}

// MARK: - SKTexture gradient
extension SKTexture {
    static func prismGradient(size: CGSize, top: UIColor, bottom: UIColor) -> SKTexture {
        let img = UIColor.aureateGradientImage(size: size, colors: [top, bottom])
        return SKTexture(image: img)
    }

    static func radialGlow(size: CGSize, color: UIColor) -> SKTexture {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return SKTexture() }
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [color.cgColor, color.withAlphaComponent(0).cgColor] as CFArray,
            locations: [0, 1]
        )!
        ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0,
                               endCenter: center, endRadius: radius, options: [])
        let img = UIGraphicsGetCurrentImage() ?? UIImage()
        return SKTexture(image: img)
    }
}

// MARK: - SKAction helpers
extension SKAction {
    static func luminousPulse(scale: CGFloat = 1.08, duration: TimeInterval = 0.9) -> SKAction {
        let up = SKAction.scale(to: scale, duration: duration / 2)
        let down = SKAction.scale(to: 1, duration: duration / 2)
        up.timingMode = .easeInEaseOut
        down.timingMode = .easeInEaseOut
        return SKAction.repeatForever(SKAction.sequence([up, down]))
    }

    static func hoverFloat(amount: CGFloat = 4, duration: TimeInterval = 1.6) -> SKAction {
        let up = SKAction.moveBy(x: 0, y: amount, duration: duration / 2)
        let down = SKAction.moveBy(x: 0, y: -amount, duration: duration / 2)
        up.timingMode = .easeInEaseOut
        down.timingMode = .easeInEaseOut
        return SKAction.repeatForever(SKAction.sequence([up, down]))
    }

    static func shimmerFade() -> SKAction {
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.35)
        let fadeOut = SKAction.fadeAlpha(to: 0.4, duration: 0.35)
        return SKAction.repeatForever(SKAction.sequence([fadeIn, fadeOut]))
    }
}

// MARK: - UIImage helper
private func UIGraphicsGetCurrentImage() -> UIImage? {
    return UIGraphicsGetImageFromCurrentImageContext()
}
