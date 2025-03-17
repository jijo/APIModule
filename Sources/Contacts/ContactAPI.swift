//
//  ContactAPI.swift
//  
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation

public struct APIRequest {
    var urlRequest: URLRequest
    var isAuth: Bool = false
    
    public var url: URL? {
        urlRequest.url
    }
}

public enum ContactEndPoint {
    case myContacts
    case myFavourites
    
    public func urlRequest(baseURL: URL) -> APIRequest {
        switch self {
        case .myContacts:
            var request = URLRequest(url: baseURL.appendingPathComponent("/api/v1/users"))
            request.httpMethod = "GET"
            var requestHeaders = [String: String]()
            requestHeaders["Content-Type"] = "application/json"
            request.allHTTPHeaderFields = requestHeaders
            return APIRequest(urlRequest: request)
        case .myFavourites:
            var request = URLRequest(url: baseURL.appendingPathComponent("/api/v1/favs"))
            request.httpMethod = "GET"
            var requestHeaders = [String: String]()
            requestHeaders["Content-Type"] = "application/json"
            request.allHTTPHeaderFields = requestHeaders
            return APIRequest(urlRequest: request)
        }
    }
}

public class ContactAPI {
    
    let client: HttpClient
    let baseURL: URL
    
    public init(client: HttpClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }
    public func getMyContacts() async throws -> [Contact] {
        let contactRequest = ContactEndPoint.myContacts.urlRequest(baseURL: baseURL)
        let (data, httpResponse) = try await client.performRequest(contactRequest)
        return try ContactDataMapper.map(data, from: httpResponse)
    }
    public func getMyFavourites() async throws -> [Contact] {
        let contactRequest = ContactEndPoint.myFavourites.urlRequest(baseURL: baseURL)
        let (data, httpResponse) = try await client.performRequest(contactRequest)
        return try ContactDataMapper.map(data, from: httpResponse)
    }
}
