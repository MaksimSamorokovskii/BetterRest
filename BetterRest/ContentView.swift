//
//  ContentView.swift
//  BetterRest
//
//  Created by Максим Самороковский on 10.02.2024.
//


import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var calculatedBedTime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculate(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Sorry, there was a problem calculating your bedTime."
        }
    }
    
    var body: some View {
            NavigationView {
                    Form {
                        HStack {
                            Text("When do you want to wake up?")
                                .font(.headline)
                            Spacer()
                            DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Desired amount of sleep")
                                .font(.headline)
                            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Daily coffee intake")
                                .font(.headline)
                            Picker("Cups of coffee", selection: $coffeAmount) {
                                ForEach(1...20, id: \.self) { cup in
                                    Text("\(cup) cup\(cup != 1 ? "s" : "")").tag(cup)
                                }
                            }
                        }
                        Section("Your ideal bedtime is") {
                            Text(calculatedBedTime)
                                .font(.title)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .navigationTitle("BetterRest")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


