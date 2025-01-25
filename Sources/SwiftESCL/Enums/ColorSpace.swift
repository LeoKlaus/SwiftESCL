//
//  ColorSpace.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

public enum ColorSpace: RawRepresentable, Equatable {
    case sRGB
    case unknown(String)
    
    public typealias RawValue = String
    
    public init(rawValue: String) {
        switch rawValue {
        case "sRGB":
            self = .sRGB
        default:
            self = .unknown(rawValue)
        }
    }
    
    public var rawValue: String {
        switch self {
        case .sRGB:
            "sRGB"
        case .unknown(let string):
            string
        }
    }
}
