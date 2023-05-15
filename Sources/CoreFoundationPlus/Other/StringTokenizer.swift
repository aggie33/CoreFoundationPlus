//
//  File.swift
//  
//
//  Created by Eric Bodnick on 5/15/23.
//

import Foundation

/// Allows you to tokenize strings into words, sentences or pargraphs in a language-neutral way.
///
/// - Note: This type uses reference semantics.
@available(macOS 13.0, *)
public struct StringTokenizer: _CFTypeInheritsImplementations {
    /// Creates a tokenizer that tokenizes `string` with `options`, using `locale`.
    public init(_ string: some StringProtocol, tokenizingBy unit: TokenizingUnit, locale: Locale? = .current) {
        let string = String(string)
        
        let options: UInt
        
        switch unit {
        case .lineBreak:
            options = kCFStringTokenizerUnitLineBreak
        case .localeAwareWord:
            options = kCFStringTokenizerUnitWordBoundary
        case .paragraph(preparingLanguage: let preparingLanguage):
            if preparingLanguage {
                options = kCFStringTokenizerUnitParagraph | kCFStringTokenizerAttributeLanguage
            } else {
                options = kCFStringTokenizerUnitParagraph
            }
        case .sentence(preparingLanguage: let preparingLanguage):
            if preparingLanguage {
                options = kCFStringTokenizerUnitSentence | kCFStringTokenizerAttributeLanguage
            } else {
                options = kCFStringTokenizerUnitSentence
            }
        case .word(preparingLatinTranscription: let preparingLatinTranscription):
            if preparingLatinTranscription {
                options = kCFStringTokenizerUnitWord | kCFStringTokenizerAttributeLatinTranscription
            } else {
                options = kCFStringTokenizerUnitWord
            }
        }
        
        rawValue = CFStringTokenizerCreate(nil, string as CFString, CFRangeMake(0, string.count), options, locale.map { $0 as CFLocale })
        self._string = string
    }
    
    var rawValue: CFStringTokenizer
    var _string: String
    
    /// The string that the tokenizer is tokenizing.
    public var string: String {
        get { _string }
        set {
            _string = newValue
            CFStringTokenizerSetString(rawValue, newValue as CFString, CFRangeMake(0, newValue.count))
        }
    }
    
    public enum TokenizingUnit {
        /// Finds words in the string.
        case word(preparingLatinTranscription: Bool)
        
        /// Finds sentences in the string.
        case sentence(preparingLanguage: Bool)
        
        /// Finds paragraphs in the string.
        case paragraph(preparingLanguage: Bool)
        
        /// Finds line breaks in the string.
        case lineBreak
        
        /// Uses a locale-aware word boundary.
        case localeAwareWord
        
        public static var word: Self { .word(preparingLatinTranscription: false) }
        public static var sentence: Self { .sentence(preparingLanguage: false) }
        public static var paragraph: Self { .paragraph(preparingLanguage: false) }
    }
    
    public struct Token {
        /// The language of the token, or `nil` if one was not found or the tokenizer was not asked to prepare it.
        public let languageCode: Locale.LanguageCode?
        
        /// The transcription of the string in latin, or `nil` if it could not be created or the tokenizer wasn't asked to create it.
        public let latinTranscription: String?
        
        /// The range of the token in the string.
        public let range: Range<String.Index>
        
        /// A substring containing the results of the token.
        public let substring: Substring
        
        /// The type of token.
        public let type: TokenType
    }
    
    public typealias TokenType = CFStringTokenizerTokenType
    
    /// The tokenizer's current token.
    public var currentToken: Token?
    
    @discardableResult private mutating func makeToken(type: TokenType) -> Token? {
        let range = CFStringTokenizerGetCurrentTokenRange(rawValue)
        
        guard range.location != kCFNotFound else {
            self.currentToken = nil
            return nil
        }
        
        let start = range.location
        
        let startIndex = string.index(string.startIndex, offsetBy: start)
        let endIndex = string.index(startIndex, offsetBy: range.length)
        let language = (CFStringTokenizerCopyCurrentTokenAttribute(rawValue, kCFStringTokenizerAttributeLanguage) as? String)
        let latinTranscription = CFStringTokenizerCopyCurrentTokenAttribute(rawValue, kCFStringTokenizerAttributeLatinTranscription) as? String
        
        self.currentToken = Token(
            languageCode: language.map { Locale.LanguageCode($0) },
            latinTranscription: latinTranscription,
            range: startIndex..<endIndex,
            substring: string[startIndex..<endIndex],
            type: type
        )
        
        return currentToken
    }
    
    /// Moves the tokenizer to the next token.
    @discardableResult public mutating func advanceToNextToken() -> Token? {
        let type = CFStringTokenizerAdvanceToNextToken(rawValue)
        return makeToken(type: type)
    }
    
    /// Moves the tokenizer to the token containing the character at `index`.
    @discardableResult public mutating func moveToToken(atIndex index: String.Index) -> Token? {
        let index = index.utf16Offset(in: string)
        
        let type = CFStringTokenizerGoToTokenAtIndex(rawValue, index)
        return makeToken(type: type)
    }
    
    /// Finds the most likely language in `string`.
    public static func bestLanguage(for string: String) -> Locale.LanguageCode? {
        CFStringTokenizerCopyBestStringLanguage(string as CFString, CFRangeMake(0, string.count)).map { Locale.LanguageCode($0 as String) }
    }
}

@available(macOS 13.0, *)
extension StringTokenizer.Token: CustomStringConvertible {
    public var description: String {
        String(substring)
    }
}

extension String {
    @available(macOS 13.0, *)
    public var bestLanguage: Locale.LanguageCode? {
        StringTokenizer.bestLanguage(for: self)
    }
    
    /// Creates a tokenizer with `boundary` as its word boundary.
    @available(macOS 13.0, *)
    public func tokenized(by boundary: StringTokenizer.TokenizingUnit) -> StringTokenizer {
        StringTokenizer(self, tokenizingBy: boundary)
    }
    
    /// A tokenizer that will find the words in the string.
    @available(macOS 13.0, *)
    public var words: StringTokenizer {
        self.tokenized(by: .word)
    }
    
    /// A tokenizer that will find the sentences in the string.
    @available(macOS 13.0, *)
    public var sentences: StringTokenizer {
        self.tokenized(by: .sentence)
    }
    
    /// A tokenizer that will find the paragraphs in the string.
    @available(macOS 13.0, *)
    public var paragraphs: StringTokenizer {
        self.tokenized(by: .paragraph)
    }
}

@available(macOS 13.0, *)
extension StringTokenizer: Sequence {
    public func makeIterator() -> Iterator {
        Iterator(tokenizer: self)
    }
    
    public struct Iterator: IteratorProtocol {
        public init(tokenizer: StringTokenizer) {
            self.tokenizer = tokenizer
        }
        
        public var tokenizer: StringTokenizer
        
        public mutating func next() -> StringTokenizer.Token? {
            guard let token = tokenizer.advanceToNextToken() else {
                tokenizer.moveToToken(atIndex: tokenizer.string.startIndex)
                return nil
            }
            
            return token
        }
    }
}
