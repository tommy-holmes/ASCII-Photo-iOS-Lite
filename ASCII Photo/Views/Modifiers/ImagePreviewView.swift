import SwiftUI

struct ImagePreviewView: View {
    var uiImage: UIImage?
    
    var body: some View {
        Representatble(uiImage: uiImage)
    }
}

private extension ImagePreviewView {
    struct Representatble: UIViewRepresentable {
        let uiImage: UIImage?
        
        private var imageView: UIImageView
        
        init(uiImage: UIImage?) {
            self.uiImage = uiImage
            self.imageView = UIImageView(image: uiImage)
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(imageView)
        }
        
        func makeUIView(context: Context) -> UIScrollView {
            let sv = UIScrollView()
            sv.isDirectionalLockEnabled = false
            sv.showsHorizontalScrollIndicator = false
            sv.showsVerticalScrollIndicator = false
            sv.minimumZoomScale = 1
            sv.maximumZoomScale = uiImage?.size.width ?? 10
            sv.addSubview(imageView)
            sv.delegate = context.coordinator
            
            return sv
        }
        
        func updateUIView(_ uiView: UIScrollView, context: Context) {
            let imageView = uiView.subviews.first(where: { $0 is UIImageView }) as? UIImageView
            imageView?.image = uiImage
        }
    }
}

private extension ImagePreviewView.Representatble {
    final class Coordinator: NSObject, UIScrollViewDelegate {
        let image: UIImageView
        
        init(_ image: UIImageView) {
            self.image = image
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            image
        }
    }
}
