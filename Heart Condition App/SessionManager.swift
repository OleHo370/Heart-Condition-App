//
//  SessionManager.swift
//  Heart Condition App
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
        print("WC activated")
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    // Implement other WCSessionDelegate methods here
    
}

