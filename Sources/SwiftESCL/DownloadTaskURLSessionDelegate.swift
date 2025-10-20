//
//  DownloadTaskURLSessionDelegate.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 25.01.25.
//

import Foundation

public final class DownloadTaskURLSessionDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    
    var progressObserver: NSKeyValueObservation?
    
    let updateProgress: @Sendable (Progress, NSKeyValueObservedChange<Double>) -> ()
    
    private let queue = DispatchQueue(label: "downloadTaskDelegateLockQueue-" + UUID().uuidString)
    
    init(_ updateProgress: @Sendable @escaping (Progress, NSKeyValueObservedChange<Double>) -> ()) {
        self.updateProgress = updateProgress
    }
    
    public func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        self.queue.sync {
            self.progressObserver = task.progress.observe(\.fractionCompleted, changeHandler: updateProgress)
        }
    }
}
