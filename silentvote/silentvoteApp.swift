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
            ZStack {
                ContentView()

                if splashVisible {
                    SplashView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .statusBarHidden(splashVisible)
            .task {
                try? await Task.sleep(for: .seconds(20))

                withAnimation(.easeInOut(duration: 0.4)) {
                    splashVisible = false
                }
            }
        }
    }
}
