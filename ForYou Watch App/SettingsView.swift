//
//  SettingsView.swift
//  ForYou Watch App
//
//  Created by Aarya Raut on 5/8/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @State private var baseInterval: String = ""
    @State private var shortenedInterval: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Reminder Intervals")) {
                        TextField("Normal interval (minutes)", text: $baseInterval)
//                            .keyboardType(.numberPad)
                        
                        TextField("Shortened interval (minutes)", text: $shortenedInterval)
//                            .keyboardType(.numberPad)
                        
                        Text("Shorter interval is used when you skip a reminder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Section {
                        Button("Save Settings") {
                            saveSettings()
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.blue)
                    }
                }
                .navigationTitle("Settings")
                .onAppear {
                    baseInterval = "\(reminderManager.baseReminderInterval)"
                    shortenedInterval = "\(reminderManager.shortenedReminderInterval)"
                }
            }
        }
        
        private func saveSettings() {
            if let base = Int(baseInterval), base > 0 {
                reminderManager.baseReminderInterval = base
            }
            
            if let shortened = Int(shortenedInterval), shortened > 0 {
                reminderManager.shortenedReminderInterval = shortened
            }
            
            reminderManager.saveSettings()
        }
}

#Preview {
    SettingsView()
        .environmentObject(ReminderManager.shared)
}
