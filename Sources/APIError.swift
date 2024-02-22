//
//  File.swift
//  
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation

public enum APIError: Swift.Error {
    case invalidData
    case serverDefined(String)
    case noResponse
}
