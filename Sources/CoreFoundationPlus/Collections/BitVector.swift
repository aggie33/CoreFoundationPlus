//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/12/23.
//

import Foundation

/// An ordered collection of bits.
public struct BitVector: RangeReplaceableCollection, ExpressibleByArrayLiteral, RandomAccessCollection {
    public func index(after i: Int) -> Int {
        i + 1
    }
    
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    internal static var bitsPerByte = 8
    internal static var bitsPerBucket = bitsPerByte * MemoryLayout<UInt8>.stride
    
    /// The bytes stored in this bit vector.
    public var bytes: [UInt8]
    
    /// The number of bits the bit vector is currently keeping track of.
    public var bitCount: Int {
        willSet {
            print("Will set bitCount")
            
            // If we already have enough space to store the additional bits, don't do anything.
            if newValue <= bytes.count * 8 {
                print("No bytes needed: \(newValue) <= \(bytes.count * 8)")
                return
            } else {
                print("We need more bytes")
                
                // Find the number of additional bytes we need to add.
                let additionalBitsNeeded = newValue - (bytes.count * 8)
                let additionalBytesNeeded = Int(ceil(Double(additionalBitsNeeded) / 8))
                
                // Fill the new bytes with zero.
                for _ in 0..<additionalBytesNeeded {
                    bytes.append(.zero)
                }
            }
        }
        didSet {
            print("Did set bit count")
        }
    }
    
    /// The number of bits in the bit vector.
    public var count: Int {
        bitCount
    }
    
    /// Creates a bit vector with `bytes`, taking `bitCount` bits from them.
    public init(bytes: [UInt8], bitCount: Int? = nil) {
        let bitCount = bitCount ?? bytes.count * 8
        
        self.bytes = bytes
        self.bitCount = bitCount
    }
    
    public typealias Element = Bit
    
    /// Gets a bit at an index.
    public subscript(position: Int) -> Bit {
        get {
            let bucketIndex = position / BitVector.bitsPerBucket
            let bitOfBucket = position & (BitVector.bitsPerBucket - 1)
            
            return Bit(rawValue: (bytes[bucketIndex] >> (BitVector.bitsPerBucket - 1 - bitOfBucket)) & 0x1)!
        }
        set {
            let bucketIndex = position / BitVector.bitsPerBucket
            let bitOfBucket = position & (BitVector.bitsPerBucket - 1);
            
            if newValue == .on {
                print(bucketIndex)
                print(bytes)
                bytes[bucketIndex] |= (1 << (BitVector.bitsPerBucket - 1 - bitOfBucket));
            } else {
                bytes[bucketIndex] &= ~(1 << (BitVector.bitsPerBucket - 1 - bitOfBucket));
            }
        }
    }
    
    /// Creates a bit vector from an array of bytes.
    public init(arrayLiteral elements: UInt8...) {
        self.init(bytes: elements)
    }
    
    public init() {
        self.bytes = []
        self.bitCount = 0
    }
    
    public init(bits: [Bit]) {
        self.init(bits)
    }
    
    /// Replaces the elements in `subrange` with `newElements`.
    public mutating func replaceSubrange<C, R>(
        _ subrange: R,
        with newElements: C
    ) where C : Collection, R : RangeExpression, Self.Element == C.Element, Self.Index == R.Bound {
        let range = subrange.relative(to: self)
        
        if range.count == newElements.count {
            // Since the count is the same, we don't need to change the size of the bit vector
            for (index, value) in zip(range, newElements) {
                self[index] = value
            }
        }
        
        else if range.count > newElements.count {
            // The new elements contain fewer elements than the range's count.
            
            let lengthDifference = range.count - newElements.count
            let newCount = bitCount - lengthDifference
            
            for index in (range.endIndex + lengthDifference)..<count {
                self[index - lengthDifference] = self[index]
            }
            
            for (index, value) in zip(range, newElements) {
                self[index] = value
            }
            
            self.bitCount = newCount
        }
        
        else  {
            // The new elements contain more elements than can fit in the range
            
            let lengthDifference = newElements.count - range.count
            let newCount = bitCount + lengthDifference
            
            self.bitCount = newCount
            
            for index in (range.endIndex..<count).reversed() {
                self[index + lengthDifference] = self[index]
            }
            
            for (index, value) in newElements.enumerated() {
                self[range.lowerBound + index] = value
            }
        }
    }
    
    public func index(before i: Int) -> Int {
        i - 1
    }
}

extension BitVector: Equatable, Hashable, Codable { }

extension BitVector: CustomStringConvertible {
    public var description: String {
        var str = ""
        for bit in self {
            str.append(bit.isOff ? "0" : "1")
        }
        return str
    }
}

public enum Bit: UInt8, ExpressibleByIntegerLiteral {
    case off = 0
    case on = 1
    
    public mutating func flip() {
        switch self {
        case .on:
            self = .off
        case .off:
            self = .on
        }
    }
    
    public var isOn: Bool {
        self == .on
    }
    
    public var isOff: Bool {
        self == .off
    }
    
    public init(integerLiteral value: UInt8) {
        self.init(rawValue: value)!
    }
}
