//
//  ContentView.swift
//  Heart Condition App Watch App
//
//  Created by Ole Ho on 2023-03-05.
//

import SwiftUI
import HealthKit
import UserNotifications

struct Exercise: Codable, Hashable {
    var description: String
    var schedule: [ExerciseDay]
}
struct ExerciseDay: Codable, Hashable {
    var hour: Int
    var completed: Bool
    
    enum CodingKeys: String, CodingKey {
        case hour
        case completed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hour = try container.decode(Int.self, forKey: .hour)
        completed = try container.decodeIfPresent(Bool.self, forKey: .completed) ?? false
    }
}
struct Medication: Codable, Hashable {
    var medication: String
    var dosage: String
    var notes: String
    var start_date: String
    var end_date: String
    var schedule: [[Dose]]
}
struct Dose: Codable, Hashable {
    var hour: Int
    var amount: Int
    var completed: Bool
    
    enum CodingKeys: String, CodingKey {
        case hour
        case amount
        case completed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hour = try container.decode(Int.self, forKey: .hour)
        amount = try container.decode(Int.self, forKey: .amount)
        completed = try container.decodeIfPresent(Bool.self, forKey: .completed) ?? false
    }
}
struct Patient: Codable, Hashable {
    var id: String
    var name: String
    var exercises: [Exercise]
    var prescriptions: [Medication]
    
    init() {
        self.id = ""
        self.name = "Patient"
        self.exercises = []
        self.prescriptions = []
    }
}



func savePatientData(patient: Patient) {
    // saved patient data completed property data is not accurate for unknown reasons
    
    let encoder = JSONEncoder()
    let data = try! encoder.encode(patient)
    
    // save json file
    let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.heartapp")!
    let filePath = containerURL.appendingPathComponent("patient.json")

    do {
        try data.write(to: filePath, options: .atomic)
        print("File saved: \(filePath)")
    } catch {
        print("Error saving file: \(error.localizedDescription)")
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    @State var patient: Patient
    
    func makeBody(configuration: Self.Configuration) -> some View {
        Image(systemName: configuration.isOn ? "checkmark.square" : "square")
            .frame(alignment: .leading)
            .padding(.leading, 0)
            .foregroundColor(.white)
            .onTapGesture {
                configuration.isOn.toggle()
                savePatientData(patient: patient)
            }
    }
}

struct Checkbox: View {
    @Binding var isSelected: Bool
    
    @State var patient: Patient
    
    var body: some View {
        Toggle("", isOn: $isSelected).labelsHidden()
            .toggleStyle(CheckboxToggleStyle(patient: patient))
    }
}

struct ContentView: View {
    @EnvironmentObject var heartManager: HeartManager
    @ObservedObject var sessionManager = SessionManager()
    
    @State private var patient = Patient()

    var body: some View {
        VStack {
            TabView {
                VStack {
                    // TODO display app logo
                    Text("Heart Condition App")
                    Text("Hello " + patient.name + "!")
                }.id(0)
                ForEach(Array(0...6), id: \.self) { day in
                    PageView(day: day, patient: patient)
                        .id(day+1)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
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

struct PageView: View {
    let day: Int
    @State var patient: Patient
    
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        
        let red = RoundedRectangle(cornerRadius: 10)
            .foregroundColor(Color.red)
        let blue = RoundedRectangle(cornerRadius: 10)
            .foregroundColor(Color.blue)
        
        VStack {
            Text(daysOfWeek[day])
                .frame(maxWidth: .infinity)
                .fontWeight(.bold)
                .background(Color.purple)
      
            List {
                
                ForEach(patient.exercises.indices, id: \.self) { i in
                    let exercise = patient.exercises[i]
                    let exerciseDay = exercise.schedule[day]
                    let hours = exerciseDay.hour
                    if hours > 0 {
                        
                        HStack() {
                            Checkbox(isSelected: $patient.exercises[i].schedule[day].completed, patient: patient)
                            Text("\(exercise.description) \(hours) hours")
                        }
                        .listRowBackground(red)
                        .frame(maxWidth: .infinity, alignment: .leading) // <6>
                        .padding(.leading, 0)
                    }
                }
                
                ForEach(patient.prescriptions.indices, id: \.self) { i in
                    let prescription = patient.prescriptions[i]
                    
                    let doseArray = prescription.schedule[day]
                    
                    if doseArray.count > 0 {
                        Text("\(prescription.medication) \(prescription.dosage)")
                            .listRowBackground(blue)
                        
                        ForEach(doseArray.indices, id: \.self) { j in
                            let dose = doseArray[j]
                            HStack() {
                                Checkbox(isSelected: $patient.prescriptions[i].schedule[day][j].completed, patient: patient)
                                Text("\(String(format: "%02d", dose.hour)):00 | \(dose.amount) pills")
                            }
                            .listRowBackground(blue)
                                
                        }
                    }
                }
            }
            //.id(day)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
