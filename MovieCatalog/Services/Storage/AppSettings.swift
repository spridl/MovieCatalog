//
//  AppSettings.swift
//  MovieCatalog
//
//  Created by Тимур on 19.08.2025.
//

import Foundation

final class AppSettings {
    private enum Keys {
        static let searchCount = "searchCount"
    }
    
    static var searchCount: Int {
        get {
            UserDefaults.standard.integer(forKey: Keys.searchCount)
        } set {
            UserDefaults.standard.set(newValue, forKey: Keys.searchCount)
        }
    }
    
    static func incrementSearchCount() {
        let current = UserDefaults.standard.integer(forKey: Keys.searchCount)
        UserDefaults.standard.set(current + 1, forKey: Keys.searchCount)
    }
}
