//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Tolga PIRTURK on 31.05.2021.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
    }
}
