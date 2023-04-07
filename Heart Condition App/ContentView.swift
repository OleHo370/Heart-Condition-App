//
//  ContentView.swift
//  Heart Condition App
//
//  Created by Ole Ho on 2023-03-05.
//

import SwiftUI
import WatchConnectivity
import WebKit

struct WebView: UIViewRepresentable {
    var url: URL
    var onMessageReceived: ((String) -> Void)? = nil
    

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var onMessageReceived: ((String) -> Void)?
        var webView: WKWebView?
        
        init(webView: WKWebView? = nil, onMessageReceived: ((String) -> Void)? = nil) {
            super.init()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Handle navigation finish event
            print("finished navigation")
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "messageHandler", let messageBody = message.body as? String {
                onMessageReceived?(messageBody)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let coordinator = context.coordinator
        coordinator.webView = webView
        coordinator.onMessageReceived = onMessageReceived
                
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.add(context.coordinator, name: "messageHandler")
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    
}

struct ContentView: View {
    @StateObject var sessionManager = SessionManager()
    
    let url = URL(string: "https://oleho370.github.io/heart-checker-web/")!
    
    var body: some View {
        WebView(url: url, onMessageReceived: { message in
            print(message)
//            if WCSession.default.isReachable {
//                let message = ["user": message]
//
//                WCSession.default.sendMessage(message, replyHandler: { replyMessage in
//                    // handle reply message here
//                }, errorHandler: { error in
//                    print("Error sending message: \(error.localizedDescription)")
//                })
//            } else {
//                print("Watch is not reachable")
//            }
        })

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
