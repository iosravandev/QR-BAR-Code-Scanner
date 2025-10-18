//
//  CodeType.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import Foundation
import SwiftUI

enum CodeType: String, Codable, CaseIterable, Hashable {
    case barcode
    case qr

    var raw: String { rawValue }

    var displayName: String {
        switch self {
        case .barcode: return "Штрих-код"
        case .qr: return "QR-код"
        }
    }

    var systemImage: String {
        switch self {
        case .barcode: return "barcode"
        case .qr: return "qrcode"
        }
    }
}
