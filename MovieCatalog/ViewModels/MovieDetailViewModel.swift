//
//  MovieDetailViewModel.swift
//  MovieCatalog
//
//  Created by Тимур on 15.08.2025.
//

import Foundation

final class MovieDetailViewModel {
    private let movieId: String
    var onUpdate: (() -> Void)?
    
    private(set) var movie: MovieDetail?
    
    init(movieId: String) {
        self.movieId = movieId
    }
    
    func loadMovieDetails() async {
        do {
            let details = try await NetworkService.shared.fetchMovieDetails(id: movieId)
            self.movie = details
            onUpdate?()
        } catch {
            print("Ошибка загрузки деталей фильма \(error.localizedDescription)")
        }
    }
}
