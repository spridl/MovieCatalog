//
//  NetworkService.swift
//  MovieCatalog
//
//  Created by Тимур on 14.08.2025.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    private let tunnel = "https://"
    private let server = "www.omdbapi.com/"
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "OMDBApiKey") as? String ?? ""
    
    
    func searchMovies(query: String, page: Int = 1) async throws -> SearchResponse {
        var components = URLComponents(string: tunnel + server)
        components?.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "s", value: query),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        let response = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let result = try decoder.decode(SearchResponse.self, from: response.0)
        print(result)
        return result
    }
    func fetchMovieDetails(id: String) async throws -> MovieDetail {
        var components = URLComponents(string: tunnel + server)
        components?.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "i", value: id),
            URLQueryItem(name: "plot", value: "full")
        ]
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        let response = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let result = try decoder.decode(MovieDetail.self, from: response.0)
        print(result)
        return result
    }
}
