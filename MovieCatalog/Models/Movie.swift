//
//  Movie.swift
//  MovieCatalog
//
//  Created by Тимур on 11.08.2025.
//

import Foundation

struct Movie: Codable {
    let title: String?
    let year: String?
    let imdbID: String
    let type: String?
    let poster: String
    
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID = "imdbID"
        case type = "Type"
        case poster = "Poster"
    }
}
