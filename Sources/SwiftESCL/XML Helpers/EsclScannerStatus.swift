//
//  EsclScannerStatus.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 23.01.25.
//

import Foundation
import OSLog

public struct ScannerStatus: XMLDecodable, Sendable {
    public var version: String?
    public var state: ScannerState?
    public var adfState: AdfState?
    public var scanJobs: [String:EsclScanJob]
    
    /**
     Initialize from the XML returned by a scanner.
     - Parameter xmlData: The data returned by the scanner.
     */
    public init(xmlData: Data) throws {
        let parser = XMLParser(data: xmlData)
        let delegate = ParserDelegate()
        parser.delegate = delegate
        parser.shouldProcessNamespaces = true
        parser.parse()
        if let error = delegate.parsingError {
            throw error
        }
        guard let scannerStatus = delegate.scannerStatus else {
            throw XMLDecodingError.couldntInstantiateObject
        }
        self = scannerStatus
    }
    
    /// This should only be used for mocking
    public init(version: String? = nil, state: ScannerState? = nil, adfState: AdfState? = nil, scanJobs: [String:EsclScanJob] = [:]) {
        self.version = version
        self.state = state
        self.adfState = adfState
        self.scanJobs = scanJobs
    }
    
    /// This should only be used for mocking
    public class ParserDelegate: NSObject, XMLParserDelegate {
        
        static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: ScannerBrowser.self)
        )
        
        var currentValue = ""
        var scannerStatus: ScannerStatus? = nil
        var parsingError: Error? = nil
        
        var currentJobUri: String? = nil
        var currentJobUuid: String? = nil
        var currentJobAge: Int? = nil
        var currentJobImagesCompleted: Int?
        var currentJobState: ScanJobState?
        
        public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            switch elementName.lowercased() {
            case "scannerstatus":
                self.scannerStatus = ScannerStatus()
            default:
                currentValue = ""
            }
        }
        
        public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
            self.parsingError = parseError
            parser.abortParsing()
        }
        
        public func parser(_ parser: XMLParser, foundCharacters string: String) {
            currentValue += string
        }
        
        public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            switch elementName.lowercased() {
            case "version":
                self.scannerStatus?.version = currentValue
            case "state":
                guard let state = ScannerState(rawValue: currentValue) else {
                    self.parsingError = XMLDecodingError.unexptedType(ScannerState.self, currentValue)
                    parser.abortParsing()
                    return
                }
                self.scannerStatus?.state = state
            case "adfstate":
                guard let adfState = AdfState(rawValue: currentValue) else {
                    self.parsingError = XMLDecodingError.unexptedType(AdfState.self, currentValue)
                    parser.abortParsing()
                    return
                }
                self.scannerStatus?.adfState = adfState
            case "joburi":
                let regex = #/.*\/ScanJobs\/([0-9a-f\-]*)/#
                
                if let jobID = currentValue.firstMatch(of: regex)?.1 {
                    self.currentJobUri = String(jobID)
                } else {
                    self.currentJobUri = currentValue
                }
            case "jobuuid":
                self.currentJobUuid = currentValue
            case "age":
                guard let age = Int(currentValue) else {
                    self.parsingError = XMLDecodingError.unexptedType(Int.self, currentValue)
                    parser.abortParsing()
                    return
                }
                self.currentJobAge = age
            case "imagescompleted":
                guard let imageCompleted = Int(currentValue) else {
                    self.parsingError = XMLDecodingError.unexptedType(Int.self, currentValue)
                    parser.abortParsing()
                    return
                }
                self.currentJobImagesCompleted = imageCompleted
            case "jobstate":
                guard let jobState = ScanJobState(rawValue: currentValue) else {
                    self.parsingError = XMLDecodingError.unexptedType(ScanJobState.self, currentValue)
                    parser.abortParsing()
                    return
                }
                self.currentJobState = jobState
            case "jobinfo":
                guard let currentJobUri, let currentJobState, let currentJobUuid else {
                    self.parsingError = XMLDecodingError.unexptedType(EsclScanJob.self, currentValue)
                    parser.abortParsing()
                    return
                }
                
                self.scannerStatus?.scanJobs[currentJobUri] = EsclScanJob(
                    jobUuid: currentJobUuid,
                    age: currentJobAge,
                    imagesCompleted: currentJobImagesCompleted,
                    jobState: currentJobState
                )
                self.currentJobUuid = nil
                self.currentJobAge = nil
                self.currentJobImagesCompleted = nil
                self.currentJobState = nil
            case "scannerstatus", "jobs":
                break
            default:
                Self.logger.info("Unexpected key \(elementName, privacy: .public)")
            }
            currentValue = ""
        }
    }
}
