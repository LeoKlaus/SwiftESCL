//
//  ScanJobError.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 23.01.25.
//

public enum ScanJobError: Error, Sendable {
    /// The scanner is not ready to take a job, includes the current state of the scanner.
    case scannerNotReady(ScannerState?)
    /// The scanner did accept the job, but didn't return its ID (this might be a parsing errro).
    case noJobIdReceived
    /// The scanner rejected the job
    case conflictingArguments
    /// The scanner is unavailable
    case deviceUnavailable
    /// ScanJob has been cancelled
    case cancelled
}
