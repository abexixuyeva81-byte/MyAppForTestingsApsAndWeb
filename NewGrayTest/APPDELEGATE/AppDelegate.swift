//// AppDelegate.swift
//
//import SwiftUI
//import FlagsmithClient
//import AppsFlyerLib
//import AppTrackingTransparency
//import AdSupport
//import UserNotifications
//
//@main
//class AppDelegate: UIResponder, UIApplicationDelegate, DeepLinkDelegate, UNUserNotificationCenterDelegate {
//    
//    var window: UIWindow?
//    weak var initialVC: ViewController?
//    var identifierAdvertising: String = ""
//    var timer = 0
//    static var orientationLock = UIInterfaceOrientationMask.all
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        let logger = Logger.shared
//        logger.log("Application did finish launching.")
//        
//        Flagsmith.shared.apiKey = "HarD6ZQmoCo6BvqRMg9aSb"
//        
//        let viewController = ViewController()
//        initialVC = viewController
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = initialVC
//        window?.makeKeyAndVisible()
//        
//        // --- APPSFLYER CONFIG ---
//        AppsFlyerLib.shared().appsFlyerDevKey = "itFfAJovmtJH5U8iWeKajL"
//        AppsFlyerLib.shared().appleAppID = "6754912500"
//        AppsFlyerLib.shared().deepLinkDelegate = self
//        AppsFlyerLib.shared().delegate = self
//        
//        let appsflyerId = AppsFlyerLib.shared().getAppsFlyerUID()
//        logger.log("AppsFlyer Initial ID: \(appsflyerId)")
//        AppFlowManager.shared.appsflyerId = appsflyerId
//        
//        #if DEBUG
//        AppsFlyerLib.shared().isDebug = true
//        logger.log("AppsFlyer is in DEBUG mode.")
//        #endif
//        
//        start(viewController: viewController)
//        
//        // Этот вызов автоматически отслеживает событие "Install"
//        AppsFlyerLib.shared().start()
//        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
//        
//        return true
//    }
//
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return AppDelegate.orientationLock
//    }
//
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        Logger.shared.log("Application opened with URL: \(url.absoluteString)")
//        AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
//        return true
//    }
//
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        Logger.shared.log("Application did become active.")
//        if #available(iOS 14, *) {
//            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
//            ATTrackingManager.requestTrackingAuthorization { (status) in
//                Logger.shared.log("ATT status received: \(status.rawValue)")
//                self.timer = 10
//                switch status {
//                case .authorized:
//                    self.identifierAdvertising = ASIdentifierManager.shared().advertisingIdentifier.uuidString
//                    self.timer = 1
//                    Logger.shared.log("ATT Authorized. IDFA: \(self.identifierAdvertising)")
//                case .denied:
//                    self.identifierAdvertising = ASIdentifierManager.shared().advertisingIdentifier.uuidString
//                    Logger.shared.log("ATT Denied.")
//                case .notDetermined:
//                    Logger.shared.log("ATT Not Determined.")
//                case .restricted:
//                    Logger.shared.log("ATT Restricted.")
//                @unknown default:
//                    Logger.shared.log("ATT Unknown status.")
//                }
//            }
//        } else {
//            self.identifierAdvertising = ASIdentifierManager.shared().advertisingIdentifier.uuidString
//        }
//        AppsFlyerLib.shared().start()
//    }
//}
//
//extension AppDelegate: AppsFlyerLibDelegate {
//    
//    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
//        Logger.shared.log("AF onConversionDataSuccess: \(data)")
//    }
//
//    func onConversionDataFail(_ error: Error) {
//        Logger.shared.log("AF onConversionDataFail: \(error.localizedDescription)")
//    }
//    
//    func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
//        Logger.shared.log("AF onAppOpenAttribution: \(attributionData)")
//    }
//
//    func onAppOpenAttributionFailure(_ error: Error) {
//        Logger.shared.log("AF onAppOpenAttributionFailure: \(error.localizedDescription)")
//    }
//}
//
//// MARK: - App Startup
//extension AppDelegate {
//    func start(viewController: ViewController) {
//        Logger.shared.log("Starting app flow, fetching remote config...")
//        Flagsmith.shared.getValueForFeature(withID: "healthdata", forIdentity: nil) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let value):
//                    guard let stringJSON = value?.stringValue else {
//                        Logger.shared.log("Remote config value is nil. Opening native app.")
//                        viewController.openApp()
//                        return
//                    }
//                    
//                    self.parseJSONString(stringJSON) { parsedResult in
//                        guard !parsedResult.isEmpty else {
//                            Logger.shared.log("Parsed URL from remote config is empty. Opening native app.")
//                            viewController.openApp()
//                            return
//                        }
//                        
//                        let stringURL = parsedResult
//                        guard let url = URL(string: stringURL) else {
//                            Logger.shared.log("Parsed string is not a valid URL. Opening native app.")
//                            viewController.openApp()
//                            return
//                        }
//                        
//                        Logger.shared.log("Successfully fetched and parsed URL: \(url.absoluteString)")
//                        AppFlowManager.shared.webViewURL = url
//                        // Всегда открываем наше дебаг-приложение, которое уже само решит, что делать с URL
//                        viewController.openApp()
//                    }
//                    
//                case .failure(let error):
//                    Logger.shared.log("Error fetching remote config: \(error.localizedDescription). Opening native app.")
//                    viewController.openApp()
//                }
//            }
//        }
//    }
//    
//    func parseJSONString(_ jsonString: String, completion: @escaping (String) -> Void) {
//        if let jsonData = jsonString.data(using: .utf8) {
//            do {
//                let property = try JSONDecoder().decode(Property.self, from: jsonData)
//                completion(property.about)
//            } catch {
//                Logger.shared.log("Failed to decode JSON: \(error)")
//                completion("")
//            }
//        } else {
//            Logger.shared.log("Failed to convert string to Data")
//            completion("")
//        }
//    }
//}
//
//struct Property: Codable {
//    let privacyPolicy, about: String
//}


