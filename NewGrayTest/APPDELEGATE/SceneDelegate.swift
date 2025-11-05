import UIKit
import WebKit


struct WebViewEvents {
    static let registration = "af_complete_registration"
    static let firstDeposit = "fd"
    static let repeatDeposit = "rd"
}

class ADJWebHandler: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView!
    var urlString: String
    
    // НОВЫЙ КОД: Имя хэндлера, которое будет знать JavaScript
    private let scriptMessageHandlerName = "appsflyerEventHandler"
    
    init(url: String) {
        self.urlString = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        
        let topBackgroundView = UIView()
        topBackgroundView.backgroundColor = UIColor(named: "bgFill")
        topBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBackgroundView)
        
        let bottomBackgroundView = UIView()
        bottomBackgroundView.backgroundColor = UIColor(named: "bgFill")
        bottomBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBackgroundView)
        
        NSLayoutConstraint.activate([
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            topBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            bottomBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // ИЗМЕНЕНО: Передаем конфигурацию в setupWeb
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        // НОВЫЙ КОД: Регистрируем наш обработчик сообщений
        contentController.add(self, name: scriptMessageHandlerName)
        configuration.userContentController = contentController
        
        self.webView = self.setupWeb(frame: self.view.bounds, configuration: configuration)
        self.view.addSubview(self.webView)
        self.setupConstraints()
        if let url = URL(string: self.urlString) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
        self.makeSecureWithWindow()
        Orientation.orientation = .all
    }
    
    // ИЗМЕНЕНО: Принимаем конфигурацию, чтобы добавить наш обработчик
    func setupWeb(frame: CGRect, configuration: WKWebViewConfiguration?) -> WKWebView {
        let config = configuration ?? WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.applicationNameForUserAgent = "MyApp/1.0"
        
        let webView = WKWebView(frame: frame, configuration: config)
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_1 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Mobile/14A403 Safari/602.1"
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.allowsLinkPreview = false
        webView.scrollView.bounces = false
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    func makeSecureWithWindow() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
            let field = UITextField()
            field.isSecureTextEntry = true
            window.addSubview(field)
            window.layer.superlayer?.addSublayer(field.layer)
            field.layer.sublayers?.last?.addSublayer(window.layer)
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            field.leftView = view
            field.leftViewMode = .always
        }
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
           guard message.name == scriptMessageHandlerName else { return }
           
           guard let body = message.body as? [String: Any],
                 let eventName = body["eventName"] as? String else {
               Logger.shared.log("Could not parse WebView message body or find eventName")
               return
           }
           
           Logger.shared.log("Received event from WebView: \(eventName) with data: \(body)")
           
           // ИЗМЕНЕНО: Используем новые константы для имен событий, которые приходят из JS
           switch eventName {
           case WebViewEvents.registration:
               AppsFlyerManager.logRegistrationEvent()
               
           case WebViewEvents.firstDeposit, WebViewEvents.repeatDeposit:
               guard let amount = body["amount"] as? Double,
                     let currency = body["currency"] as? String else {
                   Logger.shared.log("Amount or currency is missing for deposit event")
                   return
               }
               
               if eventName == WebViewEvents.firstDeposit {
                   AppsFlyerManager.logFirstDepositEvent(amount: amount, currency: currency)
               } else {
                   AppsFlyerManager.logRepeatDepositEvent(amount: amount, currency: currency)
               }
               
           default:
               Logger.shared.log("Unknown event received: \(eventName)")
           }
       }


