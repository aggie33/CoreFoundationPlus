import XCTest
@testable import CoreFoundationPlus

final class CoreFoundationPlusTests: XCTestCase {
    @Preference("numCookies") var numCookies = 0
    @Preference("isAwesome") var isAwesome = true
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        XCTAssertEqual(5.compare(to: 6), .lessThan)
        
        let preferences = Preferences()
        
        var int = Int.random(in: 1...100)
        numCookies = int
        XCTAssertEqual(numCookies, int)
        
        isAwesome = true
        XCTAssertEqual(isAwesome, true)
        print(preferences)
    }
}
