import SwiftUI

struct GeneratedImageView: View {
    @Binding var isShowing: Bool
    
    @EnvironmentObject private var imageModel: ImageModel
    
    @State private var textSize = 2.0
    @State private var inverted = false
    
    var body: some View {
        NavigationStack {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollView(showsIndicators: false) {
                    Text(imageModel.parsedImageString)
                        .font(.system(size: textSize))
                        .monospaced()
                }
            }
            .contextMenu {
                ShareLink("Copy Text", item: imageModel.parsedImageString)
            }
            
            VStack(spacing: 20) {
                Stepper("Zoom", value: $textSize, in: 1...13, step: 0.5)
                
                Toggle("Invert", isOn: $inverted)
                    .onChange(of: inverted) { _ in
                        imageModel.invert()
                    }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isShowing = false
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: imageModel.drawImage(), preview: .init("ASCII Image"))
                }
            }
        }
        .interactiveDismissDisabled()
    }
}
