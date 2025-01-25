//
//  AdfState.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 23.01.25.
//

public enum AdfState: String {
    case processing = "ScannerAdfProcessing"
    case empty = "ScannerAdfEmpty"
    case jam = "ScannerAdfJam"
    case loaded = "ScannerAdfLoaded"
    case mispick = "ScannerAdfMispick"
    case hatchOpen = "ScannerAdfHatchOpen"
    case pageTooShort = "ScannerAdfDuplexPageTooShort"
    case pageTooLong = "ScannerAdfDuplexPageTooLong"
    case multipickDetected = "ScannerAdfMultipickDetected"
    case inputTrayFailed = "ScannerAdfInputTrayFailed"
    case inputTrayOverloaded = "ScannerAdfInputTrayOverloaded"
}
