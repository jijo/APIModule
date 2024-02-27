//
//  HTTPURLSession.swift
//  
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation
public protocol HTTPURLSession {
    func data(for request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse)
}
