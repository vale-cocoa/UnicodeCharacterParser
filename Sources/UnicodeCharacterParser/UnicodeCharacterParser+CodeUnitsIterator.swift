//
//  UnicodeCharacterParser+CodeUnitsIterator.swift
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

extension UnicodeCharacterParser {
    struct CodeUnitsIterator: IteratorProtocol {
        static var _mod: Int { MemoryLayout<Element>.stride }
        
        static var _bufferSize: Int { 1024 * _mod }
        
        let _stream: InputStream
        
        var _buffer = Array<UInt8>(repeating: 0, count: _bufferSize)
        
        var _bufferResidue: Array<UInt8> = []
        
        var _codeUnitsIterator: IndexingIterator<Array<Element>> = IndexingIterator(_elements: [])
        
        var _error: Swift.Error? = nil
        
        init?(_ url: URL) {
            guard
                let stream = InputStream(url: url)
            else { return nil }
            
            self.init(stream: stream)
        }
        
        init(_ data: Data) {
            let stream = InputStream(data: data)
            self.init(stream: stream)
        }
        
        init(stream: InputStream) {
            self._stream = stream
            self._stream.open()
        }
        
        typealias Element = Codec.CodeUnit
        
        mutating func next() -> Element? {
            switch _stream.streamStatus {
            case .open: fallthrough
            case .opening: fallthrough
            case .reading: break
            
            case .error:
                self._error = _stream.streamError
                fallthrough
            case .atEnd:
                _stream.close()
                fallthrough
            case .closed: return nil
            
            case .notOpen: fallthrough
            case .writing: fallthrough
            @unknown default:
                _stream.close()
                preconditionFailure("Stream is in unmanageable status: \(_stream.streamStatus)")
            }
            if let n = _codeUnitsIterator.next() { return n }
            
            let lenght = _stream.read(&_buffer, maxLength: Self._bufferSize)
            guard
                lenght > 0
            else {
                _stream.close()
                if lenght < 0 {
                    _error = _stream.streamError!
                }
                
                return nil
            }
            
            let toIterate: Array<UInt8> = _bufferResidue + _buffer.prefix(lenght)
            let upTo = toIterate.count - (toIterate.count % Self._mod)
            _codeUnitsIterator = toIterate[toIterate.startIndex..<upTo]
                .withUnsafeBytes({
                    Array($0.bindMemory(to: Element.self)).makeIterator()
                })
            defer {
                _bufferResidue = Array(toIterate[upTo..<toIterate.endIndex])
            }
            
            return _codeUnitsIterator.next()
        }
        
    }
    
}
