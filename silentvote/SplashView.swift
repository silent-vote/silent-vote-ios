//
//  SplashView.swift
//  silentvote
//
//  Created by shelton on 2026/9/11.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var elementsVisible = false

    private static let iconSideLength: CGFloat = 120
    private static let squircleCornerRadius: CGFloat = iconSideLength * 0.2237

    var body: some View {
        VStack(spacing: 24) {
            Image(.splashIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Self.iconSideLength, height: Self.iconSideLength)
                .clipShape(RoundedRectangle(cornerRadius: Self.squircleCornerRadius, style: .continuous))
                .scaleEffect(elementsVisible || reduceMotion ? 1 : 1.08)
                .opacity(elementsVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: elementsVisible)

            Text("splash.tagline")
                .font(.headline)
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.7)
                .opacity(elementsVisible ? 1 : 0)
                .animation(
                    reduceMotion
                        ? .easeOut(duration: 0.5)
                        : .easeOut(duration: 0.4).delay(0.25),
                    value: elementsVisible
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .ignoresSafeArea()
        .onAppear {
            elementsVisible = true
        }
    }
}

#Preview {
    SplashView()
}
