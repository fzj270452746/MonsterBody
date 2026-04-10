import Foundation

// MARK: - Body Part Symbol
struct BodyGlyph: Equatable, Codable {
    let partCategory: BodyPartCategory
    let styleIndex: Int          // 1-9

    var assetName: String { "\(partCategory.rawValue)-\(styleIndex)" }

    static func allGlyphs(for part: BodyPartCategory) -> [BodyGlyph] {
        (1...GlyphVault.glyphsPerPart).map { BodyGlyph(partCategory: part, styleIndex: $0) }
    }
}
