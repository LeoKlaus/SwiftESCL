//
//  EsclScanJob.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 24.01.25.
//

import Foundation

public struct EsclScanJob {
    var jobUuid: String
    var age: Int?
    var imagesCompleted: Int?
    var jobState: ScanJobState
}
