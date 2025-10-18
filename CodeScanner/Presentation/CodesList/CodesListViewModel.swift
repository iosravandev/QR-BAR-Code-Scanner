//
//  CodesListViewModel.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import Foundation
import Combine

@MainActor
final class CodesListViewModel: ObservableObject {
    @Published var items: [ScannedCode] = []

    private let repo: CodesRepositoryProtocol
    private var bag = Set<AnyCancellable>()

    init(repo: CodesRepositoryProtocol = CodesRepository.shared) {
        self.repo = repo

        repo.all()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.items = $0 }
            .store(in: &bag)
    }
}
