//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/15/23.
//

import XCTest
@testable import CoreFoundationPlus

class BinaryHeapTests: XCTestCase {
    
    func testEmptyInitialization() {
        let heap: BinaryHeap<Int> = []
        XCTAssertTrue(heap.isEmpty)
    }
    
    func testArrayLiteralInitialization() {
        let heap: BinaryHeap<Int> = [3, 1, 4, 1, 5, 9, 2]
        XCTAssertEqual(heap, [1, 1, 2, 3, 4, 5, 9])
    }
    
    func testMinAndMax() {
        let heap: BinaryHeap<Int> = [3, 1, 4, 1, 5, 9, 2]
        XCTAssertEqual(heap.min, 1)
        XCTAssertEqual(heap.max, 9)
    }
    
    func testInsert() {
        var heap: BinaryHeap<Int> = [3, 1, 4, 1, 5, 9, 2]
        heap.insert(6)
        XCTAssertEqual(heap, [1, 1, 2, 3, 4, 5, 6, 9])
    }
    
    func testRemoveMin() {
        var heap: BinaryHeap<Int> = [3, 1, 4, 1, 5, 9, 2]
        let min = heap.removeMin()
        XCTAssertEqual(min, 1)
        XCTAssertEqual(heap, [1, 2, 3, 4, 5, 9])
    }
    
    func testCountOfValue() {
        let heap: BinaryHeap<Int> = [3, 1, 4, 1, 5, 9, 2]
        XCTAssertEqual(heap.count(of: 1), 2)
        XCTAssertEqual(heap.count(of: 0), 0)
    }
    
    func testCustomStringConvertible() {
        let heap: BinaryHeap<Int> = [3, 1, 4, 1, 5, 9, 2]
        XCTAssertEqual(heap.description, "[1, 1, 2, 3, 4, 5, 9]")
    }
}
