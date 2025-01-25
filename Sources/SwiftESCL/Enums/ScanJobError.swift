//
//  ScanJobError.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 23.01.25.
//

public enum ScanJobError: Error {
    case scannerNotReady(ScannerState?)
    case noJobIdReceived
    case conflictingArguments
    case deviceUnavailable
}
