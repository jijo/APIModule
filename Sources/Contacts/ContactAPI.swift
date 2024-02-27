//
//  ContactAPI.swift
//  
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation

public enum ContactEndPoint {
    case myContacts
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case .myContacts:
            var request = URLRequest(url: baseURL.appendingPathComponent("/api/v1/users"))
            request.httpMethod = "GET"
            var requestHeaders = [String: String]()
            requestHeaders["Content-Type"] = "application/json"
            request.allHTTPHeaderFields = requestHeaders
            return request
        }
    }
}

public class ContactAPI {
    
    let client: HttpClient
    let baseURL: URL
    
    public init(client: HttpClient, baseURL: URL ) {
        self.client = client
        self.baseURL = baseURL
    }
    public func getMyContacts() async throws -> [Contact] {
        let contactRequest = ContactEndPoint.myContacts.url(baseURL: baseURL)
        let (data, httpResponse) = try await client.performRequest(contactRequest)
        return try ContactDataMapper.map(data, from: httpResponse)
    }
}
