//
//  OpenFoodFactsService.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import Foundation

struct OFFProductResponse: Codable {
    let status: Int
    let product: OFFProduct?
}

struct OFFProduct: Codable {
    let productName: String?
    let brands: String?
    let ingredientsText: String?
    let nutriscoreGrade: String?
}

final class OpenFoodFactsService {
    private let client: HTTPClient

    init(client: HTTPClient = URLSessionHTTPClient()) {
        self.client = client
    }

    func fetch(barcode: String) async throws -> ProductInfo? {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json") else {
            return nil
        }

        do {
            let (data, _) = try await client.get(url: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let decoded = try decoder.decode(OFFProductResponse.self, from: data)
            guard decoded.status == 1, let p = decoded.product else {
                return nil
            }

            return ProductInfo(
                name: p.productName,
                brand: p.brands,
                ingredients: p.ingredientsText,
                nutriScore: p.nutriscoreGrade?.uppercased()
            )
        } catch {
#if DEBUG
            print("❌ OpenFoodFactsService error for barcode \(barcode): \(error)")
#endif
            throw error
        }
    }
}
