import SwiftUI
import UIKit

// MARK: - Rich Text Editor (UIViewRepresentable)

struct RichTextEditor: UIViewRepresentable {
    var viewModel: EditorViewModel

    func makeUIView(context: Context) -> LineNumberTextView {
        let editorView = LineNumberTextView()
        let textView = editorView.textView

        textView.delegate = context.coordinator
        textView.attributedText = viewModel.attributedText
        textView.isEditable = true
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.allowsEditingTextAttributes = viewModel.isRichText
        textView.autocorrectionType = .default
        textView.spellCheckingType = .default
        textView.smartQuotesType = .default
        textView.smartDashesType = .default
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 60, right: 12)
        textView.font = AppSettings.shared.defaultUIFont
        textView.backgroundColor = .clear
        textView.tintColor = UIColor(AppTheme.primary)
        textView.keyboardDismissMode = .interactive

        editorView.showLineNumbers = viewModel.showLineNumbers

        // Store reference in viewModel for direct manipulation
        viewModel.textView = textView

        return editorView
    }

    func updateUIView(_ editorView: LineNumberTextView, context: Context) {
        // Sync line number visibility
        if editorView.showLineNumbers != viewModel.showLineNumbers {
            editorView.showLineNumbers = viewModel.showLineNumbers
        }

        // Sync word wrap
        let textView = editorView.textView
        if viewModel.wordWrapEnabled {
            if !textView.textContainer.widthTracksTextView {
                textView.textContainer.widthTracksTextView = true
                textView.textContainer.lineBreakMode = .byWordWrapping
                textView.setNeedsLayout()
            }
        } else {
            if textView.textContainer.widthTracksTextView {
                textView.textContainer.widthTracksTextView = false
                textView.textContainer.size = CGSize(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: CGFloat.greatestFiniteMagnitude
                )
                textView.textContainer.lineBreakMode = .byClipping
                textView.setNeedsLayout()
            }
        }

        // Update text only when not actively editing
        let tv = editorView.textView
        if !context.coordinator.isUpdatingFromViewModel && !tv.isFirstResponder {
            if tv.attributedText != viewModel.attributedText {
                context.coordinator.isUpdatingFromViewModel = true
                tv.attributedText = viewModel.attributedText
                context.coordinator.isUpdatingFromViewModel = false
                editorView.updateLineNumbers()
            }
        }
    }

    func makeCoordinator() -> RichTextCoordinator {
        RichTextCoordinator(viewModel: viewModel)
    }
}

// MARK: - LineNumberTextView (UIKit Container)

final class LineNumberTextView: UIView {

    let textView = UITextView()
    let gutterView = LineGutterView()
    private let gutterSeparator = UIView()

    private let gutterWidth: CGFloat = 44

