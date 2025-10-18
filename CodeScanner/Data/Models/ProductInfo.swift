//
//  ProductInfo.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import Foundation

struct ProductInfo: Codable, Equatable, Hashable {
    let name: String?
    let brand: String?
    let ingredients: String?
    let nutriScore: String?
}

// MARK: - Convenience
extension ProductInfo {
    var summary: String {
        var parts: [String] = []
        if let brand, !brand.isEmpty { parts.append(brand) }
        if let nutriScore, !nutriScore.isEmpty { parts.append("Nutri-Score: \(nutriScore)") }
        return parts.joined(separator: " · ")
    }
    
    var isEmpty: Bool {
        name?.isEmpty ?? true && brand?.isEmpty ?? true &&
        ingredients?.isEmpty ?? true && nutriScore?.isEmpty ?? true
    }
}
