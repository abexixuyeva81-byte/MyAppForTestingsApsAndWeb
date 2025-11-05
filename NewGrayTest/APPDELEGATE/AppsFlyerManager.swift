// AppsFlyerManager.swift

import Foundation
import AppsFlyerLib

// ИЗМЕНЕНО: Используем стандартные константы событий из SDK AppsFlyer
// и добавляем свои кастомные параметры.

class AppsFlyerManager {
    
    // Метод для отправки события регистрации
    static func logRegistrationEvent() {
        // ИЗМЕНЕНО: Используем стандартное событие AFEventCompleteRegistration
        AppsFlyerLib.shared().logEvent(name: AFEventCompleteRegistration, values: nil) { (response, error) in
            if let error = error {
                Logger.shared.log("AF Error logging registration: \(error)")
                return
            }
            if let response = response {
                Logger.shared.log("AF Response for registration: \(response)")
            }
        }
    }
    
    // Метод для отправки события Первого Депозита (ФД)
    static func logFirstDepositEvent(amount: Double, currency: String) {
        // ИЗМЕНЕНО: Для всех депозитов используем стандартное событие AFEventPurchase.
        // Чтобы отличить первый от повторного, добавляем кастомный параметр.
        let eventValues: [String: Any] = [
            AFEventParamRevenue: amount,      // Стандартный параметр для суммы
            AFEventParamCurrency: currency,   // Стандартный параметр для валюты
            "deposit_type": "first"           // Наш кастомный параметр для аналитики
        ]
        
        AppsFlyerLib.shared().logEvent(name: AFEventPurchase, values: eventValues) { (response, error) in
            if let error = error {
                Logger.shared.log("AF Error logging first deposit: \(error)")
                return
            }
            if let response = response {
                Logger.shared.log("AF Response for first deposit: \(response)")
            }
        }
    }
    
    // Метод для отправки события Повторного Депозита (РД)
    static func logRepeatDepositEvent(amount: Double, currency: String) {
        let eventValues: [String: Any] = [
            AFEventParamRevenue: amount,
            AFEventParamCurrency: currency,
            "deposit_type": "repeat" // Наш кастомный параметр
        ]
        
        AppsFlyerLib.shared().logEvent(name: AFEventPurchase, values: eventValues) { (response, error) in
            if let error = error {
                Logger.shared.log("AF Error logging repeat deposit: \(error)")
                return
            }
            if let response = response {
                Logger.shared.log("AF Response for repeat deposit: \(response)")
            }
        }
    }
}



////
////  AppsFlyerManager.swift
////  NewGrayTest
////
////  Created by D K on 16.09.2025.
////
//
//import Foundation
//import AppsFlyerLib
//
//// Имена событий, которые будут видны в дашборде AppsFlyer и Keitaro.
//// Их можно менять, но нужно согласовать с тем, кто настраивает Keitaro.
//struct AppsFlyerEvents {
//    static let registration = "registration" // Регистрация
//    static let firstDeposit = "fd"           // Первый депозит
//    static let repeatDeposit = "rd"          // Повторный депозит
//}
//
//class AppsFlyerManager {
//    
//    // Метод для отправки события регистрации
//    static func logRegistrationEvent() {
//            AppsFlyerLib.shared().logEvent(name: AppsFlyerEvents.registration, values: nil) { (response, error) in
//                if let error = error {
//                    Logger.shared.log("AF Error logging registration: \(error)")
//                    return
//                }
//                if let response = response {
//                    Logger.shared.log("AF Response for registration: \(response)")
//                }
//            }
//        }
//    
//    // Метод для отправки события Первого Депозита (ФД)
//    // Веб-вью должен передать сумму и валюту
//    static func logFirstDepositEvent(amount: Double, currency: String) {
//        let eventValues: [String: Any] = [
//            AFEventParamRevenue: amount,
//            AFEventParamCurrency: currency
//        ]
//        
//        AppsFlyerLib.shared().logEvent(name: AppsFlyerEvents.firstDeposit, values: eventValues) { (response, error) in
//                    if let error = error {
//                        Logger.shared.log("AF Error logging first deposit: \(error)")
//                        return
//                    }
//                    if let response = response {
//                        Logger.shared.log("AF Response for first deposit: \(response)")
//                    }
//                }
//    }
//    
//    // Метод для отправки события Повторного Депозита (РД)
//    static func logRepeatDepositEvent(amount: Double, currency: String) {
//        let eventValues: [String: Any] = [
//            AFEventParamRevenue: amount,
//            AFEventParamCurrency: currency
//        ]
//        
//        AppsFlyerLib.shared().logEvent(name: AppsFlyerEvents.repeatDeposit, values: eventValues) { (response, error) in
//                    if let error = error {
//                        Logger.shared.log("AF Error logging repeat deposit: \(error)")
//                        return
//                    }
//                    if let response = response {
//                        Logger.shared.log("AF Response for repeat deposit: \(response)")
//                    }
//                }
//    }
//}


