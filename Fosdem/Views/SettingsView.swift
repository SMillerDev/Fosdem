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
    @State private var bookmarks: Bool = SettingsHelper().bookmarks
    @State private var future: Bool = SettingsHelper().future
    @State private var localTime: Bool = SettingsHelper().localTime
    @State private var year: String = SettingsHelper().year

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Form {
            Section("Filters") {
                Toggle(isOn: $bookmarks, label: { Label("Bookmarks only", systemImage: "bookmark")})
                Toggle(isOn: $future, label: { Label("Future events only", systemImage: "clock")})
            }
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
        }.presentationDetents([.fraction(0.3)])
            .onChange(of: year) { _, value in
                SettingsHelper().year = value
                do {
                    try modelContext.delete(model: Conference.self)
                } catch {
                    debugPrint("Failed to clear")
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
