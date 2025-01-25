//
//  Capabilities.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 22.01.25.
//

import Foundation
import UniformTypeIdentifiers

/**
 An object representing the capabilites of a single source on a scanner.
 */
public struct Capabilities {
    public var colorModes: [ColorMode]
    public var documentFormats: Set<UTType>
    public var supportedResolutions: [Int]
    public var supportedIntents: [Intent]
    public var edgeAutoDetection: [AutoDetectionEdge]
    public var colorSpaces: [ColorSpace]
    public var ccdChannels: [CcdChannel]
    public var binaryRendering: [BinaryRendering]
    public var contentTypes: [ContentType]
    public var justification: Justification?
    public var feederCapacity: Int?
    public var adfOptions: [AdfOption]
    
    public var minWidth: Int?
    public var maxWidth: Int?
    public var minHeight: Int?
    public var maxHeight: Int?
    public var minPageWidth: Int?
    public var minPageHeight: Int?
    public var maxXOffset: Int?
    public var maxYOffset: Int?
    public var maxOpticalXResolution: Int?
    public var maxOpticalYResolution: Int?
    public var riskyLeftMargin: Int?
    public var riskyRightMargin: Int?
    public var riskyTopMargin: Int?
    public var riskyBottomMargin: Int?
    
    public var maxScanRegions: Int?
    
    public init(colorModes: [ColorMode] = [], documentFormats: Set<UTType> = [], supportedResolutions: [Int] = [], supportedIntents: [Intent] = [], edgeAutoDetection: [AutoDetectionEdge] = [], colorSpaces: [ColorSpace] = [], ccdChannels: [CcdChannel] = [], binaryRendering: [BinaryRendering] = [], contentTypes: [ContentType] = [], justification: Justification? = nil, feederCapacity: Int? = nil, adfOptions: [AdfOption] = [], minWidth: Int? = nil, maxWidth: Int? = nil, minHeight: Int? = nil, maxHeight: Int? = nil, maxXOffset: Int? = nil, maxYOffset: Int? = nil, maxOpticalXResolution: Int? = nil, maxOpticalYResolution: Int? = nil, riskyLeftMargin: Int? = nil, riskyRightMargin: Int? = nil, riskyTopMargin: Int? = nil, riskyBottomMargin: Int? = nil, maxScanRegions: Int? = nil) {
        self.colorModes = colorModes
        self.documentFormats = documentFormats
        self.supportedResolutions = supportedResolutions
        self.supportedIntents = supportedIntents
        self.edgeAutoDetection = edgeAutoDetection
        self.colorSpaces = colorSpaces
        self.ccdChannels = ccdChannels
        self.binaryRendering = binaryRendering
        self.contentTypes = contentTypes
        self.justification = justification
        self.feederCapacity = feederCapacity
        self.adfOptions = adfOptions
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.maxXOffset = maxXOffset
        self.maxYOffset = maxYOffset
        self.maxOpticalXResolution = maxOpticalXResolution
        self.maxOpticalYResolution = maxOpticalYResolution
        self.riskyLeftMargin = riskyLeftMargin
        self.riskyRightMargin = riskyRightMargin
        self.riskyTopMargin = riskyTopMargin
        self.riskyBottomMargin = riskyBottomMargin
        self.maxScanRegions = maxScanRegions
    }
}
