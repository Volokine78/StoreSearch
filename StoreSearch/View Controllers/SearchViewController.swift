//
//  ViewController.swift
//  StoreSearch
//
//  Created by Tolga PIRTURK on 14.05.2021.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var landscapeVC: LandscapeViewController?
    private let search = Search()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        
        tableView.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        var cellNib = UINib(nibName: SearchResultCell.reuseIdentifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: SearchResultCell.reuseIdentifier)
        cellNib = UINib(nibName: Constants.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constants.nothingFoundCell)
        cellNib = UINib(nibName: Constants.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constants.loadingCell)
    }
    
    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
            case .compact:
                showLandscape(with: coordinator)
            case .regular, .unspecified:
                hideLandscape(with: coordinator)
            @unknown default:
                break
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            segue.destination.modalPresentationStyle = .pageSheet
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let searchResult = search.searchResults[indexPath.row]
            detailViewController.searchResult = searchResult
        }
    }
    
    // MARK: - Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    // MARK: - Helper Methods
    
    func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message: "There was an error accessing the iTunes Store." + "Please try again",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else { return }
        
        landscapeVC = storyboard!.instantiateViewController(
            withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeVC {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
            addChild(controller)
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            } , completion: { _ in
                controller.didMove(toParent: self)
            })
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
            } , completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
            })
        }
    }
}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        search.performSearch(
            for: searchBar.text!,
            category: segmentedControl.selectedSegmentIndex)
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
        
//        if !searchBar.text!.isEmpty {
//            searchBar.resignFirstResponder()
//
//            dataTask?.cancel()
//            isLoading = true
//            tableView.reloadData()
//            hasSearched = true
//            searchResults = []
//
//            let url = iTunesURL(searchText: searchBar.text!,
//                                category: segmentedControl.selectedSegmentIndex)
//            //print("URL: '\(url)'")
//            let session = URLSession.shared
//            dataTask = session.dataTask(with: url) { data, response, error in
//                if let error = error as NSError?, error.code == -999 {
//                    return
//                } else if let httpResponse = response as? HTTPURLResponse,
//                          httpResponse.statusCode == 200 {
//                    if let data = data {
//                        self.searchResults = self.parse(data: data)
//                        self.searchResults.sort(by: <)
//                        DispatchQueue.main.async {
//                            self.isLoading = false
//                            self.tableView.reloadData()
//                        }
//                        return
//                    }
//                } else {
//                    print("Failure! \(response!)")
//                }
//                DispatchQueue.main.async {
//                    self.hasSearched = false
//                    self.isLoading = false
//                    self.tableView.reloadData()
//                    self.showNetworkError()
//                }
//            }
//            dataTask?.resume()
//        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if search.isLoading {
            return 1
        } else if !search.hasSearched {
            return 0
        } else if search.searchResults.count == 0 {
            return 1
        } else {
            return search.searchResults.count
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if search.isLoading {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.loadingCell,
                for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        } else if search.searchResults.count == 0 {
            return tableView.dequeueReusableCell(
                withIdentifier:Constants.nothingFoundCell,
                for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultCell.reuseIdentifier,
                for: indexPath) as! SearchResultCell
            
            let searchResult = search.searchResults[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        if search.searchResults.count == 0 || search.isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}
