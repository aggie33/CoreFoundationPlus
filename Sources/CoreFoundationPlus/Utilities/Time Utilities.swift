//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/9/23.
//

import Foundation

public protocol TimeIntervalProtocol: Equatable, Hashable, CustomStringConvertible, Codable, AdditiveArithmetic {
    /// The duration of the time interval, in seconds.
    var seconds: Double { get }
    
    /// Creates a new time interval that is `seconds` seconds long.
    init(seconds: Double)
}

extension TimeIntervalProtocol {
    public var description: String {
        if #available(macOS 12.0, *) {
            return "\(seconds.formatted()) seconds"
        } else {
            return "\(seconds) seconds"
        }
    }
    
    public static func seconds(_ seconds: Double) -> Self {
        Self(seconds: seconds)
    }
    
    public static func milliseconds(_ ms: Double) -> Self {
        Self(seconds: ms / 1_000)
    }
    
    public static func microseconds(_ ms: Double) -> Self {
        Self(seconds: ms / 1_000_000)
    }
    
    public static func nanoseconds(_ ns: Double) -> Self {
        .microseconds(ns / 1000)
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        .seconds(lhs.seconds + rhs.seconds)
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        .seconds(lhs.seconds + rhs.seconds)
    }
    
    public static func * (lhs: Self, rhs: Double) -> Self {
        .seconds(lhs.seconds * rhs)
    }
    
    public static func / (lhs: Self, rhs: Double) -> Self {
        .seconds(lhs.seconds / rhs)
    }
    
    public static func *= (lhs: inout Self, rhs: Double) {
        lhs = lhs * rhs
    }
    
    public static func /= (lhs: inout Self, rhs: Double) {
        lhs = lhs / rhs
    }
}

/// A duration, or time interval.
public struct TimeInterval: TimeIntervalProtocol {
    public static var zero: TimeInterval { .seconds(0) }
    
    /// The length of the interval, in seconds.
    public var seconds: Double
    
    public init(seconds: Double) {
        self.seconds = seconds
    }
}

public protocol AbsoluteTimeProtocol<TimeIntervalType>: Equatable, Hashable, CustomStringConvertible, Codable {
    associatedtype TimeIntervalType: TimeIntervalProtocol
    
    var timeIntervalSinceReferenceDate: TimeIntervalType { get }
    init(timeIntervalSinceReferenceDate: TimeIntervalType)
    
    static var current: Self { get }
}

var absoluteTimeIntervalSince1970: Double { 978307200.0 }


extension AbsoluteTimeProtocol {
    public var description: String {
        "\(timeIntervalSinceReferenceDate.seconds) seconds since Jan 1 2001 00:00:00 GMT"
    }
    
    /// The current time.
    public static var current: Self {
        var tv = timeval()
        
        // gets the current time
        gettimeofday(&tv, nil)
        
        // subtracts the time interval between 1970 and 2001 from the time so that it matches up with the 2001 reference date
        // then adds the microseconds multiplied by 0.000_000_1
        let ret = Double(tv.tv_sec) - absoluteTimeIntervalSince1970 + (1.0E-6 * Double(tv.tv_usec))
        
        // returns self
        return Self(timeIntervalSinceReferenceDate: .seconds(ret))
    }
    
    public static var now: Self {
        .current
    }
    
    public static var firstDayOf1970: Self {
        Self(timeIntervalSinceReferenceDate: .seconds(978307200.0))
    }
    
    public static var firstDayOf1904: Self {
        Self(timeIntervalSinceReferenceDate: .seconds(3061152000.0))
    }
    
    public static var firstDayOf1601: Self {
        Self(timeIntervalSinceReferenceDate: .seconds(12622780800.0))
    }
    
    /// The reference date.
    public static var reference: Self {
        Self(timeIntervalSinceReferenceDate: .seconds(0))
    }
    
    public static func + (lhs: Self, rhs: TimeIntervalType) -> Self {
        Self(timeIntervalSinceReferenceDate: lhs.timeIntervalSinceReferenceDate + rhs)
    }
    
    public static func - (lhs: Self, rhs: TimeIntervalType) -> Self {
        Self(timeIntervalSinceReferenceDate: lhs.timeIntervalSinceReferenceDate - rhs)
    }
    
    public static func += (lhs: inout Self, rhs: TimeIntervalType) {
        lhs = lhs + rhs
    }
    
    public static func -= (lhs: inout Self, rhs: TimeIntervalType) {
        lhs = lhs - rhs
    }
}

/// An absolute point in time measured since the reference date of Jan 1 2001 00:00:00 GMT.
///
/// You can use this type to measure time, or the higher-level type `Date`.
/// ```swift
/// let now = AbsoluteTime.now
///
/// let aFewSecondsLater = now + .seconds(3)
/// ```
public struct AbsoluteTime: AbsoluteTimeProtocol {
    /// The time interval since the reference date of Jan 1 2001 00:00:00 GMT.
    public var timeIntervalSinceReferenceDate: TimeInterval
    
    /// Creates a new AbsoluteTime.
    public init(timeIntervalSinceReferenceDate: TimeInterval) {
        self.timeIntervalSinceReferenceDate = timeIntervalSinceReferenceDate
    }
}
