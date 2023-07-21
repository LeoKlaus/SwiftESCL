//
//  eSCLScanner.swift
//  Swift-eSCL
//
//  Created by Leo Wehrfritz on 14.07.22.
//  Licensed under the MIT License
//

import Foundation
import Combine
import os

/**
 An object representing a single eSCL scanner. It contains no information but the scanners hostname/ip.
 The methods of this class are the way you can interact with the device.
 */
public class esclScanner: NSObject, URLSessionDelegate {
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: esclScanner.self)
        )
    
    var baseURI: String
    public var scanner: Scanner = Scanner()
    private var usePlainText: Bool = false
    
    public init(ip: String, root: String, usePlainText: Bool = false) {
        if usePlainText {
            self.baseURI = "http://\(ip)/\(root)/"
            self.usePlainText = true
        } else {
            self.baseURI = "https://\(ip)/\(root)/"
        }
        super.init()
        self.getCapabilities()
    }

    public enum ScannerStatus {
        case Idle
        case Processing
        case Testing
        case Stopped
        case Down
    }
    
    /**
     This method retrieves the capabilities of a scanner.
     */
    private func getCapabilities() {
        
        var capabilities = Scanner()
        
        var urlRequest = URLRequest(url: URL(string: self.baseURI + "ScannerCapabilities")!)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/xml", forHTTPHeaderField: "Accept")
        
        let configuration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.init())
        
        let sem = DispatchSemaphore.init(value: 0)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            defer { sem.signal() }
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                esclScanner.logger.error("Capabilities: Couldn't get capabilities from device \(self.scanner.makeAndModel, privacy: .public): \(error.debugDescription, privacy: .public)")
                if let url = urlRequest.url?.absoluteString {
                    esclScanner.logger.error("Capabilities: Queried URL: \(url, privacy: .public)")
                }
                return
            }
            
            guard(200 ... 299) ~= response.statusCode else {
                esclScanner.logger.error("Capabilities: Received invalid response from device: \(String(response.statusCode), privacy: .public)")
                return
            }
            
            let parser = CapabilityParser(data: data)
            let success:Bool = parser.parse()
            if success {
                capabilities = parser.scanner
                esclScanner.logger.info("Capabilities: Success. Capabilities for device \(self.scanner.makeAndModel, privacy: .public) parsed!")
            } else {
                esclScanner.logger.error("Capabilities: Encountered an error while parsing capabilities: \(parser.parserError.debugDescription, privacy: .public)")
                if let stringResponse = String(data: data, encoding: .utf8) {
                    esclScanner.logger.error("Device response: \(stringResponse, privacy: .public)")
                }
            }
        }
        
        
        esclScanner.logger.info("Capabilities: Querying capabilities for device \(self.scanner.makeAndModel, privacy: .public)...")
        
        task.resume()
        sem.wait()
        
        self.scanner = capabilities
    }
    
    /**
     This method query the scanners status.
     - Returns:An enum of type ScannerStatus
     */
    public func getStatus() -> ScannerStatus {
        
        var status = ScannerStatus.Down
        
        var urlRequest = URLRequest(url: URL(string: self.baseURI + "ScannerStatus")!)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/xml", forHTTPHeaderField: "Accept")
        
        let configuration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.init())

        let sem = DispatchSemaphore.init(value: 0)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            defer { sem.signal() }
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                esclScanner.logger.error("Capabilities: Couldn't get capabilities from device \(self.scanner.makeAndModel, privacy: .public): \(error)")
                if let url = urlRequest.url?.absoluteString {
                    esclScanner.logger.error("Capabilities: Queried URL: \(url, privacy: .public)")
                }
                return
            }
            
            guard(200 ... 299) ~= response.statusCode else {
                esclScanner.logger.error("Status: Received invalid response from device: \(String(response.statusCode), privacy: .public)")
                return
            }
            
            let parser = StatusParser(data: data)
            let success:Bool = parser.parse()
            if success {
                if parser.status == "Idle" {
                    status = ScannerStatus.Idle
                    esclScanner.logger.info("Status: Device is idle")
                }
                else if parser.status == "Processing" {
                    status = ScannerStatus.Processing
                    esclScanner.logger.info("Status: Device is processing")
                }
                else if parser.status == "Testing" {
                    status = ScannerStatus.Testing
                    esclScanner.logger.info("Status: Device is testing")
                }
                else if parser.status == "Stopped" {
                    status = ScannerStatus.Stopped
                    esclScanner.logger.info("Status: Device is stopped")
                }
                else {
                    status = ScannerStatus.Down
                }
            } else {
                esclScanner.logger.error("Status: Encountered an error while parsing status response")
            }
        }
        
        esclScanner.logger.info("Status: Querying status for device \(self.scanner.makeAndModel, privacy: .public)...")
        
        task.resume()
        sem.wait()
        
        return status
    }
    
    /**
     This method sends a GET request to the scanner. It is used to retrieve the scanned image.
     - Parameter uri: A string with the aboslute URL to the scanned image. This URL is created by the scanner after posting a scan-request and is available for a short time only (I'm guessing it can only be accessed once.)
     - Returns: A tuple containing the binary data of the image and the response code of the last request (which should be 200).
     */
    public func sendGetRequest(uri: String) -> (Data, Int) {
        
        var urlRequest = URLRequest(url: URL(string: uri)!)
        var imageData = Data()
        
        var responseCode = 0
        urlRequest.httpMethod = "GET"
        
        let configuration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.init())
        
        let sem = DispatchSemaphore.init(value: 0)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            defer { sem.signal() }
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                esclScanner.logger.error("GetRequest: Couldn't get capabilities from device \(self.scanner.makeAndModel, privacy: .public): \(error)")
                if let url = urlRequest.url?.absoluteString {
                    esclScanner.logger.error("GetRequest: Queried URL: \(url, privacy: .public)")
                }
                return
            }
            responseCode = response.statusCode
            guard(200 ... 299) ~= response.statusCode else {
                esclScanner.logger.error("GetRequest: Received invalid response from device: \(String(response.statusCode), privacy: .public)")
                return
            }
            esclScanner.logger.info("GetRequest: Request finished, received \(data.count) bytes")
            imageData = data
        }
        esclScanner.logger.info("GetRequest: Sending request to \(self.scanner.makeAndModel, privacy: .public)...")
        task.resume()
        sem.wait()
        return (imageData, responseCode)
    }
    
    /**
     This method sends a POST request to the scanner (this is what actually initiates the scan). And returns the results as binary data. The body of the request is generated using the following parameters:
     - Parameter resolution: A string containing the desired resolution in DPI. This could be easily changed to take an integer instead, but for my purposes, a String was easier to handle.
     - Parameter colorMode: A string containing the desired color mode. For most scanners, the available options here are "BlackAndWhite1", "Grayscale8" and "RGB24".
     - Parameter format: The mimetype of the file the scanner should produce. My scanners only support "application/pdf" and "image/jpg".
     - Parameter version: The version of the eSCL protocol to be used.
     - Parameter source: The source to use for the scan. This can either be "Platen" (that's flatbed), "Adf" or "Camera".
     - Parameter width: Width of the desired output in pixels at 300 DPI. This can be converted to inches by dividing by 300, to centimeters by dividing by 118.
     - Parameter height: Height of the desired output in pixels at 300 DPI.
     - Parameter XOffset: Offset on the X-Axis. It is necessary to set this for some scanners.
     - Parameter YOffset: Offset on the Y-Axis.
     - Parameter intent: This helps the scanner auto-determine settings for the scan. Technically, version and intent should suffice for a valid request. To my understanding, the defaults set by an intent are ignored as soon as values are provided.
     - Parameter colorSpace: The colorspace to use for the scan. Both my scanners only support one color space (sRGB), so I can't really test this.
     - Parameter ccdChannel: I'm not quite sure what exactly this does. My scanners both only support NTSC, so I can't test this.
     - Parameter contentType: I'm not quite sure how this differs from intent. My guess is that this only provides a subset of the defautls provided through an intent.
     - Parameter brightness: The brightness setting to use for the scan.
     - Parameter compressionFacter: How much the resulting image should be compressed.
     - Parameter contrast: Contrast setting to use for the scan.
     - Parameter sharpen: How much sharpening should be applied to the image.
     - Parameter threshold: I'm not quite sure what exactly this does. My best guess is that this would define the cutoff from which white is considered white when scanning in grayscale or black and white.
     - Returns: A tuple containing the the URL to the scan and the response code of the last request (which should be 200).
     */
    public func sendPostRequest(resolution: Int? = nil, colorMode: String? = nil, format: String? = nil, source: String = "Platen", width: Int? = nil, height: Int? = nil, XOffset: Int? = nil, YOffset: Int? = nil, intent: String? = nil, colorSpace: String? = nil, ccdChannel: String? = nil, contentType: String? = nil, brightness: Int? = nil, compressionFactor: Int? = nil, contrast: Int? = nil, sharpen: Int? = nil, threshold: Int? = nil) -> (String, Int) {

        var urlRequest = URLRequest(url: URL(string: self.baseURI+"ScanJobs")!)
        
        var responseCode: Int = 0
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        
        var responseURL: String = ""
        
        // Scanners will report supported sources as "Adf" or "Camera" but expect "Feeder" or "scan:Camera" for actual requests
        // It is beyond me why the Mopria Alliance chose to do this
        var fuckYouMopriaForMakingThisSoComplicated: String
        if source == "Adf" || source == "adf" {
            fuckYouMopriaForMakingThisSoComplicated = "Feeder"
        }
        else if source == "Camera" || source == "camera" {
            fuckYouMopriaForMakingThisSoComplicated = "scan:Camera"
        }
        else {
            fuckYouMopriaForMakingThisSoComplicated = source
        }
        if self.scanner.sourceCapabilities[source] == nil {
            esclScanner.logger.error("PostRequest: The selected source \"\(source , privacy: .public)\" is not supported by the scanner, aborting...")
            return ("",409)
        }
        let sourceCapabilities = self.scanner.sourceCapabilities[source]!
        // The base structure of the body
        var body = """
    <scan:ScanSettings xmlns:pwg="http://www.pwg.org/schemas/2010/12/sm" xmlns:scan="http://schemas.hp.com/imaging/escl/2011/05/03">
      <pwg:Version>\(self.scanner.version)</pwg:Version>
    """
        
        if width != nil && height != nil {
            body.append("\n<pwg:ScanRegions>")
            body.append("\n<pwg:ScanRegion>")
        
            if width! <= self.scanner.maxWidth && width! >= self.scanner.minWidth {
                body.append("\n<pwg:Width>\(width!)</pwg:Width>")
            } else {
                esclScanner.logger.warning("PostRequest: Width \(width!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
            
            if height! <= self.scanner.maxHeight && height! >= self.scanner.minHeight {
                body.append("\n<pwg:Height>\(height!)</pwg:Height>")
            } else {
                esclScanner.logger.warning("PostRequest: Height \(height!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
            
            if XOffset != nil {
                body.append("\n<pwg:XOffset>\(XOffset!)</pwg:XOffset>")
            }
            
            if YOffset != nil {
                body.append("\n<pwg:YOffset>\(YOffset!)</pwg:YOffset>")
            }
            
            body.append("\n<pwg:ContentRegionUnits>escl:ThreeHundredthsOfInches</pwg:ContentRegionUnits>")
            body.append("\n</pwg:ScanRegion>")
            body.append("\n</pwg:ScanRegions>")
        }
        
        body.append("\n<pwg:InputSource>\(fuckYouMopriaForMakingThisSoComplicated)</pwg:InputSource>")
        
        if intent != nil {
            if sourceCapabilities.supportedIntents.contains(intent!) {
                body.append("\n<scan:Intent>\(intent!)</scan:Intent>")
            } else {
                esclScanner.logger.warning("PostRequest: Intent \(intent!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
        }
        
        if format != nil {
            if sourceCapabilities.documentFormats.contains(format!) {
                body.append("\n<pwg:DocumentFormat>\(format!)</pwg:DocumentFormat>")
            } else {
                esclScanner.logger.warning("PostRequest: Format \(format!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
        }
        
        if colorMode != nil {
            if sourceCapabilities.colorModes.contains(colorMode!) {
                body.append("\n<scan:ColorMode>\(colorMode!)</scan:ColorMode>")
            } else {
                esclScanner.logger.warning("PostRequest: Color mode \(colorMode!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
        }
        
        if resolution != nil {
            if sourceCapabilities.supportedResolutions.contains(resolution!) {
                body.append("\n<scan:XResolution>\(resolution!)</scan:XResolution>\n<scan:YResolution>\(resolution!)</scan:YResolution>")
            } else {
                esclScanner.logger.warning("PostRequest: Resolution \(resolution!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
        }
        
        //colorSpace: String? = nil, ccdChannel: String? = nil, contentType: String? = nil, brightness: Int? = nil, compressionFactor: Int? = nil, contrast: Int? = nil, sharpen: Int? = nil, threshold: Int? = nil
        if colorSpace != nil {
            if sourceCapabilities.colorSpaces.contains(colorSpace!) {
                body.append("\n<scan:ColorSpace>\(colorSpace!)</scan:ColorSpace>")
            } else {
                esclScanner.logger.warning("PostRequest: Color space \(colorSpace!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
        }
        
        if ccdChannel != nil {
            if sourceCapabilities.ccdChannels.contains(ccdChannel!) {
                body.append("\n<scan:CcdChannel>\(ccdChannel!)</scan:CcdChannel>")
            } else {
                esclScanner.logger.warning("PostRequest: CCD-Channel \(ccdChannel!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
        }
        
        if contentType != nil {
            if sourceCapabilities.contentTypes.contains(contentType!) {
                body.append("\n<pwg:ContentType>\(contentType!)</pwg:ContentType>")
            } else {
                esclScanner.logger.warning("PostRequest: Content type \(contentType!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
        }
        
        if brightness != nil {
            if self.scanner.brightnessSupport.min <= brightness! && brightness! <= self.scanner.brightnessSupport.max {
                body.append("\n<scan:Brightness>\(brightness!)</scan:Brightness>")
            } else {
                esclScanner.logger.warning("PostRequest: Brightness setting \(brightness!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
        }
        
        if compressionFactor != nil {
            if self.scanner.compressionFactorSupport.min <= compressionFactor! && compressionFactor! <= self.scanner.compressionFactorSupport.max {
                body.append("\n<scan:CompressionFactor>\(compressionFactor!)</scan:CompressionFactor>")
            } else {
                esclScanner.logger.warning("PostRequest: Compression factor \(compressionFactor!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
        }
        
        if contrast != nil {
            if self.scanner.contrastSupport.min <= contrast! && contrast! <= self.scanner.contrastSupport.max {
                body.append("\n<scan:Contrast>\(contrast!)</scan:Contrast>")
            } else {
                esclScanner.logger.warning("PostRequest: Contrast setting \(contrast!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
        }
        
        if sharpen != nil {
            if self.scanner.sharpenSupport.min <= sharpen! && sharpen! <= self.scanner.sharpenSupport.max {
                body.append("\n<scan:Sharpen>\(sharpen!)</scan:Sharpen>")
            } else {
                esclScanner.logger.warning("PostRequest: Sharpen setting \(sharpen!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
        }
        
        if threshold != nil {
            if self.scanner.thresholdSupport.min <= threshold! && threshold! <= self.scanner.thresholdSupport.max {
                body.append("\n<scan:Threshold>\(threshold!)</scan:Threshold>")
            } else {
                esclScanner.logger.warning("PostRequest: Threshold \(threshold!, privacy: .public) is not supported by the scanner. Ignoring this parameter.")
            }
        }
        
        body.append("\n</scan:ScanSettings>")
        
        esclScanner.logger.info("PostRequest: created body:\n\(body, privacy: .public)")
        
        
        urlRequest.httpBody = body.data(using: .utf8)
        
        let configuration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.init())
        
        let sem = DispatchSemaphore.init(value: 0)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            defer { sem.signal() }
            guard
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                esclScanner.logger.error("PostRequest: Couldn't get capabilities from device \(self.scanner.makeAndModel, privacy: .public): \(error)")
                if let url = urlRequest.url?.absoluteString {
                    esclScanner.logger.error("PostRequest: Queried URL: \(url, privacy: .public)")
                }
                return
            }
            
            guard(200 ... 299) ~= response.statusCode else {
                esclScanner.logger.error("PostRequest: Received invalid response from device: \(response.statusCode, privacy: .public)")
                responseCode = response.statusCode
                return
            }
            
            // The scanner returns the url to the document under the "Location" header. One of the devices I tested with returned the location with "http" as the protocol even though request were made using HTTPS
            if self.usePlainText {
                responseURL = (response.allHeaderFields["Location"] as! String) + "/NextDocument"
            } else {
                responseURL = (response.allHeaderFields["Location"] as! String).replacingOccurrences(of: "http:", with: "https:") + "/NextDocument"
            }
            responseCode = response.statusCode
            esclScanner.logger.info("PostRequest: Request accepted! Location: \(responseURL, privacy: .public)")
        }
        
        esclScanner.logger.info("PostRequest: Sending request to \(self.scanner.makeAndModel, privacy: .public)...")
        
        task.resume()
        sem.wait()
        
        return (responseURL, responseCode)
    }
    
    /**
     Method to perform an entire scan operation.
     - Parameter resolution: A string containing the desired resolution in DPI. This could be easily changed to take an integer instead, but for my purposes, a String was easier to handle.
     - Parameter colorMode: A string containing the desired color mode. For most scanners, the available options here are "BlackAndWhite1", "Grayscale8" and "RGB24".
     - Parameter format: The mimetype of the file the scanner should produce. My scanners only support "application/pdf" and "image/jpg".
     - Parameter version: The version of the eSCL protocol to be used.
     - Parameter source: The source to use for the scan. This can either be "Platen" (that's flatbed), "Adf" or "Camera".
     - Parameter width: Width of the desired output in pixels at 300 DPI. This can be converted to inches by dividing by 300, to centimeters by dividing by 118.
     - Parameter height: Height of the desired output in pixels at 300 DPI.
     - Parameter XOffset: Offset on the X-Axis. It is necessary to set this for some scanners.
     - Parameter YOffset: Offset on the Y-Axis.
     - Parameter intent: This helps the scanner auto-determine settings for the scan. Technically, version and intent should suffice for a valid request. To my understanding, the defaults set by an intent are ignored as soon as values are provided.
     - Parameter colorSpace: The colorspace to use for the scan. Both my scanners only support one color space (sRGB), so I can't really test this.
     - Parameter ccdChannel: I'm not quite sure what exactly this does. My scanners both only support NTSC, so I can't test this.
     - Parameter contentType: I'm not quite sure how this differs from intent. My guess is that this only provides a subset of the defautls provided through an intent.
     - Parameter brightness: The brightness setting to use for the scan.
     - Parameter compressionFacter: How much the resulting image should be compressed.
     - Parameter contrast: Contrast setting to use for the scan.
     - Parameter sharpen: How much sharpening should be applied to the image.
     - Parameter threshold: I'm not quite sure what exactly this does. My best guess is that this would define the cutoff from which white is considered white when scanning in grayscale or black and white.
     - Returns: A tuple containing the Binary Data of the scanned image and the last http response code
     */
    public func scanDocument(resolution: Int? = nil, colorMode: String? = nil, format: String? = nil, source: String = "Platen", width: Int? = nil, height: Int? = nil, XOffset: Int? = nil, YOffset: Int? = nil, intent: String? = nil, colorSpace: String? = nil, ccdChannel: String? = nil, contentType: String? = nil, brightness: Int? = nil, compressionFactor: Int? = nil, contrast: Int? = nil, sharpen: Int? = nil, threshold: Int? = nil) -> (Data,Int) {
        
        var data = Data()
        
        if getStatus() != ScannerStatus.Idle {
            esclScanner.logger.warning("ScanDocument: Scanner is not idle but \(String(describing: self.getStatus()), privacy: .public)")
            return (data, 503)
        }
        
        let (url, postResponse) = self.sendPostRequest(resolution: resolution, colorMode: colorMode, format: format, source: source, width: width, height: height, XOffset: XOffset, YOffset: YOffset, intent: intent, colorSpace: colorSpace, ccdChannel: ccdChannel, contentType: contentType, brightness: brightness, compressionFactor: compressionFactor, contrast: contrast, sharpen: sharpen, threshold: threshold)
        
        if postResponse != 201 {
            esclScanner.logger.error("ScanDocument: Scanner didn't accept the job. \(String(postResponse), privacy: .public)")
            return (data, postResponse)
        }
        
        var responseCode = 0
        while responseCode != 200 {
            sleep(2)
            (data, responseCode) = self.sendGetRequest(uri: url)
            print(responseCode)
            if responseCode == 410 {
                return(data, postResponse)
            }
        }
        // My scanners won't reach idle after completing a scan without this
        _ = self.sendGetRequest(uri: url)
        
        return (data, responseCode)
    }
    
    /**
     Method to perform an entire scan operation.
     - Parameter resolution: A string containing the desired resolution in DPI. This could be easily changed to take an integer instead, but for my purposes, a String was easier to handle.
     - Parameter colorMode: A string containing the desired color mode. For most scanners, the available options here are "BlackAndWhite1", "Grayscale8" and "RGB24".
     - Parameter format: The mimetype of the file the scanner should produce. My scanners only support "application/pdf" and "image/jpg".
     - Parameter version: The version of the eSCL protocol to be used.
     - Parameter source: The source to use for the scan. This can either be "Platen" (that's flatbed), "Adf" or "Camera".
     - Parameter width: Width of the desired output in pixels at 300 DPI. This can be converted to inches by dividing by 300, to centimeters by dividing by 118.
     - Parameter height: Height of the desired output in pixels at 300 DPI.
     - Parameter XOffset: Offset on the X-Axis. It is necessary to set this for some scanners.
     - Parameter YOffset: Offset on the Y-Axis.
     - Parameter intent: This helps the scanner auto-determine settings for the scan. Technically, version and intent should suffice for a valid request. To my understanding, the defaults set by an intent are ignored as soon as values are provided.
     - Parameter colorSpace: The colorspace to use for the scan. Both my scanners only support one color space (sRGB), so I can't really test this.
     - Parameter ccdChannel: I'm not quite sure what exactly this does. My scanners both only support NTSC, so I can't test this.
     - Parameter contentType: I'm not quite sure how this differs from intent. My guess is that this only provides a subset of the defautls provided through an intent.
     - Parameter brightness: The brightness setting to use for the scan.
     - Parameter compressionFacter: How much the resulting image should be compressed.
     - Parameter contrast: Contrast setting to use for the scan.
     - Parameter sharpen: How much sharpening should be applied to the image.
     - Parameter threshold: I'm not quite sure what exactly this does. My best guess is that this would define the cutoff from which white is considered white when scanning in grayscale or black and white.
     - Parameter filePath: Path at which the file should be stored. If not specified, the file will be stored in the document root under the name "scan-YY-MM-dd-HH-mm-ss.fileExtension"
     - Returns: A tuple containing the URL to the file created and the last http response code
     */
    public func scanDocumentAndSaveFile(resolution: Int? = nil, colorMode: String? = nil, format: String = "application/pdf", source: String = "Platen", width: Int? = nil, height: Int? = nil, XOffset: Int? = nil, YOffset: Int? = nil, intent: String? = nil, colorSpace: String? = nil, ccdChannel: String? = nil, contentType: String? = nil, brightness: Int? = nil, compressionFactor: Int? = nil, contrast: Int? = nil, sharpen: Int? = nil, threshold: Int? = nil, filePath: URL? = nil) -> (URL?, Int) {
        
        let status = self.getStatus()
        if status != ScannerStatus.Idle {
            esclScanner.logger.warning("ScanDocumentAndSave: Scanner is not idle but \(String(describing: status), privacy: .public)")
            return (nil, 503)
        }
        
        let (url, postResponse) = self.sendPostRequest(resolution: resolution, colorMode: colorMode, format: format, source: source, width: width, height: height, XOffset: XOffset, YOffset: YOffset, intent: intent, colorSpace: colorSpace, ccdChannel: ccdChannel, contentType: contentType, brightness: brightness, compressionFactor: compressionFactor, contrast: contrast, sharpen: sharpen, threshold: threshold)
        
        if postResponse != 201 {
            esclScanner.logger.error("ScanDocumentAndSave: Scanner didn't accept the job. \(String(postResponse), privacy: .public)")
            return (nil, postResponse)
        }
        
        var data = Data()
        var responseCode = 0
        while responseCode != 200 {
            sleep(2)
            (data, responseCode) = self.sendGetRequest(uri: url)
            esclScanner.logger.info("ScanDocumentAndSave: Waiting for file, server returned: \(String(responseCode), privacy: .public)")
            if responseCode == 410 {
                return(nil, postResponse)
            }
        }
        // My scanners won't reach idle after completing a scan without this
        _ = self.sendGetRequest(uri: url)
        
        var path: URL
        if filePath == nil {
            let fileExtension = (format == "application/pdf") ? ".pdf" : ".jpeg"
            
            // This is just used for determinining a file name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YY-MM-dd-HH-mm-ss"
            let filename = "scan-" + dateFormatter.string(from: Date()) + fileExtension
            
            path = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask)[0].appendingPathComponent(filename)
        } else {
            path = filePath!
        }
        
        if (try? data.write(to: path)) != nil {
            esclScanner.logger.info("ScanDocumentAndSave: Saved file!")
        } else {
            esclScanner.logger.warning("ScanDocumentAndSave: Couldn't save file")
        }
        
        return (path, responseCode)
    }
    
    // It is necessary to build a custom URLSession for this as the self signed certificates the scanners use are obviously not trusted by default.
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.serverTrust == nil {
            completionHandler(.useCredential, nil)
        } else {
            let trust: SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }
}
