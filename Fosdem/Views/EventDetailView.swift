//
//  EventDetailView.swift
//  Fosdem
//
//  Created by Sean Molenaar on 18/10/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import SwiftUI

struct EventDetailView: View {
    @ObservedObject private var event: Event

    @State private var selectedTabIndex = 0
    @State private var permissionGranted = false

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.managedObjectContext) var context

    init(_ event: Event) {
        self.event = event
    }

    private func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                permissionGranted = true
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    private func sendNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Heads up!"
        notificationContent.subtitle = "Your event \"\(event.title)\" starts in 5 minutes"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: event.start.timeIntervalSinceNow + 300,
                                                        repeats: false)

        let req = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)

        UNUserNotificationCenter.current().add(req)
    }

    var body: some View {
        ViewThatFits {
            ScrollView {
                EventDetailHeader(event).frame(maxWidth: .infinity)

                Picker("Test", selection: $selectedTabIndex, content: {
                    Text("Description").tag(0)
                    Text("Links").disabled(event.links.isEmpty).tag(1)
                }).pickerStyle(.segmented)

                ZStack {
                    if selectedTabIndex == 0 {
                        HTMLFormattedText(event.desc ?? "", colorScheme: colorScheme)
                    }
                    if selectedTabIndex == 1 {
                        if event.links.isEmpty {
                            Text("No links").foregroundColor(.gray).font(.caption)
                        } else {
                            VStack(alignment: .leading) {
                                ForEach(Array(event.links)) { link in
                                    SwiftUI.Link(destination: URL(string: link.href)!) {
                                        Label(link.name, systemImage: "link")
                                    }.padding()
                                }
                            }
//                            List(Array(event.links)) { link in
//                                Text(link.description)
//                                if let url = link.url() {
//                                    SwiftUI.Link(destination: url) {
//                                        Label(link.name, systemImage: link.icon)
//                                    }
//                                }
//                            }
                        }
                    }
                }
            }
        }.navigationTitle(Text(event.title))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            var label = "bell"
            if event.start.timeIntervalSinceNow > 0 {
                Toggle(isOn: $event.userInfo.notify, label: {
                    Label("Notify", systemImage: label)
                }).task {
                    if $event.userInfo.notify.wrappedValue == false {
                        return
                    }
                    if !permissionGranted {
                        label = "bell.slash"
                        requestPermissions()
                    }
                    if permissionGranted {
                        sendNotification()
                    }
                }
            }
            Toggle(isOn: $event.userInfo.favorite, label: {
                Label("Favorite", systemImage: event.userInfo.favorite ? "star.fill" : "star")
            })
        })
        .onAppear {
            // Check if we already have permissions to send notifications
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    permissionGranted = true
                }
            }
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(PreviewEvent.getEvent(true)).previewDisplayName("Detail Subtitle")
        EventDetailView(PreviewEvent.getEvent(false)).previewDisplayName("Detail Non-Subtitle")
    }
}
