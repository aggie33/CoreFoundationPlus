//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/7/23.
//

import Foundation

/*
 
 COMPLETED:
 Base Utilities
    ComparisonResult
    Index
    ComparatorFunction<T>
 Byte-Order Utilities
    ByteOrder
 Preferences Utilities
    Preferences
        Preferences.Keys
        Preferences.Key
        Preferences.(App | User | Host)
    Preference
 Time Utilities
    TimeIntervalProtocol
    TimeInterval
    AbsoluteTimeProtocol
    AbsoluteTime
 Bag
    BagProtocol
    Bag<Element>
    BridgedBag<Element>
 Binary Heap
    BinaryHeap<Element>
    BinaryHeapProtocol<Element>

 INCOMPLETE:
 BitVector
 PlugIn
 PlugInInstance
 PropertyList
 RunLoop.Observer
 RunLoop.Source
 Socket
 String.Tokenizer
 */

internal protocol _CFTypeInheritsImplementations: Equatable, Hashable, CustomStringConvertible {
    associatedtype CFType: AnyObject
    var rawValue: CFType { get }
}

extension _CFTypeInheritsImplementations {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        CFEqual(lhs.rawValue, rhs.rawValue)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(CFHash(rawValue))
    }
    
    public var description: String {
        CFCopyDescription(rawValue) as String
    }
}

internal func CFTypeCast<T>(_ value: CFTypeRef, as: T.Type = T.self, typeCode: UInt) -> T? where T: AnyObject {
    if CFGetTypeID(value) == typeCode {
        return value as? T
    } else {
        return nil
    }
}
