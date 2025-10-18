//
//  CodeDetailView.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import SwiftUI

struct CodeDetailView: View {
    @StateObject private var vm: CodeDetailViewModel
    @State private var titleText: String
    @State private var showShare = false

    init(code: ScannedCode) {
        _vm = StateObject(wrappedValue: CodeDetailViewModel(code: code))
        _titleText = State(initialValue: code.customTitle ?? "")
    }

    var body: some View {
        Form {
            // MARK: - Название
            Section("Название") {
                TextField("Добавить название", text: $titleText)
                    .submitLabel(.done)
                    .onSubmit { vm.updateTitle(titleText) }
                    .onDisappear {
                        if titleText != (vm.code.customTitle ?? "") {
                            vm.updateTitle(titleText)
                        }
                    }
            }

            // MARK: - Информация
            Section("Информация") {
                if vm.code.type == .barcode {
                    LabeledContent("Код", value: vm.code.rawValue)
                    LabeledContent("Название", value: (vm.code.productInfo?.name).nonEmpty ?? "—")
                    LabeledContent("Бренд", value: (vm.code.productInfo?.brand).nonEmpty ?? "—")
                    LabeledContent("Nutri-Score", value: (vm.code.productInfo?.nutriScore).nonEmpty ?? "—")

                    if let ing = vm.code.productInfo?.ingredients, !ing.isEmpty {
                        Text(ing)
                            .textSelection(.enabled)
                    }
                } else {
                    let content = vm.code.content ?? vm.code.rawValue
                    if let url = URL(string: content),
                       ["http", "https"].contains(url.scheme?.lowercased()) {
                        Link(destination: url) {
                            Label(content, systemImage: "link")
                        }
                    } else {
                        Text(content)
                            .textSelection(.enabled)
                    }
                }
            }

            // MARK: - Мета
            Section("Мета") {
                LabeledContent("Дата", value: vm.code.createdAt.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Тип", value: vm.code.type.displayName)
            }
        }
        .navigationTitle("Детали")
        .toolbar {
            Button { showShare = true } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(activityItems: [shareText])
        }
    }

    // MARK: - Share text
    private var shareText: String {
        var lines: [String] = []
        lines.append("Тип: \(vm.code.type.displayName)")
        lines.append("Код: \(vm.code.rawValue)")

        if let p = vm.code.productInfo {
            if let n = p.name, !n.isEmpty { lines.append("Название: \(n)") }
            if let b = p.brand, !b.isEmpty { lines.append("Бренд: \(b)") }
            if let ns = p.nutriScore, !ns.isEmpty { lines.append("Nutri-Score: \(ns)") }
            if let i = p.ingredients, !i.isEmpty { lines.append("Ингредиенты: \(i)") }
        } else if let c = vm.code.content, !c.isEmpty {
            lines.append("Содержимое: \(c)")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - String helpers
private extension Optional where Wrapped == String {
    var nonEmpty: String? {
        switch self {
        case .some(let s) where !s.isEmpty: return s
        default: return nil
        }
    }
}
