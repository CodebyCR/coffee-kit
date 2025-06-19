//
//  ImageManager.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 26.05.25.
//

import Foundation

@MainActor
@Observable public final class ImageManager {
    // MARK: - Properties

    @ObservationIgnored
    private let webservice: WebserviceProvider
    public let imageService: ImageService

    // MARK: - Initializer

    public init(from webservice: WebserviceProvider) {
        self.webservice = webservice
        self.imageService = ImageService(databaseAPI: webservice.databaseAPI)
    }

    // MARK: - Methods

    public func fetchImageData(for product: Product) async -> Data {
        var imageData = Data()
        do {
            imageData = try await imageService.getImageData(for: product)
        } catch {
            print("Error fetching image data: \(error)")
        }
        return imageData
    }
}
