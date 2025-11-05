// WebViewRepresentable.swift

import SwiftUI
import UIKit

// НОВЫЙ КОД: SwiftUI обертка для нашего UIViewController с WebView.
struct WebViewRepresentable: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> ADJWebHandler {
        return ADJWebHandler(url: url.absoluteString)
    }

    func updateUIViewController(_ uiViewController: ADJWebHandler, context: Context) {
        // Ничего не делаем при обновлении
    }
}