// AppDelegate.swift

import SwiftUI
import FlagsmithClient
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, DeepLinkDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    weak var initialVC: ViewController?
    // Это свойство больше не будет напрямую использоваться в логике URL, но оставим его для совместимости
    var identifierAdvertising: String = ""
    var timer = 0 // Это свойство также можно будет убрать, но пока оставим
    static var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let logger = Logger.shared
        logger.log("Application did finish launching.")
        
        Flagsmith.shared.apiKey = "HarD6ZQmoCo6BvqRMg9aSb"
        
        let viewController = ViewController()
        initialVC = viewController
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
        
        // --- APPSFLYER CONFIG ---
        AppsFlyerLib.shared().appsFlyerDevKey = "itFfAJovmtJH5U8iWeKajL"
        AppsFlyerLib.shared().appleAppID = "6754912500" // Используем новый реальный ID
        AppsFlyerLib.shared().deepLinkDelegate = self
        AppsFlyerLib.shared().delegate = self
        
        let appsflyerId = AppsFlyerLib.shared().getAppsFlyerUID()
        logger.log("AppsFlyer Initial ID: \(appsflyerId)")
        AppFlowManager.shared.appsflyerId = appsflyerId
        
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        logger.log("AppsFlyer is in DEBUG mode.")
        #endif
        
        start(viewController: viewController)
        
        // Этот вызов автоматически отслеживает событие "Install"
        AppsFlyerLib.shared().start()
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        Logger.shared.log("Application opened with URL: \(url.absoluteString)")
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Logger.shared.log("Application did become active.")
        if #available(iOS 14, *) {
            // Запрашиваем разрешение. Сама логика формирования URL теперь не зависит от этого таймера,
            // а напрямую проверяет статус в нужный момент.
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    Logger.shared.log("ATT status received: \(status.rawValue)")
                    switch status {
                    case .authorized:
                        self.identifierAdvertising = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        Logger.shared.log("ATT Authorized. IDFA: \(self.identifierAdvertising)")
                    default:
                        Logger.shared.log("ATT status is not 'authorized'. Will use fallback UUID.")
                    }
                }
            }
        }
        AppsFlyerLib.shared().start()
    }
}

