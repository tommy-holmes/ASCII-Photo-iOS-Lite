import SwiftUI

struct CameraView: View {
    @EnvironmentObject private var model: ImageModel
    
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ViewfinderView(image: $model.viewfinderImage)
            }
            .task {
                try? await model.camera.start()
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(isPresented: .constant(true))
    }
}
