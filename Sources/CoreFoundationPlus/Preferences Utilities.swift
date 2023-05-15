//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/6/23.
//

@_implementationOnly import Foundation

/// A type that can be encoded and decoded into a property list format.
///
/// - Warning: Do not declare conformances to this protocol. Only the built-in types are supported.
///
/// The built-in types that conform to this protocol are:
/// ```
/// - Data
/// - String
/// - [some PropertyList]
/// - [String: some PropertyList]
/// - Date
/// - Bool
/// - Int
/// - Double
/// - Float
/// ```
@_marker public protocol PropertyList { }

extension String: PropertyList { }
extension Array: PropertyList where Element: PropertyList { }
extension Dictionary: PropertyList where Key == String, Value: PropertyList { }
extension Bool: PropertyList { }
extension Int: PropertyList { }
extension Double: PropertyList { }
extension Float: PropertyList { }

@dynamicMemberLookup public struct Preferences {
    /// A namespace for Preferences keys.
    ///
    /// To create a new key, do this:
    /// ```swift
    /// extension Preferences.Keys {
    ///     var exampleKey: Preferences.Key<Int> { .init(key: "exampleKey", defaultValue: 5) }
    /// }
    /// ```
    /// Then, you can use it like this:
    /// ```swift
    /// let preferences = Preferences()
    /// print(preferences.exampleKey)
    /// ```
    public struct Keys { }
    
    /// A key to use in Preferences.
    public struct Key<Value: PropertyList> {
        /// The key to use.
        var key: String
        
        /// The default value to use.
        var defaultValue: Value
    }
    
    /// A user whose preferences to search through.
    public struct User: ExpressibleByStringLiteral {
        var rawValue: String
        
        public init(stringLiteral: String) {
            self.rawValue = stringLiteral
        }
        
        public static var any: Self { Self(stringLiteral: "kCFPreferencesAnyUser") }
        public static var current: Self { Self(stringLiteral: "kCFPreferencesCurrentUser") }
    }
    
    /// A host whose preferences to search through.
    public struct Host: ExpressibleByStringLiteral {
        var rawValue: String
        
        public init(stringLiteral: String) {
            self.rawValue = stringLiteral
        }
        
        public static var any: Self { Self(stringLiteral: "kCFPreferencesAnyHost") }
        public static var current: Self { Self(stringLiteral: "kCFPreferencesCurrentHost") }
    }
    
    /// An app whose preferences to search through.
    public struct App: ExpressibleByStringLiteral {
        var rawValue: String
        
        public init(stringLiteral: String) {
            self.rawValue = stringLiteral
        }
        
        public static var any: Self { Self(stringLiteral: "kCFPreferencesAnyApplication") }
        public static var current: Self { Self(stringLiteral: "kCFPreferencesCurrentApplication") }
    }
    
    /// The user whose preferences to search through.
    public var user: User = .current
    
    /// The host whose preferences to search through.
    public var host: Host = .any
    
    /// The app whose preferences to search through.
    public var app: App = .current

    /// Gets a value from the Preferences key-value store.
    public subscript<Value: PropertyList>(key: Key<Value>) -> Value {
        get { self[key.key] ?? key.defaultValue }
        nonmutating set { self[key.key] = newValue }
    }
    
    /// Gets a value from the Preferences key-value store.
    public subscript<Value: PropertyList>(dynamicMember dm: KeyPath<Keys, Key<Value>>) -> Value {
        get { self[Keys()[keyPath: dm]] }
        nonmutating set { self[Keys()[keyPath: dm]] = newValue }
    }
    
    /// Gets a value from the Preferences key-value store.
    public subscript<Value: PropertyList>(dynamicMember dm: String) -> Value? {
        get {
            guard let value = CFPreferencesCopyValue(dm as CFString, app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString) else {
                return nil
            }
            return (value as? Value)
        }
        nonmutating set {
            if let value = newValue {
                CFPreferencesSetValue(dm as CFString, value as AnyObject, app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString)
            } else {
                CFPreferencesSetValue(dm as CFString, nil, app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString)
            }
        }
    }
    
    /// Gets a value from the Preferences key-value store.
    public subscript<Value: PropertyList>(dm: String, as type: Value.Type = Value.self) -> Value? {
        get {
            guard let value = CFPreferencesCopyValue(dm as CFString, app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString) else {
                return nil
            }
            return (value as? Value)
        }
        nonmutating set {
            if let value = newValue {
                CFPreferencesSetValue(dm as CFString, value as AnyObject, app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString)
            } else {
                CFPreferencesSetValue(dm as CFString, nil, app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString)
            }
        }
    }
    
    /// Removes the value associated with `key`.
    public func removeValue(forKey key: String) {
        CFPreferencesSetValue(key as CFString, nil, app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString)
    }
    
    /// Removes the value associated with `key`.
    public func removeValue(forKey key: Key<some PropertyList>) {
        CFPreferencesSetValue(key.key as CFString, nil, app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString)
    }
    
    /// Removes the value associated with `key`.
    public func removeValue(forKey key: KeyPath<Keys, Key<some PropertyList>>) {
        removeValue(forKey: Keys()[keyPath: key])
    }
    
    /// Creates a Preferences.
    /// - Parameters:
    ///   - user: The user whose preferences to use.
    ///   - host: The host whose preferences to use.
    ///   - app: The app whose preferences to use
    public init(user: User = .current, host: Host = .any, app: App = .current) {
        self.user = user
        self.host = host
        self.app = app
    }
    
    
}

/// Stores a value in Preferences.
///
/// You can use this property wrapper to store values in Preferences.
/// ```swift
/// struct Foo {
///     @Preference("bar") var bar = "baz"
/// }
/// ```
@propertyWrapper public struct Preference<Value: PropertyList> {
    var key: Preferences.Key<Value>
    var store: Preferences
    
    public init(wrappedValue: Value, _ key: String, store: Preferences = Preferences()) {
        self.key = .init(key: key, defaultValue: wrappedValue)
        self.store = store
    }
    
    public var wrappedValue: Value {
        get { store[key] }
        nonmutating set { store[key] = newValue }
    }
}

// Date: Equivalent to AbsoluteTime
// AbsoluteTime: Time interval since reference date
// TimeInterval: A duration of time
// Double: Just a double lol

