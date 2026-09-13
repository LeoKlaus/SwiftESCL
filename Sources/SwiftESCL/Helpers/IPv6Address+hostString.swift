//
//  IPv6Address+hostString.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 13.09.26.
//

import Network

extension IPv6Address {
    /**
     A string representation of this address that can be used to construct a URL.
     */
    var hostString: String {
        let bytes = [UInt8](self.rawValue)
        
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

        if self.isLinkLocal, let interfaceName = self.interface?.name {
            result += "%25\(interfaceName)"
        }

        return "[\(result)]"
    }
}
