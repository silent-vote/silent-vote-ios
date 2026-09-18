//
//  silentvoteApp.swift
//  silentvote
//
//  Created by shelton on 2026/9/11.
//

import SwiftUI

@main
struct silentvoteApp: App {
    @State private var appState = AppState.shared
    @State private var splashVisible = AppState.shared.capture == nil
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()

                if let capture = appState.capture {
                    CaptureView(capture: capture) {
                        appState.dismissCapture()
                    }
                    .transition(.opacity)
                }

                if splashVisible {
                    SplashView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .statusBarHidden(splashVisible)
            .onChange(of: appState.capture) { _, newCapture in
                guard newCapture != nil else { return }
                splashVisible = false
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                appState.consumeInboxIfNeeded()
            }
            .onOpenURL { _ in
                appState.consumeInboxIfNeeded()
            }
            .task {
                appState.consumeInboxIfNeeded()

                try? await Task.sleep(for: .seconds(3))

                withAnimation(.easeInOut(duration: 0.4)) {
                    splashVisible = false
                }
            }
        }
    }
}
