//
//  Data+toIPString.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 13.09.26.
//

import Foundation

enum IPDecodingError: Error {
    case invalidByteCount
}

extension Data {
    /**
     Formats this as an IPv4 string.
     
     - Returns: A string represting this as an IPv4
     - Throws: `IPDecodingError.invalidByteCount` if the byte count does not match a valid IPv4.
     */
    func toIPv4String() throws -> String {
        guard self.count == 4 else {
            throw IPDecodingError.invalidByteCount
        }
        
        let bytes = [UInt8](self)
        
        return bytes.map { String($0) }.joined(separator: ".")
    }
    
    /**
     Formats this as an IPv6 string.
     
     - Returns: A string represting this as an IPv6
     - Throws: `IPDecodingError.invalidByteCount` if the byte count does not match a valid IPv4.
     */
    func toIPv6String() throws -> String {
        guard self.count == 16 else {
            throw IPDecodingError.invalidByteCount
        }
        
        let bytes = [UInt8](self)
        
        var groups = [UInt16](repeating: 0, count: 8)
        for i in 0..<8 {
            groups[i] = (UInt16(bytes[i * 2]) << 8) | UInt16(bytes[i * 2 + 1])
        }
        
        var bestStart = -1, bestLen = 0
        var i = 0
        while i < 8 {
            guard groups[i] == 0 else { i += 1; continue }
            let start = i
            while i < 8 && groups[i] == 0 { i += 1 }
            if i - start > bestLen {
                bestLen = i - start
                bestStart = start
            }
        }
        if bestLen < 2 { bestStart = -1 }
        
        var result = ""
        i = 0
        while i < 8 {
            if i == bestStart {
                result += "::"
                i += bestLen
                continue
            }
            if !result.isEmpty && !result.hasSuffix(":") {
                result += ":"
            }
            result += String(groups[i], radix: 16)
            i += 1
        }
        
        return "[\(result)]"
    }
}
