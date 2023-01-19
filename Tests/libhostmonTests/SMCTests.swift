import XCTest
@testable import libhostmon

final class SMCTests: XCTestCase {
//
//    func testThatSMCKeyIsConvertedCorrectly() {
//        XCTAssertEqual(SMCKey(stringLiteral: "TC0P").uInt32Value, 1413689424)
//    }
//
//    func testThatSMCKeyIsParsedFromInt32Correctly() {
//        XCTAssertEqual(SMCKey(1936734008), "sp78")
//    }
//
//    func testThatSMCKeySizeIsCorrect() {
//        XCTAssertEqual(MemoryLayout<SMCKey>.size, 5)
//    }
//
//    func testThatSMCKeyDataVersionSizeIsCorrect() {
//        XCTAssertEqual(MemoryLayout<SMCKeyDataVersion>.size, 6)
//    }
//
//    func testThatSMCKeyInfoSizeIsCorrect() {
//        XCTAssertEqual(MemoryLayout<SMCKeyDataInfo>.size, 12)
//    }
//
//    func testThatSMCKeyLimitDataSizeIsCorrect() {
//        XCTAssertEqual(MemoryLayout<SMCKeyLimitData>.size, 16)
//    }
//
    func testThatSMCBytesDataSizeIsCorrect() {
        XCTAssertEqual(MemoryLayout<SMCBytes>.size, 32)
    }
//
//    func testThatSMCValueDataSizeIsCorrect() {
//        XCTAssertEqual(MemoryLayout<SMCValue>.size, 52)
//    }
//
    func testThatSMCKeyDataSizeIsCorrect() {
//        XCTAssertEqual(MemoryLayout<SMCMessage>.size, 80)
    }
}
