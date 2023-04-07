//
//  SessionManager.swift
//  Heart Condition App Watch App
//
//  Created by Ole Ho on 2023-04-03.
//

import WatchConnectivity

class SessionManager: NSObject, ObservableObject, WCSessionDelegate {
    
    var session: WCSession
    
    override init() {
        self.session = WCSession.default
        super.init()
        self.session.delegate = self
        self.session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // Implement other WCSessionDelegate methods here

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print(message["idToken"] ?? "")
    }
    
}
