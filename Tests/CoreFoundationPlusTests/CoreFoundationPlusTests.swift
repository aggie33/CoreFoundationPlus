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
         
        let int = Int.random(in: 1...100)
        numCookies = int
        XCTAssertEqual(numCookies, int)
        
        isAwesome = true
        XCTAssertEqual(isAwesome, true)
        
        if #available(macOS 13.0, *) {
            let clock = ContinuousClock()
            
            var bag = BridgedBag<Int>()
            let bridgeTime = clock.measure {
                for i in 1...100_000 {
                    bag.insert(i)
                }
            }
            
            var swbag = Bag<Int>()
            let swiftTime = clock.measure {
                for i in 1...100_000 {
                    swbag.insert(i)
                }
            }
            
            print("Swift time: \(swiftTime)")
            print("Core Foundation time: \(bridgeTime)")
            
            print("Swift is \(bridgeTime / swiftTime)x faster")
            XCTAssertEqual(swbag.sorted(), bag.sorted())
            
            let tree = Tree(5) {
                Tree(7) {
                    Tree(9) {
                        10
                        11
                        12
                    }
                    13
                    14
                    15
                }
                16
                17
                18
            }
            
            for item in tree {
                print(item)
            }
            
            print(tree)
            
            
        }
    }
}
