//
//  ImageLoader.swift
//  MovieCatalog
//
//  Created by Тимур on 15.08.2025.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func loadImage(from urlString: String) async throws -> UIImage? {
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            return cachedImage
        }
        guard let url = URL(string: urlString) else {
            return nil
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        if let image = UIImage(data: data) {
            cache.setObject(image, forKey: urlString as NSString)
            return image
        }
        return nil
    }
}
