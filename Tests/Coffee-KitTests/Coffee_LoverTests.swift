//
//  Coffee_LoverTests.swift
//  Coffee LoverTests
//
//  Created by Christoph Rohde on 20.10.24.
//

@testable import Coffee_Kit
import Foundation
import XCTest

final class Coffee_LoverTests: XCTestCase {
    func testDecodingProduct() throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.

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

        XCTAssertEqual(product.id.uuidString, "e074867a-0c6a-49ff-87ca-b1ba5dae5236".uppercased())
    }

    func testEncodingProduct() {
        let product = Product()
        guard let data = try? JSONEncoder().encode(product)
        else {
            XCTFail("Encoding failed")
            return
        }

        guard let json = String(data: data, encoding: .utf8)
        else {
            XCTFail("Decoding failed")
            return
        }

        XCTAssertFalse(json.isEmpty)
    }
}
