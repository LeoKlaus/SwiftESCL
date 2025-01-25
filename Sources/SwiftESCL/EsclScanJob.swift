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
/**
 <scan:JobInfo>
 <pwg:JobUuid>1ddea9b5-4de6-42a3-942a-ec1e2ae19968</pwg:JobUuid>
 <pwg:JobUri>/eSCL/ScanJobs/1ddea9b5-4de6-42a3-942a-ec1e2ae19968</pwg:JobUri>
 <scan:Age>4</scan:Age>
 <pwg:ImagesCompleted>1</pwg:ImagesCompleted>
 <pwg:JobState>Completed</pwg:JobState>
 </scan:JobInfo>
 */
