//
//  PocoApp.swift
//  Poco
//
//  Created by 윤여명 on 5/12/26.
//

import SwiftUI
import UIKit

@main
struct PocoApp: App {
    var body: some Scene {
        WindowGroup {
            SplashRootView()
        }
    }
}

private struct SplashRootView: View {
    @State private var isSplashVisible = true

    var body: some View {
        ZStack {
            ContentView()
                .opacity(isSplashVisible ? 0 : 1)

            if isSplashVisible {
                PocoSplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(2200))
            withAnimation(.easeOut(duration: 0.45)) {
                isSplashVisible = false
            }
        }
    }
}

private struct BundlePNGImage: View {
    let name: String

    var body: some View {
        if let path = Bundle.main.path(forResource: name, ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Text(name)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(red: 0.49, green: 0.38, blue: 0.86))
        }
    }
}

private struct PocoSplashView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(red: 0.49, green: 0.39, blue: 0.83)
                    .ignoresSafeArea()

                ZStack(alignment: .center) {
                    BundlePNGImage(name: "Logo")
                        .frame(width: min(190, proxy.size.width * 0.48), height: min(190, proxy.size.width * 0.48))
                        .offset(x: -54, y: 34)

                    BundlePNGImage(name: "Title")
                        .frame(maxWidth: min(176, proxy.size.width * 0.44), maxHeight: 150)
                        .offset(x: 64, y: -2)
                }
                .frame(width: proxy.size.width, height: 260)
                .offset(y: proxy.size.height * 0.08)
            }
        }
    }
}
