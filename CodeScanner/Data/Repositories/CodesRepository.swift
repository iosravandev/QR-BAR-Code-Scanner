//
//  CodesRepository.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import Foundation
import Combine

protocol CodesRepositoryProtocol {
    func all() -> AnyPublisher<[ScannedCode], Never>
    func save(_ code: ScannedCode) async throws
    func updateTitle(id: UUID, title: String?) throws
}

final class CodesRepository: CodesRepositoryProtocol {

    static let shared = CodesRepository()

    private let core = CoreDataManager.shared
    private let subject = CurrentValueSubject<[ScannedCode], Never>([])

    private init() { reload() }

    private func reload() {
        let items = (try? core.fetchAll()) ?? []
        if Thread.isMainThread {
            subject.send(items)
        } else {
            DispatchQueue.main.async { [subject] in subject.send(items) }
        }
    }

    func all() -> AnyPublisher<[ScannedCode], Never> {
        subject.eraseToAnyPublisher()
    }

    func save(_ code: ScannedCode) async throws {
        try core.save(code)
        reload()
    }

    func updateTitle(id: UUID, title: String?) throws {
        try core.updateTitle(id: id, title: title)
        reload()
    }
}
