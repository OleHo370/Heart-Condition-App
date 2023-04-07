//
//  Heart_Condition_AppApp.swift
//  Heart Condition App Watch App
//
//  Created by Ole Ho on 2023-03-05.
//

import SwiftUI

@main
struct Heart_Condition_App_Watch_AppApp: App {
    @StateObject private var heartManager = HeartManager()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environmentObject(heartManager)
        }
        
    }
}
