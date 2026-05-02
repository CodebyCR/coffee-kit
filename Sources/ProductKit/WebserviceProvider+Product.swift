import Foundation
import FoundationKit
import AuthenticationKit

public extension WebserviceProvider {
    var productService: ProductService {
        return ProductService(databaseAPI: databaseAPI, authManager: authManager as? AutenticationManager)
    }

    var cakeService: CakeService {
        return CakeService(databaseAPI: databaseAPI)
    }
}
