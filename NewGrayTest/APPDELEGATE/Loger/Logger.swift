// Logger.swift

import Foundation
import SwiftUI

// НОВЫЙ КОД: Синглтон для сбора логов со всего приложения.
// Он ObservableObject, чтобы SwiftUI View мог автоматически обновляться при добавлении новых логов.
class Logger: ObservableObject {
    static let shared = Logger()
    
    @Published var logs: [LogEntry] = []
    
    private init() {}
    
    /// Записывает сообщение в лог.
    /// - Parameters:
    ///   - message: Текст сообщения.
    ///   - file: Файл, из которого был вызван лог (заполняется автоматически).
    ///   - function: Функция, из которой был вызван лог (заполняется автоматически).
    func log(_ message: String, file: String = #file, function: String = #function) {
        // Выводим в консоль Xcode для удобства отладки на симуляторе
        print("LOG: \(message)")
        
        // Добавляем в массив для отображения в SwiftUI
        DispatchQueue.main.async {
            let fileName = (file as NSString).lastPathComponent
            let entry = LogEntry(message: "[\(fileName)] \(message)")
            self.logs.append(entry)
        }
    }
    
    func clearLogs() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
    }
}

struct LogEntry: Identifiable, Hashable {
    let id = UUID()
    let timestamp: Date = Date()
    let message: String
}
