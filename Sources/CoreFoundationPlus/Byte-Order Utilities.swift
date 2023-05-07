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
    
    init?(_ byteOrder: CFByteOrder) {
        switch byteOrder {
        case 1:
            self = .littleEndian
        case 2:
            self = .bigEndian
        default:
            return nil
        }
    }
    
    var byteOrder: CFByteOrder {
        rawValue
    }
    
    /// The system's current byte order.
    public static var current: Self? {
        ByteOrder(CFByteOrderGetCurrent())
    }
}
