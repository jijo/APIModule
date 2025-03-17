//
//  TokenDataMapper.swift
//  APIModule
//
//  Created by Jijo Pulikkottil on 17/03/25.
//
import Foundation
enum TokenDataMapper {
    
    static func map(_ data: Data, from response: URLResponse) throws -> String {
        guard let tokenResp = try? JSONDecoder().decode(TokenAPI.Response.self, from: data) else {
            throw APIError.invalidData
        }
        return tokenResp.token
    }
}
