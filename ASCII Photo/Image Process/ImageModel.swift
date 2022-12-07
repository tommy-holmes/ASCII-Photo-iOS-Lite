import SwiftUI
import PhotosUI
import CoreTransferable

enum ParserError: Error {
    case noImage
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
    @Published private(set) var parsedImage: String = ""
    
    let camera = Camera()
    
    private var parser: ImageToGlyphsParser? {
        didSet {
            guard let parser else { return }
            self.parsedImage = parser.parsed
        }
    }
    
    func generateArt(with glyphs: Glyphs) throws {
        guard let cgImage = chosenImage?.cgImage else { throw ParserError.noImage }
        self.parser = try ImageToGlyphsParser(image: cgImage, glyphs: glyphs)
    }
    
    func update(chosenImage: ChosenImage?) {
        if let chosenImage {
            set(chosenImage: chosenImage)
        } else {
            state = .failure(TransferError.importFailed)
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
    
    func handleCameraPhotos() async {
        let unpackedStream = camera.photoStream
            .compactMap { self.unpackPhoto($0) }
        
        for await image in unpackedStream {
            Task { @MainActor in
                chosenImage = image
            }
        }
    }
    
    func reset() {
        chosenImage = nil
        state = .empty
    }
    
    func invert() {
        guard let parser else { return }
        parser.invert()
        parsedImage = parser.parsed
    }
    
    private func set(chosenImage: ChosenImage) {
        self.state = .success(chosenImage.image)
        self.chosenImage = chosenImage
    }
    
    private func unpackPhoto(_ photo: AVCapturePhoto) -> ChosenImage? {
        guard let cgImage = photo.cgImageRepresentation() else { return nil }
        
        return ChosenImage(cgImage: cgImage)
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
