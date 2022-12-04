import SwiftUI

struct GeneratedImageView: View {
    @Binding var isShowing: Bool
    
    @State private var textSize = 7.0
    
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
            Slider(value: $textSize, in: 1...13, step: 1) {
                Text("Zoom")
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isShowing = false
                    }
                }
            }
        }
    }
}
