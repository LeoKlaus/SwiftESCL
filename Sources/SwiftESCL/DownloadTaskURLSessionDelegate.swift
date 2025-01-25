//
//  DownloadTaskURLSessionDelegate.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 25.01.25.
//

import Foundation

public class DownloadTaskURLSessionDelegate: NSObject, URLSessionTaskDelegate {
    
    var progressObserver: NSKeyValueObservation?
    
    var updateProgress: (Progress, NSKeyValueObservedChange<Double>) -> ()
    
    init(_ updateProgress: @escaping (Progress, NSKeyValueObservedChange<Double>) -> ()) {
        self.updateProgress = updateProgress
    }
    
    public func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        progressObserver = task.progress.observe(\.fractionCompleted, changeHandler: updateProgress)
    }
}
