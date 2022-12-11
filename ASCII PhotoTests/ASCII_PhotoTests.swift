import XCTest

@testable import ASCII_Photo

final class ASCII_PhotoTests: XCTestCase {
    
    private let model = ImageModel()

    func testUpdateImage() {
        let actual = UIImage(named: "saturn.jpg")!.cgImage!
        let intial = model.chosenImage?.cgImage
        
        model.update(chosenImage: .init(cgImage: actual))
        let updated = model.chosenImage!.cgImage
        
        XCTAssertNotEqual(intial, updated, "Failed to update chosen image.")
        XCTAssertEqual(actual, updated, "Failed to update to chosen image.")
        switch model.state {
        case .success:
            XCTAssert(true)
        default:
            XCTFail("State not updated.")
        }
    }
    
    func testUpdateImageNoImage() {
        model.update(chosenImage: nil)
        
        switch model.state {
        case let .failure(error):
            XCTAssertEqual(error as! ImageModel.TransferError, ImageModel.TransferError.noImage, "Incorrect error thrown.")
        default:
            XCTFail("State not updated.")
        }
    }
    
//    func testUpdatePickerItem() {
//        let actual = UIImage(named: "saturn.jpg")!.cgImage!
//        let intial = model.chosenImage?.cgImage
//
//        model.update(selectedItem: .some(.init(itemIdentifier: "")))
//        let updated = model.chosenImage!.cgImage
//        
//        XCTAssertNotEqual(intial, updated, "Failed to update chosen image.")
//        XCTAssertEqual(actual, updated, "Failed to update to chosen image.")
//        switch model.state {
//        case .success:
//            XCTAssert(true)
//        default:
//            XCTFail("State not updated.")
//        }
//    }
    
    func testUpdatePickerItemImportFailed() {
        model.update(selectedItem: nil)
        
        switch model.state {
        case .empty:
            XCTAssert(true)
        default:
            XCTFail("State not updated.")
        }
    }
    
    func testThrowsNoImage() {
        XCTAssertNil(model.chosenImage)
        XCTAssertThrowsError(try model.generateArt(with: .ascii), "No image error not thrown.") { error in
            XCTAssertEqual(error as! ParserError, ParserError.noImage, "Incorrect error thrown.")
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
