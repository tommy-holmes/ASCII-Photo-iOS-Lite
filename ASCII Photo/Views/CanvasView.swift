import SwiftUI

struct CanvasView: View {
    @StateObject private var imageModel = ImageModel()
    
    @State private var parsingImage = false
    @State private var showingGeneratedImage = false
    @State private var parsedImage = ""
    @State private var parseError: AlertError?
    
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
                        imageModel.drawImage()
                        parsingImage = false
                        showingGeneratedImage = true
                    } catch {
                        parseError = .init(error)
                    }
                } label: {
                    HStack {
                        if parsingImage {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Text("Generate art")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .disabled(parsingImage)
        .animation(.easeInOut(duration: 0.5), value: imageModel.chosenImage?.image)
        .sheet(isPresented: $showingGeneratedImage) {
            GeneratedImageView()
        }
        .alert($parseError)
        .environmentObject(imageModel)
    }
}

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView()
    }
}
