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

class SearchResult: Codable {
    var artistName: String? = ""
    var trackName: String? = ""
    
    var name: String{
        return trackName ?? ""
    }
}
