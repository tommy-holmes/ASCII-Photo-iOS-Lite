import SwiftUI
import PhotosUI

struct SelectedImageView: View {
    @EnvironmentObject private var model: ImageModel
    
    @State private var payloadInDropArea: Bool = false
    @State private var selectedItem: PhotosPickerItem?
    
    private let haptics = UIImpactFeedbackGenerator()
    
    var body: some View {
        Group {
            switch model.state {
            case .empty:
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .foregroundStyle(.regularMaterial)
                        .overlay {
                            if payloadInDropArea {
                                RoundedRectangle(cornerRadius: 13)
                                    .stroke(style: .init(lineWidth: 4, dash: [13]))
                                    .foregroundStyle(.selection)
                            }
                        }
                    
                    VStack(spacing: 20) {
                        Label("Drag & Drop Image", systemImage: "square.and.arrow.down")
                            .foregroundStyle(.secondary)
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Label("Select Image", systemImage: "photo")
                                .controlSize(.large)
                        }
                    }
                }
                .dropDestination(for: ImageModel.ChosenImage.self) { items, _ in
                    model.update(chosenImage: items.first)
                    return true
                } isTargeted: { inDropArea in
                    payloadInDropArea = inDropArea
                    if inDropArea { haptics.impactOccurred() }
                }
                
            case .success(let image):
                VStack(spacing: 20) {
                    image
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                        .scaledToFit()
                    
                    Button {
                        model.reset()
                    } label: {
                        Text("Choose another")
                    }
                }
                
            case .loading(let progress):
                ProgressView(progress)
                
            case .failure(let error):
                VStack(spacing: 20) {
                    Label("Error", systemImage: "xmark.circle")
                        .foregroundStyle(.red)
                    
                    Text(error.localizedDescription)
                    
                    Button {
                        model.reset()
                    } label: {
                        Label("Try again", systemImage: "gobackward")
                    }

                }
            }
        }
        .onChange(of: selectedItem) { _ in
            model.update(selectedItem: selectedItem)
        }
    }
}

struct SelectedImageView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedImageView()
    }
}
