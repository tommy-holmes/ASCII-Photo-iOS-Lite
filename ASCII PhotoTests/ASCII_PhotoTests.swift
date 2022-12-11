import XCTest

@testable import ASCII_Photo

final class ASCII_PhotoTests: XCTestCase {
    
    private let model = ImageModel()

    func testUpdateImage() throws {
        let img = UIImage(named: "saturn.jpg")!.cgImage!
        model.update(chosenImage: .init(cgImage: img))
        
        XCTAssertEqual(img, model.chosenImage!.cgImage, "Failed to update chosen image.")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
