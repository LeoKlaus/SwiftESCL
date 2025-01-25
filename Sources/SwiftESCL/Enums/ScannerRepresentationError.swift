//
//  ScannerRepresentationError.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

import Foundation

public enum ScannerRepresentationError: Error {
    case noAdminUrl
    case invalidAdminUrl
    case noUuid
    case noRoot
    
    case invalidResponse
    case notFound
    case serviceUnavailable
    case unexpectedStatus(Int, Data?)
    
    case invalidUrl
    
    case scanJobNotFound
    case unexpectedScanJobState(ScanJobState)
}
