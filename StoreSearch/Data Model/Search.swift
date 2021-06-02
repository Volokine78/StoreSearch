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
}
