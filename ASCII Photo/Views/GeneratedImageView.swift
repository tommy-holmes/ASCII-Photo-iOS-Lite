import SwiftUI

struct GeneratedImageView: View {
    @Binding var isShowing: Bool
    
    var parsed: String
    
    var body: some View {
        NavigationStack {
            ScrollView(.horizontal) {
                ScrollView {
                    Text(parsed)
                        .font(.system(size: 7))
                        .monospaced()
                }
            }
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

//struct GeneratedImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeneratedImageView(cgImage: cgImage)
//    }
//}
