//
//  MopriaCertification.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

public struct MopriaCertification: Sendable {
    public var name: String = ""
    public var version: String = ""
    
    public init(name: String = "", version: String = "") {
        self.name = name
        self.version = version
    }
}
