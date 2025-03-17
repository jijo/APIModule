//
//  HTTPURLSessionSpy.swift
//  
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation
import APIModule
actor HTTPURLSessionSpy: HTTPURLSession {
    private var messages = [URL : (Data, HTTPURLResponse)]()
    var executedURLs: [URL] = []
    
    func startOver() {
        executedURLs = []
    }
    
    func setResponse(_ response: (Data, HTTPURLResponse), `for` url: URL) {
        messages[url] = response
    }

    public func data(for request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
        
        let headers = request.allHTTPHeaderFields
        let token = headers?["Authorization"]
        try await Task.sleep(for: .seconds(0.04))
        executedURLs.append(request.url!)
        guard let result = messages[request.url!] else {
            print("throwing connectivity err for \(request.url!)")
            throw APIError.connectivity
        }
        if token?.hasPrefix("Invalid") == true {
            let logoutresponse = responseWithStatusCode(401, url: request.url!)
            return (result.0, logoutresponse)
        }
        return result
    }
    
    private func responseWithStatusCode(_ code: Int, url: URL) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: url,
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}
