//
//  ContactAPITests.swift
//
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import XCTest
import APIModule
final class ContactAPITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_init_doesNotExecuteURLRequest() async {
        let (_, session) = makeSUT()
        let executedUrls = session.executedURLs
        XCTAssertTrue(executedUrls.isEmpty)
    }
    
    func test_deliverConnectivityErrorOnClientError() async throws {
        let (sut, _) = makeSUT()
        do {
            _ = try await sut.getMyContacts()
        } catch let error {
            XCTAssertEqual((error as? APIError) , APIError.connectivity)
        }
    }
    
    func test_deliverErrorOnInvalidJSONWith200Status() async throws {
        let url = URL(string: "https://aurl.com")!
        let (sut, session) = makeSUT(url: url)
        
        let myContactURL = ContactEndPoint.myContacts.url(baseURL: url).url!
        let invalidJSON = "".data(using: .utf8)!
        session.setResponse((invalidJSON, responseWithStatusCode(200, url: myContactURL)), for: myContactURL)
        
        do {
            _ = try await sut.getMyContacts()
        } catch let error {
            XCTAssertEqual((error as? APIError), APIError.invalidData)
        }
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
