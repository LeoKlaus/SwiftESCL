//
//  EsclScanImageInfo.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 24.01.25.
//

import Foundation
import OSLog

public struct EsclScanImageInfo: XMLDecodable {
    
    /// UUID of the scanjob
    var jobUUID: String?
    /// Width of the scanjob
    var actualWidth: Int?
    /// Height of the scanjob
    var actualHeight: Int?
    /// Bytes per line of the scanjob
    var actualBytesPerLine: Int?
    
    public init(xmlData: Data) throws {
        let parser = XMLParser(data: xmlData)
        let delegate = ParserDelegate()
        parser.delegate = delegate
        parser.shouldProcessNamespaces = true
        parser.parse()
        if let error = delegate.parsingError {
            throw error
        }
        guard let scanImageInfo = delegate.scanImageInfo else {
            throw XMLDecodingError.couldntInstantiateObject
        }
        self = scanImageInfo
    }
    
    public init(jobUUID: String? = nil, actualWidth: Int? = nil, actualHeight: Int? = nil, actualBytesPerLine: Int? = nil) {
        self.jobUUID = jobUUID
        self.actualWidth = actualWidth
        self.actualHeight = actualHeight
        self.actualBytesPerLine = actualBytesPerLine
    }
    
    public class ParserDelegate: NSObject, XMLParserDelegate {
        
        static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: ScannerBrowser.self)
        )
        
        var currentValue = ""
        var scanImageInfo: EsclScanImageInfo? = nil
        var parsingError: Error? = nil
        
        public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            switch elementName.lowercased() {
            case "scanimageinfo":
                self.scanImageInfo = EsclScanImageInfo()
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
            case "jobuuid":
                self.scanImageInfo?.jobUUID = currentValue
            case "actualwidth":
                guard let width = Int(currentValue) else {
                    self.parsingError = XMLDecodingError.unexptedType(ScannerState.self, currentValue)
                    parser.abortParsing()
                    return
                }
                self.scanImageInfo?.actualWidth = width
            case "actualheight":
                guard let height = Int(currentValue) else {
                    self.parsingError = XMLDecodingError.unexptedType(ScannerState.self, currentValue)
                    parser.abortParsing()
                    return
                }
                self.scanImageInfo?.actualHeight = height
            case "actualbytesperline":
                guard let bytesPerLine = Int(currentValue) else {
                    self.parsingError = XMLDecodingError.unexptedType(ScannerState.self, currentValue)
                    parser.abortParsing()
                    return
                }
                self.scanImageInfo?.actualBytesPerLine = bytesPerLine
            case "joburi", "scanimageinfo":
                break
            default:
                Self.logger.info("Unexpected key \(elementName, privacy: .public)")
            }
            currentValue = ""
        }
    }
}
