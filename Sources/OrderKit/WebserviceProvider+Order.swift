import Foundation
import FoundationKit
import AuthenticationKit

public extension WebserviceProvider {
    var orderService: OrderService {
        return OrderService(databaseAPI: databaseAPI, authManager: authManager as? AutenticationManager)
    }
}
