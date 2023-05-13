//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/12/23.
//

import Foundation

public protocol BinaryHeapProtocol<Element>: RangeReplaceableCollection, RandomAccessCollection, ExpressibleByArrayLiteral where Element: Comparable {
    mutating func insert(_ value: Element)
    
    var count: Int { get }
    func count(of value: Element) -> Int
    
    /// The minimum element in the binary heap, or `nil` if it is empty.
    var min: Element? { get }
    
    /// The maximum element in the binary heap, or `nil` if it is empty.
    var max: Element? { get }
    
    /// Removes and returns the minimum element of the collection.
    @discardableResult mutating func removeMin() -> Element
}

/// A collection of sorted values.
public struct BinaryHeap<Element: Comparable> {
    var values: [Element] {
        get { _values }
        set {
            _values = newValue.sorted()
        }
    }
    
    private var _values: [Element]
}

extension BinaryHeap: Sequence {
    public func makeIterator() -> some IteratorProtocol<Element> {
        values.makeIterator()
    }
}
extension BinaryHeap: MutableCollection {
    public var startIndex: Int { values.startIndex }
    public var endIndex: Int { values.endIndex }
    
    public subscript(position: Int) -> Element {
        get { values[position] }
        set { values[position] = newValue }
    }
    
    public func index(after i: Int) -> Int {
        values.index(after: i)
    }
}
extension BinaryHeap: RangeReplaceableCollection {
    public init() {
        self._values = []
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Element == C.Element {
        values.replaceSubrange(subrange, with: newElements)
    }
}
extension BinaryHeap: BidirectionalCollection {
    public func index(before i: Int) -> Int {
        i - 1
    }
}
extension BinaryHeap: RandomAccessCollection { }

extension BinaryHeap: Equatable where Element: Equatable { }
extension BinaryHeap: Hashable where Element: Hashable { }
extension BinaryHeap: Encodable where Element: Encodable { }
extension BinaryHeap: Decodable where Element: Decodable { }

extension BinaryHeap: CustomStringConvertible {
    public var description: String { values.description }
}
extension BinaryHeap: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self._values = elements.sorted()
    }
}

extension BinaryHeap: BinaryHeapProtocol {
    public var max: Element? {
        last
    }
    
    public var min: Element? {
        first
    }
    
    /// Returns the number of times `value` occurs in `self`.
    ///
    /// - Note: This method has O(n) performance.
    public func count(of value: Element) -> Int {
        var count = 0
        forEach { if $0 == value { count += 1 }}
        return count
    }
    
    public mutating func insert(_ value: Element) {
        append(value)
    }
    
    public mutating func removeMin() -> Element {
        removeFirst()
    }
}
