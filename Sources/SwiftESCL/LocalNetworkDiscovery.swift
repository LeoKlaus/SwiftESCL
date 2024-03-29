//
//  LocalNetworkDiscovery.swift
//  Swift-eSCL
//
//  Created by Leo Wehrfritz on 14.07.22.
//  Licensed under the MIT License
//

import Foundation
import Network
import SwiftUI
import os

/**
 An object storing the attributes of a single scanner.
 */
public class ScannerRepresentation {
    public var hostname: String
    public var location: String?
    public var model: String?
    public var iconUrl: URL?
    public var root: String
    
    /**
     This initialiser is only meant for manually adding devices if Bonjour doesn't work or isn't avaiable.
     - Parameter hostname: String containing the hostname/ip of the scanner.
     - Parameter root: The path to the eSCL root of the device. This should be  "eSCL" for most devices.
     */
    public init(hostname: String, root: String) {
        self.hostname = hostname
        self.root = root
    }
    
    /**
     The main initialiser. This takes a TXT-Record from the Bonjour discovery and retrieves all necessary data.
     -  Parameter txtRecord: An NWTXTRecord returned by an eSCL-Compliant scanner.
     */
    init(txtRecord: NWTXTRecord) {
        let recordDict = txtRecord.dictionary
        self.hostname = URL(string: recordDict["adminurl"] ?? "")!.host!
        // Location
        if recordDict["note"] != nil {
            self.location = recordDict["note"]
        }
        // Make and model
        if recordDict["ty"] != nil {
            self.model = recordDict["ty"]
        }
        // URL to a small image of the device
        if recordDict["representation"] != nil {
            // Some devices seem to report this as a full URL
            if recordDict["representation"]!.starts(with: "http") {
                // Because of the self signed certificate, the image has to be loaded via http to prevent certificate errors in AsyncImage
                self.iconUrl = URL(string: recordDict["representation"]!.replacingOccurrences(of: "https:", with: "http:"))
            }
            // Some other devices only report the subdirectory
            else {
                self.iconUrl = URL(string: "http://" + self.hostname + recordDict["representation"]!)
            }
        }
        // eSCL root of the device
        self.root = recordDict["rs"]!
    }
}

/**
 Object that can handle Bonjour requests.
 */
public class Browser {
    
    let browser: NWBrowser
    /// A dictionary in the format [hostname:ScannerRepresentation] of discovered devices.
    var scanners: Binding<[String:ScannerRepresentation]>?

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: Browser.self)
        )
    
    /**
     Create a new browser without a binding dictionary. Calling start() on this won't do anything.
     */
    public init(usePlainText: Bool = false) {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        if usePlainText {
            browser = NWBrowser(for: .bonjourWithTXTRecord(type: "_uscan._tcp", domain: nil), using: parameters)
        } else {
            browser = NWBrowser(for: .bonjourWithTXTRecord(type: "_uscans._tcp", domain: nil), using: parameters)
        }
        self.scanners = nil
    }
    
    /**
     Method to pass a binding dictionary to the browser. This isn't done in the main init to prevent issues with initiation in other classes.
     - Parameter scanners: A binding dictionary in the format [hostname:ScannerRepresentation] of discovered devices.
     */
    public func setDevices(scanners: Binding<[String:ScannerRepresentation]>) {
        self.scanners = scanners
    }

    /**
     Method to start discovery of devices via Bonjour.
     */
    public func start() {
        browser.stateUpdateHandler = { newState in
            Browser.logger.info("Browser: browser.stateUpdateHandler \(String(describing: newState))")
        }
        
        browser.browseResultsChangedHandler = { results, changes in
            results.forEach{ device in
                //print("Device metadata: \(device.metadata)")
                switch device.metadata {
                    
                case .bonjour(let record):
                    // Generate a ScannerRepresentation object containing all information the scanner provided.
                    let scanner = ScannerRepresentation(txtRecord: record)
                    self.scanners![scanner.hostname].wrappedValue = scanner
                    
                case .none:
                    Browser.logger.info("Browser: Record: none")
                @unknown default:
                    Browser.logger.info("Browser: Record: default")
                }
            }
        }
        browser.start(queue: .main)
    }
}
