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
        subsystem: Bundle.main.bundleIdentifier ?? "SwiftESCL",
        category: String(describing: ScannerBrowser.self)
    )
    
    @Published public var discovered: [EsclScanner] = []
    
    var browser: NWBrowser
    var usePlainText: Bool

    /// Connections opened to resolve a discovered device's real host/port, keyed by identity so they can be found again for cleanup.
    private var pendingConnections: [ObjectIdentifier: NWConnection] = [:]

    /// The connection currently resolving each device's host/port, keyed by the device's uuid. Lets a `.changed`/`.removed` event
    /// invalidate a resolution that's still in flight so it can't add a scanner back after it was superseded or removed.
    private var resolutionsByDeviceId: [String: ObjectIdentifier] = [:]
    
    
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
    
    /**
     Switch encryption for the current browser. This stops discovery and does not start it again.
     - Parameter usePlainText Whether to query for scanners using the `uscan` or `uscans` service type. All scanners must discoverable via `uscan`, but most require the use of HTTPS for all operations. Plain text should only be used when no scanner can be found using `uscans`.
     */
    public func switchEncryption(usePlainText: Bool) {
        self.stopDiscovery()
        
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
                    
                    switch device.endpoint {
                    case .service(_,_,_,_),
                            .hostPort(_,_):
                        self.handleDiscoveredDevice(device)
                        
                    case .unix(_):
                        self.logger.warning("Got UNIX path, this is not a valid scanner advertisement.")
                    case .url(_):
                        self.logger.warning("Got URL, this is not a valid scanner advertisement.")
                    case .opaque(_):
                        self.logger.warning("Got an opaque endpoint, this is not a valid scanner advertisement.")
                    @unknown default:
                        self.logger.warning("Received unexpected value for device endpoint")
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
                        self.handleDiscoveredDevice(new)
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

        for connection in pendingConnections.values {
            connection.cancel()
        }
        pendingConnections.removeAll()
        resolutionsByDeviceId.removeAll()
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
    
    private func addScanner(_ device: NWBrowser.Result, host: String, port: Int) {
        switch device.metadata {
        case .none:
            self.logger.warning("Device \(String(describing: device.endpoint), privacy: .public) has no metadata.")
        case .bonjour(let record):
            do {
                let scannerRep = try EsclScanner(host: host, port: port, txtRecord: record, usePlainText: usePlainText)
                guard !self.discovered.contains(where: { $0.id == scannerRep.id }) else {
                    self.logger.debug("Scanner \(scannerRep.id, privacy: .public) is already discovered; ignoring duplicate.")
                    return
                }
                self.discovered.append(scannerRep)
            } catch {
                self.logger.error("Couldn't initialize device \(String(describing: device.endpoint), privacy: .public):\n\(error.localizedDescription, privacy: .public)\n\(String(describing: error), privacy: .public)")
                for (key, value) in record.dictionary {
                    self.logger.debug("\(key):\t\(value)")
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
            let id = record.dictionary["uuid"] ?? record.dictionary["UUID"]
            self.discovered.removeAll(where: { $0.id == id })

            if let id, let connectionId = self.resolutionsByDeviceId.removeValue(forKey: id) {
                self.pendingConnections.removeValue(forKey: connectionId)?.cancel()
            }
        @unknown default:
            self.logger.warning("Device \(String(describing: device.endpoint), privacy: .public) has unexpected metadata.")
        }
    }
    
    private nonisolated func handleDiscoveredDevice(_ device: NWBrowser.Result) {
        guard case .bonjour(let record) = device.metadata,
              let deviceId = record.dictionary["uuid"] ?? record.dictionary["UUID"] else {
            self.logger.warning("Device \(String(describing: device.endpoint), privacy: .public) has no usable Bonjour metadata; skipping host/port resolution.")
            return
        }

        let connection = NWConnection(to: device.endpoint, using: .tcp)
        let connectionId = ObjectIdentifier(connection)

        let forgetConnection: @Sendable () -> Void = {
            DispatchQueue.main.async {
                self.pendingConnections.removeValue(forKey: connectionId)
                // Only clear the "current resolution" pointer if a newer event hasn't already replaced it.
                if self.resolutionsByDeviceId[deviceId] == connectionId {
                    self.resolutionsByDeviceId.removeValue(forKey: deviceId)
                }
            }
        }

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                defer {
                    connection.cancel()
                    forgetConnection()
                }

                guard let innerEndpoint = connection.currentPath?.remoteEndpoint,
                      case .hostPort(let host, let port) = innerEndpoint else {
                    self.logger.warning("Connected to \(String(describing: device.endpoint), privacy: .public) but couldn't resolve a host/port for it.")
                    return
                }

                switch host {
                case .name(let hostName, _):
                    self.logger.debug("Got hostname: \(hostName)")
                    DispatchQueue.main.async {
                        guard self.resolutionsByDeviceId[deviceId] == connectionId else { return }
                        self.addScanner(device, host: hostName, port: Int(port.rawValue))
                    }
                case .ipv4(let IPv4Address):
                    do {
                        let ipv4String = try IPv4Address.rawValue.toIPv4String()
                        self.logger.debug("Got IPv4: \(ipv4String)")
                        DispatchQueue.main.async {
                            guard self.resolutionsByDeviceId[deviceId] == connectionId else { return }
                            self.addScanner(device, host: ipv4String, port: Int(port.rawValue))
                        }
                    } catch {
                        self.logger.error("Failed to decode IPv4 string \(error.localizedDescription, privacy: .public)")
                    }
                case .ipv6(let IPv6Address):
                    do {
                        let ipv6String = try IPv6Address.rawValue.toIPv6String()
                        self.logger.debug("Got IPv6: \(ipv6String)")
                        DispatchQueue.main.async {
                            guard self.resolutionsByDeviceId[deviceId] == connectionId else { return }
                            self.addScanner(device, host: ipv6String, port: Int(port.rawValue))
                        }
                    } catch {
                        self.logger.error("Failed to decode IPv6 string \(error.localizedDescription, privacy: .public)")
                    }

                @unknown default:
                    self.logger.warning("Received unexpected endpoint information")
                }
            case .failed(let error):
                self.logger.warning("Connection to \(String(describing: device.endpoint), privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
                connection.cancel()
                forgetConnection()
            case .cancelled:
                forgetConnection()
            default:
                break
            }
        }

        DispatchQueue.main.async {
            // A previous resolution for the same device that's still in flight is now stale — cancel it.
            if let staleConnectionId = self.resolutionsByDeviceId[deviceId] {
                self.pendingConnections.removeValue(forKey: staleConnectionId)?.cancel()
            }
            self.resolutionsByDeviceId[deviceId] = connectionId
            self.pendingConnections[connectionId] = connection
        }
        connection.start(queue: .global())
    }
}

