//
//  TorchManager.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import AVFoundation

struct TorchManager {
    func setTorch(_ on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if on {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
#if DEBUG
            print("⚠️ Torch error: \(error)")
#endif
        }
    }
}

