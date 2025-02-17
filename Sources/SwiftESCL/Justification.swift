//
//  Justification.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

public enum ImagePositionHorizontal: String {
    case left = "Left"
    case center = "Center"
    case right = "Right"
}

public enum ImagePositionVertical: String {
    case top = "Top"
    case center = "Center"
    case bottom = "Bottom"
}

public struct Justification {
    public var xImagePosition: ImagePositionHorizontal = .left
    public var yImagePosition: ImagePositionVertical = .top
    
    public init(xImagePosition: ImagePositionHorizontal = .left, yImagePosition: ImagePositionVertical = .top) {
        self.xImagePosition = xImagePosition
        self.yImagePosition = yImagePosition
    }
}
