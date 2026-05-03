import SwiftUI
import Observation

// MARK: - App Settings

@Observable
final class AppSettings {
    static let shared = AppSettings()

    var isDarkMode: Bool {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode") }
    }
    var defaultFontId: String {
        didSet { UserDefaults.standard.set(defaultFontId, forKey: "defaultFontId") }
    }
    var defaultFontSize: CGFloat {
        didSet { UserDefaults.standard.set(defaultFontSize, forKey: "defaultFontSize") }
    }
    var autoSaveEnabled: Bool {
        didSet { UserDefaults.standard.set(autoSaveEnabled, forKey: "autoSaveEnabled") }
    }
    var useICloud: Bool {
        didSet { UserDefaults.standard.set(useICloud, forKey: "useICloud") }
    }

    var preferredColorScheme: ColorScheme? {
        isDarkMode ? .dark : nil
    }

    var defaultUIFont: UIFont {
        let family = AppFontCatalog.font(byId: defaultFontId) ?? AppFontCatalog.defaultFont
        return family.uiFont(size: defaultFontSize)
    }

    private init() {
        let defaults = UserDefaults.standard
        self.isDarkMode = defaults.object(forKey: "isDarkMode") as? Bool ?? false
        self.defaultFontId = defaults.string(forKey: "defaultFontId") ?? "sf-pro"
        self.defaultFontSize = defaults.object(forKey: "defaultFontSize") as? CGFloat ?? 16
        self.autoSaveEnabled = defaults.object(forKey: "autoSaveEnabled") as? Bool ?? true
        self.useICloud = defaults.object(forKey: "useICloud") as? Bool ?? true
    }
}
