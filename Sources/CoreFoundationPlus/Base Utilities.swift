//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/6/23.
//

@_implementationOnly import CoreFoundation

extension CFRange {
    init(_ range: Range<Int>) {
        self.init(location: range.lowerBound, length: range.upperBound - range.lowerBound)
    }
    
    init(_ range: ClosedRange<Int>) {
        self.init(location: range.lowerBound, length: range.upperBound + 1 - range.lowerBound)
    }
}

/// The result of a comparison between two comparable values.
public enum ComparisonResult: Index, Hashable, Codable {
    /// The value is less than the other value.
    case lessThan = -1
    
    /// The value is equal to the other value.
    case equalTo = 0
    
    /// The value is greater than the other value.
    case greaterThan = 1
    
    init(_ result: CFComparisonResult) {
        switch result {
        case .compareEqualTo:
            self = .equalTo
        case .compareGreaterThan:
            self = .greaterThan
        case .compareLessThan:
            self = .lessThan
        @unknown default:
            fatalError("New comparison result")
        }
    }
    
    var rawValue: CFComparisonResult {
        switch self {
        case .lessThan:
            return .compareLessThan
        case .equalTo:
            return .compareEqualTo
        case .greaterThan:
            return .compareGreaterThan
        }
    }
}

extension Comparable {
    /// Compares `self` to `other`.
    public func compare(to other: Self) -> ComparisonResult {
        if self < other {
            return .lessThan
        } else if self == other {
            return .equalTo
        } else {
            return .greaterThan
        }
    }
}

/// An array index.
public typealias Index = Int

/// A function that compares two values.
public typealias ComparatorFunction<T: Comparable> = (_ first: T, _ second: T) -> ComparisonResult
