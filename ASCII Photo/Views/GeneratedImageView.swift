import SwiftUI

struct GeneratedImageView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var imageModel: ImageModel
    
    @State private var inverted = false
    
    var body: some View {
        NavigationStack {
            ImagePreviewView(uiImage: imageModel.parsedImage?.uiImage)
                .contextMenu {
                    ShareLink("Copy Text", item: imageModel.parsedImageString)
                }
            
            Spacer()
            
            Toggle("Invert", isOn: $inverted)
                .onChange(of: inverted) { _ in
                    imageModel.invert()
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                    if let image = imageModel.parsedImage {
                        ToolbarItem(placement: .primaryAction) {
                            ShareLink(item: image, preview: .init("ASCII Image"))
                        }
                    }
                }
        }
        .interactiveDismissDisabled()
    }
}
