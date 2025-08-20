//
//  FavoritesViewModel.swift
//  MovieCatalog
//
//  Created by Тимур on 18.08.2025.
//

import Foundation

final class FavoritesViewModel {
    private(set) var favorites: [FavoriteMovie] = []
    var onUpdate: (() -> Void)?
    
    func loadFavorites() {
        favorites = CoreDataManager.shared.fetchFavorites()
        onUpdate?()
    }
    
    func remove(at index: Int) {
        let movie = favorites[index]
        if let id = movie.id {
            CoreDataManager.shared.removeFromFavorites(id: id)
            loadFavorites()
        }
    }
}
