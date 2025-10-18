//
//  CameraScannerView.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import SwiftUI
import AVFoundation

// MARK: - Preview based on AVCaptureVideoPreviewLayer
final class CameraPreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }

    var session: AVCaptureSession? {
        get { videoPreviewLayer.session }
        set { videoPreviewLayer.session = newValue }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
    }
}

// MARK: - Coordinator (metadata delegate)
final class ScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    let onCode: (String, CodeType) -> Void

    private var lastValue: String?
    private var lastFire: Date = .distantPast
    private let dedupeInterval: TimeInterval = 1.0

    init(onCode: @escaping (String, CodeType) -> Void) { self.onCode = onCode }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = obj.stringValue else { return }

        let now = Date()
        if value == lastValue, now.timeIntervalSince(lastFire) < dedupeInterval { return }
        lastValue = value
        lastFire = now

        let type: CodeType = (obj.type == .qr) ? .qr : .barcode
        onCode(value, type)
    }
}

// MARK: - UIViewRepresentable
struct CameraScannerView: UIViewRepresentable {
    let onCode: (String, CodeType) -> Void

    func makeCoordinator() -> ScannerCoordinator { ScannerCoordinator(onCode: onCode) }

    func makeUIView(context: Context) -> CameraPreviewView {
        let preview = CameraPreviewView()

        let session = AVCaptureSession()
        session.beginConfiguration()

        if let device = AVCaptureDevice.default(for: .video),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
        } else {
            session.commitConfiguration()
            return preview
        }
        
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(context.coordinator, queue: .main)

            let requested: [AVMetadataObject.ObjectType] = [
                .qr, .ean8, .ean13, .code128, .code39, .code93,
                .upce, .dataMatrix, .pdf417, .aztec, .itf14
            ]
            output.metadataObjectTypes = requested.filter { output.availableMetadataObjectTypes.contains($0) }
        }

        if let connection = session.connections.first {
            if #available(iOS 17.0, *) {
                let angle = currentRotationAngle()
                if connection.isVideoRotationAngleSupported(angle) {
                    connection.videoRotationAngle = angle
                }
            } else {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = currentVideoOrientation()
                }
            }
        }

        session.commitConfiguration()
        preview.session = session

        DispatchQueue.global(qos: .userInitiated).async { session.startRunning() }
        return preview
    }

    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        guard let connection = uiView.session?.connections.first else { return }
        if #available(iOS 17.0, *) {
            let angle = currentRotationAngle()
            if connection.isVideoRotationAngleSupported(angle) {
                connection.videoRotationAngle = angle
            }
        } else {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = currentVideoOrientation()
            }
        }
    }

    // MARK: - Helpers

    // iOS 17+
    private func currentRotationAngle() -> CGFloat {
        switch currentInterfaceOrientation() {
        case .landscapeLeft:      return 270
        case .landscapeRight:     return 90
        case .portraitUpsideDown: return 180
        default:                  return 0
        }
    }

    // iOS 16 and earlier
    private func currentVideoOrientation() -> AVCaptureVideoOrientation {
        switch currentInterfaceOrientation() {
        case .landscapeLeft:      return .landscapeLeft
        case .landscapeRight:     return .landscapeRight
        case .portraitUpsideDown: return .portraitUpsideDown
        default:                  return .portrait
        }
    }

    private func currentInterfaceOrientation() -> UIInterfaceOrientation {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            return .portrait
        }
        return scene.interfaceOrientation
    }
}
