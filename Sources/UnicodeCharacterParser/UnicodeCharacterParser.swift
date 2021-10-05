//
//  UnicodeCharacterParser.swift
//  CharacterParser
//
//  Created by Valeriano Della Longa on 2021/10/03.
//  Copyright © 2021 Valeriano Della Longa. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import Foundation

public struct UnicodeCharacterParser<Codec: UnicodeCodec>: IteratorProtocol {
    public enum Error: Swift.Error {
        case streamError(Swift.Error)
        
        case truncatedCodeUnit(Array<UInt8>)
        
    }
    
    public var error: Error? = nil
    
    public typealias Element = Character
    
    internal private(set) var _codeUnitsIterator: CodeUnitsIterator
    
    internal private(set) var _codec = Codec()
    
    internal private(set) lazy var _replacement: Character = {
        let decoded = Codec.decode(Codec.encodedReplacementCharacter)
        
        return Character(decoded)
    }()
    
    public init(streamingBytesFrom data: Data) {
        let iterator = CodeUnitsIterator(data)
        self.init(codeUnitsIterator: iterator)
    }
    
    public init?(streamingBytesAt url: URL) {
        guard
            let iterator = CodeUnitsIterator(url)
        else { return nil }
        
        self.init(codeUnitsIterator: iterator)
    }
    
    internal init(codeUnitsIterator: CodeUnitsIterator) {
        self._codeUnitsIterator = codeUnitsIterator
    }
    
    public mutating func next() -> Character? {
        switch _codec.decode(&_codeUnitsIterator) {
        case .emptyInput:
            defer {
                if let streamError = _codeUnitsIterator._error {
                    error = .streamError(streamError)
                } else if !_codeUnitsIterator._bufferResidue.isEmpty {
                    error = .truncatedCodeUnit(_codeUnitsIterator._bufferResidue)
                }
            }
            
            return nil
        
        case .scalarValue(let scalar): return Character(scalar)
        
        case .error: return _replacement
        }
    }
    
}
