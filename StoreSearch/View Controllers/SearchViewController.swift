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
    weak var splitViewDetail: DetailViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            searchBar.becomeFirstResponder()
        }
        
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
        
        title = NSLocalizedString("Search", comment: "split view primary button")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.navigationBar.isHidden = true
        }
    }
    
    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
            case .compact:
                if newCollection.horizontalSizeClass == .compact {
                    showLandscape(with: coordinator)
                }
            case .regular, .unspecified:
                hideLandscape(with: coordinator)
            @unknown default:
                break
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                segue.destination.modalPresentationStyle = .pageSheet
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
                detailViewController.isPopUp = true
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    // MARK: - Helper Methods
    
    func showNetworkError() {
        let alert = UIAlertController(
            title: NSLocalizedString("Whoops...", comment: "Error alert: title"),
            message: NSLocalizedString("There was an error accessing the iTunes Store." + "Please try again", comment: "Error alert: message"),
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
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            } , completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
            })
        }
    }
    
    private func hidePrimaryPane() {
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.splitViewController!.preferredDisplayMode = .secondaryOnly
            },
            completion: { _ in
                self.splitViewController!.preferredDisplayMode = .automatic
            }
        )
    }
    
    private func showPopUpView() {
        
        UIView.animate(
            withDuration: 1.5,
            animations: {
                self.splitViewDetail?.popupView.alpha = 1
            }
        )
    }
}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        if let category = Search.Category(
            rawValue: segmentedControl.selectedSegmentIndex) {
            
            search.performSearch(
                for: searchBar.text!,
                category: category) { success in
                if !success {
                    self.showNetworkError()
                }
                self.tableView.reloadData()
                self.landscapeVC?.searchResultsReceived()
            }
            
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
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
        switch search.state {
            case .notSearchedYet:
                return 0
            case .loading:
                return 1
            case .noResults:
                return 1
            case .results(let list):
                return list.count
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch search.state {
            case .notSearchedYet:
                fatalError("Should never get here")
            
            case .loading:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: Constants.loadingCell,
                    for: indexPath)
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                return cell
                
            case .noResults:
                return tableView.dequeueReusableCell(
                    withIdentifier: Constants.nothingFoundCell,
                    for: indexPath)
                
            case .results(let list):
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchResultCell.reuseIdentifier,
                    for: indexPath) as! SearchResultCell
                let searchResult = list[indexPath.row]
                cell.configure(for: searchResult)
                return cell
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        searchBar.resignFirstResponder()
        
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        } else {
            if case .results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
                showPopUpView()
            }
            if splitViewController!.displayMode != .oneBesideSecondary {
                hidePrimaryPane()
            }
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        switch search.state {
            case .notSearchedYet, .loading, .noResults:
                return nil
            case .results:
                return indexPath
        }
    }
}
