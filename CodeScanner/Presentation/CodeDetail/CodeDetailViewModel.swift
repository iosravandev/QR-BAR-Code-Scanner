//
//  CodeDetailViewModel.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import Foundation

@MainActor
final class CodeDetailViewModel: ObservableObject {
    @Published var code: ScannedCode

    private let repo: CodesRepositoryProtocol

    init(code: ScannedCode, repo: CodesRepositoryProtocol = CodesRepository.shared) {
        self.code = code
        self.repo = repo
    }

    func updateTitle(_ title: String) {
        do {
            let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
            try repo.updateTitle(id: code.id, title: normalized.isEmpty ? nil : normalized)
            code.customTitle = normalized.isEmpty ? nil : normalized
        } catch {
#if DEBUG
            print("❌ updateTitle error: \(error)")
#endif
        }
    }
}