// MARK: - AppsFlyerLibDelegate
extension AppDelegate: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        Logger.shared.log("AF onConversionDataSuccess: \(data)")
    }

    func onConversionDataFail(_ error: Error) {
        Logger.shared.log("AF onConversionDataFail: \(error.localizedDescription)")
    }
    
    func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        Logger.shared.log("AF onAppOpenAttribution: \(attributionData)")
    }

    func onAppOpenAttributionFailure(_ error: Error) {
        Logger.shared.log("AF onAppOpenAttributionFailure: \(error.localizedDescription)")
    }
}

// MARK: - App Startup Logic
extension AppDelegate {
    
    // ИЗМЕНЕНО: Полностью переписанная логика старта
    func start(viewController: ViewController) {
        Logger.shared.log("Starting app flow, fetching remote config...")
        Flagsmith.shared.getValueForFeature(withID: "healthdata", forIdentity: nil) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let value):
                    guard let urlTemplate = value?.stringValue, !urlTemplate.isEmpty else {
                        Logger.shared.log("Remote config value is nil or empty. Opening native app.")
                        viewController.openApp()
                        return
                    }
                    
                    Logger.shared.log("Received URL template: \(urlTemplate)")
                    
                    // 1. Получаем AppsFlyer ID
                    let appsflyerId = AppsFlyerLib.shared().getAppsFlyerUID()
                    Logger.shared.log("Using AppsFlyer ID: \(appsflyerId)")
                    
                    // 2. Получаем User ID (IDFA или сохраненный UUID)
                    let userId = self.getUserIdentifier()
                    
                    // 3. Подставляем значения в шаблон
                    var finalUrlString = urlTemplate.replacingOccurrences(of: "{appsflyer_id}", with: appsflyerId)
                    finalUrlString = finalUrlString.replacingOccurrences(of: "{user_id}", with: userId)
                    
                    Logger.shared.log("Constructed final URL: \(finalUrlString)")
                    
                    // 4. Проверяем и открываем
                    guard let finalUrl = URL(string: finalUrlString) else {
                        Logger.shared.log("Constructed string is not a valid URL. Opening native app.")
                        viewController.openApp()
                        return
                    }
                    
                    // Сохраняем URL для нашего дебаг-экрана и открываем его
                    AppFlowManager.shared.webViewURL = finalUrl
                    viewController.openApp()
                    
                case .failure(let error):
                    Logger.shared.log("Error fetching remote config: \(error.localizedDescription). Opening native app.")
                    viewController.openApp()
                }
            }
        }
    }
    
    // НОВЫЙ КОД: Вспомогательная функция для получения IDFA или UUID
    private func getUserIdentifier() -> String {
        if #available(iOS 14, *) {
            // Проверяем статус разрешения на трекинг
            if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                // Убедимся, что IDFA не "нулевой"
                if idfa != "00000000-0000-0000-0000-000000000000" {
                    Logger.shared.log("ATT is authorized. Using IDFA as user identifier: \(idfa)")
                    return idfa
                } else {
                     Logger.shared.log("ATT is authorized, but IDFA is zeroed. Using fallback UUID.")
                }
            }
        }
        // Если статус не .authorized или версия iOS < 14, используем сохраненный UUID
        Logger.shared.log("ATT is not authorized. Using fallback UUID.")
        return getPersistentUserID()
    }

    // НОВЫЙ КОД: Вспомогательная функция для работы с UUID в UserDefaults
    private func getPersistentUserID() -> String {
        let userDefaults = UserDefaults.standard
        let key = "persistentUserID"
        
        // Если UUID уже есть, возвращаем его
        if let existingUUID = userDefaults.string(forKey: key) {
            Logger.shared.log("Found persistent UUID in UserDefaults: \(existingUUID)")
            return existingUUID
        } else {
            // Если нет, создаем новый, сохраняем и возвращаем
            let newUUID = UUID().uuidString
            userDefaults.set(newUUID, forKey: key)
            Logger.shared.log("Generated and saved new persistent UUID: \(newUUID)")
            return newUUID
        }
    }
    
    // Этот метод больше не нужен, т.к. парсинг JSON убран из этой логики
    // func parseJSONString...
}

// Эта структура больше не нужна, можно удалить или закомментировать
// struct Property: Codable { ... }
