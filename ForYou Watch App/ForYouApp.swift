//
//  ForYouApp.swift
//  ForYou Watch App
//
//  Created by Aarya Raut on 5/8/25.
//

import SwiftUI
import WatchKit
import UserNotifications

@main
struct ForYou_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ReminderManager.shared)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                ReminderManager.shared.checkAndRescheduleReminders()
            }
        }
    }
}


class AppDelegate: NSObject, WKApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching() {
        // Request notification permissions
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
                self.registerNotificationCategories()
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
        
        // Initialize the reminder manager
        _ = ReminderManager.shared
    }
    
    func registerNotificationCategories() {
        // Create actions for hydration reminder notifications
        let drinkAction = UNNotificationAction(
            identifier: "DRINK_ACTION",
            title: "Drank Water",
            options: .foreground
        )
        
        let skipAction = UNNotificationAction(
            identifier: "SKIP_ACTION",
            title: "Skip",
            options: .destructive
        )
        
        // Create the reminder category with the actions
        let reminderCategory = UNNotificationCategory(
            identifier: "HYDRATION_REMINDER",
            actions: [drinkAction, skipAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register the category
        UNUserNotificationCenter.current().setNotificationCategories([reminderCategory])
    }
    
    // Handle notification responses
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case "DRINK_ACTION":
            ReminderManager.shared.logWaterDrunk()
            ReminderManager.shared.scheduleNextReminder(false)
            
        case "SKIP_ACTION":
            ReminderManager.shared.logSkipped()
            ReminderManager.shared.scheduleNextReminder(true)
            
        default:
            break
        }
        
        completionHandler()
    }
}

class ReminderManager: ObservableObject {
    static let shared = ReminderManager()
    
    // Settings
    @Published var baseReminderInterval: Int = 60 // minutes
    @Published var shortenedReminderInterval: Int = 30 // minutes
    @Published var waterCount: Int = 0
    @Published var skipCount: Int = 0
    @Published var lastAction: String = "None"
    @Published var nextReminderTime: Date? = nil
    
    // UserDefaults keys
    private let baseIntervalKey = "baseReminderInterval"
    private let shortenedIntervalKey = "shortenedReminderInterval"
    private let waterCountKey = "waterCount"
    private let skipCountKey = "skipCount"
    private let nextReminderTimeKey = "nextReminderTime"
    
    private init() {
        // Load saved settings
        baseReminderInterval = UserDefaults.standard.integer(forKey: baseIntervalKey)
        if baseReminderInterval == 0 { baseReminderInterval = 60 } // Default if not set
        
        shortenedReminderInterval = UserDefaults.standard.integer(forKey: shortenedIntervalKey)
        if shortenedReminderInterval == 0 { shortenedReminderInterval = 30 } // Default if not set
        
        waterCount = UserDefaults.standard.integer(forKey: waterCountKey)
        skipCount = UserDefaults.standard.integer(forKey: skipCountKey)
        
        // Load next reminder time, if any
        if let savedDate = UserDefaults.standard.object(forKey: nextReminderTimeKey) as? Date {
            nextReminderTime = savedDate
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(baseReminderInterval, forKey: baseIntervalKey)
        UserDefaults.standard.set(shortenedReminderInterval, forKey: shortenedIntervalKey)
        UserDefaults.standard.set(waterCount, forKey: waterCountKey)
        UserDefaults.standard.set(skipCount, forKey: skipCountKey)
        
        // Save next reminder time
        if let nextTime = nextReminderTime {
            UserDefaults.standard.set(nextTime, forKey: nextReminderTimeKey)
        } else {
            UserDefaults.standard.removeObject(forKey: nextReminderTimeKey)
        }
    }
    
    func logWaterDrunk() {
        waterCount += 1
        lastAction = "Drank water"
        saveSettings()
    }
    
    func logSkipped() {
        skipCount += 1
        lastAction = "Skipped"
        saveSettings()
    }
    
    func resetCounts() {
        waterCount = 0
        skipCount = 0
        saveSettings()
    }
    
    func scheduleNextReminder(_ shortenDuration: Bool) {
        // Cancel any pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Determine interval based on whether user skipped
        let interval = shortenDuration ? shortenedReminderInterval : baseReminderInterval
        
        // Calculate next reminder time
        let nextDate = Date().addingTimeInterval(Double(interval * 60))
        nextReminderTime = nextDate
        
        // Save the next reminder time
        saveSettings()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Drink Water!"
        
        if shortenDuration {
            content.body = "You skipped last time, so here's a quicker reminder."
        } else {
            content.body = "Stay hydrated for better health!"
        }
        
        content.sound = .default
        content.categoryIdentifier = "HYDRATION_REMINDER"
        
        // Create trigger
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: nextDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "HydrationReminder-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func timeUntilNextReminder() -> String {
        guard let nextDate = nextReminderTime else {
            return "Not scheduled"
        }
        
        let now = Date()
        
        if nextDate < now {
            return "Overdue"
        }
        
        let difference = Calendar.current.dateComponents([.hour, .minute], from: now, to: nextDate)
        
        if let hour = difference.hour, let minute = difference.minute {
            if hour > 0 {
                return "\(hour)h \(minute)m"
            } else {
                return "\(minute)m"
            }
        } else {
            return "Soon"
        }
    }
    
    func checkAndRescheduleReminders() {
        // Check if there's a saved next reminder time
        if let nextTime = nextReminderTime {
            let now = Date()
            
            // If the time has passed or is coming up very soon (within 1 minute)
            if nextTime <= now.addingTimeInterval(60) {
                // Schedule a new reminder using the base interval
                scheduleNextReminder(false)
            } else {
                // Reschedule the existing reminder
                
                // Create notification content
                let content = UNMutableNotificationContent()
                content.title = "Time to Drink Water!"
                content.body = "Stay hydrated for better health!"
                content.sound = .default
                content.categoryIdentifier = "HYDRATION_REMINDER"
                
                // Create trigger
                let triggerDate = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second],
                    from: nextTime
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                // Create request
                let request = UNNotificationRequest(
                    identifier: "HydrationReminder-\(UUID().uuidString)",
                    content: content,
                    trigger: trigger
                )
                
                // Schedule notification
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error rescheduling notification: \(error)")
                    }
                }
            }
        }
    }
}
