//
//  ScannerBrowser.swift
//  SwiftESCL-next
//
//  Created by Leo Wehrfritz on 20.01.25.
//

import Foundation
import Network
import OSLog


@MainActor
open class ScannerBrowser: ObservableObject {
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ScannerBrowser.self)
    )
    
    @Published public var discovered: [EsclScanner] = []
    
    let browser: NWBrowser
    let usePlainText: Bool
    
    
    /**
     Initalize a ScannerBrowser to search for scanners via Bonjour in the local network.
     For this to work, you have to add
     <key>NSBonjourServices</key>
     <array>
        <string>_uscan._tcp</string>
        <string>_uscans._tcp</string>
     </array>
     to the Info.plist of your app.
     
     - Parameter usePlainText Whether to query for scanners using the `uscan` or `uscans` service type. All scanners must discoverable via `uscan`, but most require the use of HTTPS for all operations. Plain text should only be used when no scanner can be found using `uscans`.
     */
    public init(usePlainText: Bool = false) {
        
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        if usePlainText {
            browser = NWBrowser(for: .bonjourWithTXTRecord(type: "_uscan._tcp", domain: nil), using: parameters)
        } else {
            browser = NWBrowser(for: .bonjourWithTXTRecord(type: "_uscans._tcp", domain: nil), using: parameters)
        }
        
        self.usePlainText = usePlainText
    }
    
    /// Starts bonjour discovery
    open func startDiscovery() {
        
        if browser.state == .ready {
            return
        }
        
        browser.stateUpdateHandler = { newState in
            self.logger.debug("Browser switched state: \(String(describing: newState), privacy: .public)")
        }
        
        browser.browseResultsChangedHandler = { _, changes in
            changes.forEach { change in
                switch change {
                case .identical:
                    self.logger.debug("Identical")
                case .added(let device):
                    self.logger.debug("New device found: \(String(describing: device.endpoint), privacy: .public)")
                    DispatchQueue.main.async {
                        self.addScanner(device)
                    }
                case .removed(let device):
                    self.logger.debug("Device removed: \(String(describing: device.endpoint), privacy: .public)")
                    DispatchQueue.main.async {
                        self.removeScanner(device)
                    }
                case .changed(let old, let new, let flags):
                    self.logger.debug("Device changed: \(String(describing: old.metadata), privacy: .public) -> \(String(describing: new.metadata), privacy: .public): \(String(describing: flags), privacy: .public)")
                    DispatchQueue.main.async {
                        self.removeScanner(old)
                        self.addScanner(new)
                    }
                @unknown default:
                    break
                }
            }
        }
        
        browser.start(queue: .main)
    }
    
    /// Stops bonjour discovery (Warning: you have to recreate ScannerBrowser before being able to start discovery again!)
    public func stopDiscovery() {
        browser.cancel()
    }
    
    /**
     Manually add a scanner to the device list.
     - Parameter hostname:      Hostname/IP of the scanner to add.
     - Parameter root:          Path to the eSCL endpoint. You probably don't have to change this.
     - Parameter usePlainText:  Whether to use HTTPS or not.
     
     - Throws: ScannerRepresentationError.invalidUrl, if the hostname/root combination combines to an invalid URL.
     */
    public func addScanner(hostname: String, root: String = "eSCL", usePlainText: Bool = false) throws {
        let scannerRep = try EsclScanner(hostname: hostname, root: root, usePlainText: usePlainText)
        self.discovered.append(scannerRep)
    }
    
    private func addScanner(_ device: NWBrowser.Result) {
        switch device.metadata {
        case .none:
            self.logger.warning("Device \(String(describing: device.endpoint), privacy: .public) has no metadata.")
        case .bonjour(let record):
            do {
                let scannerRep = try EsclScanner(txtRecord: record, usePlainText: usePlainText)
                self.discovered.append(scannerRep)
            } catch {
                self.logger.error("Couldn't initialize device \(String(describing: device.endpoint), privacy: .public):\n\(error.localizedDescription, privacy: .public)\n\(String(describing: error), privacy: .public)")
                for (key, value) in record.dictionary {
                    print("\(key):\t\(value)")
                }
            }
        @unknown default:
            self.logger.warning("Device \(String(describing: device.endpoint), privacy: .public) has unexpected metadata.")
        }
    }
    
    private func removeScanner(_ device: NWBrowser.Result) {
        switch device.metadata {
        case .none:
            self.logger.warning("Device \(String(describing: device.endpoint), privacy: .public) has no metadata.")
        case .bonjour(let record):
            do {
                let scannerRep = try EsclScanner(txtRecord: record, usePlainText: usePlainText)
                self.discovered.removeAll(where: { $0.id == scannerRep.id })
            } catch {
                self.logger.error("Couldn't initialize device \(String(describing: device.endpoint), privacy: .public):\n\(error.localizedDescription, privacy: .public)\n\(String(describing: error), privacy: .public)")
            }
        @unknown default:
            self.logger.warning("Device \(String(describing: device.endpoint), privacy: .public) has unexpected metadata.")
        }
    }
}

