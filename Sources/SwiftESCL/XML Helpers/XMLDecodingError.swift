//
//  XMLDecodingError.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 23.01.25.
//

enum XMLDecodingError: Error {
    case couldntInstantiateObject
    case missingKey(String)
    case unexptedType(Any.Type, String)
}
