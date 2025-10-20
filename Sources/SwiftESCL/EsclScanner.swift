//
//  ScannerRepresentation.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

import Foundation
import Network
import UniformTypeIdentifiers
import OSLog

/// An object storing the attributes of a single scanner.
public actor EsclScanner: Identifiable {
    
    public static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ScannerBrowser.self)
    )
    
    public let id: String
    
    public let baseUrl: URL
    /// Hostname of the scanner
    public let hostname: String
    /// (User defined) location of the scanner
    public let location: String?
    /// Model of the scanner
    public let model: String?
    /// Url to an image of the scanner
    public let iconUrl: URL?
    /// Root path for eSCL (usually "eSCL")
    public let root: String
    
    /// eSCL version of the scanner
    public let esclVersion: String?
    /// Configuration page URL for the scanner
    public let adminUrl: String?
    /// Mime types supported by the scanner (all scanners must support JPEG and PDF)
    public var mimeTypes: [UTType] = [.pdf, .jpeg]
    /// Color spaces supported by the scanner
    public var colorSpaces: [ColorCapability] = []
    /// Input sources supported by the scanner
    public var inputSources: [InputSource] = []
    /// Whether the scanner supports automatic duplex scanning via the ADF
    public var duplex: Bool = false
    
    public var capabilities: EsclScannerCapabilities? = nil
    
    /**
     This initialiser is only meant for manually adding devices if Bonjour doesn't work or isn't avaiable.
     - Parameter hostname: String containing the hostname/ip of the scanner.
     - Parameter root: The path to the eSCL root of the device. This should be  "eSCL" for most devices.
     */
    public init(id: String = UUID().uuidString, hostname: String, location: String? = nil, model: String? = nil, iconUrl: String? = nil, root: String, esclVersion: String? = nil, adminUrl: String? = nil, mimeTypes: [UTType] = [.pdf, .jpeg], colorSpaces: [ColorCapability] = [], inputSources: [InputSource] = [], duplex: Bool = false, usePlainText: Bool = false) throws {
        self.id = id
        self.hostname = hostname
        self.root = root
        
        self.location = location
        self.model = model
        if let iconUrl {
            self.iconUrl = URL(string: iconUrl)
        } else {
            self.iconUrl = nil
        }
        self.esclVersion = esclVersion
        self.adminUrl = adminUrl
        
        self.mimeTypes = mimeTypes
        self.colorSpaces = colorSpaces
        self.inputSources = inputSources
        
        if duplex {
            self.inputSources.append(.adfDuplex)
        }
        
        self.duplex = duplex
        
        if usePlainText {
            guard let url = URL(string: "http://" + hostname + "/" + root) else {
                throw ScannerRepresentationError.invalidUrl
            }
            self.baseUrl = url
        } else {
            guard let url = URL(string: "https://" + hostname + "/" + root) else {
                throw ScannerRepresentationError.invalidUrl
            }
            self.baseUrl = url
        }
    }
    
    /**
     The main initialiser. This takes a TXT-Record from the Bonjour discovery and retrieves all necessary data.
     -  Parameter txtRecord: An NWTXTRecord returned by an eSCL-Compliant scanner.
     */
    init(txtRecord: NWTXTRecord, usePlainText: Bool) throws {
        let recordDict = txtRecord.dictionary
        
        guard let adminUrlString = recordDict["adminurl"] else {
            throw ScannerRepresentationError.noAdminUrl
        }
        
        guard let adminUrlHost = URL(string: adminUrlString)?.host else {
            throw ScannerRepresentationError.invalidAdminUrl
        }
        
        // According to the specification, the key should be "uuid", but my device uses "UUID"
        guard let uuid = recordDict["uuid"] ?? recordDict["UUID"] else {
            throw ScannerRepresentationError.noUuid
        }
        
        guard let root = recordDict["rs"] else {
            throw ScannerRepresentationError.noRoot
        }
        
        self.id = uuid
        
        self.root = root
        
        self.hostname = adminUrlHost
        
        if usePlainText {
            guard let url = URL(string: "http://" + hostname + "/" + root) else {
                throw ScannerRepresentationError.invalidUrl
            }
            self.baseUrl = url
        } else {
            guard let url = URL(string: "https://" + hostname + "/" + root) else {
                throw ScannerRepresentationError.invalidUrl
            }
            self.baseUrl = url
        }
        
        // Location
        self.location = recordDict["note"]
        
        // Make and model
        self.model = recordDict["ty"]
        
        // eSCL Version
        self.esclVersion = recordDict["Vers"] ?? recordDict["vers"]
        
        // Admin url
        self.adminUrl = recordDict["adminurl"]
        
        // Supported mime types
        if let pdl = recordDict["pdl"] {
            self.mimeTypes = pdl.split(separator: ",").compactMap{ UTType(mimeType: String($0)) }
        }
        
        // Supported color spaces
        if let cs = recordDict["cs"] {
            self.colorSpaces = cs.split(separator: ",").compactMap{ ColorCapability(rawValue: String($0)) }
        }
        
        // Supported input sources
        if let inputSources = recordDict["is"] {
            self.inputSources = inputSources.split(separator: ",").compactMap { InputSource(rawValue: String($0)) }
        }
        
        // Duplex support
        if let duplex = recordDict["duplex"], duplex == "T" {
            self.duplex = true
        }
        
        // URL to a preview image for the device
        if let representation = recordDict["representation"] {
            
            // Some devices seem to report this as a full URL
            if recordDict["representation"]!.starts(with: "http") {
                // Because of the self signed certificate, the image has to be loaded via http to prevent certificate errors in AsyncImage
                self.iconUrl = URL(string: representation.replacingOccurrences(of: "https:", with: "http:"))
            }
            
            // Some other devices only report the subdirectory
            else {
                self.iconUrl = URL(string: "http://" + self.hostname + representation)
            }
        } else {
            self.iconUrl = nil
        }
    }
    
    /**
     Send a request to the scanner without returning the response
     - Parameter method: String representing the HTTP-method, default is `"GET"`
     - Parameter endpoint: The endpoint to send the request to
     - Parameter body: The body to send with the request, default is `nil`
     */
    func sendRequestAndIgnoreResponse(method: String = "GET", endPoint: EsclEndpoint, body: Data? = nil) async throws {
        _ = try await self.sendRequest(method: method, endPoint: endPoint, body: body)
    }
    
    /**
     Start a scan job.
     - Parameter scanSettings: Settings for the scan job
     */
    public func sendJobRequest(scanSettings: ScanSettings) async throws -> String {
        let url = self.baseUrl.appendingPathComponent(EsclEndpoint.scanJobs.uri)
        
        let session = URLSession(configuration: .default, delegate: UnsafeURLSessionDelegate(), delegateQueue: nil)
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "POST"
        
        urlRequest.httpBody = scanSettings.requestBody
        
        urlRequest.addValue("application/xml", forHTTPHeaderField: "Accept")
        
        Self.logger.debug("Sending POST request to \(url.absoluteString)")
        if let body = urlRequest.httpBody, let bodyStr = String(data: body, encoding: .utf8) {
            Self.logger.debug("Body:\n\(bodyStr)")
        }
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ScannerRepresentationError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 201:
            guard let jobUri =
                    httpResponse.value(forHTTPHeaderField: "Location") else {
                throw ScanJobError.noJobIdReceived
            }
            return jobUri
        case 404:
            throw ScannerRepresentationError.notFound
        case 409:
            throw ScanJobError.conflictingArguments
        case 503:
            throw ScanJobError.deviceUnavailable
        default:
            throw ScannerRepresentationError.unexpectedStatus(httpResponse.statusCode, data)
        }
    }
    
    /**
     Send a request to the scanner and return the response data
     - Parameter method: String representing the HTTP-method, default is `"GET"`
     - Parameter endpoint: The endpoint to send the request to
     - Parameter body: The body to send with the request, default is `nil`
     - Parameter updateProgress: A function that should be called by the URLSessionDelegate for progress updates
     */
    public func sendRequest(method: String = "GET", endPoint: EsclEndpoint, body: Data? = nil, _ updateProgress: @Sendable @escaping (Progress, NSKeyValueObservedChange<Double>) -> () = { _,_ in }) async throws -> Data {
        let url = self.baseUrl.appendingPathComponent(endPoint.uri)
        
        let session = URLSession(configuration: .default, delegate: UnsafeURLSessionDelegate(), delegateQueue: nil)
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method
        
        urlRequest.httpBody = body
        
        urlRequest.addValue("application/xml", forHTTPHeaderField: "Accept")
        
        Self.logger.debug("Sending \(method) request to \(url.absoluteString)")
        if let body, let bodyStr = String(data: body, encoding: .utf8) {
            Self.logger.debug("Body:\n\(bodyStr)")
        }
        
        let (data, response) = try await session.data(for: urlRequest, delegate: DownloadTaskURLSessionDelegate(updateProgress))
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ScannerRepresentationError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 404:
            throw ScannerRepresentationError.notFound
        case 503:
            throw ScannerRepresentationError.serviceUnavailable
        default:
            throw ScannerRepresentationError.unexpectedStatus(httpResponse.statusCode, data)
        }
    }
    
    /**
     Send a request to the scanner and decode the response.
     - Parameter method: String representing the HTTP-method, default is `"GET"`
     - Parameter endpoint: The endpoint to send the request to
     - Parameter body: The body to send with the request, default is `nil`
     */
    public func sendRequest<T: XMLDecodable>(method: String = "GET", endPoint: EsclEndpoint, body: Data? = nil) async throws -> T {
        let data: Data = try await self.sendRequest(method: method, endPoint: endPoint, body: body)
        return try T(xmlData: data)
    }
    
    /// Convenience method to get the scanner capabilities
    public func getCapabilities() async throws -> EsclScannerCapabilities {
        
        if let capabilities {
            return capabilities
        }
        
        let caps: EsclScannerCapabilities = try await self.sendRequest(endPoint: .scannerCapabilities)
        self.capabilities = caps
        return caps
    }
    
    /// Cenvenience method to get the scanner status
    public func getStatus() async throws -> ScannerStatus {
        return try await self.sendRequest(endPoint: .scannerStatus)
    }
    
    /**
     Convenience method to start a scan job.
     - Parameter scanSettings: Settings for the scan job
     - Returns A string containing the job ID (exluding the `/ScanJobs/` path)
     */
    public func startJob(_ scanSettings: ScanSettings) async throws -> String {
        let status = try await getStatus()
        guard status.state == .idle else {
            throw ScanJobError.scannerNotReady(status.state)
        }
        
        let jobUri = try await self.sendJobRequest(scanSettings: scanSettings)
        
        let regex = #/.*\/ScanJobs\/([0-9a-f\-]*)/#
        
        if let jobID = jobUri.firstMatch(of: regex)?.1 {
            return String(jobID)
        }
        
        return jobUri
    }
    
    /**
     Convenience method to cancel a running scan job
     - Parameter jobId: The ID of the scan job
     */
    public func cancelJob(_ jobId: String) async throws {
        try await self.sendRequestAndIgnoreResponse(endPoint: .scanJob(jobId))
    }
    
    /**
     Convenience method to get the next document of a scan job
     - Parameter jobId: The ID of the scan job
     - Parameter updateProgress:A function that should be called by the URLSessionDelegate for progress updates
     */
    public func getNextDocument(for jobId: String, _ updateProgress: @Sendable @escaping (Progress, NSKeyValueObservedChange<Double>) -> () = { _,_ in }) async throws -> Data {
        return try await self.sendRequest(endPoint: .scanNextDocument(jobId), updateProgress)
    }
    
    /**
     Convenience method to perform a scan job start to finish (This potentially runs for minutes!)
     - Parameter jobId: The ID of the scan job
     - Parameter updateProgress:A function that should be called by the URLSessionDelegate for progress updates
     */
    public func performScan(_ scanSettings: ScanSettings, _ updateProgress: @Sendable @escaping (Progress, NSKeyValueObservedChange<Double>) -> () = { _,_ in }) async throws -> [Data] {
        
        let jobId = try await self.startJob(scanSettings)
        
        var waitingForScanner = true
        
        var scanResults: [Data] = []
        
        var retries: Int = 0
        
        while waitingForScanner {
            
            if Task.isCancelled {
                try await self.cancelJob(jobId)
                throw ScanJobError.cancelled
            }
            
            do {
                scanResults.append(try await self.getNextDocument(for: jobId, updateProgress))
                retries = 0
            } catch ScannerRepresentationError.notFound {
                waitingForScanner = false
            } catch ScannerRepresentationError.serviceUnavailable {
                // My scanner throws a 503 after the first page of multi-page documents, this should catch that
                if retries < 3 {
                    Self.logger.info("Received a 503 while trying to get next page, trying again in a second...")
                    try await Task.sleep(for: .seconds(1))
                } else {
                    Self.logger.error("Scanner still returned a 503 after three retries, cancelling request...")
                    throw ScannerRepresentationError.serviceUnavailable
                }
            }
        }
        
        let status = try await self.getStatus()
        
        guard let jobStatus = status.scanJobs[jobId] else {
            //throw ScannerRepresentationError.scanJobNotFound
            Self.logger.error("Couldn't find job with URI \(jobId) in scanner status. Full status:\n\(String(describing: status))")
            return scanResults
        }
        
        guard jobStatus.jobState == .completed else {
            //throw ScannerRepresentationError.unexpectedScanJobState(jobStatus.jobState)
            Self.logger.error("Scanner doesn't report job as completed. Full status:\n\(String(describing: status))")
            return scanResults
        }
        
        return scanResults
    }
}
