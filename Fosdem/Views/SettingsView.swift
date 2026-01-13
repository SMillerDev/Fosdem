//
//  SettingsView.swift
//  Fosdem
//
//  Created by Sean Molenaar on 14/11/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage("year") var year: String?
    @AppStorage("localTime") var localTime: Bool = false
    var body: some View {
        Form {
            Section("Settings") {
                Toggle(isOn: $localTime,
                       label: {
                        Label("Local timezone", systemImage: "globe")
                    }
                )
                Picker(selection: $year) {
                    ForEach(getYears(), id: \.self) {
                        Text($0)
                    }
                } label: {
                    Label("Year", systemImage: "calendar")
                }
            }
            Section("About") {
                AboutView()
            }
        }.presentationDetents([.fraction(0.3)])
        .onChange(of: year) { _, _ in
            do {
                if #available(iOS 18, *) {
                    try modelContext.container.erase()
                } else {
                    modelContext.container.deleteAllData()
                }
            } catch {
                // NO-OP
            }
            Task {
                await RoomStatusFetcher.fetchRoomStatus()
                await RemoteScheduleFetcher.fetchSchedule()
            }
        }
    }

    private func getYears() -> [String] {
        let cal = Calendar.current
        let start = try? Date("2020-01-01T00:00:00Z", strategy: .iso8601)
        let last = cal.date(byAdding: .yearForWeekOfYear, value: 1, to: Date())!

        let formatter = DateFormatter()
        formatter.dateFormat = "Y"
        formatter.timeZone = .gmt

        var years: [String] = []
        for date in Int(formatter.string(from: start!))!...Int(formatter.string(from: last))! {
            years.append(String(date))
        }

        return years
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
