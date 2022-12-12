import SwiftUI

struct CameraView: View {
    @EnvironmentObject private var model: ImageModel
    
    @Binding var isPresented: Bool
    
    @State private var cameraError: AlertError?
    private static let barHeightFactor = 0.15
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ViewfinderView(image: $model.viewfinderImage)
                    .overlay(alignment: .top) {
                        Color.black
                            .opacity(0.25)
                            .frame(height: geo.size.height * Self.barHeightFactor)
                    }
                    .overlay(alignment: .bottom) {
                        actionsView()
                            .frame(height: geo.size.height * Self.barHeightFactor)
                            .padding()
                            .background(.black.opacity(0.75))
                    }
                    .overlay(alignment: .center)  {
                        Color.clear
                            .frame(height: geo.size.height * (1 - (Self.barHeightFactor * 2)))
                            .accessibilityElement()
                            .accessibilityLabel("View Finder")
                            .accessibilityAddTraits([.isImage])
                    }
                    .background(.black)
            }
            .task {
                do {
                    try await model.camera.start()
                } catch {
                    cameraError = .init(error)
                }
            }
            .alert($cameraError)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Close")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea()
            .statusBarHidden(true)
        }
    }
    
    private func actionsView() -> some View {
        HStack(alignment: .center) {
            Spacer()
            
            Button {
                model.camera.takePhoto()
                isPresented = false
            } label: {
                Label {
                    Text("Take photo")
                } icon: {
                    ZStack {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 62)
                        Circle()
                            .fill(.white)
                            .frame(width: 50)
                    }
                }
                .labelStyle(.iconOnly)
                .offset(x: 25)
            }
            
            Spacer()
            
            Button {
                model.camera.switchCaptureDevice()
            } label: {
                Label("Switch camera", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .labelStyle(.iconOnly)
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(isPresented: .constant(true))
            .preferredColorScheme(.dark)
    }
}
