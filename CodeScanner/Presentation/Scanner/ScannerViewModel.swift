//
//  ScannerViewModel.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import Foundation
import Combine

@MainActor
final class ScannerViewModel: ObservableObject {
    @Published var isTorchOn = false
    @Published var lastScanned: ScannedCode?
    @Published var alert: AppAlert?

    private let off = OpenFoodFactsService()
    private let repo: CodesRepositoryProtocol

    private var isProcessing = false

    init(repo: CodesRepositoryProtocol = CodesRepository.shared) {
        self.repo = repo
    }

    func handleScan(raw: String, type: CodeType) {
        guard !isProcessing else { return }
        isProcessing = true
        Task { await processScan(raw: raw, type: type) }
    }

    private func presentError(_ message: String) {
        alert = AppAlert(title: "Ошибка", message: message)
    }

    private func presentSuccess() {
        alert = AppAlert(title: "Сохранено", message: "Код добавлен в список.")
    }

    private func setLast(_ code: ScannedCode) {
        self.lastScanned = code
    }

    private func isDigits(_ s: String) -> Bool { s.allSatisfy { $0.isNumber } }

    private func processScan(raw: String, type: CodeType) async {
        var code = ScannedCode(
            id: UUID(),
            rawValue: raw,
            type: type,
            customTitle: nil,
            content: nil,
            productInfo: nil,
            createdAt: Date()
        )

        do {
            if type == .barcode, isDigits(raw) {
                if let p = try? await off.fetch(barcode: raw) {
                    code.productInfo = p
                }
            } else {
                code.content = raw
            }

            try await repo.save(code)
            setLast(code)
            presentSuccess()
        } catch {
            presentError("Не удалось сохранить/обработать код: \(error.localizedDescription)")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.isProcessing = false
        }
    }
}
