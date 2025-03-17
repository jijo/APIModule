//
//  HttpClient.swift
//  
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation
public class HttpClient {
    
    private let session: HTTPURLSession
    private var tokenRequester: TokenRequester? = nil
    
    public init(_ session: HTTPURLSession, tokenRequester: TokenRequester? = nil) {
        self.session = session
        self.tokenRequester = tokenRequester
    }
    
    public func performRequest(_ apiRequest: APIRequest) async throws -> (data: Data, response: HTTPURLResponse) {
        
        var result: (data: Data, response: HTTPURLResponse)
        do {
            var urlRequest = apiRequest.urlRequest
            if let tokenRequester, !apiRequest.isAuth {
                //get access token
                let token = try await tokenRequester.getRefreshToken(httpClient: self)
                urlRequest.allHTTPHeaderFields?["Authorization"] = token
                
                //get data from server
                result = try await session.data(for: urlRequest)
                
                //check is loggedout
                if result.response.isLoggedOut {
                    await tokenRequester.setTokenExpired()
                    let token = try await tokenRequester.getRefreshToken(httpClient: self)
                    urlRequest.allHTTPHeaderFields?["Authorization"] = "\(token)"
                    result = try await session.data(for: urlRequest)
                }
            } else {
                //get data from server
                result = try await session.data(for: urlRequest)
            }
            
        } catch {
            throw error
        }
        if !result.response.isOK {
            throw APIError.getErrorFrom(data: result.data, httpResponse: result.response)
        }
        return result
    }
}
