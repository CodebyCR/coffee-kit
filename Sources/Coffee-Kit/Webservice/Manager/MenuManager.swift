//
//  MenuManager.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 20.10.24.
//

import Foundation

@MainActor
@Observable public final class MenuManager {
    // MARK: - Properties

    @ObservationIgnored
    private let webservice: WebserviceProvider

    public var items: [Product] = []

    // MARK: - Computed Properties

    public var productService: ProductService {
        return ProductService(databaseAPI: webservice.databaseAPI)
    }

    // MARK: - Initializer

    public init() {
        self.webservice = WebserviceProvider(inMode: .dev)
    }

    public init(from webservice: WebserviceProvider) {
        self.webservice = webservice
    }

    // MARK: - Methods

    public func getSelection(for category: MenuCategory) -> [Product] {
        return items.filter { $0.category == category.rawValue.lowercased() }
    }

//    public func getCachedItems() -> [Product] {
//        var cachedItems: [Product] = []
//        Task {
//            cachedItems.append(contentsOf: await productService.menuCache.values())
//        }
//        return cachedItems
//    }

    @Sendable public func fillUpCache() async {
        let productService = ProductService(databaseAPI: webservice.databaseAPI)
        do {
            try await productService.fillUpCache()
        } catch {
            print("Error filling up cache: \(error)")
        }
    }
}
