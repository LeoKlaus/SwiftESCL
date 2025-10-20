//
//  HttpErrorCode.swift
//  SwiftESCL-next
//
//  Created by Leo Wehrfritz on 20.01.25.
//

enum EsclHttpErrorCode: Int, Sendable {
    /// The request was understood, and the scanner started the transaction
    case ok = 200
    /// A scan job is created
    case created = 201
    /// The client is redirected to a secure connection
    case moved = 301
    /// Request could not be understood due to wrong syntax
    case badRequest = 400
    /// The client is challenged for access credentials
    case unauthorized = 401
    /// Resource is not found
    case notFound = 404
    /// Not a valid method for the URI requested
    case methodNotAllowed = 405
    /// The parameters or payload are of the wrong types or values. Request not understood.
    case conflict = 409
    /// The resource (likely a job instance) used to exist but is gone.
    case gone = 410
    /// The Range header in the request does not match the range of data the scanner has cached.
    case requestedRangeNotSatisfiable = 416
    /// The scanner could not perform the request for lack of resource or unknown internal error
    case internalServerError = 500
    /// The scanner isn’t momentarily able to attend this request. The client app should retry later.
    case serviceUnavailable = 503
}
