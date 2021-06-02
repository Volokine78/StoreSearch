//
//  Search.swift
//  StoreSearch
//
//  Created by Tolga PIRTURK on 2.06.2021.
//

import Foundation

class Search {
    var searchResults: [SearchResult] = []
    var hasSearched = false
    var isLoading = false
    
    private var dataTask: URLSessionDataTask?
    
    func performSearch(for text: String, category: Int) {
        print("Searching...")
    }
    
    // MARK: - Helper Methods
    private func iTunesURL(searchText: String, category: Int) -> URL {
        let kind: String
        switch category {
            case 1: kind = "musicTrack"
            case 2: kind = "software"
            case 3: kind = "ebook"
            default: kind = ""
        }
        
        let encodedText = searchText.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = "https://itunes.apple.com/search?" +
                "term=\(encodedText)&limit=200&entity=\(kind)"
        
        let url = URL(string: urlString)
        return url!
    }
    
    private func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
}
