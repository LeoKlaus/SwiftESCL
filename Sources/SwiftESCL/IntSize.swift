//
//  IntSize.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 24.01.25.
//

public struct IntSize: Equatable {
    public var width: Int
    public var height: Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}
