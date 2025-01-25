//
//  EsclScanner.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 22.01.25.
//

import Foundation
import OSLog
import UniformTypeIdentifiers

/**
 An object representing the ScannerCapabilities of a scanner.
 */
public struct EsclScannerCapabilities: XMLDecodable {
    
    public var version: String?
    public var makeAndModel: String?
    public var manufacturer: String?
    public var serialNumber: String?
    public var uuid: String?
    public var adminUri: String?
    public var iconUri: String?
    public var certifications: [MopriaCertification] = []
    // This contains the capabilities of each source.
    public var sourceCapabilities: [InputSource: Capabilities] = [:]
    
    public var brightnessSupport: SteppedRange?
    public var compressionFactorSupport: SteppedRange?
    public var contrastSupport: SteppedRange?
    public var sharpenSupport: SteppedRange?
    public var thresholdSupport: SteppedRange?
    public var jobSourceInfoSupport: Bool?

    
    public init(version: String? = nil, makeAndModel: String? = nil, manufacturer: String? = nil, serialNumber: String? = nil, uuid: String? = nil, adminUri: String? = nil, iconUri: String? = nil, certifications: [MopriaCertification] = [], sourceCapabilities: [InputSource : Capabilities] = [:], brightnessSupport: SteppedRange? = nil, compressionFactorSupport: SteppedRange? = nil, contrastSupport: SteppedRange? = nil, sharpenSupport: SteppedRange? = nil, thresholdSupport: SteppedRange? = nil, jobSourceInfoSupport: Bool? = nil) {
        self.version = version
        self.makeAndModel = makeAndModel
        self.manufacturer = manufacturer
        self.serialNumber = serialNumber
        self.uuid = uuid
        self.adminUri = adminUri
        self.iconUri = iconUri
        self.certifications = certifications
        self.sourceCapabilities = sourceCapabilities
        self.brightnessSupport = brightnessSupport
        self.compressionFactorSupport = compressionFactorSupport
        self.contrastSupport = contrastSupport
        self.sharpenSupport = sharpenSupport
        self.thresholdSupport = thresholdSupport
        self.jobSourceInfoSupport = jobSourceInfoSupport
    }
    
    public init(xmlData: Data) throws {
        let parser = XMLParser(data: xmlData)
        let delegate = ParserDelegate()
        parser.delegate = delegate
        parser.parse()
        if let error = delegate.parsingError {
            throw error
        }
        guard let scanner = delegate.scanner else {
            throw XMLDecodingError.couldntInstantiateObject
        }
        self = scanner
    }
    
    /*public func getStatus() async throws {
        let url = self.baseUrl.appendingPathComponent(EsclEndpoint.scannerStatus.uri)
        
        let session = URLSession(configuration: .default, delegate: UnsafeURLSessionDelegate(), delegateQueue: nil)
        
        let plistDecoder = PropertyListDecoder()
        try plistDecoder.decode(Int.self, from: Data())
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.addValue("application/xml", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ScannerRepresentationError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            print(String(data: data, encoding: .utf8)!)
        case 404:
            throw ScannerRepresentationError.notFound
        default:
            throw ScannerRepresentationError.unexpectedStatus(httpResponse.statusCode, data)
        }
    }*/
    
    public class ParserDelegate: NSObject, XMLParserDelegate {
        
