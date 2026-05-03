import Foundation
import Observation
import SwiftUI
import UIKit

// MARK: - Active Toolbar Mode

enum ActiveToolbar: Equatable {
    case none
    case formatting
    case font
    case fontSize
    case color
    case paragraph
}

// MARK: - Editor ViewModel

@Observable
final class EditorViewModel {
    // Document
    var document: TextDocument
    var attributedText: NSAttributedString
    var selectedRange: NSRange = NSRange(location: 0, length: 0)

    // Current attributes at cursor
    var isBold: Bool = false
    var isItalic: Bool = false
    var isUnderline: Bool = false
    var isStrikethrough: Bool = false
    var currentFontName: String = "SF Pro"
    var currentFontSize: CGFloat = 16
    var currentTextColor: UIColor = .label
    var currentHighlightColor: UIColor?
    var currentAlignment: NSTextAlignment = .left
    var currentLineSpacing: CGFloat = 4

    // Toolbar
    var activeToolbar: ActiveToolbar = .none
    var showToolbar: Bool = true

    // State
    var hasUnsavedChanges: Bool = false
    var wordCount: Int = 0
    var characterCount: Int = 0
    var currentLine: Int = 1
    var currentColumn: Int = 1
    var totalLines: Int = 1

    // Editor Settings
    var showLineNumbers: Bool = false {
        didSet {
            UserDefaults.standard.set(showLineNumbers, forKey: "showLineNumbers")
            updateLineNumberVisibility()
        }
    }
    var wordWrapEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(wordWrapEnabled, forKey: "wordWrapEnabled")
            updateWordWrap()
        }
    }

    // Internal
    var textView: UITextView?
    private var autoSaveTimer: Timer?

    var isRichText: Bool {
        document.documentFileType == .richText
    }

    var fileName: String {
        document.fileURL.deletingPathExtension().lastPathComponent
    }

    // MARK: - Init

    init(document: TextDocument) {
        self.document = document
        self.attributedText = document.attributedText
        self.showLineNumbers = UserDefaults.standard.object(forKey: "showLineNumbers") as? Bool ?? false
        self.wordWrapEnabled = UserDefaults.standard.object(forKey: "wordWrapEnabled") as? Bool ?? true
        updateCounts()
    }

    // MARK: - Text Updates

    func textDidChange(_ newText: NSAttributedString) {
        attributedText = newText
        document.attributedText = newText
        hasUnsavedChanges = true
        updateCounts()
        updateCursorPosition()
        scheduleAutoSave()
    }

    func selectionDidChange(_ range: NSRange) {
        selectedRange = range
        updateCurrentAttributes()
        updateCursorPosition()
    }

    // MARK: - Cursor Position (Line/Column)

    func updateCursorPosition() {
        let text = attributedText.string
        let nsString = text as NSString
        let location = min(selectedRange.location, nsString.length)

        // Calculate current line & column
        var line = 1
        var lastLineStart = 0
        for i in 0..<location {
            if nsString.character(at: i) == 10 { // \n
                line += 1
                lastLineStart = i + 1
            }
        }
        currentLine = line
        currentColumn = location - lastLineStart + 1

        // Total lines
        totalLines = max(1, text.components(separatedBy: "\n").count)
    }

    // MARK: - Line Number Visibility

    func updateLineNumberVisibility() {
        // Notify the text view to show/hide line numbers by refreshing
        // The actual line number rendering happens in the LineNumberGutter
        NotificationCenter.default.post(
            name: .editorSettingsChanged,
            object: nil,
            userInfo: ["showLineNumbers": showLineNumbers]
        )
    }

    // MARK: - Word Wrap

    func updateWordWrap() {
        guard let textView else { return }
        if wordWrapEnabled {
            textView.textContainer.lineBreakMode = .byWordWrapping
            textView.textContainer.widthTracksTextView = true
            textView.isScrollEnabled = true
        } else {
            textView.textContainer.lineBreakMode = .byClipping
            textView.textContainer.widthTracksTextView = false
            textView.textContainer.size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            textView.isScrollEnabled = true
        }
        textView.setNeedsDisplay()
        textView.setNeedsLayout()
    }

    // MARK: - Attribute Queries

    func updateCurrentAttributes() {
        let location = selectedRange.location
        guard location > 0 || attributedText.length > 0 else { return }

        let queryLocation = min(max(location - 1, 0), attributedText.length - 1)
        guard queryLocation >= 0, queryLocation < attributedText.length else { return }

        if let font = attributedText.currentFont(at: queryLocation) {
            let traits = font.fontDescriptor.symbolicTraits
            isBold = traits.contains(.traitBold)
            isItalic = traits.contains(.traitItalic)
            currentFontName = font.familyName
            currentFontSize = font.pointSize
        }

        let range = selectedRange.length > 0
            ? selectedRange
            : NSRange(location: queryLocation, length: 1)

        if range.location + range.length <= attributedText.length {
            let mutable = NSMutableAttributedString(attributedString: attributedText)
            isUnderline = mutable.hasUnderline(in: range)
            isStrikethrough = mutable.hasStrikethrough(in: range)
        }

        currentTextColor = attributedText.currentTextColor(at: queryLocation) ?? .label
        currentHighlightColor = attributedText.currentHighlightColor(at: queryLocation)
        currentAlignment = attributedText.currentAlignment(at: queryLocation)
        currentLineSpacing = attributedText.currentLineSpacing(at: queryLocation)
    }

    // MARK: - Formatting

    func toggleBold() {
        applyToSelection { mutable, range, defaultFont in
            mutable.toggleTrait(.traitBold, in: range, defaultFont: defaultFont)
        }
    }

    func toggleItalic() {
        applyToSelection { mutable, range, defaultFont in
            mutable.toggleTrait(.traitItalic, in: range, defaultFont: defaultFont)
        }
    }

    func toggleUnderline() {
        applyToSelection { mutable, range, _ in
            mutable.toggleUnderline(in: range)
        }
    }

    func toggleStrikethrough() {
        applyToSelection { mutable, range, _ in
            mutable.toggleStrikethrough(in: range)
        }
    }

    func setAlignment(_ alignment: NSTextAlignment) {
        let range = effectiveParagraphRange()
        applyToRange(range) { mutable, range, _ in
            mutable.setAlignment(alignment, in: range)
        }
    }

    func setFont(_ fontFamily: FontFamily) {
        applyToSelection { mutable, range, defaultFont in
            mutable.setFontFamily(fontFamily.fontName, in: range, defaultFont: defaultFont)
        }
    }

    func setFontSize(_ size: CGFloat) {
        applyToSelection { mutable, range, defaultFont in
            mutable.setFontSize(size, in: range, defaultFont: defaultFont)
        }
    }

    func setTextColor(_ color: UIColor) {
        applyToSelection { mutable, range, _ in
            mutable.setTextColor(color, in: range)
        }
    }

    func setHighlightColor(_ color: UIColor?) {
        applyToSelection { mutable, range, _ in
            mutable.setHighlightColor(color, in: range)
        }
    }

    func setLineSpacing(_ spacing: CGFloat) {
        let range = effectiveParagraphRange()
        applyToRange(range) { mutable, range, _ in
            mutable.setLineSpacing(spacing, in: range)
        }
    }

    func setParagraphSpacing(_ spacing: CGFloat) {
        let range = effectiveParagraphRange()
        applyToRange(range) { mutable, range, _ in
            mutable.setParagraphSpacing(spacing, in: range)
        }
    }

    func setFirstLineIndent(_ indent: CGFloat) {
        let range = effectiveParagraphRange()
        applyToRange(range) { mutable, range, _ in
            mutable.setFirstLineIndent(indent, in: range)
        }
    }

    func setHeading(_ level: Int) {
        let range = effectiveParagraphRange()
        let sizes: [Int: CGFloat] = [1: 28, 2: 24, 3: 20, 0: currentFontSize]
        let size = sizes[level] ?? 16

        applyToRange(range) { mutable, range, defaultFont in
            mutable.setFontSize(size, in: range, defaultFont: defaultFont)
            if level > 0 {
                mutable.toggleTrait(.traitBold, in: range, defaultFont: defaultFont)
            }
        }
    }

    // MARK: - Private Helpers

    private func applyToSelection(
        _ modification: (NSMutableAttributedString, NSRange, UIFont) -> Void
    ) {
        let range = selectedRange
        guard range.length > 0 else { return }
        applyToRange(range, modification)
    }

    private func applyToRange(
        _ range: NSRange,
        _ modification: (NSMutableAttributedString, NSRange, UIFont) -> Void
    ) {
        guard range.length > 0, range.location + range.length <= attributedText.length else { return }

        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let defaultFont = AppSettings.shared.defaultUIFont
        modification(mutable, range, defaultFont)

        // Apply directly to textView for undo support
        if let textView {
            textView.textStorage.beginEditing()
            textView.textStorage.setAttributedString(mutable)
            textView.textStorage.endEditing()
            textView.selectedRange = range
        }

        attributedText = mutable
        document.attributedText = mutable
        hasUnsavedChanges = true
        updateCurrentAttributes()
        scheduleAutoSave()
    }

    private func effectiveParagraphRange() -> NSRange {
        let text = attributedText.string as NSString
        if selectedRange.length > 0 {
            return text.paragraphRange(for: selectedRange)
        }
        if selectedRange.location < text.length {
            return text.paragraphRange(for: NSRange(location: selectedRange.location, length: 0))
        }
        if text.length > 0 {
            return text.paragraphRange(for: NSRange(location: max(text.length - 1, 0), length: 0))
        }
        return NSRange(location: 0, length: text.length)
    }

    // MARK: - Word Count

    private func updateCounts() {
        let text = attributedText.string
        characterCount = text.count
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        wordCount = words.count
        totalLines = max(1, text.components(separatedBy: "\n").count)
    }

    // MARK: - Auto-save

    private func scheduleAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.save()
        }
    }

    func save() {
        guard hasUnsavedChanges else { return }
        document.save(to: document.fileURL, for: .forOverwriting) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.hasUnsavedChanges = false
                }
            }
        }
    }

    // MARK: - Toolbar Toggle

    func toggleToolbar(_ toolbar: ActiveToolbar) {
        withAnimation(AppTheme.smoothAnimation) {
            if activeToolbar == toolbar {
                activeToolbar = .none
            } else {
                activeToolbar = toolbar
            }
        }
    }

    deinit {
        autoSaveTimer?.invalidate()
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let editorSettingsChanged = Notification.Name("editorSettingsChanged")
}
