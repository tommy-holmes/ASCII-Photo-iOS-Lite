import UIKit
import Accelerate

struct GlyphParserConfigs {
    enum Scheme {
        case light
        case dark
    }
    
    var glyphRowLength = 300
    var perferredScheme: Scheme = .dark
}

final class ImageToGlyphsParser {
    
    private(set) lazy var parsed: String = {
        generateArt()
    }()
    private var cgImage: CGImage?
    private var glyphs: Glyphs = .ascii
    private var cachedPixelData: [Pixel_8]!
    
    var configs = GlyphParserConfigs()
    
    func update(image: CGImage, glyphs: Glyphs? = nil) throws {
        guard image != cgImage else { return }
        cgImage = image
        updateFormat(for: image)
        cachedPixelData = try attributedPixelData(from: try sourceBuffer(for: image))
        
        if let glyphs { self.glyphs = glyphs }
        parsed = generateArt()
    }
    
    func update(glyphs: Glyphs) {
        guard glyphs != self.glyphs else { return }
        self.glyphs = glyphs
        parsed = generateArt()
    }
    
    func invert() {
        update(glyphs: glyphs.reversed())
    }
    
    func drawImage() -> UIImage {
        let fgColor = configs.perferredScheme == .light ? UIColor.black : UIColor.white
        let bgColor = configs.perferredScheme == .light ? UIColor.white : UIColor.black
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.monospacedSystemFont(ofSize: 5, weight: .regular),
            NSAttributedString.Key.foregroundColor: fgColor,
        ]
        let attrText = NSAttributedString(string: parsed, attributes: attributes)
        let textSize = attrText.size()
        let renderer = UIGraphicsImageRenderer(size: textSize)
        
        return renderer.image { context in
            bgColor.setFill()
            context.fill(.init(origin: .zero, size: textSize))
            attrText.draw(at: .zero)
        }
    }
    
    private lazy var format: vImage_CGImageFormat = {
        guard let cgImage, let format = vImage_CGImageFormat(cgImage: cgImage) else {
            fatalError("unable to create format")
        }
        return format
    }()
    
    private func updateFormat(for image: CGImage) {
        guard let format = vImage_CGImageFormat(cgImage: image) else {
            fatalError("unable to create format")
        }
        self.format = format
    }
    
    private func sourceBuffer(for image: CGImage) throws -> vImage_Buffer {
        let width = configs.glyphRowLength
        let height = width * image.height / image.width / 2
        
        var sourceImageBuffer = try vImage_Buffer(cgImage: image, format: format)
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
        var asciiString = ""
        
        for (ix, pixel) in cachedPixelData.enumerated() {
            let value = Float(pixel) / Float(256) * Float(glyphs.charaters.count)
            let glyphIndex = glyphs.charaters.count - 1 - Int(value)
            asciiString.append(glyphs.charaters[glyphIndex])
            if ix % configs.glyphRowLength == 0 {
                asciiString.append("\n")
            }
        }
        return asciiString
    }
}
