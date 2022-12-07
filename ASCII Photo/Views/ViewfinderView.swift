import SwiftUI

struct ViewfinderView: View {
    @Binding var image: Image?
    
    var body: some View {
        GeometryReader { geo in
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

struct ViewfinderView_Previews: PreviewProvider {
    static var previews: some View {
        ViewfinderView(image: .constant(.init(systemName: "camera")))
    }
}
