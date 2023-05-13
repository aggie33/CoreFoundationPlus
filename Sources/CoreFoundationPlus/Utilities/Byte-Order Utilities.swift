//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/6/23.
//

import CoreFoundation

@frozen public enum ByteOrder: Index, Hashable, Codable {
    /// A little-endian system.
    case littleEndian = 1
    
    /// A big-endian system.
    case bigEndian = 2
    
    /// The system's current byte order.
    @inlinable public static var current: Self? {
        switch Int(OSHostByteOrder()) {
        case OSLittleEndian:
            return .littleEndian
        case OSBigEndian:
            return .bigEndian
        default:
            return nil
        }
    }
}

