//
//  CaptureView.swift
//  silentvote
//
//  Created by shelton on 2026/9/17.
//

import SwiftUI

struct CaptureView: View {
    let capture: QuickCapture
    var onDone: () -> Void

    private var image: UIImage? {
        capture.imageURL.flatMap { UIImage(contentsOfFile: $0.path) }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .accessibilityLabel("capture.accessibility.screenshot")
            } else {
                Text("capture.missing")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 16) {
                if image != nil {
                    Text("capture.received")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }

                Button(action: onDone) {
                    Text("capture.done")
                        .fontWeight(.semibold)
                        .frame(maxWidth: 240)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.vertical, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview("missing screenshot") {
    CaptureView(capture: QuickCapture(imageURL: nil), onDone: {})
}
