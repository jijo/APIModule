//
//  File.swift
//  
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation
public class HttpClient {
    
    private let session: HTTPURLSession
    
    public init(_ session: HTTPURLSession) {
        self.session = session
    }
    
    public func performRequest(_ request: URLRequest) async throws -> (data: Data, response: URLResponse) {
        
        do {
            let result = try await session.data(for: request)
            return result
        }
        catch {
            throw APIError.connectivity
        }
    }
}
