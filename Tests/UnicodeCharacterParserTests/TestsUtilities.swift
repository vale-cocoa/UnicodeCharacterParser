//
//  TestsUtilities.swift
//  UnicodeCharacterParserTests
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

import XCTest
@testable import UnicodeCharacterParser

let randomChars: [Character] = {
    let charFromUInt32: (UInt32) -> Character? = {
        guard let scalar = UnicodeScalar($0) else { return nil }
        
        return Character(scalar)
    }
    
    let lettersAndNumbers = [
        UnicodeScalar("a").value...UnicodeScalar("z").value,
        UnicodeScalar("A").value...UnicodeScalar("Z").value,
        UnicodeScalar("0").value...UnicodeScalar("9").value
    ]
        .joined()
        .compactMap(charFromUInt32)
    
    
    let emojis = (0x1F601...0x1F64F as ClosedRange<UInt32>)
        .compactMap(charFromUInt32)
    
    return lettersAndNumbers + emojis
}()

let randomUTF8pageURL: URL = {
    if let fileURL = Bundle.module.url(forResource: "randoUTF8mpage", withExtension: "txt") {
        
        return fileURL
    } else {
        var tString = (0..<(1024 * 10)).reduce(into: "", { partial, _ in
            partial.append(randomChars.randomElement()!)
        })
        let resourceURL = Bundle.module.resourceURL!
        var fileURL = resourceURL.appendingPathComponent("randomUTF8page")
        fileURL.appendPathExtension("txt")
        try! tString.write(to: fileURL, atomically: false, encoding: .utf8)
        
        return fileURL
    }
}()

let randomUTF16pageURL: URL = {
    if let fileURL = Bundle.module.url(forResource: "randomUTF16page", withExtension: "txt") {
        
        return fileURL
    } else {
        let tString = try! String(contentsOf: randomUTF8pageURL, encoding: .utf8)
        let resourceURL = Bundle.module.resourceURL!
        var fileURL = resourceURL.appendingPathComponent("randomUTF16page")
        fileURL.appendPathExtension("txt")
        try! tString.write(to: fileURL, atomically: false, encoding: .utf16)
        
        return fileURL
    }
}()

let randomUTF32pageURL: URL = {
    if let fileURL = Bundle.module.url(forResource: "randomUTF32page", withExtension: "txt") {
        
        return fileURL
    } else {
        let tString = try! String(contentsOf: randomUTF8pageURL, encoding: .utf8)
        let resourceURL = Bundle.module.resourceURL!
        var fileURL = resourceURL.appendingPathComponent("randomUTF32page")
        fileURL.appendPathExtension("txt")
        try! tString.write(to: fileURL, atomically: false, encoding: .utf32)
        
        return fileURL
    }
}()
