//
//  YearHelper.swift
//  Fosdem
//
//  Created by Sean Molenaar on 16/10/2022.
//  Copyright © 2022 Sean Molenaar. All rights reserved.
//

import Foundation

class SettingsHelper: ObservableObject {

    public static let DEFAULTBOOL: Bool = false
    public static let DEFAULTYEAR: String = "2024"

    @Published var bookmarks: Bool {
        didSet {
            UserDefaults.standard.set(bookmarks, forKey: "bookmarks")
        }
    }

    @Published var future: Bool {
        didSet {
            UserDefaults.standard.set(future, forKey: "future")
        }
    }

    @Published var localTime: Bool {
        didSet {
            UserDefaults.standard.set(localTime, forKey: "localTime")
        }
    }

    @Published var year: String {
        didSet {
            UserDefaults.standard.set(year, forKey: "year")
        }
    }

    init() {
        year = UserDefaults.standard.string(forKey: "year") ?? SettingsHelper.DEFAULTYEAR
        bookmarks = UserDefaults.standard.bool(forKey: "bookmarks")
        future = UserDefaults.standard.bool(forKey: "future")
        localTime = UserDefaults.standard.bool(forKey: "localTime")
    }
}
