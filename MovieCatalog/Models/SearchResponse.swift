//
//  SearchResponse.swift
//  MovieCatalog
//
//  Created by Тимур on 11.08.2025.
//

import Foundation

struct SearchResponse: Decodable {
    let search: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case search = "Search"
    }
}
