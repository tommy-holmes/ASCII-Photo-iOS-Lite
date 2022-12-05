import SwiftUI

struct GeneratedImageView: View {
    @Binding var isShowing: Bool
    
    @State private var textSize = 7.0
    @State private var showingAlert = false
    
    var parsed: String
    
    var body: some View {
        NavigationStack {
            ScrollView(.horizontal) {
                ScrollView {
                    Text(parsed)
                        .font(.system(size: textSize))
                        .monospaced()
                }
            }
            Slider(value: $textSize, in: 1...13, step: 0.5) {
                Text("Zoom")
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
                        UIPasteboard.general.string = parsed
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
