//
//  AdfState.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 23.01.25.
//

public enum AdfState: String, CaseIterable {
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

    public init?(rawValue: String) {
        // Some widely-deployed servers (NAPS2, for example) emit the
        // misspelled value "ScannedAdfLoaded" instead of "ScannerAdfLoaded",
        // so both spellings are accepted here.
        let normalized = rawValue == "ScannedAdfLoaded" ? "ScannerAdfLoaded" : rawValue
        guard let match = Self.allCases.first(where: { $0.rawValue == normalized }) else {
            return nil
        }
        self = match
    }
}
