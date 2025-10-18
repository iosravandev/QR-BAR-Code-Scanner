//
//  ScannerView.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import SwiftUI
import AVFoundation

struct ScannerView: View {
    
    @StateObject private var vm = ScannerViewModel()

    @State private var auth = CameraPermissionManager().status()

    var body: some View {
        ZStack {
            if auth == .authorized {
                CameraScannerView(onCode: { value, type in
                    vm.handleScan(raw: value, type: type)
                })
                .ignoresSafeArea()
                .overlay(ScannerOverlay())

                VStack {
                    HStack { Spacer(); torchButton }.padding()
                    Spacer()
                }
            } else if auth == .notDetermined {
                ProgressView()
                    .task { auth = await CameraPermissionManager().request() }
            } else {
                VStack(spacing: 12) {
                    Text("Доступ к камере запрещен")
                    Button("Открыть настройки") { openSettings() }
                }
                .padding()
            }
        }
        .alert(item: $vm.alert) { a in
            Alert(
                title: Text(a.title),
                message: Text(a.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var torchButton: some View {
        Button {
            vm.isTorchOn.toggle()
            TorchManager().setTorch(vm.isTorchOn)
        } label: {
            Image(systemName: vm.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                .font(.title2)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .accessibilityLabel("Фонарик")
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

struct ScannerOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height) * 0.7
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [8]))
                .frame(width: size, height: size)
                .foregroundStyle(.white)
                .shadow(radius: 3)
                .position(x: geo.size.width/2, y: geo.size.height/2)
        }
        .allowsHitTesting(false)
    }
}
