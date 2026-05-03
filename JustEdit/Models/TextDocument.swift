import UIKit
import UniformTypeIdentifiers

// MARK: - TextDocument (UIDocument)

final class TextDocument: UIDocument {

    var attributedText: NSAttributedString = NSAttributedString()
    var documentFileType: DocumentFileType = .plainText

    // MARK: - Save

    override func contents(forType typeName: String) throws -> Any {
        let utType = UTType(typeName)

        if utType == .rtf || documentFileType == .richText {
            let range = NSRange(location: 0, length: attributedText.length)
            if range.length > 0 {
                return try attributedText.data(
                    from: range,
                    documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
                )
            }
            return Data()
        } else {
            return attributedText.string.data(using: .utf8) ?? Data()
        }
    }

    // MARK: - Load

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else {
            attributedText = NSAttributedString()
            return
        }

        let utType = typeName.flatMap { UTType($0) }
        let isRTF = utType == .rtf || documentFileType == .richText

        if isRTF {
            if let rtfText = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
            ) {
                attributedText = rtfText
            } else {
                // Fallback to plain text if RTF parsing fails
                let str = String(data: data, encoding: .utf8) ?? ""
                attributedText = NSAttributedString(string: str, attributes: defaultAttributes())
            }
        } else {
            let str = String(data: data, encoding: .utf8) ?? ""
            attributedText = NSAttributedString(string: str, attributes: defaultAttributes())
        }
    }

    // MARK: - Default Attributes

    private func defaultAttributes() -> [NSAttributedString.Key: Any] {
        let font = AppSettings.shared.defaultUIFont
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4

        return [
            .font: font,
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle,
        ]
    }

    // MARK: - Convenience

    static func create(
        name: String,
        fileType: DocumentFileType,
        in directory: URL
    ) -> TextDocument {
        let fileName = "\(name).\(fileType.fileExtension)"
        let fileURL = directory.appendingPathComponent(fileName)

        let document = TextDocument(fileURL: fileURL)
        document.documentFileType = fileType
        document.attributedText = NSAttributedString(
            string: "",
            attributes: document.defaultAttributes()
        )
        return document
    }
}