    var showLineNumbers: Bool = false {
        didSet {
            gutterView.isHidden = !showLineNumbers
            gutterSeparator.isHidden = !showLineNumbers
            updateTextViewInsets()
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // Gutter
        gutterView.translatesAutoresizingMaskIntoConstraints = false
        gutterView.isHidden = true
        addSubview(gutterView)

        // Separator
        gutterSeparator.translatesAutoresizingMaskIntoConstraints = false
        gutterSeparator.backgroundColor = UIColor.separator.withAlphaComponent(0.3)
        gutterSeparator.isHidden = true
        addSubview(gutterSeparator)

        // Text view
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        addSubview(textView)

        NSLayoutConstraint.activate([
            // Gutter
            gutterView.topAnchor.constraint(equalTo: topAnchor),
            gutterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gutterView.bottomAnchor.constraint(equalTo: bottomAnchor),
            gutterView.widthAnchor.constraint(equalToConstant: gutterWidth),

            // Separator
            gutterSeparator.topAnchor.constraint(equalTo: topAnchor),
            gutterSeparator.leadingAnchor.constraint(equalTo: gutterView.trailingAnchor),
            gutterSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
            gutterSeparator.widthAnchor.constraint(equalToConstant: 0.5),

            // Text view fills remaining space
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // Dynamic leading constraint for textView
        updateTextViewLeadingConstraint()

        // Observe text view scroll & text changes
        textView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification, object: textView
        )
    }

    private var textViewLeadingConstraint: NSLayoutConstraint?

    private func updateTextViewLeadingConstraint() {
        textViewLeadingConstraint?.isActive = false
        if showLineNumbers {
            textViewLeadingConstraint = textView.leadingAnchor.constraint(
                equalTo: gutterSeparator.trailingAnchor
            )
        } else {
            textViewLeadingConstraint = textView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            )
        }
        textViewLeadingConstraint?.isActive = true
    }

    private func updateTextViewInsets() {
        updateTextViewLeadingConstraint()
        if showLineNumbers {
            textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 60, right: 12)
        } else {
            textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 60, right: 12)
        }
    }

    // KVO for scroll sync
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "contentOffset" {
            updateLineNumbers()
        }
    }

    @objc private func textDidChange() {
        updateLineNumbers()
    }

    func updateLineNumbers() {
        guard showLineNumbers, !gutterView.isHidden else { return }
        gutterView.update(
            textView: textView,
            gutterWidth: gutterWidth
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLineNumbers()
    }

    deinit {
        textView.removeObserver(self, forKeyPath: "contentOffset")
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Line Gutter View (draws line numbers)

final class LineGutterView: UIView {

    private var lineData: [(number: Int, yPosition: CGFloat, isCurrent: Bool)] = []
    private var currentLine: Int = 1

    private let numberFont = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    private let currentNumberFont = UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold)
    private let numberColor = UIColor.secondaryLabel.withAlphaComponent(0.45)
    private let currentNumberColor = UIColor(AppTheme.primary)
    private let gutterBackground = UIColor.secondarySystemBackground.withAlphaComponent(0.4)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    func update(textView: UITextView, gutterWidth: CGFloat) {
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        let text = textView.text ?? ""
        let contentOffset = textView.contentOffset
        let visibleRect = CGRect(
            x: 0,
            y: contentOffset.y,
            width: textView.bounds.width,
            height: textView.bounds.height
        )

        var newLineData: [(number: Int, yPosition: CGFloat, isCurrent: Bool)] = []

        // Calculate current line from cursor
        let cursorLocation = textView.selectedRange.location
        var currentLineNumber = 1
        let nsText = text as NSString
        for i in 0..<min(cursorLocation, nsText.length) {
            if nsText.character(at: i) == 10 { // \n
                currentLineNumber += 1
            }
        }
        currentLine = currentLineNumber

        // Walk through each line in the text
        let nsString = text as NSString
        var lineNumber = 0
        var charIndex = 0

        while charIndex <= nsString.length {
            lineNumber += 1
            let lineRange: NSRange
            if charIndex < nsString.length {
                lineRange = nsString.lineRange(for: NSRange(location: charIndex, length: 0))
            } else if charIndex == nsString.length && (nsString.length == 0 || nsString.character(at: nsString.length - 1) == 10) {
                // Empty last line after trailing newline
                lineRange = NSRange(location: charIndex, length: 0)
            } else {
                break
            }

            // Get the glyph range for this line
            let glyphRange: NSRange
            if lineRange.length > 0 {
                glyphRange = layoutManager.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)
            } else {
                // For empty trailing line, use the end position
                if layoutManager.numberOfGlyphs > 0 {
                    let lastGlyph = layoutManager.numberOfGlyphs - 1
                    var lastRect = layoutManager.lineFragmentRect(forGlyphAt: lastGlyph, effectiveRange: nil)
                    let yPos = lastRect.maxY + textView.textContainerInset.top
                    if yPos + 20 >= visibleRect.minY && yPos <= visibleRect.maxY {
                        newLineData.append((lineNumber, yPos - contentOffset.y, lineNumber == currentLine))
                    }
                } else {
                    let yPos = textView.textContainerInset.top
                    newLineData.append((lineNumber, yPos - contentOffset.y, lineNumber == currentLine))
                }
                break
            }

            // Get the first line fragment for this line (top of the line)
            if glyphRange.location < layoutManager.numberOfGlyphs {
                let lineRect = layoutManager.lineFragmentRect(
                    forGlyphAt: glyphRange.location, effectiveRange: nil
                )
                let yPos = lineRect.origin.y + textView.textContainerInset.top

                // Only include visible lines (with some buffer)
                if yPos + lineRect.height >= visibleRect.minY - 50 && yPos <= visibleRect.maxY + 50 {
                    newLineData.append((lineNumber, yPos - contentOffset.y, lineNumber == currentLine))
                }
            }

            // Move to next line
            let nextCharIndex = lineRange.location + lineRange.length
            if nextCharIndex <= charIndex {
                break // Safety: prevent infinite loop
            }
            charIndex = nextCharIndex
        }

        self.lineData = newLineData
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        // Draw gutter background
        ctx.setFillColor(gutterBackground.cgColor)
        ctx.fill(rect)

        // Draw each line number
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right

        for data in lineData {
            let isCurrent = data.isCurrent
            let attrs: [NSAttributedString.Key: Any] = [
                .font: isCurrent ? currentNumberFont : numberFont,
                .foregroundColor: isCurrent ? currentNumberColor : numberColor,
                .paragraphStyle: paragraphStyle,
            ]

            let numberString = "\(data.number)" as NSString
            let drawRect = CGRect(
                x: 2,
                y: data.yPosition + 1, // small offset for vertical centering
                width: bounds.width - 8,
                height: 20
            )
            numberString.draw(in: drawRect, withAttributes: attrs)

            // Current line highlight bar
            if isCurrent {
                ctx.setFillColor(currentNumberColor.withAlphaComponent(0.06).cgColor)
                ctx.fill(CGRect(x: 0, y: data.yPosition, width: bounds.width, height: 20))
            }
        }
    }
}
