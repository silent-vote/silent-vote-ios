//
//  ShareViewController.swift
//  ShareCapture
//
//  Share extension entry point. Non-interactive on purpose: it takes the
//  first image attachment, writes it into the shared CaptureInbox, then
//  foregrounds SilentVote with silentvote://capture so the normal capture
//  screen opens. If any step fails the sheet is simply dismissed (cancelled)
//  and the app stays closed.
//

import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    private static let hostAppURL = URL(string: "silentvote://capture")!

    private var isHandling = false
    private var didFinish = false

    override func loadView() {
        view = UIView(frame: .zero)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isHandling else { return }
        isHandling = true
        Task { @MainActor in
            await handleShare()
        }
    }

    private func handleShare() async {
        guard let provider = firstImageAttachment() else {
            finish(cancelled: true)
            return
        }

        guard let contentType = provider.registeredContentTypes(conformingTo: .image).first,
              let imageData = await loadImageData(from: provider, typeIdentifier: contentType.identifier)
        else {
            finish(cancelled: true)
            return
        }

        let fileExtension = contentType.preferredFilenameExtension ?? "jpg"

        guard let inbox = CaptureInbox.shared,
              inbox.write(imageData: imageData, fileExtension: fileExtension) != nil
        else {
            finish(cancelled: true)
            return
        }

        openHostApp()
    }

    private func loadImageData(from provider: NSItemProvider, typeIdentifier: String) async -> Data? {
        await withCheckedContinuation { continuation in
            provider.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { data, _ in
                continuation.resume(returning: data)
            }
        }
    }

    private func firstImageAttachment() -> NSItemProvider? {
        let items = extensionContext?.inputItems.compactMap { $0 as? NSExtensionItem } ?? []
        return items
            .lazy
            .flatMap { $0.attachments ?? [] }
            .first { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }
    }

    private func openHostApp() {
        // A share extension runs inside its own process, but UIKit still puts a
        // UIApplication instance in that process's responder chain, so the public
        // open() call is reachable by walking UIResponder.next. When it can't be
        // found, the inbox survives and the app picks the capture up on next launch.
        guard let application = findApplication() else {
            finish(cancelled: false)
            return
        }

        application.open(Self.hostAppURL, options: [:]) { [weak self] _ in
            self?.finish(cancelled: false)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.finish(cancelled: false)
        }
    }

    private func findApplication() -> UIApplication? {
        var responder: UIResponder? = self
        while let current = responder {
            if let application = current as? UIApplication {
                return application
            }
            responder = current.next
        }
        return nil
    }

    private func finish(cancelled: Bool) {
        guard !didFinish else { return }
        didFinish = true
        if cancelled {
            let error = NSError(
                domain: NSCocoaErrorDomain,
                code: CocoaError.Code.userCancelled.rawValue
            )
            extensionContext?.cancelRequest(withError: error)
        } else {
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
}
