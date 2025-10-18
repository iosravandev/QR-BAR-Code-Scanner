//
//  CameraPermissionManager.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import AVFoundation

enum CameraAuthStatus { case authorized, denied, notDetermined, restricted }

struct CameraPermissionManager {
    func status() -> CameraAuthStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }

    func request() async -> CameraAuthStatus {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted ? .authorized : .denied)
            }
        }
    }
}
