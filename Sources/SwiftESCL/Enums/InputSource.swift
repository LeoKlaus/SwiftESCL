//
//  InputSource.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

public enum InputSource: String {
    case platen, adf, camera, adfDuplex
    
    func toBodyString() -> String {
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
