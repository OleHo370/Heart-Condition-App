//
//  ContentView.swift
//  Heart Condition App Watch App
//
//  Created by Ole Ho on 2023-03-05.
//

import SwiftUI
import HealthKit
import UserNotifications

struct Excercise: Codable {
    var description: String
    var schedule: [Int]
}
struct Medication: Codable {
    var medication: String
    var dosage: String
    var notes: String
    var start_date: String
    var end_date: String
    var schedule: [[Dose]]
}
struct Dose: Codable {
    var hour: Int
    var amount: Int
}
struct Patient: Codable {
    var id: String
    var name: String
    var excercises: [Excercise]
    var prescriptions: [Medication]
    
    init() {
        self.id = ""
        self.name = ""
        self.excercises = []
        self.prescriptions = []
    }
}

struct ContentView: View {
    @EnvironmentObject var heartManager: HeartManager
    @ObservedObject var sessionManager = SessionManager()
    
    @State private var patient = Patient()
    
    var body: some View {
        
        VStack {
            Text("Hello \(patient.name)")
            Button("Schedule Notification") {
                
                let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                
                for exercise in patient.excercises {
                    for i in 0..<7 {
                        let hourValue = exercise.schedule[i]
                        if hourValue == 0 {
                            continue
                        }
                        let content = UNMutableNotificationContent()
                        content.title = "Time to \(exercise.description) !"
                        content.subtitle = "You need to \(exercise.description) for \(hourValue) hours every \(daysOfWeek[i]) "
                        content.sound = UNNotificationSound.default
                        var dateComponents = DateComponents();
                        dateComponents.weekday = i;
                        dateComponents.hour = 8;
                        
                        // show this notification five seconds from now
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        
                        // choose a random identifier
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        
                        // add our notification request
                        UNUserNotificationCenter.current().add(request)
                    }
                }
                
                for medication in patient.prescriptions {
                    for i in 0..<7{
                        let doses = medication.schedule[i]
                        for dose in doses {
                            let content = UNMutableNotificationContent()
                            content.title = "Time to take \(medication.medication)!"
                            content.subtitle = "You need to take \(dose.amount) \(medication.dosage) pills of \(medication.medication) now! (\(dose.hour):00 on \(daysOfWeek[i]))"
                            content.sound = UNNotificationSound.default
                            var dateComponents = DateComponents();
                            dateComponents.weekday = i;
                            dateComponents.hour = dose.hour;
                            
                            // show this notification five seconds from now
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                            
                            // choose a random identifier
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            
                            // add our notification request
                            UNUserNotificationCenter.current().add(request)
                        }
                    }
                }
            }
           
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            heartManager.requestAuthorization()
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        .onReceive(sessionManager.$patient) { updatedPatient in
            print("updated patient")
            patient = updatedPatient
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
