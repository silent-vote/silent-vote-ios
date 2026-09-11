//
//  silentvoteApp.swift
//  silentvote
//
//  Created by shelton on 2026/9/11.
//

import SwiftUI

@main
struct silentvoteApp: App {
    @State private var splashVisible = true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .overlay {
                    if splashVisible {
                        SplashView()
                            .transition(.opacity)
                    }
                }
                .statusBarHidden(splashVisible)
                .task {
                    try? await Task.sleep(for: .seconds(1.5))
                    withAnimation(.easeInOut(duration: 0.4)) {
                        splashVisible = false
                    }
                }
        }
    }
}
