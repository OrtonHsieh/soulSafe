//
//  BasicScrollViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/15.
//

import UIKit

class BSViewController: UIViewController {
    let scrollView = UIScrollView()
    var viewControllers: [UIViewController] = []
    let mainVC = MainViewController()
    let memoriesVC = MemoriesViewController()
    let settingVC = SettingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupScrollView()
        setupScrollViewConponents()
    }
    
    func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false // Disable bouncing behavior
        scrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(scrollView)
    }
    
    func setupScrollViewConponents() {
        viewControllers = [memoriesVC, mainVC, settingVC]
        
        // Add the child view controllers to the scroll view
        for (index, viewController) in viewControllers.enumerated() {
            addChild(viewController)
            let xPosition = view.bounds.width * CGFloat(index)
            viewController.view.frame = CGRect(x: xPosition, y: 0, width: view.bounds.width, height: view.frame.height)
            scrollView.addSubview(viewController.view)
            viewController.didMove(toParent: self)
        }
        
        // Update the content size of the scroll view
        scrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(viewControllers.count), height: view.bounds.height)
        
        // Set the initial content offset to show the second view controller
        scrollView.contentOffset = CGPoint(x: view.bounds.width, y: 0)
    }
}

extension BSViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0 // 鎖住垂直滾動，將 y 軸偏移量設為 0
    }
}
