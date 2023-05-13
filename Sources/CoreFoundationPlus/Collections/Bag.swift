//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/10/23.
//

import Foundation

/// An unordered collection that can contain duplicate values.
public protocol BagProtocol<Element>: Sequence, ExpressibleByArrayLiteral, Hashable, Equatable, CustomStringConvertible where Element: Hashable, ArrayLiteralElement == Element {
    /// Creates a new bag with `values`.
    init(_ values: [Element])
    
    /// Creates a new bag with `values`.
    @_disfavoredOverload init<S: Sequence>(_ values: S) where S.Element == Element
    
    /// Creates a new, empty bag.
    init()
    
    /// Checks if `self` contains `element`.
    func contains(_ element: Element) -> Bool
    
    /// Finds the number of times `value` occurs in the collection.
    func count(of value: Element) -> Int
    
    /// Gets `value` if it exists in the collection.
    subscript(value: Element) -> Element? { get }
    
    /// The number of elements in `self`.
    var count: Int { get }
    
    /// An array containing the values in `self`.
    var values: [Element] { get }
    
    /// Inserts the value into the bag.
    mutating func insert(_ value: Element)
    
    /// Removes all of the elements from the bag.
    mutating func removeAll()
    
    /// Removes `element` from the bag, if it is in the bag.
    mutating func remove(_ element: Element)
    
    /// Replaces all elements equal to `element` with `element`.
    mutating func replace(_ element: Element)
    
    /// Replaces all elements equal to `element` with `element`, or if no elements equal to `element` are present, adds `element` to the bag.
    mutating func `set`(_ element: Element)
}

/// An unordered collection that can contain duplicate values.
///
///```swift
///var bag = Bag<Int>()
///bag.insert(5)
///
///// prints [5]
///print(bag)
///
///bag.insert(2)
///bag.insert(7)
///
///// prints [2, 5, 7]
///print(bag)
///
///bag.insert(7)
///
///// prints [2, 7, 5, 7]
///print(bag)
///```
///
/// - Note: Unlike BridgedBag, this is implemented in Swift. In general, you should use this. For large collections (100,000+ elements), this is about 1.5x faster than BridgedBag. For smaller collections, it's less consistent.
public struct Bag<Element> where Element: Hashable {
    internal var storage: [Element: Int]
}

extension Bag: BagProtocol {
    /// Creates a bag with `values`.
    public init(_ values: [Element]) {
        storage = [:]
        
        for value in values {
            storage[value, default: 0] += 1
        }
    }
    
    /// Creates a bag with `values`.
    public init<S: Sequence>(_ values: S) where S.Element == Element {
        storage = [:]
        
        for value in values {
            storage[value, default: 0] += 1
        }
    }
    
    /// Creates an empty bag.
    public init() {
        storage = [:]
    }
    
    /// Checks if `self` contains `element`.
    public func contains(_ element: Element) -> Bool {
        storage.keys.contains(element)
    }
    
    /// Finds the number of times `value` occurs in the collection.
    public func count(of value: Element) -> Int {
        storage[value] ?? 0
    }
    
    /// Gets `value` if it exists in the collection.
    public subscript(value: Element) -> Element? {
        storage.keys.first { $0 == value }
    }
    
    /// The number of elements in `self`.
    public var count: Int {
        storage.reduce(0) { $0 + $1.value }
    }
    
    /// An array containing the values in `self`.
    public var values: [Element] {
        var values = [Element]()
        for (key, value) in storage {
            for _ in 0..<value {
                values.append(key)
            }
        }
        return values
    }
    
    /// Inserts the value into the bag.
    public mutating func insert(_ value: Element) {
        storage[value, default: 0] += 1
    }
    
    /// Removes all of the elements from the bag.
    public mutating func removeAll() {
        storage = [:]
    }
    
    /// Removes `element` from the bag, if it is in the bag.
    public mutating func remove(_ element: Element) {
        if let count = storage[element] {
            if count == 1 {
                storage.removeValue(forKey: element)
            } else {
                storage[element] = count - 1
            }
        }
    }
    
    /// Replaces all elements equal to `element` with `element`.
    public mutating func replace(_ element: Element) {
        let value = storage.removeValue(forKey: element)
        storage[element] = value
    }
    
    /// Replaces all elements equal to `element` with `element`, or if no elements equal to `element` are present, adds `element` to the bag.
    public mutating func `set`(_ element: Element) {
        if storage.keys.contains(element) {
            replace(element)
        } else {
            storage[element] = 1
        }
    }
    
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
    public func makeIterator() -> some IteratorProtocol<Element> {
        values.makeIterator()
    }
    
    public var description: String {
        values.description
    }
}

/// This bag uses the underlying storage of a CFBag.
public struct BridgedBag<Element: Hashable>: _CFTypeInheritsImplementations {
    typealias CFType = CFBag
    
    class Storage {
        enum Storage {
            case immutable(CFBag)
            case mutable(CFMutableBag)
        }
        
        var storage: Storage
        
        init(storage: Storage) {
            self.storage = storage
        }
    }
    
    var storage: Storage
    
    var rawValue: CFBag {
        immutable
    }
    var immutable: CFBag {
        switch storage.storage {
        case .immutable(let bag):
            return bag
        case .mutable(let bag):
            return bag
        }
    }
    
    func mutableCopy() -> BridgedBag {
        var newBag = BridgedBag()
        for element in values {
            newBag.insert(element)
        }
        return newBag
    }
    
