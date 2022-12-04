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
    
    func generateArt(with glyphs: [Character]) throws -> String {
        guard let cgImage = chosenImage?.cgImage else { throw ParserError.noImage }
        let parser = try ImageToGlyphsParser(image: cgImage, glyphs: glyphs)
        
        return parser.parsed
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
    
    func reset() {
        chosenImage = nil
        state = .empty
    }
    
    private func set(chosenImage: ChosenImage) {
        self.state = .success(chosenImage.image)
        self.chosenImage = chosenImage
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
        let image: Image
        let cgImage: CGImage
        
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
            #if canImport(AppKit)
                guard let nsImage = NSImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(nsImage: nsImage)
                return ChosenImage(image: image)
            #elseif canImport(UIKit)
                guard
                    let uiImage = UIImage(data: data),
                    let cgImage = uiImage.cgImage
                else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return ChosenImage(image: image, cgImage: cgImage)
            #else
                throw TransferError.importFailed
            #endif
            }
        }
    }
}
