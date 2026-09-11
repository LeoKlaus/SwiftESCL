//
//  DiscoveryTests.swift
//  SwiftESCL
//

import Testing
import Foundation
import Network
@testable import SwiftESCL

private func txtRecord(adminUrl: String) -> NWTXTRecord {
    NWTXTRecord([
        "adminurl": adminUrl,
        "uuid": "4509a320-00a0-008f-00b6-002507510eca",
        "rs": "eSCL"
    ])
}

@Test func usesThePortFromTheAdminUrl() throws {
    let scanner = try EsclScanner(
        txtRecord: txtRecord(adminUrl: "https://naps2-4509a320.local.:13284/eSCL/admin"),
        usePlainText: false
    )

    #expect(scanner.port == 13284)
    #expect(scanner.baseUrl.absoluteString == "https://naps2-4509a320.local.:13284/eSCL")
}

@Test func usesThePortFromTheAdminUrlForPlainText() throws {
    let scanner = try EsclScanner(
        txtRecord: txtRecord(adminUrl: "http://naps2-4509a320.local.:13283/eSCL/admin"),
        usePlainText: true
    )

    #expect(scanner.port == 13283)
    #expect(scanner.baseUrl.absoluteString == "http://naps2-4509a320.local.:13283/eSCL")
}

@Test func keepsTheSchemeDefaultWhenTheAdminUrlHasNoPort() throws {
    let scanner = try EsclScanner(
        txtRecord: txtRecord(adminUrl: "http://192.168.1.2/index.html"),
        usePlainText: false
    )

    #expect(scanner.port == nil)
    #expect(scanner.baseUrl.absoluteString == "https://192.168.1.2/eSCL")
}

@Test func manuallyAddedScannersCanSpecifyAPort() throws {
    let scanner = try EsclScanner(hostname: "192.168.1.2", port: 8090, root: "eSCL", usePlainText: true)

    #expect(scanner.baseUrl.absoluteString == "http://192.168.1.2:8090/eSCL")
}

@Test func manuallyAddedScannersDefaultToNoExplicitPort() throws {
    let scanner = try EsclScanner(hostname: "192.168.1.2", root: "eSCL")

    #expect(scanner.port == nil)
    #expect(scanner.baseUrl.absoluteString == "https://192.168.1.2/eSCL")
}
