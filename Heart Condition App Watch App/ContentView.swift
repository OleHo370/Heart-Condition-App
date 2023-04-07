//
//  ContentView.swift
//  Heart Condition App Watch App
//
//  Created by Ole Ho on 2023-03-05.
//

import SwiftUI
import HealthKit
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var heartManager: HeartManager
    @StateObject var sessionManager = SessionManager()
    
    var body: some View {
        VStack {

            Button("Schedule Notification") {
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

                let json = """
                "id": "b302bd2f-8fd2-4439-b1d8-859b536a7629",
                    "name": "Joe",
                    "excercises": [
                        {
                            "description": "Run",
                            "schedule": [1, 1, 1, 1, 1, 1, 1]
                        },
                        {
                            "description": "Swim",
                            "schedule": [0, 0, 0, 0, 0, 0, 1]
                        }
                    ],
                    "prescriptions": [
                        {
                            "medication": "Atorvastatin",
                            "dosage": "40mg",
                            "notes": "Statins to lower cholesterol levels",
                            "start_date": "2022-01-01",
                            "end_date": "2022-06-30",
                            "schedule": [
                                [
                                    {
                                        "hour": 8,
                                        "amount": 1
                                    }
                                ],
                                [
                                    {
                                        "hour": 8,
                                        "amount": 1
                                    }
                                ],
                                [
                                    {
                                        "hour": 8,
                                        "amount": 1
                                    }
                                ],
                                [
                                    {
                                        "hour": 8,
                                        "amount": 1
                                    }
                                ],
                                [
                                    {
                                        "hour": 8,
                                        "amount": 1
                                    }
                                ],
                                [
                                    {
                                        "hour": 20,
                                        "amount": 1
                                    }
                                ],
                                [
                                    {
                                        "hour": 8,
                                        "amount": 1
                                    }
                                ]
                            ]
                        },
                        {
                            "medication": "Metoprolol",
                            "dosage": "50mg",
                            "notes": "Beta blocker to control heart rate and blood pressure",
                            "start_date": "2022-01-01",
                            "end_date": "2022-06-30",
                            "schedule": [
                                [],
                                [
                                    {
                                        "hour": 8,
                                        "amount": 2
                                    },
                                    {
                                        "hour": 20,
                                        "amount": 1
                                    }
                                ],
                                [],
                                [],
                                [],
                                [
                                    {
                                        "hour": 8,
                                        "amount": 2
                                    },
                                    {
                                        "hour": 20,
                                        "amount": 1
                                    }
                                ],
                                []
                            ]
                        }
                    ]
                }


                """.data(using: .utf8)!

                let decoder = JSONDecoder()
                var patient = Patient()
                do {
                    patient = try decoder.decode(Patient.self, from: json)
                } catch {
                    // If an error is thrown, the code execution will jump to this block
                    print("An error occurred: \(error.localizedDescription)")
                }

                print(patient.name) // Prints "Durian"
                
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
