//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Tolga PIRTURK on 15.05.2021.
//

import Foundation

class ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult: Codable, CustomStringConvertible {
    var description: String {
        return "\nResult - Kind: \(kind ?? "None"), Genre: \(genre), Name: \(name), Artist Name: \(artistName ?? "None"), Track Price: \(trackPrice ?? 0.0) \(currency), \(imageSmall), \(imageLarge), \(storeURL ?? "None")"
    }
    
    var kind: String? = ""
    var artistName: String? = ""
    var trackName: String? = ""
    var trackPrice: Double? = 0.0
    var currency = ""
    var imageSmall = ""
    var imageLarge = ""
    var storeURL: String? = ""
    var genre = ""
    
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case storeURL = "trackViewUrl"
        case genre = "primaryGenreName"
        case kind, artistName, trackName
        case trackPrice, currency
    }

    var name: String{
        return trackName ?? ""
    }
}
