import UIKit

// MARK: - App Font Catalog

struct FontFamily: Identifiable, Hashable {
    let id: String
    let displayName: String
    let fontName: String
    let category: FontCategory

    enum FontCategory: String, CaseIterable {
        case system = "System"
        case serif = "Serif"
        case sansSerif = "Sans Serif"
        case monospace = "Monospace"
        case handwriting = "Handwriting"
    }

    func uiFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        if fontName.hasPrefix(".SF") || fontName == "system" {
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
        if fontName == "system-rounded" {
            let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
            if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: descriptor, size: size)
            }
            return systemFont
        }
        if fontName == "system-serif" {
            let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
            if let descriptor = systemFont.fontDescriptor.withDesign(.serif) {
                return UIFont(descriptor: descriptor, size: size)
            }
            return systemFont
        }
        if fontName == "system-mono" {
            return UIFont.monospacedSystemFont(ofSize: size, weight: weight)
        }
        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
    }
}

// MARK: - Font Catalog

enum AppFontCatalog {
    static let allFonts: [FontFamily] = [
        // System
        FontFamily(id: "sf-pro", displayName: "SF Pro", fontName: "system", category: .system),
        FontFamily(id: "sf-rounded", displayName: "SF Rounded", fontName: "system-rounded", category: .system),
        FontFamily(id: "sf-mono", displayName: "SF Mono", fontName: "system-mono", category: .monospace),
        FontFamily(id: "new-york", displayName: "New York", fontName: "system-serif", category: .serif),

        // Sans Serif (iOS built-in)
        FontFamily(id: "helvetica-neue", displayName: "Helvetica Neue", fontName: "HelveticaNeue", category: .sansSerif),
        FontFamily(id: "avenir", displayName: "Avenir", fontName: "Avenir-Book", category: .sansSerif),
        FontFamily(id: "avenir-next", displayName: "Avenir Next", fontName: "AvenirNext-Regular", category: .sansSerif),
        FontFamily(id: "gill-sans", displayName: "Gill Sans", fontName: "GillSans", category: .sansSerif),
        FontFamily(id: "futura", displayName: "Futura", fontName: "Futura-Medium", category: .sansSerif),

        // Serif
        FontFamily(id: "georgia", displayName: "Georgia", fontName: "Georgia", category: .serif),
        FontFamily(id: "times", displayName: "Times New Roman", fontName: "TimesNewRomanPSMT", category: .serif),
        FontFamily(id: "palatino", displayName: "Palatino", fontName: "Palatino-Roman", category: .serif),
        FontFamily(id: "baskerville", displayName: "Baskerville", fontName: "Baskerville", category: .serif),

        // Monospace
        FontFamily(id: "courier", displayName: "Courier", fontName: "Courier", category: .monospace),
        FontFamily(id: "courier-new", displayName: "Courier New", fontName: "CourierNewPSMT", category: .monospace),
        FontFamily(id: "menlo", displayName: "Menlo", fontName: "Menlo-Regular", category: .monospace),

        // Handwriting
        FontFamily(id: "snell", displayName: "Snell Roundhand", fontName: "SnellRoundhand", category: .handwriting),
        FontFamily(id: "noteworthy", displayName: "Noteworthy", fontName: "Noteworthy-Light", category: .handwriting),
        FontFamily(id: "marker-felt", displayName: "Marker Felt", fontName: "MarkerFelt-Wide", category: .handwriting),
    ]

    static let defaultFont = allFonts[0]

    static func font(byId id: String) -> FontFamily? {
        allFonts.first { $0.id == id }
    }

    static func fonts(in category: FontFamily.FontCategory) -> [FontFamily] {
        allFonts.filter { $0.category == category }
    }
}
