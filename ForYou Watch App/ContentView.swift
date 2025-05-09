//
//  ContentView.swift
//  ForYou Watch App
//
//  Created by Aarya Raut on 5/8/25.
//


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("💧")
                                    .font(.system(size: 30))
                            )
                        Spacer()
                    }
                }

                Section(header: Text("Status")) {
                    Text("Water: \(reminderManager.waterCount)")
                    Text("Skipped: \(reminderManager.skipCount)")
                        .foregroundColor(.red)
                    Text("Last: \(reminderManager.lastAction)")
                        .font(.caption)
                    Text("Next: \(reminderManager.timeUntilNextReminder())")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Actions")) {
                    Button("I Drank Water") {
                        reminderManager.logWaterDrunk()
                    }
                    .tint(.blue)

                    Button("Schedule Reminder") {
                        reminderManager.scheduleNextReminder(false)
                    }
                    .tint(.green)

                    Button("Reset Counts", role: .destructive) {
                        reminderManager.resetCounts()
                    }
                }
            }
            .formStyle(.automatic)
            .navigationTitle("For YOU")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(reminderManager)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ReminderManager.shared)
}



//import SwiftUI
//
//struct ContentView: View {
//    @EnvironmentObject var reminderManager: ReminderManager
//    @State private var showSettings = false
//    
//    
//    var body: some View {
//            NavigationStack {
//                VStack(spacing: 20) {
//                    // Water drop graphic
//                    Circle()
//                        .fill(Color.blue)
//                        .frame(width: 30, height: 30)
//                        .overlay(
//                            Text("💧")
//                                .font(.system(size: 50))
//                        )
//                    
//                    // Status text
//                    VStack(spacing: 5) {
//                        Text("Water: \(reminderManager.waterCount)")
//                            .font(.headline)
//                        
//                        Text("Skipped: \(reminderManager.skipCount)")
//                            .font(.subheadline)
//                            .foregroundColor(.red)
//                        
//                        Text("Last action: \(reminderManager.lastAction)")
//                            .font(.caption)
//                        
//                        Text("Next reminder: \(reminderManager.timeUntilNextReminder())")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                    .padding()
//                    
//                    // Action buttons
//                    Button("I Drank Water") {
//                        reminderManager.logWaterDrunk()
//                    }
//                    .buttonStyle(.bordered)
//                    .tint(.blue)
//                    
//                    Button("Schedule Reminder") {
//                        reminderManager.scheduleNextReminder(false)
//                    }
//                    .buttonStyle(.bordered)
//                    .tint(.green)
//                    
//                    Button("Reset Counts") {
//                        reminderManager.resetCounts()
//                    }
//                    .buttonStyle(.bordered)
//                    .tint(.red)
//                    .padding(.top, 10)
//                }
//                .padding()
//                .navigationTitle("WaterWell")
//                .toolbar {
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button(action: {
//                            showSettings = true
//                        }) {
//                            Image(systemName: "gear")
//                        }
//                    }
//                }
//                .sheet(isPresented: $showSettings) {
//                    SettingsView()
//                }
//            }
//        }
//}
//
//#Preview {
//    ContentView()
//        .environmentObject(ReminderManager.shared)
//}
