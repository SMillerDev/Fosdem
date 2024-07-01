//
//  AppDelegate.swift
//  Fosdem
//
//  Created by Sean Molenaar on 02/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct Fosdem: App {

    let container: ModelContainer

    var body: some Scene {
        WindowGroup {
            EventListView()
        }.modelContainer(container)
    }

    init() {
        do {
            container = try ModelContainer(for: Conference.self,
                                           Room.self,
                                           Event.self,
                                           Link.self,
                                           Person.self,
                                           Track.self)
            RemoteScheduleFetcher.context = ModelContext(container)
        } catch {
            fatalError("Failed to create ModelContainer for Conference.")
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static let year = SettingsHelper().year

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        debugPrint(paths[0])

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
}
