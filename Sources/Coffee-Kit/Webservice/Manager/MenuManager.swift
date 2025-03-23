//
//  MenuManager.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 20.10.24.
//

import Foundation

@MainActor
public final class MenuManager: ObservableObject {
    // MARK: - Properties

    private var webservice: WebserviceProvider

    @Published public var items: [Product] = []

    // MARK: - Computed Properties

    public var itemSequence: CoffeeService {
        return CoffeeService(databaseAPI: webservice.databaseAPI)
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
