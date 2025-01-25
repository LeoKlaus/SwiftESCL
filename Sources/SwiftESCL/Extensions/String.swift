//
//  String.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 24.01.25.
//

import Foundation

public extension String {
    /// Allows for comparison of version numbers. Returns true if self is higher or equal to otherVersion
    func isNewerOrEqualTo(_ otherVersion: String) -> Bool {
        return self.compare(otherVersion, options: .numeric) != .orderedAscending
    }
}
