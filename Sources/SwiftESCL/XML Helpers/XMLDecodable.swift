//
//  XMLDecodable.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 23.01.25.
//

import Foundation

public protocol XMLDecodable {
    
    init(xmlData: Data) throws
    
    associatedtype ParserDelegate: NSObject, XMLParserDelegate
}
