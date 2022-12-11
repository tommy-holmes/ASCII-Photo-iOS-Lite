import XCTest

@testable import ASCII_Photo

final class ASCII_PhotoTests: XCTestCase {
    
    private let model = ImageModel()

    func testUpdateImage() {
        let actual = UIImage(named: "saturn.jpg")!.cgImage!
        let intial = model.chosenImage?.cgImage
        
        model.update(chosenImage: .init(cgImage: actual))
        let final = model.chosenImage!.cgImage
        
        XCTAssertNotEqual(intial, final, "Failed to update chosen image.")
        XCTAssertEqual(actual, final, "Failed to update to chosen image.")
        switch model.state {
        case .success:
            XCTAssert(true)
        default:
            XCTFail("State not updated.")
        }
    }
    
    func testResetModel() {
        let img = UIImage(named: "saturn.jpg")!.cgImage!
        model.update(chosenImage: .init(cgImage: img))
        let updated = model.chosenImage!.cgImage
        
        XCTAssertEqual(img, updated, "Failed to update chosen image.")
        
        model.reset()
        XCTAssertNil(model.chosenImage, "Chosen image not reset.")
        switch model.state {
        case .empty:
            XCTAssert(true)
        default:
            XCTFail("State not updated.")
        }
    }

    func testPerformanceGenerateArt() {
        let img = UIImage(named: "saturn.jpg")!.cgImage!
        model.update(chosenImage: .init(cgImage: img))
        measure {
            try! model.generateArt(with: .ascii)
        }
    }

}
