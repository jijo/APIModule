//
//  File.swift
//  
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation
public class HttpClient {
    
    let session: URLSession
    
    public init(_ session: URLSession) {
        self.session = session
    }
    
    @discardableResult
    public func performRequest(_ request: URLRequest) async throws -> (data: Data, response: URLResponse) {
        
        try await session.data(for: request)
    }
}
