//
//  DownloadTaskURLSessionDelegate.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 25.01.25.
//

import Foundation
import os

public final class DownloadTaskURLSessionDelegate: NSObject, URLSessionTaskDelegate {

    private let progressObserver = OSAllocatedUnfairLock<NSKeyValueObservation?>(initialState: nil)

    let updateProgress: @Sendable (Progress, NSKeyValueObservedChange<Double>) -> ()

    init(_ updateProgress: @Sendable @escaping (Progress, NSKeyValueObservedChange<Double>) -> ()) {
        self.updateProgress = updateProgress
    }

    public func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        let observer = task.progress.observe(\.fractionCompleted, changeHandler: updateProgress)
        progressObserver.withLock { $0 = observer }
    }
}
