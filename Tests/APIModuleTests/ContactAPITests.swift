//
//  ContactAPITests.swift
//
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import XCTest
import APIModule
final class ContactAPITests: XCTestCase {

    func test_init_doesNotExecuteURLRequest() async {
        let (_, session) = makeSUT()
        let executedUrls = await session.executedURLs
        XCTAssertTrue(executedUrls.isEmpty)
    }
    //thers is no response from server, considered connectivity error
    func test_deliverConnectivityErrorOnClientError() async throws {
        let (sut, _) = makeSUT()
        do {
            _ = try await sut.getMyContacts()
        } catch let error {
            XCTAssertEqual((error as? APIError), APIError.connectivity)
            return
        }
        XCTFail()
    }
    
    func test_deliverErrorOnInvalidJSONWith200Status() async throws {
        let url = URL(string: "https://aurl.com")!
        let (sut, session) = makeSUT(url: url)
        
        let myContactURL = ContactEndPoint.myContacts.urlRequest(baseURL: url).url!
        let invalidJSON = """
[
{"contactsssss_ID" : 2 }
]
"""
        await session.setResponse((invalidJSON.data(using: .utf8)!, responseWithStatusCode(200, url: myContactURL)), for: myContactURL)
        
        do {
            _ = try await sut.getMyContacts()
        } catch let error {
            XCTAssertEqual((error as? APIError), APIError.invalidData)
            return
        }
        XCTFail()
    }
    
    func test_load_DeliverErroFor400Status() async throws {
        let url = URL(string: "https://aurl.com")!
        let (sut, session) = makeSUT(url: url)

        let myContactURL = ContactEndPoint.myContacts.urlRequest(baseURL: url).url!
        await session.setResponse(("".data(using: .utf8)!, responseWithStatusCode(400, url: url)), for: myContactURL)
        
        do {
            _ = try await sut.getMyContacts()
        } catch let error {
            XCTAssertEqual((error as? APIError), APIError.serverDefined("400"))
            return
        }
        XCTFail()
    }
    
    //return connectivity error if the token provider service is down
    func test_load_DeliverSuccessFor401Status() async throws {
        let url = URL(string: "https://aurl.com")!
        let (sut, session) = makeSUT(url: url)
        
        let validJSON = """
[
{"contact_ID" : 2 }
]
"""

        let myContactURL = ContactEndPoint.myContacts.urlRequest(baseURL: url).url!
        await session.setResponse((validJSON.data(using: .utf8)!, responseWithStatusCode(401, url: url)), for: myContactURL)
        
        do {
            _ = try await sut.getMyContacts()
        } catch let error {
            XCTAssertEqual((error as? APIError), APIError.serverDefined("401"))
            return
        }
        XCTFail()
    }
    
    func test_load_deliversSuccessWith200HTTPResponseWithJSONItems() async throws {
        let url = URL(string: "https://aurl.com")!
        let (sut, session) = makeSUT(url: url)

        let validJSON = """
[
{"contact_ID" : 2 }
]
"""
        let myContactURL = ContactEndPoint.myContacts.urlRequest(baseURL: url).url!
        await session.setResponse((validJSON.data(using: .utf8)!, responseWithStatusCode(200, url: url)), for: myContactURL)
        
        do {
            let contacts = try await sut.getMyContacts()
            XCTAssertEqual(contacts.count, 1)
        } catch {
            XCTFail()
        }
    }
    
    @MainActor func test_load_DeliverConnectivityErrorIfTaskIsCancelled() async throws {
        let url = URL(string: "https://aurl.com")!
        
        let (sut, session) = makeSUT(url: url)

        let dataResponse = """
[
{"contact_ID" : 2 }
]
"""
        let myContactURL = ContactEndPoint.myContacts.urlRequest(baseURL: url).url!
        await session.setResponse((dataResponse.data(using: .utf8)!, responseWithStatusCode(200, url: url)), for: myContactURL)
        
        let exp = expectation(description: "Wait for load completion")
        let task = Task {
            do {
                let contacts = try await sut.getMyContacts()
                exp.fulfill()
                XCTAssertEqual(contacts.count, 0)
            } catch let error {
                exp.fulfill()
                XCTAssertTrue(error is CancellationError, "Error should be of type CancellationError")
            }
        }
        task.cancel()
        await fulfillment(of: [exp])
    }
    
    private func makeSUT(url: URL = URL(string: "https://somedomain.com")!) -> (sut: ContactAPI, session: HTTPURLSessionSpy) {
        
        let session = HTTPURLSessionSpy()
        let httpClient = HttpClient(session)
        let sut = ContactAPI(client: httpClient, baseURL: url)

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
//https://stackoverflow.com/a/77584728
