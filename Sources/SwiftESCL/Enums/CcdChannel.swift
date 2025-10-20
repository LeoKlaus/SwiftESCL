//
//  CcdChannel.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

public enum CcdChannel: String, Sendable {
    case red = "Red"
    case green = "Green"
    case blue = "Blue"
    case ntsc = "NTSC"
    case grayCcd = "GrayCcd"
    case grayCcdEmulated = "GrayCcdEmulated"
}
