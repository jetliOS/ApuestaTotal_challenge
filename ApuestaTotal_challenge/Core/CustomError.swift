//
//  CustomError.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 17/03/26.
//

import Foundation

enum CustomError: Error, LocalizedError {
    case errorServer(statusCode: Int)
    case errorDecoding
    case errorUnknown
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .errorServer(let code):
            return "Server returned status code \(code)"
        case .errorDecoding:
            return "Failed to decode the response"
        case .errorUnknown:
            return "An unknown error occurred"
        case .networkUnavailable:
            return "No internet connection"
        }
    }
}
