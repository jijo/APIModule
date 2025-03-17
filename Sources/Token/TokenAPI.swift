//
//  File.swift
//  
//
//  Created by Jijo Pulikkottil on 30/07/24.
//

import Foundation

public enum TokenEndPoint {
    case getToken
    
    public func urlRequest(baseURL: URL) -> APIRequest {
        switch self {
        case .getToken:
            var request = URLRequest(url: baseURL)
            request.httpMethod = "GET"
            var requestHeaders = [String: String]()
            requestHeaders["Content-Type"] = "application/json"
            request.allHTTPHeaderFields = requestHeaders
            return APIRequest(urlRequest: request, isAuth: true)
        }
    }
}

public class TokenAPI {
    
    public struct Response: Decodable {
        let token: String
    }
    
    private let client: HttpClient
    private let baseURL: URL
    
    public init(client: HttpClient, baseURL: URL ) {
        self.client = client
        self.baseURL = baseURL
    }
    public func getRefreshToken() async throws -> String {
        let tokenRequest = TokenEndPoint.getToken.urlRequest(baseURL: baseURL)
        let (data, httpResponse) = try await client.performRequest(tokenRequest)
        return try TokenDataMapper.map(data, from: httpResponse)
    }
}
