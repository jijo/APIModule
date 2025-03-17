//
//  ContactDataMapper.swift
//
//
//  Created by Jijo Pulikkottil on 22/02/24.
//

import Foundation

enum ContactDataMapper {
    
    private struct Item: Decodable {
        let contact_ID: Int

        var contact: Contact {
            Contact(contact_ID: contact_ID)
        }
    }
    
    static func map(_ data: Data, from response: URLResponse) throws -> [Contact] {
        guard let items = try? JSONDecoder().decode([Item].self, from: data) else {
            throw APIError.invalidData
        }
        return items.map {$0.contact}
    }
}
