import SwiftUI

struct CanvasView: View {
    @StateObject private var imageModel = ImageModel()
    
    @State private var parsingImage = false
    @State private var showingGeneratedImage = false
    @State private var parsedImage = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            SelectedImageView()
            
            Spacer()
            
            if imageModel.chosenImage?.image != nil {
                Button {
                    do {
                        parsingImage = true
                        try imageModel.generateArt(with: .ascii)
                        parsingImage = false
                        showingGeneratedImage = true
                    } catch {
                        print(error)
                    }
                } label: {
                    HStack {
                        if parsingImage {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .padding()
                        } else {
                            Text("Generate art")
                                .padding()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .disabled(parsingImage)
        .animation(.easeInOut(duration: 0.5), value: imageModel.chosenImage?.image)
        .sheet(isPresented: $showingGeneratedImage) {
            GeneratedImageView(isShowing: $showingGeneratedImage)
        }
        .environmentObject(imageModel)
    }
}

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView()
    }
}
