//
//  HTTPURLSessionSpy.swift
//  
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation
import APIModule
class HTTPURLSessionSpy: HTTPURLSession {
 
    private var messages = [URL : (Data, HTTPURLResponse)]()
    var executedURLs: [URL] = []
    
    var requestedURLs: [URL]? {
        return Array(messages.keys) as? [URL]
    }
    
    func setResponse(_ response: (Data, HTTPURLResponse), `for` url: URL) {
        messages[url] = response
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        executedURLs.append(request.url!)
        guard let result = messages[request.url!] else {
            throw "some error"
        }
        return result
    }
}
extension String: Error {}
