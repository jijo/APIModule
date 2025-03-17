//
//  File.swift
//
//
//  Created by Jijo Pulikkottil on 30/07/24.
//

import Foundation
public actor TokenRequester {
    
    static private var sharedInstance: TokenRequester?
    private var refreshTask: Task<String, Error>? = nil
    
    private var baseURL: URL!
    
    // Private initializer to enforce singleton pattern
    private init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // Function to safely initialize and return the singleton instance
    public static func shared(baseURL: URL) async -> TokenRequester {
        if sharedInstance == nil {
            sharedInstance = TokenRequester(baseURL: baseURL)
        } else {
            await sharedInstance?.updateBaseURL(baseURL)
        }
        return sharedInstance!
    }
    
    // Function to update baseURL inside actor context
    private func updateBaseURL(_ newBaseURL: URL) {
        self.baseURL = newBaseURL
    }
    
//    public func getRefreshToken(httpClient: HttpClient) async throws -> String  {
//        
//        if let accessToken = token {
//            print("get ud token \(token)")
//            return accessToken
//        }
//        if let refreshTask {
//            let tokenGot = try await refreshTask.value
//            print("tokenGot = \(tokenGot)")
//            return tokenGot
//        }
//        print("No refresh in progress, starting new one...")
//        
//        refreshTask = Task { [baseURL] in
//                    defer { refreshTask = nil } // Reset task only after completion
//                    let tokenAPI = TokenAPI(client: httpClient, baseURL: baseURL!)
//                    let newToken = try await tokenAPI.getRefreshToken()
//                    setToken(newToken)
//                    return newToken
//                }
//        return try await refreshTask!.value
//        
////        //if isTokenExpired(accessToken) {
////        refreshTask = Task {
////            defer { refreshTask = nil } // Reset task after completion
////            // request should be changed to return the new token
////            let tokenAPI = TokenAPI(client: httpClient, baseURL: baseURL)
////            return try await tokenAPI.getRefreshToken()
////        }
////        print("refresh task assigned")
//////        refreshTask = task
////        let newToken = try await refreshTask!.value
////        setToken(newToken)
////        //}
////        return newToken
//    }
    
    public func getRefreshToken(httpClient: HttpClient) async throws -> String {
        if let accessToken = token {
            print("Returning existing token: \(accessToken)")
            return accessToken
        }

        // ✅ Ensure multiple calls wait for the same task
        if let existingTask = refreshTask {
            print("Waiting for ongoing token refresh...")
            return try await existingTask.value
        }

        print("Starting new token request...")

        // ✅ Ensuring only one Task runs inside the actor
        let task = Task { [baseURL] in
            defer { refreshTask = nil } // Reset task after completion
            let tokenAPI = TokenAPI(client: httpClient, baseURL: baseURL!)
            let newToken = try await tokenAPI.getRefreshToken()
            setToken(newToken)
            return newToken
        }
        refreshTask = task

        return try await task.value
    }
    
    public func setTokenExpired() {
        if token == nil {
            return
        }
        print("set token expired")
        refreshTask = nil
        UserDefaults.standard.removeObject(forKey: "accessToken")
    }
    
    func setToken(_ token: String) {
        print("setting token \(token)")
        UserDefaults.standard.set(token, forKey: "accessToken")
    }
    
    public var token: String? {
        UserDefaults.standard.string(forKey: "accessToken")
    }
    
}
