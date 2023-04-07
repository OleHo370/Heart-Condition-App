//
//  HeartManager.swift
//  Heart Condition App Watch App
//
//  Created by Ole Ho on 2023-03-05.
//

import Foundation
import HealthKit

class HeartManager: NSObject, ObservableObject {
    
    let healthStore = HKHealthStore()
    
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.activitySummaryType()
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error.
        }
    }
}
