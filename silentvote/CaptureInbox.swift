//
//  CaptureInbox.swift
//  silentvote
//
//  Shared between the app and the ShareCapture extension.
//
//  A one-hop mailbox for captured images, living in the App Group container.
//  The share extension writes image bytes in; the app drains the newest item
//  and discards the rest. After consumption the inbox is always empty, so a
//  screenshot never outlives the capture screen that shows it.
//

import Foundation

struct ConsumedCapture: Equatable {
    let data: Data
    let suggestedFilename: String
}

struct CaptureInbox {
    static let appGroupIdentifier = "group.autos.vibration.silentvote"

    let directory: URL

    /// nil when the App Group container is unavailable (entitlement not
    /// provisioned). Handoff then fails closed — the writer cancels and the
    /// app never opens — instead of writing where no reader could look.
    static let shared = CaptureInbox.appGroupDirectory().map { CaptureInbox(directory: $0) }

    private static func appGroupDirectory() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent("Inbox", isDirectory: true)
    }

    @discardableResult
    func write(imageData: Data, fileExtension: String) -> URL? {
        let fileManager = FileManager.default
        guard (try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)) != nil else {
            return nil
        }

        let ext = fileExtension.isEmpty ? "png" : fileExtension
        // Zero-padded epoch milliseconds keep the lexical file-name order
        // identical to the chronological order, across processes.
        let timestamp = Int(Date().timeIntervalSince1970 * 1_000)
        let name = String(format: "%013d", timestamp) + "-" + UUID().uuidString + "." + ext
        let url = directory.appendingPathComponent(name)

        guard (try? imageData.write(to: url, options: .atomic)) != nil else {
            return nil
        }
        return url
    }

    /// Returns the newest readable inbox item, deleting every other file in
    /// the inbox — including any unreadable ones, so a corrupt item can never
    /// poison it. Nothing is consumed, and nothing deleted, from an empty inbox.
    func consumeNewest() -> ConsumedCapture? {
        let fileManager = FileManager.default
        let files = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil))?
            .sorted { $0.lastPathComponent > $1.lastPathComponent } ?? []

        for file in files {
            if let data = try? Data(contentsOf: file) {
                for stale in files where stale != file {
                    try? fileManager.removeItem(at: stale)
                }
                try? fileManager.removeItem(at: file)
                return ConsumedCapture(data: data, suggestedFilename: file.lastPathComponent)
            }
            try? fileManager.removeItem(at: file)
        }
        return nil
    }
}