    var mutable: CFMutableBag {
        mutating get {
            switch storage.storage {
            case let .mutable(mutable):
                if !isKnownUniquelyReferenced(&storage) {
                    self = mutableCopy()
                } else {
                    return mutable
                }
                
                return self.mutable
            case .immutable:
                self = mutableCopy()
                return self.mutable
            }
        }
    }
}
extension BridgedBag: BagProtocol {
    private static func makeBagCallbacks() -> CFBagCallBacks {
        let retain: CFBagRetainCallBack = { allocator, pointer in
            guard let pointer else {
                return nil
            }
            
            return UnsafeRawPointer(Unmanaged<AnyObject>.fromOpaque(pointer).retain().toOpaque())
        }
        
        let release: CFBagReleaseCallBack = { allocator, pointer in
            pointer.map { Unmanaged<AnyObject>.fromOpaque($0).release() }
        }
        
        let copyDescription: CFBagCopyDescriptionCallBack = { pointer in
            guard let pointer else { return nil }
            
            let element = Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
            return Unmanaged.passUnretained(String(describing: element) as CFString)
        }
        
        let equal: CFBagEqualCallBack = { pointer1, pointer2 in
            guard let pointer1, let pointer2 else { return false }
                
            let val1 = Unmanaged<AnyObject>.fromOpaque(pointer1).takeUnretainedValue() as! any Equatable
            let val2 = Unmanaged<AnyObject>.fromOpaque(pointer2).takeUnretainedValue() as! any Equatable
            
            return DarwinBoolean(isEqual(val1, val2))
        }
        
        let hash: CFBagHashCallBack = { pointer in
            guard let pointer else { return 0 }
            
            let val = Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue() as! any Hashable
            return UInt(bitPattern: val.hashValue)
        }
        
        return CFBagCallBacks(version: 0, retain: retain, release: release, copyDescription: copyDescription, equal: equal, hash: hash)
    }
    
    public init(_ values: [Element]) {
        let buffer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: values.count)
        
        for (i, value) in values.enumerated() {
            buffer[i] = UnsafeRawPointer(Unmanaged.passUnretained(value as AnyObject).toOpaque())
        }
        
        let bag = withUnsafePointer(to: BridgedBag.makeBagCallbacks()) { callbacks in
            CFBagCreate(nil, buffer, values.count, callbacks)!
        }
        
        self.storage = .init(storage: .immutable(bag))
    }
    
    @_disfavoredOverload public init<S>(_ values: S) where S : Sequence, Element == S.Element {
        self.init(Array(values))
    }
    
    public init() {
        let bag = withUnsafePointer(to: BridgedBag.makeBagCallbacks()) { callbacks in
            CFBagCreateMutable(nil, 0, callbacks)!
        }
        
        self.storage = .init(storage: .mutable(bag))
    }
    
    public func contains(_ element: Element) -> Bool {
        CFBagContainsValue(immutable, UnsafeRawPointer(Unmanaged.passUnretained(element as AnyObject).toOpaque()))
    }
    
    public func count(of value: Element) -> Int {
        CFBagGetCountOfValue(immutable, Unmanaged.passUnretained(value as AnyObject).toOpaque())
    }
    
    public subscript(value: Element) -> Element? {
        CFBagGetValue(immutable, Unmanaged.passUnretained(value as AnyObject).toOpaque()).map {
            Unmanaged<AnyObject>.fromOpaque($0).takeUnretainedValue() as! Element
        }
    }
    
    public var count: Int { CFBagGetCount(immutable) }
    
    /// An array containing the values in `self`.
    public var values: [Element] {
        let buffer = UnsafeMutableBufferPointer<UnsafeRawPointer?>.allocate(capacity: count)
        CFBagGetValues(immutable, buffer.baseAddress)
        
        defer { buffer.deallocate() }
        return buffer.compactMap {
            guard let ptr = $0 else {
                return nil
            }
            
            return Unmanaged<AnyObject>.fromOpaque(ptr).takeUnretainedValue() as? Element
        }
    }

    /// Inserts the value into the bag.
    public mutating func insert(_ value: Element) {
        CFBagAddValue(mutable, UnsafeRawPointer(Unmanaged.passUnretained(value as AnyObject).toOpaque()))
    }
    
    /// Removes all of the elements from the bag.
    public mutating func removeAll() {
        CFBagRemoveAllValues(mutable)
    }
    
    /// Removes `element` from the bag, if it is in the bag.
    public mutating func remove(_ element: Element) {
        CFBagRemoveValue(mutable, UnsafeRawPointer(Unmanaged.passUnretained(element as AnyObject).toOpaque()))
    }
    
    /// Replaces all elements equal to `element` with `element`.
    public mutating func replace(_ element: Element) {
        CFBagReplaceValue(mutable, UnsafeRawPointer(Unmanaged.passUnretained(element as AnyObject).toOpaque()))
    }
    
    /// Replaces all elements equal to `element` with `element`, or if no elements equal to `element` are present, adds `element` to the bag.
    public mutating func `set`(_ element: Element) {
        CFBagSetValue(mutable, UnsafeRawPointer(Unmanaged.passUnretained(element as AnyObject).toOpaque()))
    }
    
    public func makeIterator() -> some IteratorProtocol<Element> {
        values.makeIterator()
    }
    
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
    public var description: String {
        self.values.description
    }
}
extension BridgedBag {
    public init(_ bag: CFBag, containingElementsOfType type: Element.Type = Element.self) {
        self.storage = .init(storage: .immutable(bag))
    }
    
    public init(_ bag: CFMutableBag, containingElementsOfType type: Element.Type = Element.self) {
        self.storage = .init(storage: .mutable(bag))
    }
}

func isEqual<T1, T2>(_ val1: T1, _ val2: T2) -> Bool where T1: Equatable, T2: Equatable {
    if let val2 = val2 as? T1 {
        return val1 == val2
    } else {
        return false
    }
}
