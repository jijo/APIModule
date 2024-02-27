//
//  HTTPURLResponse.swift
//  
//
//  Created by Jijo Pulikkottil on 27/02/24.
//

import Foundation

public extension HTTPURLResponse {
    var isOK: Bool {
        (200..<300).contains(statusCode)
    }
}
