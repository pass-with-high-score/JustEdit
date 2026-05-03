import UIKit

// MARK: - Trait Helpers

extension NSMutableAttributedString {

    // MARK: - Font Trait Toggling

    func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits, in range: NSRange, defaultFont: UIFont) {
        guard range.length > 0 else { return }

        let hasTrait = self.hasTrait(trait, in: range)

        enumerateAttribute(.font, in: range, options: []) { value, attrRange, _ in
            let font = (value as? UIFont) ?? defaultFont
            var traits = font.fontDescriptor.symbolicTraits

            if hasTrait {
                traits.remove(trait)
            } else {
                traits.insert(trait)
            }

            if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                let newFont = UIFont(descriptor: descriptor, size: font.pointSize)
                addAttribute(.font, value: newFont, range: attrRange)
            }
        }
    }

    func hasTrait(_ trait: UIFontDescriptor.SymbolicTraits, in range: NSRange) -> Bool {
        guard range.length > 0, range.location + range.length <= length else { return false }
        var found = true
        enumerateAttribute(.font, in: range, options: []) { value, _, stop in
            guard let font = value as? UIFont else {
                found = false
                stop.pointee = true
                return
            }
            if !font.fontDescriptor.symbolicTraits.contains(trait) {
                found = false
                stop.pointee = true
            }
        }
        return found
    }

    // MARK: - Underline / Strikethrough

    func toggleUnderline(in range: NSRange) {
        guard range.length > 0 else { return }
        let hasUnderline = self.hasUnderline(in: range)
        if hasUnderline {
            removeAttribute(.underlineStyle, range: range)
        } else {
            addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
    }

    func hasUnderline(in range: NSRange) -> Bool {
        guard range.length > 0, range.location + range.length <= length else { return false }
        var found = true
        enumerateAttribute(.underlineStyle, in: range, options: []) { value, _, stop in
            if value == nil {
                found = false
                stop.pointee = true
            }
        }
        return found
    }

    func toggleStrikethrough(in range: NSRange) {
        guard range.length > 0 else { return }
        let has = self.hasStrikethrough(in: range)
        if has {
            removeAttribute(.strikethroughStyle, range: range)
        } else {
            addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
    }

    func hasStrikethrough(in range: NSRange) -> Bool {
        guard range.length > 0, range.location + range.length <= length else { return false }
        var found = true
        enumerateAttribute(.strikethroughStyle, in: range, options: []) { value, _, stop in
            if value == nil {
                found = false
                stop.pointee = true
            }
        }
        return found
    }

    // MARK: - Font & Size

    func setFontFamily(_ fontFamily: String, in range: NSRange, defaultFont: UIFont) {
        guard range.length > 0 else { return }
        enumerateAttribute(.font, in: range, options: []) { value, attrRange, _ in
            let currentFont = (value as? UIFont) ?? defaultFont
            let traits = currentFont.fontDescriptor.symbolicTraits
            var descriptor = UIFontDescriptor(name: fontFamily, size: currentFont.pointSize)
            if let withTraits = descriptor.withSymbolicTraits(traits) {
                descriptor = withTraits
            }
            let newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
            addAttribute(.font, value: newFont, range: attrRange)
        }
    }

    func setFontSize(_ size: CGFloat, in range: NSRange, defaultFont: UIFont) {
        guard range.length > 0 else { return }
        enumerateAttribute(.font, in: range, options: []) { value, attrRange, _ in
            let currentFont = (value as? UIFont) ?? defaultFont
            let newFont = currentFont.withSize(size)
            addAttribute(.font, value: newFont, range: attrRange)
        }
    }

    // MARK: - Colors

    func setTextColor(_ color: UIColor, in range: NSRange) {
        guard range.length > 0 else { return }
        addAttribute(.foregroundColor, value: color, range: range)
    }

    func setHighlightColor(_ color: UIColor?, in range: NSRange) {
        guard range.length > 0 else { return }
        if let color {
            addAttribute(.backgroundColor, value: color, range: range)
        } else {
            removeAttribute(.backgroundColor, range: range)
        }
    }

    // MARK: - Paragraph Style

    func setAlignment(_ alignment: NSTextAlignment, in range: NSRange) {
        guard range.length > 0 else { return }
        enumerateAttribute(.paragraphStyle, in: range, options: []) { value, attrRange, _ in
            let style = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle
                ?? NSMutableParagraphStyle()
            style.alignment = alignment
            addAttribute(.paragraphStyle, value: style, range: attrRange)
        }
    }

    func setLineSpacing(_ spacing: CGFloat, in range: NSRange) {
        guard range.length > 0 else { return }
        let fullRange = NSRange(location: 0, length: length)
        let effectiveRange = NSIntersectionRange(range, fullRange)
        guard effectiveRange.length > 0 else { return }

        enumerateAttribute(.paragraphStyle, in: effectiveRange, options: []) { value, attrRange, _ in
            let style = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle
                ?? NSMutableParagraphStyle()
            style.lineSpacing = spacing
            addAttribute(.paragraphStyle, value: style, range: attrRange)
        }
    }

    func setParagraphSpacing(_ spacing: CGFloat, in range: NSRange) {
        guard range.length > 0 else { return }
        enumerateAttribute(.paragraphStyle, in: range, options: []) { value, attrRange, _ in
            let style = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle
                ?? NSMutableParagraphStyle()
            style.paragraphSpacing = spacing
            addAttribute(.paragraphStyle, value: style, range: attrRange)
        }
    }

    func setFirstLineIndent(_ indent: CGFloat, in range: NSRange) {
        guard range.length > 0 else { return }
        enumerateAttribute(.paragraphStyle, in: range, options: []) { value, attrRange, _ in
            let style = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle
                ?? NSMutableParagraphStyle()
            style.firstLineHeadIndent = indent
            addAttribute(.paragraphStyle, value: style, range: attrRange)
        }
    }
}

// MARK: - Query Helpers

extension NSAttributedString {

    func currentFont(at location: Int) -> UIFont? {
        guard location < length else { return nil }
        return attribute(.font, at: location, effectiveRange: nil) as? UIFont
    }

    func currentTextColor(at location: Int) -> UIColor? {
        guard location < length else { return nil }
        return attribute(.foregroundColor, at: location, effectiveRange: nil) as? UIColor
    }

    func currentHighlightColor(at location: Int) -> UIColor? {
        guard location < length else { return nil }
        return attribute(.backgroundColor, at: location, effectiveRange: nil) as? UIColor
    }

    func currentAlignment(at location: Int) -> NSTextAlignment {
        guard location < length else { return .left }
        let style = attribute(.paragraphStyle, at: location, effectiveRange: nil) as? NSParagraphStyle
        return style?.alignment ?? .left
    }

    func currentLineSpacing(at location: Int) -> CGFloat {
        guard location < length else { return 0 }
        let style = attribute(.paragraphStyle, at: location, effectiveRange: nil) as? NSParagraphStyle
        return style?.lineSpacing ?? 0
    }
}
