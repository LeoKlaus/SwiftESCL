//
//  IPv4Address+hostString.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 14.09.26.
//

import Network

extension IPv4Address {
    /**
     A string representation of this address that can be used to construct a URL.
     */
    var hostString: String {
        let bytes = [UInt8](self.rawValue)
        return bytes.map { String($0) }.joined(separator: ".")
    }
}
