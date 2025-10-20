//
//  ScannerBrowserError.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 15.08.25.
//

public enum ScannerBrowserError: Error, Sendable {
    /// The browser was previously closed and cannot be used anymore. Create a new `ScannerBrowser` instance to start discovery.
    case browserIsClosed
}
