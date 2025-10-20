//
//  SteppedRange.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 22.01.25.
//

import Foundation

public struct SteppedRange: Equatable, Sendable {
    public var min: Int = 0
    public var max: Int = 0
    public var normal: Int = 0
    public var step: Int = 0
    
    public init(min: Int = 0, max: Int = 0, normal: Int = 0, step: Int = 0) {
        self.min = min
        self.max = max
        self.normal = normal
        self.step = step
    }
}
