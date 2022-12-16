import SwiftUI
import PhotosUI
import CoreTransferable

enum ParserError: Error {
    case noImage
    case drawFailed
}

final class ImageModel: ObservableObject {
    enum ImageState {
        case empty
        case success(Image)
        case loading(Progress)
        case failure(Error)
    }
    @Published private(set) var state: ImageState = .empty
    @Published private(set) var chosenImage: ChosenImage?
    @Published private(set) var parsedImageString = ""
    @Published var viewfinderImage: Image?
    
    private var parser = ImageToGlyphsParser()
    
    let camera = Camera()
    
    init() {
        Task { await handleCameraPreviews() }
        Task { await handleCameraPhotos() }
        
        self.camera.takingPhotoHandler = {
            assert(Thread.isMainThread)
            self.state = .loading(.init())
        }
    }
    
    func generateArt(with glyphs: Glyphs) throws {
        guard let cgImage = chosenImage?.cgImage else { throw ParserError.noImage }

        try parser.update(image: cgImage)
        parser.update(glyphs: glyphs)
        parsedImageString = parser.generateArtString()
    }
    
    func update(chosenImage: ChosenImage?) {
        if let chosenImage {
            set(chosenImage: chosenImage)
        } else {
            state = .failure(TransferError.noImage)
        }
    }
    
    func update(selectedItem: PhotosPickerItem?) {
        if let selectedItem {
            let progress = loadTransferable(from: selectedItem)
            state = .loading(progress)
        } else {
            reset()
        }
    }
    
    func reset() {
        chosenImage = nil
        state = .empty
    }
    
    func invert() {
        parser.invert()
        parsedImageString = parser.generateArtString()
    }
    
    func drawImage() -> GeneratedImage {
        let uiImage = parser.drawImage(from: parsedImageString)
        return GeneratedImage(uiImage: uiImage)
    }
    
    private func set(chosenImage: ChosenImage) {
        state = .success(chosenImage.image)
        self.chosenImage = chosenImage
    }
    
    private func unpackPhoto(_ photo: AVCapturePhoto) -> ChosenImage? {
        guard let cgImage = photo.cgImageRepresentation() else { return nil }
        
        return ChosenImage(cgImage: cgImage)
    }
    
    private func handleCameraPreviews() async {
        let imageStream = camera.previewStream
            .map { $0.image }
        
        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image
            }
        }
    }
    
    private func handleCameraPhotos() async {
        let unpackedStream = camera.photoStream
            .compactMap { self.unpackPhoto($0) }
        
        for await image in unpackedStream {
            Task { @MainActor in
                update(chosenImage: image)
                camera.stop()
            }
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        imageSelection.loadTransferable(type: ChosenImage.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let chosenImage?):
                    self?.set(chosenImage: chosenImage)
                case .success(nil):
                    self?.reset()
                case .failure(let error):
                    self?.state = .failure(error)
                }
            }
        }
    }
    
}

extension ImageModel {
    enum TransferError: Error {
        case importFailed
        case noImage
    }
    
    struct ChosenImage: Transferable {
        let cgImage: CGImage
        let image: Image
        
        init(cgImage: CGImage) {
            self.cgImage = cgImage
            self.image = Image(uiImage: UIImage(cgImage: cgImage))
        }
        
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
                guard
                    let uiImage = UIImage(data: data),
                    let cgImage = uiImage.cgImage
                else {
                    throw TransferError.importFailed
                }
                return ChosenImage(cgImage: cgImage)
            }
        }
    }
}

extension ImageModel {
    struct GeneratedImage: Transferable {
        let uiImage: UIImage
        let image: Image
        
        init(uiImage: UIImage) {
            self.uiImage = uiImage
            self.image = Image(uiImage: uiImage)
        }
        
        static var transferRepresentation: some TransferRepresentation {
            ProxyRepresentation(exporting: \.image)
        }
    }
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}
