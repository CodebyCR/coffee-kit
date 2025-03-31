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

    @ObservationIgnored private var webservice: WebserviceProvider

    public var items: [Product] = []

    // MARK: - Computed Properties

    public var itemSequence: ProductService {
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
        items.filter { $0.category == category.rawValue.lowercased() }
    }
}
