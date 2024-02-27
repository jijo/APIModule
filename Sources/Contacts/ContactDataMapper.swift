//
//  ContactDataMapper.swift
//
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation

enum ContactDataMapper {
    
    static func map(_ data: Data, from response: URLResponse) throws -> [Contact] {
        guard let contacts = try? JSONDecoder().decode([Contact].self, from: data) else {
            throw APIError.invalidData
        }
        return contacts
    }
}
