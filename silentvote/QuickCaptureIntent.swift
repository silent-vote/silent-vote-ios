//
//  QuickCaptureIntent.swift
//  silentvote
//
//  Created by shelton on 2026/9/17.
//

import AppIntents
import UniformTypeIdentifiers

struct QuickCaptureIntent: AppIntent {
    static let title: LocalizedStringResource = "Silent Vote Quick Capture"

    static let description = IntentDescription(
        "Opens Silent Vote with a screenshot of the screen, captured by the Shortcuts app with the Get Screen action."
    )

    static var supportedModes: IntentModes {
        .foreground(.immediate)
    }

    @Parameter(
        title: "Screenshot",
        supportedContentTypes: [.image],
        inputConnectionBehavior: .connectToPreviousIntentResult
    )
    var screenshot: IntentFile?

    func perform() async throws -> some IntentResult {
        let file = screenshot

        var imageData: Data?
        if let file {
            imageData = try? await file.data(contentType: .image)
        }

        await AppState.shared.receive(imageData: imageData, suggestedFilename: file?.filename)

        return .result()
    }
}
