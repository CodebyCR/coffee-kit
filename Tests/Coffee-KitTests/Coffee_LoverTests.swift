//
//  Coffee_LoverTests.swift
//  Coffee LoverTests
//
//  Created by Christoph Rohde on 20.10.24.
//

//
//  Coffee_LoverTests.swift
//  Coffee LoverTests
//
//  Created by Christoph Rohde on 20.10.24.
//

import Foundation
import Testing
import FoundationKit
import AuthenticationKit
import ProductKit
import OrderKit
import ImageKit

struct Coffee_LoverTests {
    @Test("Decoding a product from JSON")
    func decodingProduct() throws {
        let ressource = """
        {
            "id": "e074867a-0c6a-49ff-87ca-b1ba5dae5236",
            "category": "cake",
            "category_number": 1,
            "name": "Cheesecake",
            "price": 5.4,
            "image_name":"Cheesecake.png",
            "metadata": {
                "created_at": "2024-12-27 16:21:15",
                "updated_at": "2024-12-27 17:45:14",
                "tag_ids": [
                    null
                ]
            }
        }
        """

        let data = Data(ressource.utf8)
        let product = try JSONDecoder().decode(Product.self, from: data)

        #expect(product.id.uuidString == "e074867a-0c6a-49ff-87ca-b1ba5dae5236".uppercased())
    }

    @Test("Encoding a product to JSON")
    func encodingProduct() {
        let product = Product()
        guard let data = try? JSONEncoder().encode(product)
        else {
            Issue.record("Encoding failed")
            return
        }

        guard let json = String(data: data, encoding: .utf8)
        else {
            Issue.record("Decoding failed")
            return
        }

        #expect(!json.isEmpty)
    }
}
