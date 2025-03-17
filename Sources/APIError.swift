//
//  APIError.swift
//  
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation

public struct ErrorMessage: Decodable {
    let errorMessage: String
}

public enum APIError: Swift.Error, Equatable {
    case invalidData
    case serverDefined(String)
    case connectivity
    case loggedOut
    
    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidData, .invalidData):
            return true
        case (.connectivity, .connectivity):
            return true
        case (.loggedOut, .loggedOut):
            return true
        case (.serverDefined(let reasonLHS), .serverDefined(let reasonRHS)):
            return reasonLHS == reasonRHS
        default:
            return false
        }
    }
    public static func getErrorFrom(data: Data, httpResponse: HTTPURLResponse) -> APIError {

        if let message = try? JSONDecoder().decode(ErrorMessage.self, from: data) {
            
            return .serverDefined(message.errorMessage)
        }
        return .serverDefined(String(httpResponse.statusCode))
    }
}
