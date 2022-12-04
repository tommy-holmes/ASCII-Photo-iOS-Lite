import UIKit
import Accelerate

struct GlyphParserConfigs {
    var glyphRowLength = 200
    var isColorEnabled = false
}

final class ImageToGlyphsParser {
    
    private(set) var parsed: String = ""
    
    private var cgImage: CGImage
    private var glyphs: [Character]
    private var cachedPixelData: [Pixel_8]?
    
    var configs: GlyphParserConfigs = .init()
    
    init(image: CGImage, glyphs: [Character]) throws {
        self.cgImage = image
        self.glyphs = glyphs
        
        cachedPixelData = try attributedPixelData(from: try sourceBuffer(for: image))
        parsed = generateArt()
    }
    
    func update(image: CGImage) throws {
        guard image != cgImage else { return }
        cgImage = image
        updateFormat(for: cgImage)
        cachedPixelData = try attributedPixelData(from: try sourceBuffer(for: image))
        parsed = generateArt()
    }
    
    func update(glyphs: [Character]) {
        guard glyphs != self.glyphs else { return }
        self.glyphs = glyphs
        parsed = generateArt()
    }
    
    private lazy var format: vImage_CGImageFormat = {
        guard let format = vImage_CGImageFormat(cgImage: cgImage) else {
            fatalError("unable to create format")
        }
        return format
    }()
    
    private func updateFormat(for image: CGImage) {
        guard let format = vImage_CGImageFormat(cgImage: cgImage) else {
            fatalError("unable to create format")
        }
        self.format = format
    }
    
    private func sourceBuffer(for image: CGImage) throws -> vImage_Buffer {
        let width = configs.glyphRowLength
        let height = width * cgImage.height / cgImage.width / 2
        
        var sourceImageBuffer = try vImage_Buffer(cgImage: cgImage, format: format)
        var scaledBuffer = try vImage_Buffer(width: width, height: height, bitsPerPixel: format.bitsPerPixel)
        
        defer { sourceImageBuffer.free() }
        vImageScale_ARGB8888(&sourceImageBuffer,
                             &scaledBuffer,
                             nil,
                             vImage_Flags(kvImageNoFlags))
        
        return scaledBuffer
    }
    
    private func attributedPixelData(from imageBuffer: vImage_Buffer) throws -> [Pixel_8] {
        let cgImage = try imageBuffer.createCGImage(format: format)
        
        let source = try vImage.PixelBuffer<vImage.Interleaved8x4>(cgImage: cgImage, cgImageFormat: &format)
        let destination = vImage.PixelBuffer<vImage.Planar8>(size: source.size)
        
        let divisor: Int32 = 0x1000
        let fDivisor = Float(divisor)
        
        let redCoefficient: Float = 0.2126
        let greenCoefficient: Float = 0.7152
        let blueCoefficient: Float = 0.0722
        
        let matrix = [
            0,
            Int16(redCoefficient * fDivisor),
            Int16(greenCoefficient * fDivisor),
            Int16(blueCoefficient * fDivisor)
        ]
        
        source.withUnsafePointerToVImageBuffer { src in
            destination.withUnsafePointerToVImageBuffer { dest in
                
                _ = vImageMatrixMultiply_ARGB8888ToPlanar8(
                    src,
                    dest,
                    matrix,
                    divisor,
                    nil,
                    0,
                    vImage_Flags(kvImageNoFlags))
            }
        }
        return destination.array
    }
    
    private func generateArt() -> String {
        guard let cachedPixelData else { return "" }
        
        var asciiString = ""
        
        for (ix, pixel) in cachedPixelData.enumerated() {
            let value = Float(pixel) / Float(256) * Float(glyphs.count)
            let glyphIndex = glyphs.count - 1 - Int(value)
            asciiString.append(glyphs[glyphIndex])
            if ix % configs.glyphRowLength == 0 {
                asciiString.append("\n")
            }
        }
        return asciiString
    }
}
