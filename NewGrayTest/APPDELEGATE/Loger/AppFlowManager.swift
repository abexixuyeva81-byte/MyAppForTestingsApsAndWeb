// AppFlowManager.swift

import Foundation
import SwiftUI

// НОВЫЙ КОД: Класс для управления состоянием и потоком приложения.
// Хранит важные данные, которые нужны в разных частях UI.
class AppFlowManager: ObservableObject {
    static let shared = AppFlowManager()
    
    @Published var webViewURL: URL?
    @Published var appsflyerId: String = "Initializing..."
    
    private init() {}
}
