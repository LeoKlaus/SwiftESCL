//
//  ScanSettings.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 21.01.25.
//

import UniformTypeIdentifiers


/**
 All parameters except version are optional. The scanner will use its default values for all settings that are not provided.
 */
public struct ScanSettings {
    
    /// Source for the scan
    public var source: InputSource
    
    /// The version of the eSCL protocol to be used
    public var version: String
    
    /// This helps the scanner auto-determine settings for the scan. If this is specified, the scanner may choose to ignore other parameters
    public var intent: Intent? = nil
    
    /// File format the scanner should produce
    public var mimeType: UTType? = nil
    
    /// The desired resolution in DPI.
    public var resolution: Int? = nil
    
    /// Color mode for the scan
    public var colorMode: ColorMode? = nil
    
    /// Size of the output in 300ths of an inch
    public var size: PaperSize? = nil
    
    /// Offset from the top-left origin point
    public var offset: IntSize? = nil

    /// Should be used when no `intent` is specified. Changes the way images are processed
    public var contentType: ContentType? = nil
    
    /// Colorspace for the scan
    public var colorSpace: ColorSpace? = nil
    
    /// Which CCD color channels to use for grayscale and monochrome scanning.
    public var ccdChannel: CcdChannel? = nil

    /// Which type of binary rendering to apply for black and white images.
    public var binaryRendering: BinaryRendering? = nil

    /// Whether or not to use the hardware duplexer
    public var duplex: Bool? = nil

    /// If the ADF supports `selectSinglePage`, this determines how many pages are scanned
    public var numberOfPages: Int? = nil
    
    
    
    /* Currently not supported
    /// Create a pending job on the scanner
    public var storedJobRequest: JobRequest? = nil //JobRequest consists of `JobName` and an optional `PIN`
    */
    
    /// Detect blank pages and set `BlankPageDetected` in `ScanImageInfo`
    public var blankPageDetection: Bool? = nil
    
    /// Detect blank pages and remove them
    public var blankPageDetectionAndRemoval: Bool? = nil
    
    /// Adjust the brightness of the output
    public var brightness: Int? = nil
    
    /// Compression factor, lower numbers mean less compression
    public var compressionFactor: Int? = nil
    
    /// Adjust the gamma of the output
    public var gamma: Int? = nil

    /// Adjust the contrast of the output
    public var contrast: Int? = nil

    /// The inflection point of image "highlights"; lower values lighten highlights
    public var highlight: Int? = nil

    /// Defines the level of noise removal
    public var noiseRemoval: Int? = nil
    
    /// The inflection point of image "shadows"; lower values darken shadows
    public var shadow: Int? = nil
    
    /// Adjust the sharpening of the output
    public var sharpen: Int? = nil
    
    /// Adjust the threshold level for black and white scans
    public var threshold: Int? = nil
    
    public init(source: InputSource, version: String, intent: Intent? = nil, mimeType: UTType? = nil, resolution: Int? = nil, colorMode: ColorMode? = nil, size: PaperSize? = nil, offset: IntSize? = nil, contentType: ContentType? = nil, colorSpace: ColorSpace? = nil, ccdChannel: CcdChannel? = nil, binaryRendering: BinaryRendering? = nil, duplex: Bool? = nil, numberOfPages: Int? = nil, blankPageDetection: Bool? = nil, blankPageDetectionAndRemoval: Bool? = nil, brightness: Int? = nil, compressionFactor: Int? = nil, gamma: Int? = nil, contrast: Int? = nil, highlight: Int? = nil, noiseRemoval: Int? = nil, shadow: Int? = nil, sharpen: Int? = nil, threshold: Int? = nil) {
        self.source = source
        self.version = version
        self.intent = intent
        self.mimeType = mimeType
        self.resolution = resolution
        self.colorMode = colorMode
        self.size = size
        self.offset = offset
        self.contentType = contentType
        self.colorSpace = colorSpace
        self.ccdChannel = ccdChannel
        self.binaryRendering = binaryRendering
        self.duplex = duplex
        self.numberOfPages = numberOfPages
        self.blankPageDetection = blankPageDetection
        self.blankPageDetectionAndRemoval = blankPageDetectionAndRemoval
        self.brightness = brightness
        self.compressionFactor = compressionFactor
        self.gamma = gamma
        self.contrast = contrast
        self.highlight = highlight
        self.noiseRemoval = noiseRemoval
        self.shadow = shadow
        self.sharpen = sharpen
        self.threshold = threshold
    }
    
    
    /**
     Calculate the offset for the current scansettings. This is only needed if the scanners ADF uses a justification that is not top-left.
     - Parameter for: The scanner to calculate the offset for.
     */
    mutating public func calculateOffSet(for scanner: EsclScanner) {
        if let sourceCaps = scanner.capabilities?.sourceCapabilities[self.source] {
            
            if self.offset?.width == nil && sourceCaps.justification?.xImagePosition == .right, let maxWidth = sourceCaps.maxWidth, let scanSize = self.size?.rawValue {
                
                self.offset = IntSize(width: maxWidth - scanSize.width, height: self.offset?.height ?? 0)
                
            }
            
            if self.offset?.height == nil && sourceCaps.justification?.yImagePosition == .bottom, let maxHeight = sourceCaps.maxHeight, let scanSize = self.size?.rawValue {
                
                self.offset = IntSize(width: self.offset?.width ?? 0, height: maxHeight - scanSize.height)
                
            }
        }
    }
    
