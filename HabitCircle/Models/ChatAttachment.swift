import SwiftUI
import PhotosUI

/// Pending photo attachment in the chat composer (ChatGPT-style).
struct ChatAttachment: Equatable {
    let image: UIImage
    let previewAssetName: String?

    static func == (lhs: ChatAttachment, rhs: ChatAttachment) -> Bool {
        lhs.previewAssetName == rhs.previewAssetName
    }
}