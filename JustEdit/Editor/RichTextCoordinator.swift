import UIKit

// MARK: - Rich Text Coordinator

final class RichTextCoordinator: NSObject, UITextViewDelegate {
    var viewModel: EditorViewModel
    var isUpdatingFromViewModel = false

    init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        guard !isUpdatingFromViewModel else { return }
        viewModel.textDidChange(textView.attributedText)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        guard !isUpdatingFromViewModel else { return }
        viewModel.selectionDidChange(textView.selectedRange)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if viewModel.activeToolbar == .none {
            viewModel.activeToolbar = .formatting
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.save()
    }

    // MARK: - Typing Attributes

    func updateTypingAttributes(_ textView: UITextView) {
        // When no text is selected, set typing attributes for new text
        if viewModel.selectedRange.length == 0 {
            var attrs = textView.typingAttributes
            if let font = attrs[.font] as? UIFont {
                var traits = font.fontDescriptor.symbolicTraits
                if viewModel.isBold {
                    traits.insert(.traitBold)
                }
                if viewModel.isItalic {
                    traits.insert(.traitItalic)
                }
                if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                    attrs[.font] = UIFont(descriptor: descriptor, size: font.pointSize)
                }
            }
            textView.typingAttributes = attrs
        }
    }
}
