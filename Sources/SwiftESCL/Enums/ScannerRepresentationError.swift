//
//  ScannerRepresentationError.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

import Foundation

public enum ScannerRepresentationError: Error {
    /// The TXT record of the scanner didn't include an admin URI
    case noAdminUrl
    /// The admin URI in the scanners TXT record is not a valid URL
    case invalidAdminUrl
    /// The TXT record of the scanner doesn't include a UUID
    case noUuid
    /// The TXT record of the scanner doesn't inlcude the eSCL root path
    case noRoot
    
    /// Received an unexpected response from the scanner
    case invalidResponse
    /// Scanner returned a 404 status
    case notFound
    /// Scanner returned a 503 status (this can be expected if the scanner is busy)
    case serviceUnavailable
    /// Scanner returned an unexpected status code, includes the HTTP status code and full response body
    case unexpectedStatus(Int, Data?)
    /// The given scanner URL is not a valid URL
    case invalidUrl
    /// The given job ID wasn't found in the scanners status response
    case scanJobNotFound
    /// The scanner returned an unexpected state for the scan job, includes the state of the job
    case unexpectedScanJobState(ScanJobState)
}