    public func generateRequestBody() -> Data {
        var bodyStr = """
<?xml version="1.0" encoding="UTF-8"?>
    <scan:ScanSettings xmlns:pwg="http://www.pwg.org/schemas/2010/12/sm" xmlns:scan="http://schemas.hp.com/imaging/escl/2011/05/03">
      <pwg:Version>\(self.version)</pwg:Version>
"""
        
        bodyStr += "\n<pwg:InputSource>\(source.toBodyString())</pwg:InputSource>"
        
        if let intent {
            bodyStr += "\n<scan:Intent>\(intent.rawValue)</scan:Intent>"
        }
        
        if let format = mimeType?.preferredMIMEType {
            if self.version.isNewerOrEqualTo("2.1") {
                bodyStr += "\n<scan:DocumentFormatExt>\(format)</scan:DocumentFormatExt>"
            } else {
                bodyStr += "\n<pwg:DocumentFormat>\(format)</pwg:DocumentFormat>"
            }
        }
        
        if let resolution {
            bodyStr += "\n<scan:XResolution>\(resolution)</scan:XResolution>\n<scan:YResolution>\(resolution)</scan:YResolution>"
        }
        
        if let colorMode {
            bodyStr += "\n<scan:ColorMode>\(colorMode.rawValue)</scan:ColorMode>"
        }
        
        if let size {
            bodyStr += "\n<pwg:ScanRegions>"
            bodyStr += "\n<pwg:ScanRegion>"
            
            bodyStr += "\n<pwg:Width>\(size.rawValue.width)</pwg:Width>"
            
            bodyStr += "\n<pwg:Height>\(size.rawValue.height)</pwg:Height>"
            
            if let offset {
                bodyStr += "\n<pwg:XOffset>\(offset.width)</pwg:XOffset>"
                bodyStr += "\n<pwg:YOffset>\(offset.height)</pwg:YOffset>"
            }
            
            bodyStr += "\n<pwg:ContentRegionUnits>escl:ThreeHundredthsOfInches</pwg:ContentRegionUnits>"
            bodyStr += "\n</pwg:ScanRegion>"
            bodyStr += "\n</pwg:ScanRegions>"
        }
        
        if let contentType {
            bodyStr += "\n<pwg:ContentType>\(contentType.rawValue)</pwg:ContentType>"
        }
        
        if let colorSpace {
            bodyStr += "\n<scan:ColorSpace>\(colorSpace.rawValue)</scan:ColorSpace>"
        }
        
        if let ccdChannel {
            bodyStr += "\n<scan:CcdChannel>\(ccdChannel.rawValue)</scan:CcdChannel>"
        }
        
        if let binaryRendering {
            bodyStr += "\n<scan:BinaryRendering>\(binaryRendering.rawValue)</scan:BinaryRendering>"
        }
        
        if let duplex, duplex {
            bodyStr += "\n<scan:Duplex>true</scan:Duplex>"
        }
        
        if let numberOfPages {
            bodyStr += "\n<scan:NumberOfPages>\(numberOfPages)</scan:NumberOfPages>"
        }
        
        
        // I don't have a scanner to test these settings with, and the documentation for eSCL doesn't state the keys or values for this
        if let blankPageDetection, blankPageDetection {
            bodyStr += "\n<scan:BlankPageDetection>true</scan:BlankPageDetection>"
        }
        
        // I don't have a scanner to test these settings with, and the documentation for eSCL doesn't state the keys or values for this
        if let blankPageDetectionAndRemoval, blankPageDetectionAndRemoval {
            bodyStr += "\n<scan:BlankPageDetectionAndRemoval>true</scan:BlankPageDetectionAndRemoval>"
        }
        
        if let brightness {
            bodyStr += "\n<scan:Brightness>\(brightness)</scan:Brightness>"
        }
        
        if let compressionFactor {
            bodyStr += "\n<scan:CompressionFactor>\(compressionFactor)</scan:CompressionFactor>"
        }
        
        if let gamma {
            bodyStr += "\n<scan:Gamma>\(gamma)</scan:Gamma>"
        }
        
        if let contrast {
            bodyStr += "\n<scan:Contrast>\(contrast)</scan:Contrast>"
        }
        
        if let highlight {
            bodyStr += "\n<scan:Highlight>\(highlight)</scan:Highlight>"
        }
        
        if let noiseRemoval {
            bodyStr += "\n<scan:NoiseRemoval>\(noiseRemoval)</scan:NoiseRemoval>"
        }
        
        if let shadow {
            bodyStr += "\n<scan:Shadow>\(shadow)</scan:Shadow>"
        }
        
        if let sharpen {
            bodyStr += "\n<scan:Sharpen>\(sharpen)</scan:Sharpen>"
        }
        
        if let threshold {
            bodyStr += "\n<scan:Threshold>\(threshold)</scan:Threshold>"
        }
        
        bodyStr += "\n</scan:ScanSettings>"
        
        return Data(bodyStr.utf8)
    }
}
