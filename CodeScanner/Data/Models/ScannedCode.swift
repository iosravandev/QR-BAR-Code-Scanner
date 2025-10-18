//
//  ScannedCode.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import Foundation

struct ScannedCode: Identifiable, Codable, Hashable {
    let id: UUID
    let rawValue: String
    let type: CodeType
    var customTitle: String?
    var content: String?
    var productInfo: ProductInfo?
    let createdAt: Date
}

// MARK: - Convenience
extension ScannedCode {
    var displayTitle: String {
        if let t = customTitle, !t.isEmpty { return t }
        if let name = productInfo?.name, !name.isEmpty { return name }
        return rawValue
    }
}

// MARK: - Core Data mapping
extension ScannedCode {
    init(entity: ScannedCodeEntity) {
        self.id = entity.id ?? UUID()
        self.rawValue = entity.rawValue ?? ""
        self.type = CodeType(rawValue: entity.typeRaw ?? "qr") ?? .qr
        self.customTitle = entity.customTitle
        self.content = entity.content
        self.productInfo = ProductInfo(
            name: entity.productName,
            brand: entity.brand,
            ingredients: entity.ingredients,
            nutriScore: entity.nutriScore
        )
        self.createdAt = entity.createdAt ?? Date()
    }
}
