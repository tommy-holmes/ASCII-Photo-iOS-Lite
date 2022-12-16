import SwiftUI

struct GeneratedImageView: View {
    @Binding var isShowing: Bool
    
    @EnvironmentObject private var imageModel: ImageModel
    
    @State private var textSize = 2.0
    @State private var showingAlert = false
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
                    Button {
                        UIPasteboard.general.string = imageModel.parsedImageString
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
