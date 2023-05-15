//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/15/23.
//

import Foundation

import XCTest
@testable import CoreFoundationPlus

class BitVectorTests: XCTestCase {

    func testEmptyInitialization() {
        let bitVector = BitVector()
        XCTAssertTrue(bitVector.isEmpty)
    }

    func testInitializationWithBytes() {
        let bitVector = BitVector(bytes: [0b10101100, 0b11110000])
        XCTAssertEqual(bitVector.count, 16)
        XCTAssertEqual(bitVector[0], .on)
        XCTAssertEqual(bitVector[1], .off)
        XCTAssertEqual(bitVector[2], .on)
        XCTAssertEqual(bitVector[3], .off)
        // continue for the rest of the bits
    }
    
    func testArrayLiteralInitialization() {
        let bitVector: BitVector = [0b10101100, 0b11110000]
        XCTAssertEqual(bitVector.count, 16)
        XCTAssertEqual(bitVector[0], .on)
        // continue for the rest of the bits
    }
    
    func testSubscriptSetAndGet() {
        var bitVector: BitVector = [0b10101100, 0b11110000]
        bitVector[0] = .off
        XCTAssertEqual(bitVector[0], .off)
        // continue for the rest of the bits
    }
    
    func testReplaceSubrange() {
        var bitVector: BitVector = [0b10101100, 0b11110000]
        bitVector.replaceSubrange(0..<4, with: [.on, .on, .on, .on])
        XCTAssertEqual(bitVector[0], .on)
        XCTAssertEqual(bitVector[1], .on)
        // continue for the rest of the bits
    }
    
    func testCustomStringConvertible() {
        let bitVector: BitVector = [0b10101100, 0b11110000]
        XCTAssertEqual(bitVector.description, "1010110011110000")
    }
}
