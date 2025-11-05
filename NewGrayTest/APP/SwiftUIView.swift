// SwiftUIView.swift

import SwiftUI

struct SwiftUIView: View {
    // Подписываемся на наш логгер и менеджер потока
    @StateObject private var logger = Logger.shared
    @StateObject private var appFlowManager = AppFlowManager.shared
    
    // Состояние для отображения WebView, текста для поиска и фидбека о копировании
    @State private var showWebView = false
    @State private var searchText = ""
    @State private var copiedLogsFeedback = false // НОВЫЙ КОД: для фидбека

    // Фильтрует логи на основе текста в поисковой строке
    private var filteredLogs: [LogEntry] {
        if searchText.isEmpty {
            return logger.logs
        } else {
            return logger.logs.filter { $0.message.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // НОВЫЙ КОД: Форматтер для красивого отображения даты в логах
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Info Panel
                VStack(spacing: 8) {
                    Text("AppsFlyer ID:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(appFlowManager.appsflyerId)
                        .font(.system(.footnote, design: .monospaced))
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .onTapGesture {
                            UIPasteboard.general.string = appFlowManager.appsflyerId
                        }
                    
                    VStack(spacing: 8) { // Обернули кнопки в VStack для лучшей компоновки
                        HStack {
                            // Кнопка для открытия WebView
                            Button(action: {
                                if appFlowManager.webViewURL != nil {
                                    showWebView.toggle()
                                }
                            }) {
                                Label("Open WebView", systemImage: "safari.fill")
                            }
                            .tint(.blue)
                            .buttonStyle(.borderedProminent)
                            .disabled(appFlowManager.webViewURL == nil)
                            
                            // Кнопка для очистки логов
                            Button(role: .destructive, action: {
                                logger.clearLogs()
                            }) {
                                Label("Clear Logs", systemImage: "trash.fill")
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        // НОВЫЙ КОД: Кнопка для копирования всех логов
                        Button(action: copyAllLogs) {
                            if copiedLogsFeedback {
                                Label("Copied!", systemImage: "checkmark.circle.fill")
                            } else {
                                Label("Copy All Logs", systemImage: "doc.on.doc.fill")
                            }
                        }
                        .tint(copiedLogsFeedback ? .green : .accentColor) // Меняем цвет при фидбеке
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()

                // MARK: - Search Field
                TextField("Search logs...", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                
                // MARK: - Logs List
                List {
                    // Используем отфильтрованные логи
                    ForEach(filteredLogs.reversed(), id: \.self) { entry in
                        HStack(alignment: .top) {
                            Text("[\(dateFormatter.string(from: entry.timestamp))]")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            Text(entry.message)
                                .font(.system(.caption, design: .monospaced))
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Debug Console")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .fullScreenCover(isPresented: $showWebView) {
            ZStack(alignment: .topTrailing) {
                if let url = appFlowManager.webViewURL {
                    WebViewRepresentable(url: url)
                        .edgesIgnoringSafeArea(.all)
                }
                
                Button(action: {
                    showWebView = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.6).clipShape(Circle()))
                        .padding()
                }
            }
        }
    }
    
    // НОВЫЙ КОД: Функция для копирования логов в буфер обмена
    private func copyAllLogs() {
        // Формируем единый текст из всех логов
        let allLogsText = logger.logs.map { entry in
            "[\(dateFormatter.string(from: entry.timestamp))] \(entry.message)"
        }.joined(separator: "\n")
        
        // Копируем в буфер обмена
        UIPasteboard.general.string = allLogsText
        
        // Показываем фидбек
        withAnimation {
            copiedLogsFeedback = true
        }
        
        // Через 2 секунды убираем фидбек
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copiedLogsFeedback = false
            }
        }
    }
}

#Preview {
    // Для превью можно добавить несколько тестовых логов
    let logger = Logger.shared
    logger.log("App started")
    logger.log("Fetching remote config...")
    logger.log("AF onConversionDataSuccess: [\"af_status\": \"Organic\"]")
    return SwiftUIView()
}
