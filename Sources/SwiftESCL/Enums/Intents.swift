//
//  Intents.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

public enum Intent: RawRepresentable, Equatable {
    
    /// Scanning optimized for text
    case document
    /// A composite document with mixed text/graphic/photo content
    case textAndGraphic
    /// Scanning optimized for photo
    case photo
    /// Scanning optimized for performance (fast output)
    case preview
    
    /// Scanning optimized for 3 dimensional objects
    case object
    /// Scanning optimized for a business card
    case businessCard
    
    case unknown(String)
    
    public typealias RawValue = String
    
    public init(rawValue: String) {
        switch rawValue {
        case "Document":
            self = .document
        case "TextAndGraphic":
            self = .textAndGraphic
        case "Photo":
            self = .photo
        case "Preview":
            self = .preview
        case "Object":
            self = .object
        case "BusinessCard":
            self = .businessCard
        default:
            self = .unknown(rawValue)
        }
    }
    
    public var rawValue: String {
        switch self {
        case .document:
            "Document"
        case .textAndGraphic:
            "TextAndGraphic"
        case .photo:
            "Photo"
        case .preview:
            "Preview"
        case .object:
            "Object"
        case .businessCard:
            "BusinessCard"
        case .unknown(let string):
            string
        }
    }
}
