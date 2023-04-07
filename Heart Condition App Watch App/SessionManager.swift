//
//  SessionManager.swift
//  Heart Condition App Watch App
//
//  Created by Ole Ho on 2023-04-03.
//

import WatchConnectivity

class SessionManager: NSObject, ObservableObject, WCSessionDelegate {
    
    var session: WCSession
    
    @Published var patient: Patient
    
    override init() {
        session = WCSession.default
        patient = Patient()
        super.init()
        session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // Implement other WCSessionDelegate methods here

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        DispatchQueue.main.async {
            
            let json = message["patient"] as! String
            // if empty string
            if json.count == 0 {
                return
            }
            let data = json.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            
            do {
                self.patient = try decoder.decode(Patient.self, from: data)
            } catch {
                // If an error is thrown, the code execution will jump to this block
                print("An error occurred: \(error.localizedDescription)")
            }
            
            print("received patient data " + self.patient.name)
        }
    }
    
}
