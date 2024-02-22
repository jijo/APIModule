//
//  File.swift
//  
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation

public enum APIError: Swift.Error, Equatable {
    case invalidData
    case serverDefined(String)
    case connectivity
    
    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidData, .invalidData):
            return true
        case (.connectivity, .connectivity):
            return true
        case (.serverDefined(let reasonLHS), .serverDefined(let reasonRHS)):
            return reasonLHS == reasonRHS
        default:
            return false
        }
    }
}
