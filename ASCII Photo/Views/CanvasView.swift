import SwiftUI

private let glyphs: [Character] = ["$", "@", "B", "%", "8", "&", "W", "M", "#", "*", "o", "a", "h", "k", "b", "d", "p", "q", "w", "m", "Z", "O", "0", "Q", "L", "C", "J", "U", "Y", "X", "z", "c", "v", "u", "n", "x", "r", "j", "f", "t", "/", "\\", "|", ")", "(", "1", "}", "{", "]", "[", "?", "-", "_", "+", "~", ">", "<", "i", "!", "l", "I", ";", ":", ",", "\"", "^", "`", "\\", "\'", ".", " ", " ", " ", " ", " "]

struct CanvasView: View {
    @StateObject private var imageModel = ImageModel()
    
    @State private var parsingImage = false
    @State private var showingGeneratedImage = false
    @State private var parsedImage = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            SelectedImageView()
                .environmentObject(imageModel)
            
            Spacer()
            
            if imageModel.chosenImage?.image != nil {
                Button {
                    do {
                        parsingImage = true
                        parsedImage = try imageModel.generateArt(with: glyphs)
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
            GeneratedImageView(isShowing: $showingGeneratedImage, parsed: parsedImage)
        }
    }
}

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView()
    }
}
