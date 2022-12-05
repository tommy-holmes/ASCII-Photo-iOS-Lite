import SwiftUI

struct GeneratedImageView: View {
    @Binding var isShowing: Bool
    
    @EnvironmentObject private var imageModel: ImageModel
    
    @State private var textSize = 7.0
    @State private var showingAlert = false
    @State private var inverted = false
    
    var body: some View {
        NavigationStack {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollView(showsIndicators: false) {
                    Text(imageModel.parsedImage)
                        .font(.system(size: textSize))
                        .monospaced()
                }
            }
            
            VStack {
                Slider(value: $textSize, in: 1...13, step: 0.5) {
                    Text("Zoom")
                }
                
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
                    Button {
                        UIPasteboard.general.string = imageModel.parsedImage
                        showingAlert = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .alert("Copied to clipboard", isPresented: $showingAlert) {
                Button("Okay") {
                    showingAlert = false
                }
            }
        }
    }
}
