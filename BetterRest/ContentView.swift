//
//  ContentView.swift
//  BetterRest
//
//  Created by Luv Modi on 5/16/24.
//

import SwiftUI
import SwiftData
import CoreML

struct ContentView: View {
    @State private var wakeUpTime = defaultWakeTime
    @State private var coffeeCups = 1
    @State private var sleepTime = 8.0
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false

    static private var defaultWakeTime: Date {
        var component = DateComponents()
        component.hour = 7
        component.minute = 0
        return Calendar.current.date(from: component) ?? .now
    }
    var body: some View {
        NavigationStack {
            Form {
                VStack (alignment: .leading, spacing: 0) {
                    Text("At what time do you wake up?")
                        .font(.headline)
                    
                    DatePicker("Preferred time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack (alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepTime.formatted()) hours", value: $sleepTime, in: 4...12, step: 0.25)
                }
                
                VStack (alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper("^[\(coffeeCups) cup](inflect: true)", value: $coffeeCups, in: 1...20)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calcBedTime)
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calcBedTime() {
        let config = MLModelConfiguration()
        do {
            let sleepCalc = try SleepCalculator(configuration: config)
            let wakeTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (wakeTimeComponents.hour ?? 0) * 60 * 60
            let minute = (wakeTimeComponents.minute ?? 0) * 60
            let prediction = try sleepCalc.prediction(wake: Double(hour + minute), estimatedSleep: sleepTime, coffee: Double(coffeeCups))
            let sleepTime = wakeUpTime - prediction.actualSleep
            alertTitle = "Your sleep time is ..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error Occurred"
            alertMessage = "Some issue occurred while trying to calc your sleep time"
        }
        showAlert = true
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
