//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/11/23.
//

import Foundation

/// A binary tree.
public protocol TreeProtocol<Element>: Sequence {
    /// Creates a new, empty binary tree.
    init(_ value: Element)
    
    /// Creates a binary tree with `children` as its children.
    init(_ value: Element, children: Children)
    
    associatedtype Element
    associatedtype Children: Sequence where Children.Element == Self
    
    var children: Children { get set }
    var value: Element { get set }
    
    func makeIterator() -> TreeIterator<Self>
}

public struct TreeIterator<T: TreeProtocol>: IteratorProtocol {
    var tree: T?
    var iterators: [TreeIterator<T>] = []
    
    public init(_ tree: T) {
        self.tree = tree
        self.iterators = tree.children.map { $0.makeIterator() }
    }
    
    public mutating func next() -> T.Element? {
        if let tree {
            defer { self.tree = nil }
            
            return tree.value
        }
        
        guard !iterators.isEmpty else { return nil }
        
        if let next = iterators[0].next() {
            return next
        } else {
            iterators.removeFirst()
            
            return self.next()
        }
    }
}

public extension TreeProtocol {
    func makeIterator() -> TreeIterator<Self> {
        TreeIterator(self)
    }
}

/// A binary tree.
public struct Tree<Element>: TreeProtocol {
    public var children: [Tree<Element>]
    public var value: Element
    
    public init(_ value: Element, children: [Tree<Element>] = []) {
        self.children = children
        self.value = value
    }
    
    public init(_ value: Element) {
        self.children = []
        self.value = value
    }
}

extension Tree: Equatable where Element: Equatable { }
extension Tree: Hashable where Element: Hashable { }
extension Tree: Encodable where Element: Encodable { }
extension Tree: Decodable where Element: Decodable { }
extension Tree: CustomStringConvertible {
    private func description(indentationLevel: Int) -> String {
        """
        \(String(repeating: "\t", count: indentationLevel))- \(value)
        \(children.map { $0.description(indentationLevel: indentationLevel + 1) }.joined())
        """
    }
    
    public var description: String {
        description(indentationLevel: 0)
    }
}
extension Tree: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Tree(value: \(value), children: \(children))"
    }
}

@resultBuilder public enum TreeBuilder<T: TreeProtocol> {
    public static func buildBlock(_ components: T...) -> [T] {
        components
    }
    
    public static func buildOptional(_ component: [T]?) -> [T] {
        component ?? []
    }
    
    public static func buildEither(first component: [T]) -> [T] {
        component
    }
    
    public static func buildEither(second component: [T]) -> [T] {
        component
    }
    
    public static func buildArray(_ components: [[T]]) -> [T] {
        components.reduce([]) { $0 + $1 }
    }
    
    public static func buildLimitedAvailability(_ component: [T]) -> [T] {
        component
    }
    
    public static func buildExpression(_ expression: T.Element) -> T {
        T(expression)
    }
    
    public static func buildExpression(_ expression: T) -> T {
        expression
    }
}

extension TreeProtocol where Children == Array<Self> {
    public init(_ value: Element, @TreeBuilder<Self> children: () -> [Self]) {
        self.init(value, children: children())
    }
}
