//
//  Test.swift
//  APIModule
//
//  Created by Jijo Pulikkottil on 08/03/25.
//

import Testing
import APIModule
import Foundation

struct TokenRefreshTests {
    
    @Test func test_DeliverConnnectivityErrorIfTokenAPINotRespondedAndTokenExpired() async throws {
        let tokenBaseURL = URL(string: "https://aurl11.com")!
        let tokenProvider = await TokenRequester.shared(baseURL: tokenBaseURL)
        let contactAPIBaseURL = URL(string: "https://somedomain11.com")!
        
        let (sut, session) = await makeSUT(contactAPIBaseUrl:  contactAPIBaseURL, tokenBaseURL: tokenBaseURL)
        
        let validJSON = """
[
{"contact_ID" : 2 }
]
"""
        let myContactURL = ContactEndPoint.myContacts.urlRequest(baseURL: contactAPIBaseURL).url!
        await session.setResponse((validJSON.data(using: .utf8)!, responseWithStatusCode(200, url: myContactURL)), for: myContactURL)
        await tokenProvider.setTokenExpired()
        do {
            let _ = try await sut.getMyContacts()
        } catch {
            print("caught err \(error)")
            let urlCounts = await session.executedURLs.count
            #expect(urlCounts == 1)
            #expect((error as? APIError) == .connectivity)
        }
    }
    
    @Test func test_DeliverSuccessIfTokenExpired() async throws {
        let tokenBaseURL = URL(string: "https://aurl11.com")!
        let tokenProvider = await TokenRequester.shared(baseURL: tokenBaseURL)
        let contactAPIBaseURL = URL(string: "https://somedomain11.com")!
        
        let (sut, session) = await makeSUT(contactAPIBaseUrl:  contactAPIBaseURL, tokenBaseURL: tokenBaseURL)
        
        let validJSON = """
[
{"contact_ID" : 2 }
]
"""
        let myContactURL = ContactEndPoint.myContacts.urlRequest(baseURL: contactAPIBaseURL).url!
        await session.setResponse((validJSON.data(using: .utf8)!, responseWithStatusCode(200, url: myContactURL)), for: myContactURL)
        
        await setValidTokenOnServer(for: session, tokenBaseURL: tokenBaseURL)
        
        await tokenProvider.setTokenExpired()
        do {
            let contacts = try await sut.getMyContacts()
            #expect(await session.executedURLs.count == 2)
            #expect(contacts.count == 1)
        } catch {
            print("caught unexpected error = \(error)")
        }
    }
    
    @Test func test_setInvalidToken() async throws {
        let tokenBaseURL = URL(string: "https://aurl33.com")!
        
        let contactAPIBaseURL = URL(string: "https://somedomain33.com")!
        
        let (sut, session) = await makeSUT(contactAPIBaseUrl:  contactAPIBaseURL, tokenBaseURL: tokenBaseURL)
        
        try await setInvalidToken(for: session, tokenBaseURL: tokenBaseURL)
        
        //set response for getcontacts api
        let validJSON = """
[
{"contact_ID" : 2 }
]
"""
        let myContactURL = ContactEndPoint.myContacts.urlRequest(baseURL: contactAPIBaseURL).url!
        await session.setResponse((validJSON.data(using: .utf8)!, responseWithStatusCode(200, url: myContactURL)), for: myContactURL)
        
        //set response for token api
        await setValidTokenOnServer(for: session, tokenBaseURL: tokenBaseURL)
        
        //executing apis
        let contacts = try await sut.getMyContacts()
        let urlsExecutedCount = await session.executedURLs.count
//        #expect(urlsExecutedCount == 3, "executed urls count is \(urlsExecutedCount)")
        #expect(await session.executedURLs.filter({$0 == myContactURL}).count == 2)
        #expect(contacts.count == 1)
    }
    
    @Test func test_DeliverSuccessWithInvalidTokenForTwoSerialAPI() async throws {
        let tokenBaseURL = URL(string: "https://aurl44.com")!
        let contactAPIBaseURL = URL(string: "https://somedomain44.com")!
        
        let (sut, session) = await makeSUT(contactAPIBaseUrl:  contactAPIBaseURL, tokenBaseURL: tokenBaseURL)
        
        try await setInvalidToken(for: session, tokenBaseURL: tokenBaseURL)
        
        //set response for getcontacts api
        let validJSON1 = """
[
{"contact_ID" : 2 }
]
"""
        let myContactURL = ContactEndPoint.myContacts.urlRequest(baseURL: contactAPIBaseURL).url!
        await session.setResponse((validJSON1.data(using: .utf8)!, responseWithStatusCode(200, url: myContactURL)), for: myContactURL)
        
        //set response for getcontacts api
        let validJSON2 = """
[
{"contact_ID" : 3 }
]
"""
        let myFavURL = ContactEndPoint.myFavourites.urlRequest(baseURL: contactAPIBaseURL).url!
        await session.setResponse((validJSON2.data(using: .utf8)!, responseWithStatusCode(200, url: myFavURL)), for: myFavURL)
        
        //set response for token api
        await setValidTokenOnServer(for: session, tokenBaseURL: tokenBaseURL)
        
        //set an invalid token
//        TokenStore.setToken("InvalidToken")
        
        //executing apis
        let contacts = try await sut.getMyContacts()
        let favs = try await sut.getMyFavourites()
        let executedURLs = await session.executedURLs
        print("executedURLs = \(executedURLs)")

        #expect(executedURLs.filter({$0 == myContactURL}).count == 2)
        #expect(executedURLs.filter({$0 == myFavURL}).count == 1)
        
        #expect(contacts.count == 1)
        #expect(favs.count == 1)
    }
    
