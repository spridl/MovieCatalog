//
//  BackgroundManager.swift
//  MovieCatalog
//
//  Created by Тимур on 20.08.2025.
//

import UIKit

class BackgroundManager {
    static let shared = BackgroundManager()
    
    private init() {}
    
    private let fileName = "background.jpg"
    
    private var fileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(fileName)
    }
    
    func saveBackground(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        try? data.write(to: fileURL)
    }
    
    func loadBackground() -> UIImage? {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        }
        return nil
    }
    
    func clearBackground() {
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    
}
