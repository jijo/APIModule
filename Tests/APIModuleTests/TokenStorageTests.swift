//
//  Untitled.swift
//  APIModule
//
//  Created by Jijo Pulikkottil on 29/01/25.
//

import Testing
import Foundation
import APIModule

struct TokenStorageTests {

    @Test func test_DeliverStoredToken() async throws {
        
        let url = URL(string: "https://aurl.com")!
        let (sut, session) = await makeSUT(url: url)

        let validJSON = """
{"token" : "validToken1" }
"""
        let refreshTokenURL = TokenEndPoint.getToken.urlRequest(baseURL: url).url!
        await session.setResponse((validJSON.data(using: .utf8)!, responseWithStatusCode(200, url: refreshTokenURL)), for: refreshTokenURL)

        #expect(await session.executedURLs.count == 0)
        await sut.setTokenExpired()
        let token = try await sut.getRefreshToken(httpClient: HttpClient(session))
        #expect(token == "validToken1")

        
        let validJSON2 = """
{"token" : "validToken2" }
"""
        await session.setResponse((validJSON2.data(using: .utf8)!, responseWithStatusCode(200, url: refreshTokenURL)), for: refreshTokenURL)
        let token2 = try await sut.getRefreshToken(httpClient: HttpClient(session))
        #expect(token2 == "validToken1")
    }
    
    @Test func test_DeliverNewTokenIfExpired() async throws {
        
        let url = URL(string: "https://aurl.com")!
        let (sut, session) = await makeSUT(url: url)
        
        let tokenProvider = await TokenRequester.shared(baseURL: URL(string: "https://aurl.com")!)
        await tokenProvider.setTokenExpired()
        
        let validJSON = """
{"token" : "validToken1" }
"""
        let refreshTokenURL = TokenEndPoint.getToken.urlRequest(baseURL: url).url!
        await session.setResponse((validJSON.data(using: .utf8)!, responseWithStatusCode(200, url: url)), for: refreshTokenURL)
        
        let token = try await sut.getRefreshToken(httpClient: HttpClient(session))
        
        #expect(await session.executedURLs.count == 1)
        #expect(token == "validToken1")
    }
    
    private func makeSUT(url: URL) async -> (sut: TokenRequester, session: HTTPURLSessionSpy) {
        
        let session = HTTPURLSessionSpy()
        let sut = await TokenRequester.shared(baseURL: url)

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
