//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/15/23.
//
import XCTest
@testable import CoreFoundationPlus

final class BagTests: XCTestCase {
    var bag: Bag<Int>!

    override func setUp() {
        super.setUp()
        bag = Bag<Int>()
    }
    
    func testInsert() {
        bag.insert(1)
        XCTAssertEqual(bag.count, 1)
        XCTAssertEqual(bag.count(of: 1), 1)
    }
    
    func testRemove() {
        bag.insert(1)
        bag.remove(1)
        XCTAssertEqual(bag.count, 0)
        XCTAssertEqual(bag.count(of: 1), 0)
    }
    
    func testReplace() {
        bag.insert(1)
        bag.replace(1)
        XCTAssertEqual(bag.count, 1)
        XCTAssertEqual(bag.count(of: 1), 1)
    }
    
    func testSet() {
        bag.set(1)
        XCTAssertEqual(bag.count, 1)
        XCTAssertEqual(bag.count(of: 1), 1)
        bag.set(1)
        XCTAssertEqual(bag.count, 1)
        XCTAssertEqual(bag.count(of: 1), 1)
    }
    
    func testRemoveAll() {
        bag.insert(1)
        bag.insert(2)
        bag.removeAll()
        XCTAssertEqual(bag.count, 0)
        XCTAssertEqual(bag.count(of: 1), 0)
        XCTAssertEqual(bag.count(of: 2), 0)
    }
}

final class BridgedBagTests: XCTestCase {
    var bag: BridgedBag<Int>!

    override func setUp() {
        super.setUp()
        bag = BridgedBag<Int>()
    }
    
    func testInsert() {
        bag.insert(1)
        XCTAssertEqual(bag.count, 1)
        XCTAssertEqual(bag.count(of: 1), 1)
    }
    
    func testRemove() {
        bag.insert(1)
        bag.remove(1)
        XCTAssertEqual(bag.count, 0)
        XCTAssertEqual(bag.count(of: 1), 0)
    }
    
    func testReplace() {
        bag.insert(1)
        bag.replace(1)
        XCTAssertEqual(bag.count, 1)
        XCTAssertEqual(bag.count(of: 1), 1)
    }
    
    func testSet() {
        bag.set(1)
        XCTAssertEqual(bag.count, 1)
        XCTAssertEqual(bag.count(of: 1), 1)
        bag.set(1)
        XCTAssertEqual(bag.count, 1)
        XCTAssertEqual(bag.count(of: 1), 1)
    }
    
    func testRemoveAll() {
        bag.insert(1)
        bag.insert(2)
        bag.removeAll()
        XCTAssertEqual(bag.count, 0)
        XCTAssertEqual(bag.count(of: 1), 0)
        XCTAssertEqual(bag.count(of: 2), 0)
    }
}
