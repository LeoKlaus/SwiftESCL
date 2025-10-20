//
//  EsclEndpoint.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

public enum EsclEndpoint: Sendable {
    case scannerCapabilities
    case scannerStatus
    case scanBufferInfo
    case scanJobs
    case scanJob(String)
    case scanNextDocument(String)
    case scanImageInfo(String)
    case unknown(String)
    
    /// The path for the endpoint (including a `/` at the beginning).
    var uri: String {
        switch self {
        case .scannerCapabilities:
            "/ScannerCapabilities"
        case .scannerStatus:
            "/ScannerStatus"
        case .scanBufferInfo:
            "/ScanBufferInfo"
        case .scanJobs:
            "/ScanJobs"
        case .scanJob(let jobId):
            "/ScanJobs/\(jobId)"
        case .scanImageInfo(let jobId):
            "/ScanJobs/\(jobId)/ScanImageInfo"
        case .scanNextDocument(let jobId):
            "/ScanJobs/\(jobId)/NextDocument"
        case .unknown(let url):
            url
        }
    }
}
