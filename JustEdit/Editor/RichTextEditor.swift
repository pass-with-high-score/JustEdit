import SwiftUI
import UIKit

// MARK: - Rich Text Editor (UIViewRepresentable)

struct RichTextEditor: UIViewRepresentable {
    var viewModel: EditorViewModel

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
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
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 80, right: 16)
        textView.font = AppSettings.shared.defaultUIFont
        textView.backgroundColor = .clear
        textView.tintColor = UIColor(AppTheme.primary)
        textView.keyboardDismissMode = .interactive

        // Store reference in viewModel for direct manipulation
        viewModel.textView = textView

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        // Only update if the change came from the viewModel (formatting), not from typing
        guard context.coordinator.isUpdatingFromViewModel else {
            // Check if text was changed externally (e.g., formatting command)
            if textView.attributedText != viewModel.attributedText
                && !textView.isFirstResponder
            {
                context.coordinator.isUpdatingFromViewModel = true
                textView.attributedText = viewModel.attributedText
                context.coordinator.isUpdatingFromViewModel = false
            }
            return
        }
    }

    func makeCoordinator() -> RichTextCoordinator {
        RichTextCoordinator(viewModel: viewModel)
    }
}
