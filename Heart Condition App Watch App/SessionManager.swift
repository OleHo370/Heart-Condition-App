//  SessionManager.swift
//  Heart Condition App Watch App
//
//  Created by Ole Ho on 2023-04-03.
//

import WatchConnectivity
import UserNotifications

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
    
    func loadJSONData(file: String) -> Data? {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.heartapp")!
        let filePath = containerURL.appendingPathComponent(file + ".json")

        do {
            let data = try Data(contentsOf: filePath)
            return data
        } catch {
            print(file + " data not found")
        }
        // Return nil if data cannot be loaded
        return nil
    }
    
    func parsePatientData(data: Data) {
        
        let decoder = JSONDecoder()
        
        do {
            self.patient = try decoder.decode(Patient.self, from: data)
        } catch {
            // If an error is thrown, the code execution will jump to this block
            print("An error occurred: \(error.localizedDescription)")
        }
        
        print("parsed patient data " + self.patient.name)
    }
    
    func setupNotifcations() {
        let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        let center = UNUserNotificationCenter.current()
        
        for exercise in patient.exercises {
            for i in 0...6 {
                let exerciseDay = exercise.schedule[i]
                
                let hourValue = exerciseDay.hour
                if hourValue == 0 {
                    continue
                }
                let content = UNMutableNotificationContent()
                content.title = "Time to \(exercise.description) !"
                content.subtitle = "You need to \(exercise.description) for \(hourValue) hours every \(daysOfWeek[i]) "
                content.sound = UNNotificationSound.default
                
                center.getPendingNotificationRequests { (requests) in
                    // create a unique id
                    let id = "\(exercise.description) \(i) \(hourValue)"
                    
                    for request in requests {
                        print(request.identifier)
                        if request.identifier == id {
                            print("notification already exists: " + id)
                            return
                        }
                    }
                    
                    var dateComponents = DateComponents();
                    dateComponents.weekday = i;
                    dateComponents.hour = hourValue;
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    
                    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                    
                    // add our notification request
                    center.add(request)
                }
            }
        }
        
        for medication in patient.prescriptions {
            for i in 0...6 {
                let doses = medication.schedule[i]
                for dose in doses {
                    let content = UNMutableNotificationContent()
                    content.title = "Time to take \(medication.medication)!"
                    content.subtitle = "You need to take \(dose.amount) pills of \(medication.medication) \(medication.dosage) now! (\(dose.hour):00 on \(daysOfWeek[i]))"
                    content.sound = UNNotificationSound.default

                    center.getPendingNotificationRequests { (requests) in
                        // create a unique id
                        let id = "\(medication.medication) \(i) \(dose.hour)"
                        
                        for request in requests {
                            if request.identifier == id {
                                print("notification already exists: " + id)
                                return
                            }
                        }

                        var dateComponents = DateComponents();
                        dateComponents.weekday = i;
                        dateComponents.hour = dose.hour;

                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

                        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

                        // add our notification request
                        center.add(request)
                    }
                }
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let data = loadJSONData(file: "patient")
        if data != nil {
            DispatchQueue.main.async {
                self.parsePatientData(data: data!)
            }
        }
    }
    
    // Implement other WCSessionDelegate methods here

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        let json = message["patient"] as! String
        // if empty string
        if json.count == 0 {
            return
        }
        let data = json.data(using: .utf8)!
        
        DispatchQueue.main.async {
            self.parsePatientData(data: data)
        }
    }
    
}
