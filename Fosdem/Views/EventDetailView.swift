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

    private func notificationRequest() -> UNNotificationRequest {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Heads up!"
        notificationContent.subtitle = "Your event \"\(event.title)\" starts in 5 minutes"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: event.start.timeIntervalSinceNow + 300,
                                                        repeats: false)

        event.userInfo.ensureUUID()
        return UNNotificationRequest(identifier: event.userInfo.notificationUUID!.uuidString, content: notificationContent, trigger: trigger)
    }

    var body: some View {
        ViewThatFits {
            ScrollView {
                EventDetailHeader(event).frame(maxWidth: .infinity)

                Picker("Test", selection: $selectedTabIndex, content: {
                    Text("Description").tag(0)
                    Text("Links").disabled(event.links.isEmpty).tag(1)
                    if event.isOngoing { Text("Live Video").tag(2) }
                }).pickerStyle(.segmented)

                ZStack {
                    if selectedTabIndex == 0 {
                        HTMLFormattedText(event.desc ?? "", colorScheme: colorScheme)
                    }
                    if selectedTabIndex == 1 {
                        if event.links.isEmpty {
                            Text("No links").foregroundColor(.gray).font(.title2).padding()
                        } else {
                            VStack(alignment: .leading) {
                                ForEach(Array(event.links)) { link in
                                    SwiftUI.Link(destination: URL(string: link.href)!) {
                                        Label(link.name, systemImage: "link")
                                    }.padding()
                                }
                            }
                        }
                    }
                    if selectedTabIndex == 2 {
                        VideoPlayer(event.room.liveStreamLink())
                    }
                }
            }
        }.navigationTitle(Text(event.title))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                ShareLink("Share web link", item: event.getPublicLink(), message: Text(event.title))
            }
            ToolbarItem(placement: .primaryAction) {
                Toggle(isOn: $event.userInfo.favorite, label: {
                    Label("Favorite", systemImage: event.userInfo.favorite ? "bookmark.fill" : "bookmark").backgroundStyle(.clear)
                }).onTapGesture(count: 1, perform: {
                    let _ = debugPrint(event.userInfo.favorite)
                    if event.start.timeIntervalSinceNow <= 0 {
                        return
                    }
                    if !permissionGranted {
                        requestPermissions()
                    }
                    if permissionGranted {
                        UNUserNotificationCenter.current().add(notificationRequest())
                    }
                    event.userInfo.ensureUUID()
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.userInfo.notificationUUID!.uuidString])
                })
            }
        }
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
