//
//  MenuManager.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 20.10.24.
//

import Foundation
import AuthenticationKit


@Observable public final class MenuManager {
    // MARK: - Properties

    @ObservationIgnored
    private let webservice: WebserviceProvider
    public let productService: ProductService

    public var items: [Product] = []

    // MARK: - Initializer

    public init(from webservice: WebserviceProvider) {
        self.webservice = webservice
        self.productService = ProductService(webserviceProvider: webservice)
    }

    // MARK: - Methods

    public func getSelection(for category: MenuCategory) -> [Product] {
        return items.filter { $0.category == category.rawValue.lowercased() }
    }
    

    public func getSelection(for category: MenuCategory, with lookupUpValue: String = "") -> [Product] {
        let filteredItems = items.filter { $0.category == category.rawValue.lowercased() }
        guard !lookupUpValue.isEmpty else {
            return filteredItems
        }
        return filteredItems.filter { $0.name.localizedCaseInsensitiveContains(lookupUpValue) }
    }

//    public func getCachedItems() -> [Product] {
//        var cachedItems: [Product] = []
//        Task {
//            cachedItems.append(contentsOf: await productService.menuCache.values())
//        }
//        return cachedItems
//    }

    @Sendable public func fillUpCache() async {
        do {
            try await productService.fillUpCache()
        } catch {
            print("Error filling up cache: \(error)")
        }
    }
}
