//
//  InputSource.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

public enum InputSource: String {
    case platen, adf, camera, adfDuplex
    
    /// The value a scanner expects for the source parameter
    var bodyString: String {
        switch self {
        case .platen:
            "Platen"
        case .adf, .adfDuplex:
            "Feeder"
        case .camera:
            "scan:Camera"
        }
    }
}
