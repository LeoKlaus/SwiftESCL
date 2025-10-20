//
//  ScanJobState.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 24.01.25.
//

public enum ScanJobState: String, Sendable {
    /// Cancelled through user interaction
    case canceled = "Canceled"
    /// Cancelled through internal device or communication error
    case aborted = "Aborted"
    /// Finished successfully
    case completed = "Completed"
    /// Job was created, scanner is preparing
    case pending = "Pending"
    /// Job is currently being scanned
    case processing = "Processing"
}