//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        guard message.name == scriptMessageHandlerName else { return }
//        
//        guard let body = message.body as? [String: Any],
//              let eventName = body["eventName"] as? String else {
//            Logger.shared.log("Could not parse WebView message body or find eventName")
//            return
//        }
//        
//        Logger.shared.log("Received event from WebView: \(eventName) with data: \(body)")
//        
//        switch eventName {
//        case AppsFlyerEvents.registration:
//            AppsFlyerManager.logRegistrationEvent()
//            
//        case AppsFlyerEvents.firstDeposit, AppsFlyerEvents.repeatDeposit:
//            guard let amount = body["amount"] as? Double,
//                  let currency = body["currency"] as? String else {
//                Logger.shared.log("Amount or currency is missing for deposit event")
//                return
//            }
//            
//            if eventName == AppsFlyerEvents.firstDeposit {
//                AppsFlyerManager.logFirstDepositEvent(amount: amount, currency: currency)
//            } else {
//                AppsFlyerManager.logRepeatDepositEvent(amount: amount, currency: currency)
//            }
//            
//        default:
//            Logger.shared.log("Unknown event received: \(eventName)")
//        }
//    }

    // ... (остальной код файла без изменений)
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil || !navigationAction.targetFrame!.isMainFrame {
            // ... твой код для открытия попапов остается без изменений
            let topInset: CGFloat = 44
            let containerView = UIView(frame: self.view.frame)
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = UIColor.black
            
            self.view.addSubview(containerView)
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
            
            var webViewFrame = self.view.safeAreaLayoutGuide.layoutFrame
            webViewFrame.size.height -= topInset
            webViewFrame.origin.y += topInset
            
            let targetView = self.setupWeb(frame: webViewFrame, configuration: configuration)
            targetView.translatesAutoresizingMaskIntoConstraints = false
            if let url = navigationAction.request.url {
                targetView.load(URLRequest(url: url))
            }
            targetView.uiDelegate = self
            
            containerView.addSubview(targetView)
            
            let closeButton = UIButton(type: .system)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.tintColor = UIColor.white
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
            containerView.addSubview(closeButton)
            
            NSLayoutConstraint.activate([
                closeButton.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -15),
                closeButton.centerYAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 22),
                targetView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: topInset),
                targetView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
                targetView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
                targetView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor)
            ])
            
            containerView.alpha = 0.0
            UIView.animate(withDuration: 0.2) {
                containerView.alpha = 1.0
            }
            
            return targetView
        }
        return nil
    }
    
    @objc func closeButtonTapped(_ sender: UIButton) {
        if let view = sender.superview {
            UIView.animate(withDuration: 0.2) {
                view.alpha = 0.0
            } completion: { _ in
                view.removeFromSuperview()
            }
        }
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if let view = webView.superview {
            UIView.animate(withDuration: 0.2) {
                view.alpha = 0.0
            } completion: { _ in
                view.removeFromSuperview()
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if !["http", "https"].contains(url.scheme) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if #available(iOS 15.0, *) {
            self.view.backgroundColor = self.webView.underPageBackgroundColor
        }
    }
}

private extension String {
    
    private var kUIInterfaceOrientationPortrait: String {
        return "UIInterfaceOrientationPortrait"
    }
    
    private var kUIInterfaceOrientationLandscapeLeft: String {
        return "UIInterfaceOrientationLandscapeLeft"
    }
    
    private var kUIInterfaceOrientationLandscapeRight: String {
        return "UIInterfaceOrientationLandscapeRight"
    }
    
    private var kUIInterfaceOrientationPortraitUpsideDown: String {
        return "UIInterfaceOrientationPortraitUpsideDown"
    }
    
    var deviceOrientation: UIInterfaceOrientationMask {
        switch self {
        case kUIInterfaceOrientationPortrait:
            return .portrait
            
        case kUIInterfaceOrientationLandscapeLeft:
            return .landscapeLeft
            
        case kUIInterfaceOrientationLandscapeRight:
            return .landscapeRight
            
        case kUIInterfaceOrientationPortraitUpsideDown:
            return .portraitUpsideDown
            
        default:
            return .all
        }
    }
}

class Orientation {
    
    private static var preferredOrientation: UIInterfaceOrientationMask {
        guard let maskStringsArray = Bundle.main.object(forInfoDictionaryKey: "UISupportedInterfaceOrientations") as? [String] else {
            return .all
        }
        
        let masksArray = maskStringsArray.compactMap { $0.deviceOrientation }
        
        return UIInterfaceOrientationMask(masksArray)
    }
    
    fileprivate(set) public static var orientation: UIInterfaceOrientationMask = preferredOrientation
    
}
