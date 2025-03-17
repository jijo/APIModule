//
//  Test.swift
//  APIModule
//
//  Created by Jijo Pulikkottil on 29/01/25.
//

import Testing
import Foundation
import APIModule

struct TokenAPITests {

    @Test func test_DeliverToken() async throws {
        
        let url = URL(string: "https://aurl.com")!
        let (sut, session) = makeSUT(url: url)
        let validJSON = """
{"token" : "validToken" }
"""
        let refreshTokenURL = TokenEndPoint.getToken.urlRequest(baseURL: url).url!
        await session.setResponse((validJSON.data(using: .utf8)!, responseWithStatusCode(200, url: url)), for: refreshTokenURL)
        let token = try await sut.getRefreshToken()
        #expect(token == "validToken", "token = \(token)")

    }
    
    @Test func test_DeliverCOnnectivityErrorIfTokenServerNotResponded() async throws {
        
        let url = URL(string: "https://aurl.com")!
        let (sut, _) = makeSUT(url: url)
        do {
            let _ = try await sut.getRefreshToken()
        } catch {
            #expect((error as? APIError) == .connectivity)
        }
    }

    private func makeSUT(url: URL = URL(string: "https://somedomain.com")!) -> (sut: TokenAPI, session: HTTPURLSessionSpy) {
        
        let session = HTTPURLSessionSpy()
        let httpClient = HttpClient(session)
        let sut = TokenAPI(client: httpClient, baseURL: url)

        return (sut, session)
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
