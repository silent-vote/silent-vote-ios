//
//  AppState.swift
//  silentvote
//
//  Created by shelton on 2026/9/17.
//

import Foundation
import Observation

struct QuickCapture: Equatable {
    let imageURL: URL?
}

@MainActor
@Observable
final class AppState {
    static let shared = AppState(inbox: .shared)

    var capture: QuickCapture?

    private let inbox: CaptureInbox?

    private init(inbox: CaptureInbox?) {
        self.inbox = inbox
    }

    /// Displays the newest unconsumed shared capture, if any (a handoff whose
    /// host-app open failed survives here until the next launch), then empties
    /// the inbox — any older items are discarded.
    func consumeInboxIfNeeded() {
        guard let item = inbox?.consumeNewest() else { return }
        receive(imageData: item.data, suggestedFilename: item.suggestedFilename)
    }

    func receive(imageData: Data?, suggestedFilename: String?) {
        removeStoredImage()

        if let imageData,
           let url = try? Self.writeTemporaryImage(imageData, suggestedFilename: suggestedFilename) {
            capture = QuickCapture(imageURL: url)
        } else {
            capture = QuickCapture(imageURL: nil)
        }
    }

    func dismissCapture() {
        removeStoredImage()
        capture = nil
    }

    private func removeStoredImage() {
        if let url = capture?.imageURL {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private static func writeTemporaryImage(_ data: Data, suggestedFilename: String?) throws -> URL {
        let fileExtension = suggestedFilename
            .flatMap { (name: String) -> String? in
                let ext = URL(fileURLWithPath: name).pathExtension
                return ext.isEmpty ? nil : ext
            } ?? "png"

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("quick-capture-\(UUID().uuidString)")
            .appendingPathExtension(fileExtension)
        try data.write(to: url, options: .atomic)
        return url
    }
}
