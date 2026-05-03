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

        // Trigger line number update
        if let editorView = textView.superview as? LineNumberTextView {
            editorView.updateLineNumbers()
        }
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        guard !isUpdatingFromViewModel else { return }
        viewModel.selectionDidChange(textView.selectedRange)

        // Update line numbers to highlight current line
        if let editorView = textView.superview as? LineNumberTextView {
            editorView.updateLineNumbers()
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if viewModel.activeToolbar == .none {
            viewModel.activeToolbar = .formatting
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.save()
    }
}
