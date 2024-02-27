//
//  HttpClient.swift
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
    
    public func performRequest(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
        
        var result: (data: Data, response: HTTPURLResponse)
        do {
            result = try await session.data(for: request)
        } catch {
            throw APIError.connectivity
        }
        if !result.response.isOK {
            throw APIError.getErrorFrom(data: result.data, httpResponse: result.response)
        }
        return result
        
    }
}
