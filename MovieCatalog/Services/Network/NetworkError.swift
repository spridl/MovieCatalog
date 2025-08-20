//
//  NetworkError.swift
//  MovieCatalog
//
//  Created by Тимур on 11.08.2025.
//

import Foundation

enum NetworkError: Error {
    case noInternetConnection
    case invalidURL
    case decodingFailed
    case unknown
}
