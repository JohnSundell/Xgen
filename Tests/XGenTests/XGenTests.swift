import XCTest
@testable import XGen

class XGenTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(XGen().text, "Hello, World!")
    }


    static var allTests : [(String, (XGenTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
