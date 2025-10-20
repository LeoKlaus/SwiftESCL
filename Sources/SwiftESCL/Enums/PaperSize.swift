//
//  PaperSize.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 21.01.25.
//

import Foundation
import SwiftUI

public enum PaperSize: RawRepresentable, Hashable {
    case a4
    case a5
    case a6
    case letter
    case legal
    
    case custom(width: Int, height: Int)
    
    public typealias RawValue = IntSize
    
    public init?(rawValue: IntSize) {
        switch rawValue {
        case IntSize(width: 2480, height: 3508):
            self = .a4
        case IntSize(width: 1748, height: 2480):
            self = .a5
        case IntSize(width: 1240, height: 1748):
            self = .a6
        case IntSize(width: 2551, height: 3295):
            self = .letter
        case IntSize(width: 2551, height: 4205):
            self = .legal
        default:
            self = .custom(width: Int(rawValue.width), height: Int(rawValue.height))
        }
    }
    
    public var rawValue: IntSize {
        switch self {
        case .a4:
            IntSize(width: 2480, height: 3508)
        case .a5:
            IntSize(width: 1748, height: 2480)
        case .a6:
            IntSize(width: 1240, height: 1748)
        case .letter:
            IntSize(width: 2551, height: 3295)
        case .legal:
            IntSize(width: 2551, height: 4205)
        case .custom(let width, let height):
            IntSize(width: width, height: height)
        }
    }
}