        static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: ParserDelegate.self)
        )
        
        public var scanner: EsclScannerCapabilities? = nil
        public var parsingError: Error? = nil
        
        private var currentValue: String = ""
        
        private var currentCertification: MopriaCertification? = nil
        private var currentCapabilities: Capabilities? = nil
        private var currentRange: SteppedRange? = nil
        
        public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            switch elementName.lowercased() {
            case "scan:scannercapabilities":
                self.scanner = EsclScannerCapabilities()
            case "scan:certification":
                self.currentCertification = MopriaCertification()
            case "scan:platen":
                self.currentCapabilities = Capabilities()
            case "scan:adfsimplexinputcaps":
                self.currentCapabilities = Capabilities()
            case "scan:adfduplexinputcaps":
                self.currentCapabilities = Capabilities()
            case "scan:camera":
                self.currentCapabilities = Capabilities()
            case "scan:justification":
                self.currentCapabilities?.justification = Justification()
            case "scan:brightnesssupport":
                self.currentRange = SteppedRange()
            case "scan:compressionfactorsupport":
                self.currentRange = SteppedRange()
            case "scan:contrastsupport":
                self.currentRange = SteppedRange()
            case "scan:sharpensupport":
                self.currentRange = SteppedRange()
            case "scan:thresholdsupport":
                self.currentRange = SteppedRange()
            default:
                self.currentValue = ""
            }
        }
        
        // Called when closing tag (`</elementName>`) is found
        public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            switch elementName.lowercased() {
            case "pwg:version":
                self.scanner?.version = self.currentValue
            case "pwg:makeandmodel":
                self.scanner?.makeAndModel = self.currentValue
            case "scan:manufacturer":
                self.scanner?.manufacturer = self.currentValue
            case "pwg:serialnumber":
                self.scanner?.serialNumber = self.currentValue
            case "scan:uuid":
                self.scanner?.uuid = self.currentValue
            case "scan:adminuri":
                self.scanner?.adminUri = self.currentValue
            case "scan:iconuri":
                self.scanner?.iconUri = self.currentValue
            case "scan:certification":
                if let currentCertification {
                    self.scanner?.certifications.append(currentCertification)
                }
            case "scan:name":
                self.currentCertification?.name = self.currentValue
            case "scan:version":
                self.currentCertification?.version = self.currentValue
            case "scan:platen":
                self.scanner?.sourceCapabilities[.platen] = self.currentCapabilities
            case "scan:adfsimplexinputcaps":
                self.scanner?.sourceCapabilities[.adf] = self.currentCapabilities
            case "scan:adfduplexinputcaps":
                self.scanner?.sourceCapabilities[.adfDuplex] = self.currentCapabilities
            case "scan:camera":
                self.scanner?.sourceCapabilities[.camera] = self.currentCapabilities
            case "scan:minwidth":
                if let minWidth = Int(self.currentValue) {
                    self.currentCapabilities?.minWidth = minWidth
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:maxwidth":
                if let maxWidth = Int(self.currentValue) {
                    self.currentCapabilities?.maxWidth = maxWidth
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:minheight":
                if let minHeight = Int(self.currentValue) {
                    self.currentCapabilities?.minHeight = minHeight
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:maxheight":
                if let maxHeight = Int(self.currentValue) {
                    self.currentCapabilities?.maxHeight = maxHeight
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:minpagewidth":
                if let minPageWidth = Int(self.currentValue) {
                    self.currentCapabilities?.minPageWidth = minPageWidth
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:minpageheight":
                if let minPageHeight = Int(self.currentValue) {
                    self.currentCapabilities?.minPageHeight = minPageHeight
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:maxxoffset":
                if let maxXOffset = Int(self.currentValue) {
                    self.currentCapabilities?.maxXOffset = maxXOffset
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:maxyoffset":
                if let maxYOffset = Int(self.currentValue) {
                    self.currentCapabilities?.maxYOffset = maxYOffset
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:maxopticalxresolution":
                self.currentCapabilities?.maxOpticalXResolution = Int(self.currentValue)
            case "scan:maxopticalyresolution":
                self.currentCapabilities?.maxOpticalYResolution = Int(self.currentValue)
            case "scan:riskyleftmargin":
                self.currentCapabilities?.riskyLeftMargin = Int(self.currentValue)
            case "scan:riskyrightmargin":
                self.currentCapabilities?.riskyRightMargin = Int(self.currentValue)
            case "scan:riskytopmargin":
                self.currentCapabilities?.riskyTopMargin = Int(self.currentValue)
            case "scan:riskybottommargin":
                self.currentCapabilities?.riskyBottomMargin = Int(self.currentValue)
            case "scan:maxscanregions":
                self.currentCapabilities?.maxScanRegions = Int(self.currentValue) ?? 1
            case "scan:colormode":
                if let colorMode = ColorMode(rawValue: self.currentValue) {
                    self.currentCapabilities?.colorModes.append(colorMode)
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "pwg:documentformat", "scan:documentformatext":
                if let mimeType = UTType(mimeType: self.currentValue) {
                    self.currentCapabilities?.documentFormats.insert(mimeType)
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:xresolution":
                if let xResolution = Int(self.currentValue) {
                    self.currentCapabilities?.supportedResolutions.append(xResolution)
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:intent":
                self.currentCapabilities?.supportedIntents.append(Intent(rawValue: self.currentValue))
            case "scan:supportededge":
                if let supportedEdge = AutoDetectionEdge(rawValue: self.currentValue) {
                    self.currentCapabilities?.edgeAutoDetection.append(supportedEdge)
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:colorspace":
                self.currentCapabilities?.colorSpaces.append(ColorSpace(rawValue: self.currentValue))
            case "scan:ccdchannel":
                if let ccdChannel = CcdChannel(rawValue: self.currentValue) {
                    self.currentCapabilities?.ccdChannels.append(ccdChannel)
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:binaryrendering":
                if let rendering = BinaryRendering(rawValue: self.currentValue) {
                    self.currentCapabilities?.binaryRendering.append(rendering)
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "pwg:contenttype":
                if let contentType = ContentType(rawValue: self.currentValue) {
                    self.currentCapabilities?.contentTypes.append(contentType)
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "pwg:ximageposition":
                if let xImagePosition = ImagePositionHorizontal(rawValue: self.currentValue) {
                    self.currentCapabilities?.justification?.xImagePosition = xImagePosition
                    self.scanner?.sourceCapabilities[.adf]?.justification = self.currentCapabilities?.justification
                    self.scanner?.sourceCapabilities[.adfDuplex]?.justification = self.currentCapabilities?.justification
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "pwg:yimageposition":
                if let yImagePosition = ImagePositionVertical(rawValue: self.currentValue) {
                    self.currentCapabilities?.justification?.yImagePosition = yImagePosition
                    self.scanner?.sourceCapabilities[.adf]?.justification = self.currentCapabilities?.justification
                    self.scanner?.sourceCapabilities[.adfDuplex]?.justification = self.currentCapabilities?.justification
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:feedercapacity":
                self.currentCapabilities?.feederCapacity = Int(self.currentValue)
                self.scanner?.sourceCapabilities[.adf]?.feederCapacity = Int(self.currentValue)
                self.scanner?.sourceCapabilities[.adfDuplex]?.feederCapacity = Int(self.currentValue)
            case "scan:adfoption":
                if let adfOption = AdfOption(rawValue: self.currentValue) {
                    self.currentCapabilities?.adfOptions.append(adfOption)
                    self.scanner?.sourceCapabilities[.adf]?.adfOptions.append(adfOption)
                    self.scanner?.sourceCapabilities[.adfDuplex]?.adfOptions.append(adfOption)
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
            case "scan:brightnesssupport":
                self.scanner?.brightnessSupport = self.currentRange
            case "scan:compressionfactorsupport":
                self.scanner?.compressionFactorSupport = self.currentRange
            case "scan:contrastsupport":
                self.scanner?.contrastSupport = self.currentRange
            case "scan:sharpensupport":
                self.scanner?.sharpenSupport = self.currentRange
            case "scan:thresholdsupport":
                self.scanner?.thresholdSupport = self.currentRange
            case "scan:min":
                self.currentRange?.min = Int(self.currentValue) ?? 0
            case "scan:max":
                self.currentRange?.max = Int(self.currentValue) ?? 0
            case "scan:normal":
                self.currentRange?.normal = Int(self.currentValue) ?? 0
            case "scan:step":
                self.currentRange?.step = Int(self.currentValue) ?? 0
            case "scan:jobsourceinfosupport":
                if self.currentValue == "true" {
                    self.scanner?.jobSourceInfoSupport = true
                } else if self.currentValue == "false" {
                    self.scanner?.jobSourceInfoSupport = false
                } else {
                    Self.logger.error("Found unexpected value for key \(elementName, privacy: .public): \(self.currentValue, privacy: .public)")
                }
                // Ignored values
            case "scan:scannercapabilities", "scan:certifications", "scan:colormodes", "scan:documentformats", "scan:yresolution", "scan:discreteresolutions", "scan:discreteresolution", "scan:ccdchannels", "scan:supportedresolutions", "scan:binaryrenderings", "scan:contenttypes", "scan:settingprofile", "scan:settingprofiles", "scan:supportedintents", "scan:colorspaces", "scan:plateninputcaps", "scan:justification", "scan:adfoptions", "scan:edgeautodetection", "scan:adf", "scan:esclconfigcap", "scan:statesupport", "scan:state":
                break
            default:
                Self.logger.info("Found unexpected key \(elementName, privacy: .public)")
                break
            }
        }
        
        // Called when a character sequence is found
        // This may be called multiple times in a single element
        public func parser(_ parser: XMLParser, foundCharacters string: String) {
            self.currentValue += string
        }
        
        // Called when a CDATA block is found
        public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
            guard let string = String(data: CDATABlock, encoding: .utf8) else {
                print("CDATA contains non-textual data, ignored")
                return
            }
            self.currentValue += string
        }
        
        // For debugging
        public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
            self.parsingError = parseError
            parser.abortParsing()
        }
    }
}
