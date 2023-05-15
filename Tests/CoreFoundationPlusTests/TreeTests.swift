//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/15/23.
//

import Foundation
@testable import CoreFoundationPlus
import XCTest

final class TreeTests: XCTestCase {
    
    // Tests for TreeProtocol
    
    func testTreeCreationWithValue() {
        let tree = Tree(10)
        XCTAssertEqual(tree.value, 10)
        XCTAssertTrue(tree.children.isEmpty)
    }
    
    func testTreeCreationWithValueAndChildren() {
        let tree = Tree(1, children: [Tree(2), Tree(3)])
        XCTAssertEqual(tree.value, 1)
        XCTAssertEqual(tree.children.count, 2)
        XCTAssertEqual(tree.children[0].value, 2)
        XCTAssertEqual(tree.children[1].value, 3)
    }
    
    func testTreeCreation() {
        let tree = Tree(1) {
            Tree(2)
            Tree(3) {
                Tree(4)
            }
        }
        
        XCTAssertEqual(tree.value, 1)
        XCTAssertEqual(tree.children.count, 2)
        XCTAssertEqual(tree.children[0].value, 2)
        XCTAssertEqual(tree.children[1].value, 3)
        XCTAssertEqual(tree.children[1].children[0].value, 4)
    }
    
    func testTreeIterator() {
        let tree = Tree(1) {
            Tree(2)
            Tree(3) {
                Tree(4)
            }
        }
        var iterator = tree.makeIterator()
        XCTAssertEqual(iterator.next(), 1)
        XCTAssertEqual(iterator.next(), 2)
        XCTAssertEqual(iterator.next(), 3)
        XCTAssertEqual(iterator.next(), 4)
        XCTAssertNil(iterator.next())
    }
}
