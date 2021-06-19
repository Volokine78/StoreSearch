//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by Tolga PIRTURK on 19.06.2021.
//

import UIKit

class MenuViewController: UITableViewController {
    
    weak var delegate: MenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Table View Delegates
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            delegate?.menuViewControllerSendEmail(self)
        }
    }
}

protocol MenuViewControllerDelegate: AnyObject {
    func menuViewControllerSendEmail(_ controller: MenuViewController)
}
