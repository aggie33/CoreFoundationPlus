//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/6/23.
//

import Foundation

// MARK: Port to Swift

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
public protocol PropertyList {
    associatedtype _BridgeType = Self
    
    var _valueToBridge: Self._BridgeType { get }
    static func _cast(from anyObject: AnyObject) -> Self?
}

extension PropertyList where _BridgeType == Self {
    public var _valueToBridge: Self._BridgeType { self }
    public static func _cast(from anyObject: AnyObject) -> Self? {
        anyObject as? Self
    }
}

extension String: PropertyList { }
extension Array: PropertyList where Element: PropertyList { }
extension Dictionary: PropertyList where Key == String, Value: PropertyList { }
extension Bool: PropertyList { }
extension Int: PropertyList { }
extension Double: PropertyList { }
extension Float: PropertyList { }

/// Use `Preferences` to store values in the application's preferences.
///
/// You can use it dynamically with a string key, like this:
/// ```swift
/// let numCookies: Int = Preferences["numCookies", as: Int.self] ?? 0
/// ```
///
/// You can define a value of the type `Preferences.Key<T>` to access a non-optional value.
/// ```swift
/// let numCookiesKey = Preferences.Key(key: "numCookies", defaultValue: 0)
/// let numCookies: Int = Preferences[numCookiesKey]
/// ```
///
/// Or, for easy access, declare an extension to `Preferences.Keys`.
/// ```swift
/// extension Preferences.Keys {
///     var numCookies: Preferences.Key<Int> { .init(key: "numCookies", defaultValue: 0) }
/// }
///
/// let numCookies: Int = Preferences.numCookies
/// ```
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
            return (Value._cast(from: value))
        }
        nonmutating set {
            if let value = newValue {
                CFPreferencesSetValue(dm as CFString, value._valueToBridge as AnyObject, app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString)
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
            return (Value._cast(from: value))
        }
        nonmutating set {
            if let value = newValue {
                CFPreferencesSetValue(dm as CFString, value._valueToBridge as AnyObject, app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString)
            } else {
                CFPreferencesSetValue(dm as CFString, nil, app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString)
            }
        }
    }
    
    /// Gets a value from the Preferences key-value store.
    public static subscript<Value: PropertyList>(key: Key<Value>) -> Value {
        get { standard[key.key] ?? key.defaultValue }
        set { standard[key.key] = newValue }
    }
    
    /// Gets a value from the Preferences key-value store.
    public static subscript<Value: PropertyList>(dynamicMember dm: KeyPath<Keys, Key<Value>>) -> Value {
        get { standard[Keys()[keyPath: dm]] }
        set { standard[Keys()[keyPath: dm]] = newValue }
    }
    
    /// Gets a value from the Preferences key-value store.
    public static subscript<Value: PropertyList>(dynamicMember dm: String) -> Value? {
        get {
            guard let value = CFPreferencesCopyValue(dm as CFString, standard.app.rawValue as CFString, standard.user.rawValue as CFString, standard.host.rawValue as CFString) else {
                return nil
            }
            return (Value._cast(from: value))
        }
        set {
            if let value = newValue {
                CFPreferencesSetValue(dm as CFString, value._valueToBridge as AnyObject, standard.app.rawValue as CFString, standard.user.rawValue as CFString, standard.host.rawValue as CFString)
            } else {
                CFPreferencesSetValue(dm as CFString, nil, standard.app.rawValue as CFString, standard.user.rawValue as CFString, standard.host.rawValue as CFString)
            }
        }
    }
    
    /// Gets a value from the Preferences key-value store.
    public static subscript<Value: PropertyList>(dm: String, as type: Value.Type = Value.self) -> Value? {
        get {
            guard let value = CFPreferencesCopyValue(dm as CFString, standard.app.rawValue as CFString, standard.user.rawValue as CFString, standard.host.rawValue as CFString) else {
                return nil
            }
            return (Value._cast(from: value))
        }
        set {
            if let value = newValue {
                CFPreferencesSetValue(dm as CFString, value._valueToBridge as AnyObject, standard.app.rawValue as CFString, standard.user.rawValue as CFString, standard.host.rawValue as CFString)
            } else {
                CFPreferencesSetValue(dm as CFString, nil, standard.app.rawValue as CFString, standard.user.rawValue as CFString, standard.host.rawValue as CFString)
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
    
    /// The default preferences value.
    public static let standard = Preferences()
    
    /// Synchronizes the Preferences storage with the storage on disk.
    public func synchronize() {
        CFPreferencesSynchronize(app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString)
    }
    
    /// Synchronizes the Preferences storage with the storage on disk.
    public static func synchronize() {
        standard.synchronize()
    }
    
    /// Adds the suite named `suiteName` to `app`.
    public func addSuite(_ suiteName: String) {
        CFPreferencesAddSuitePreferencesToApp(app.rawValue as CFString, suiteName as CFString)
    }
    
    /// Removes the suite named `suiteName` from `app`.
    public func removeSuite(_ suiteName: String) {
        CFPreferencesRemoveSuitePreferencesFromApp(app.rawValue as CFString, suiteName as CFString)
    }
    
    /// Checks if the value has been imposed on the user.
    public func isValueForced(_ key: String) -> Bool {
        CFPreferencesAppValueIsForced(key as CFString, app.rawValue as CFString)
    }
    
    /// Checks if the value has been imposed on the user.
    public func isValueForced<Value>(_ key: Key<Value>) -> Bool {
        isValueForced(key.key)
    }
    
    /// Checks if the value has been imposed on the user.
    public func isValueForced<Value>(_ key: KeyPath<Keys, Key<Value>>) -> Bool {
        isValueForced(Keys()[keyPath: key])
    }
    
    /// All valid preferences keys.
    public var keys: [String] {
        CFPreferencesCopyKeyList(app.rawValue as CFString, user.rawValue as CFString, host.rawValue as CFString) as? [String] ?? []
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
    
    /// Creates a new Preference value.
    /// - Parameters:
    ///   - wrappedValue: The initial value.
    ///   - key: The key to store the value with.
    ///   - store: The Preferences store to use.
    public init(wrappedValue: Value, _ key: String, store: Preferences = Preferences()) {
        self.key = .init(key: key, defaultValue: wrappedValue)
        self.store = store
    }
    
    /// The wrapped value.
    public var wrappedValue: Value {
        get { store[key] }
        nonmutating set { store[key] = newValue }
    }
}
