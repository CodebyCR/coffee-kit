//
//  MenuManager.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 20.10.24.
//

import Foundation

@Observable
@MainActor
public final class MenuManager {
    // MARK: - Properties

    @ObservationIgnored private var webservice: WebserviceProvider

    public var items: [Product] = []

    // MARK: - Computed Properties

    public var itemSequence: CoffeeService {
        return CoffeeService(databaseAPI: webservice.databaseAPI)
    }

//    public var cakeService: CakeService {
//        return CakeService(databaseAPI: webservice.databaseAPI)
//    }

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
