//
//  ImageService.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 26.05.25.
//

import Foundation
import FoundationKit
import ProductKit

public enum ImageServiceError: Error {
    case imageNotFound
}


public struct ImageService {
    private let imageUrl: URL
    private let urlSession: URLSession
    public private(set) var imageCache: Cache<String, Data>

    public init(databaseAPI: borrowing DatabaseAPI) {
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.timeoutIntervalForRequest = 14
        urlSessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad

        self.urlSession = URLSession(configuration: urlSessionConfiguration)
        self.imageUrl = databaseAPI.baseURL / "Images"
        self.imageCache = Cache<String, Data>()
    }

    @Sendable private func fetchImageData(from url: URL) async throws -> Data {
        let (data, responce) = try await urlSession.data(from: url)
        guard let httpResponse = responce as? HTTPURLResponse,
              200 ..< 300 ~= httpResponse.statusCode
        else {
            print("Failed to fetch image data from '\(url)'. Status code: \((responce as? HTTPURLResponse)?.statusCode ?? 0)")
            throw ImageServiceError.imageNotFound
        }

        guard data.count > 0 else {
            print("Received empty data from \(url)")
            throw ImageServiceError.imageNotFound
        }

        return data
    }

    @concurrent
    @Sendable public func getImageData(for product: borrowing Product) async throws -> Data {
        let productImageUrl = product.imageUrl(relativeTo: imageUrl)
        
        if let cachedImage = await imageCache.get(key: productImageUrl.lastPathComponent) {
            return cachedImage
        }

        let imageData = try await fetchImageData(from: productImageUrl)

        await imageCache.set(key: productImageUrl.lastPathComponent, value: imageData)
        return imageData
    }
}
