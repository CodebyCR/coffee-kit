//
//  ImageService.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 26.05.25.
//

import Foundation

public enum ImageServiceError: Error {
    case imageNotFound
}

@MainActor
public struct ImageService {
    private let imageUrl: URL
    private let urlSession: URLSession
    private(set) var imageCache: Cache<String, Data>

    public init(databaseAPI: borrowing DatabaseAPI) {
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.timeoutIntervalForRequest = 14
        urlSessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad

        self.urlSession = URLSession(configuration: urlSessionConfiguration)
        self.imageUrl = databaseAPI.baseURL / "images"
        self.imageCache = Cache<String, Data>()
    }

    @Sendable private func fetchImageData(from url: URL) async throws -> Data {
        let (data, responce) = try await urlSession.data(from: url)
        guard let httpResponse = responce as? HTTPURLResponse,
              200 ..< 300 ~= httpResponse.statusCode
        else {
            print("Failed to fetch image data from \(url). Status code: \((responce as? HTTPURLResponse)?.statusCode ?? 0)")
            throw ImageServiceError.imageNotFound
        }

        guard data.count > 0 else {
            print("Received empty data from \(url)")
            throw ImageServiceError.imageNotFound
        }

        return data
    }

    @Sendable public consuming func getImageData(for product: borrowing Product) async throws -> Data {
        if let cachedImage = await imageCache.get(key: product.imageName) {
            return cachedImage
        }

        let productImageUrl = imageUrl / product.category / product.imageName
        let imageData = try await fetchImageData(from: productImageUrl)

        await imageCache.set(key: product.imageName, value: imageData)
        return imageData
    }
}