    @Test func test_DeliverSuccessWithInvalidTokenForTwoConcurrentAPI() async throws {
        let tokenBaseURL = URL(string: "https://aurl55.com")!
        let contactAPIBaseURL = URL(string: "https://somedomain55.com")!
        
        let (sut, session) = await makeSUT(contactAPIBaseUrl:  contactAPIBaseURL, tokenBaseURL: tokenBaseURL)
        
        try await setInvalidToken(for: session, tokenBaseURL: tokenBaseURL)
        //set response for getcontacts api
        let validJSON1 = """
[
{"contact_ID" : 2 }
]
"""
        let myContactURL = ContactEndPoint.myContacts.urlRequest(baseURL: contactAPIBaseURL).url!
        await session.setResponse((validJSON1.data(using: .utf8)!, responseWithStatusCode(200, url: myContactURL)), for: myContactURL)
        
        //set response for getfabs api
        let validJSON2 = """
[
{"contact_ID" : 2 }
]
"""
        let myFavURL = ContactEndPoint.myFavourites.urlRequest(baseURL: contactAPIBaseURL).url!
        await session.setResponse((validJSON2.data(using: .utf8)!, responseWithStatusCode(200, url: myFavURL)), for: myFavURL)
        
        //set response for token api
        await setValidTokenOnServer(for: session, tokenBaseURL: tokenBaseURL)
        
        //set an invalid token
//        TokenStore.setToken("InvalidToken")
        
        func testConcurrentAPICalls() async throws -> (Int, Int) {
            async let contacts = try sut.getMyContacts()
            async let favs = try sut.getMyFavourites()
            
            // Wait for both API calls to finish
            let (firstResult, secondResult) = try await (contacts, favs)
            return (firstResult.count, secondResult.count)
            
        }
        await session.startOver()
        let (contactCount, favCount) = try await testConcurrentAPICalls()
        
        print("contactCount = \(contactCount)")
        
        #expect(contactCount == 1)
        #expect(favCount == 1)
        
        let executedURLs = await session.executedURLs
        // ✅ Validate that only one refresh request was made
        #expect(executedURLs.filter({ $0 == tokenBaseURL }).count == 1)

        let myFavURLCount = executedURLs.filter({$0 == myFavURL}).count
        let myContactUrlCount = executedURLs.filter({$0 == myContactURL}).count
        #expect(myFavURLCount == 2 && myContactUrlCount == 2)
    }

    private func setInvalidToken(`for` session: HTTPURLSessionSpy, tokenBaseURL: URL) async throws {
        
        let tokenProvider = await TokenRequester.shared(baseURL: tokenBaseURL)
        await tokenProvider.setTokenExpired()
        //set response for token api
        let invalidTokenJSON = """
{"token" : "InvalidTpken" }
"""
        let refreshTokenURL = TokenEndPoint.getToken.urlRequest(baseURL: tokenBaseURL).url!
        await session.setResponse((invalidTokenJSON.data(using: .utf8)!, responseWithStatusCode(200, url: refreshTokenURL)), for: refreshTokenURL)
        
        let invalidTpoken = try await tokenProvider.getRefreshToken(httpClient: HttpClient(session, tokenRequester: tokenProvider))
        #expect(invalidTpoken == "InvalidTpken")
    }
    private func setValidTokenOnServer(`for` session: HTTPURLSessionSpy, tokenBaseURL: URL) async {
        
//        let tokenProvider = await TokenRequester.shared(baseURL: tokenBaseURL)
        //set response for token api
        let invalidTokenJSON = """
{"token" : "validToken" }
"""
        let refreshTokenURL = TokenEndPoint.getToken.urlRequest(baseURL: tokenBaseURL).url!
        await session.setResponse((invalidTokenJSON.data(using: .utf8)!, responseWithStatusCode(200, url: refreshTokenURL)), for: refreshTokenURL)
    }
    
    private func makeSUT(contactAPIBaseUrl: URL, tokenBaseURL: URL) async -> (sut: ContactAPI, session: HTTPURLSessionSpy) {
        
        let tokenProvider = await TokenRequester.shared(baseURL: tokenBaseURL)
        let session = HTTPURLSessionSpy()
        
        let httpClient = HttpClient(session, tokenRequester: tokenProvider)
        let sut = ContactAPI(client: httpClient, baseURL: contactAPIBaseUrl)
        
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
