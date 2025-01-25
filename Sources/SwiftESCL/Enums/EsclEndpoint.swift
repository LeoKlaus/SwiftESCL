//
//  EsclEndpoint.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

public enum EsclEndpoint {
    case scannerCapabilities
    case scannerStatus
    case scanBufferInfo
    case scanJobs
    case scanJob(String)
    case scanNextDocument(String)
    case scanImageInfo(String)
    case scanData(String)
    
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
        case .scanData(let url):
            url
        }
    }
}
