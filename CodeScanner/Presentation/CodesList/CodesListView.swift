//
//  CodesListView.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import SwiftUI

struct CodesListView: View {
    @StateObject private var vm = CodesListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.items.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 44))
                        Text("Пока пусто")
                            .font(.headline)
                        Text("Отсканируйте QR или штрих-код — он появится здесь.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(vm.items) { item in
                        NavigationLink(value: item) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.displayTitle)
                                    .font(.headline)

                                HStack(spacing: 8) {
                                    Label(item.type.displayName, systemImage: item.type.systemImage)
                                    Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .foregroundColor(.secondary)
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationDestination(for: ScannedCode.self) { CodeDetailView(code: $0) }
            .navigationTitle("Сканирования")
            .toolbar {
                NavigationLink {
                    ScannerView()
                } label: {
                    Label("Сканер", systemImage: "camera.viewfinder")
                }
            }
        }
    }
}
