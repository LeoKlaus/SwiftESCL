//
//  UnsafeURLSessionDelegate.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

import Foundation

public final class UnsafeURLSessionDelegate: NSObject, URLSessionDelegate {
    
    // It is necessary to build a custom URLSessionDelegate for this as the self signed certificates the scanners use are obviously not trusted by default.
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.serverTrust == nil {
            completionHandler(.useCredential, nil)
        } else {
            let trust: SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }
}
