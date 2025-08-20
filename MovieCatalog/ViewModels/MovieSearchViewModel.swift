//
//  MovieSearchViewModel.swift
//  MovieCatalog
//
//  Created by Тимур on 14.08.2025.
//

import Foundation

@MainActor

final class MovieSearchViewModel {
    private let service = NetworkService.shared
    
    private let lastQueryKey = "lastSearchQuery"
    private(set) var movies: [Movie] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    var onLoading: ((Bool) -> Void)?
    var onUpdate: (() -> Void)?
    
    var lastQuery: String? {
        return UserDefaults.standard.string(forKey: lastQueryKey)
    }
    
    func searchMovies(query: String) {
        
        guard !query.isEmpty else { return }
        onLoading?(true)
        UserDefaults.standard.set(query, forKey: lastQueryKey)
        
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.movies = []
            self.errorMessage = "Введите название фильма"
            self.onUpdate?()
            return
        }
        Task {
            do {
                isLoading = true
                errorMessage = nil
                onUpdate?()
                
                let response = try await service.searchMovies(query: query)
                movies = response.search
                AppSettings.incrementSearchCount()
            } catch {
                movies = []
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
            onUpdate?()
        }
    }
}
