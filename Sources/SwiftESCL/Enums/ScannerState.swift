//
//  ScannerState.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 23.01.25.
//

public enum ScannerState: String, Sendable {
    case idle = "Idle"
    case processing = "Processing"
    case testing = "Testing"
    case stopped = "Stopped"
    case down = "Down"
}
