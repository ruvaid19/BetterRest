//
//  ContentView.swift
//  BetterRest
//
//  Created by Ruvaid on 13/08/26.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var bedtime = Date.now

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    .blue.opacity(0.8),
                    .purple.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Header

                    VStack(spacing: 8) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 45))
                            .foregroundStyle(.white)

                        Text("BetterRest")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Find your ideal bedtime")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.top, 20)

                    // MARK: - Wake Up

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Wake Up Time", systemImage: "sunrise.fill")
                            .font(.headline)

                        DatePicker(
                            "Wake up",
                            selection: $wakeUp,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // MARK: - Sleep Amount

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Desired Sleep", systemImage: "bed.double.fill")
                            .font(.headline)

                        Stepper(
                            "\(sleepAmount.formatted()) hours",
                            value: $sleepAmount,
                            in: 4...12,
                            step: 0.25
                        )
                    }
                    .padding()
                    .background(.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // MARK: - Coffee

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Daily Coffee", systemImage: "cup.and.saucer.fill")
                            .font(.headline)

                        Picker("Coffee", selection: $coffeeAmount) {
                            ForEach(1...20, id: \.self) { amount in
                                Text("^[\(amount) cup](inflect: true)")
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding()
                    .background(.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // MARK: - Result

                    VStack(spacing: 12) {
                        Text("Your Ideal Bedtime")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.85))

                        Text(
                            bedtime.formatted(
                                date: .omitted,
                                time: .shortened
                            )
                        )
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.25), lineWidth: 1)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .onAppear {
            calculateBedtime()
        }
        .onChange(of: wakeUp) {
            calculateBedtime()
        }
        .onChange(of: sleepAmount) {
            calculateBedtime()
        }
        .onChange(of: coffeeAmount) {
            calculateBedtime()
        }
    }

    // MARK: - Calculate Bedtime

    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents(
                [.hour, .minute],
                from: wakeUp
            )

            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )

            bedtime = wakeUp - prediction.actualSleep

        } catch {
            print("Error calculating bedtime: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
