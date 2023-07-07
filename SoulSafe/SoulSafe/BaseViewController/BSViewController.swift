//
//  BasicScrollViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/15.
//

import UIKit
import FirebaseFirestore
import AuthenticationServices

class BSViewController: UIViewController {
    let scrollView = UIScrollView()
    var viewControllers: [UIViewController] = []
    let mainVC = MainViewController()
    let memoriesVC = MemoriesViewController()
    let settingVC = SettingViewController()
    var groupTitles: [String] = [] {
        didSet {
            memoriesVC.groupTitles = groupTitles
        }
    }
    var groupIDs: [String] = [] {
        didSet {
            memoriesVC.groupIDs = groupIDs
        }
    }
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupScrollView()
        chooseUser()
        self.observeAppleIDSessionChanges()
    }
    
    private func observeAppleIDSessionChanges() {
        NotificationCenter.default.addObserver(forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil, queue: nil) { (notification: Notification) in
            // Sign user in or out
            print("Sign user in or out...")
      }
    }
    
    func chooseUser() {
        let alertController = UIAlertController(title: "選擇使用者", message: nil, preferredStyle: .actionSheet)

        let option1Action = UIAlertAction(title: "何婉綾", style: .default) { (action) in
            UserSetup.userID = User.howan["userID"] as! String
            UserSetup.userName = User.howan["userName"] as! String
            UserSetup.userImage = User.howan["userImage"] as! String
            self.setupScrollViewConponents()
            self.mainVC.delegate = self
        }

        let option2Action = UIAlertAction(title: "潘厚紳", style: .default) { (action) in
            UserSetup.userID = User.pann["userID"] as! String
            UserSetup.userName = User.pann["userName"] as! String
            UserSetup.userImage = User.pann["userImage"] as! String
            self.setupScrollViewConponents()
            self.mainVC.delegate = self
        }

        let option3Action = UIAlertAction(title: "謝承翰", style: .default) { (action) in
            UserSetup.userID = User.orton["userID"] as! String
            UserSetup.userName = User.orton["userName"] as! String
            UserSetup.userImage = User.orton["userImage"] as! String
            self.setupScrollViewConponents()
            self.mainVC.delegate = self
        }

        alertController.addAction(option1Action)
        alertController.addAction(option2Action)
        alertController.addAction(option3Action)

        // 在這裡顯示 UIAlert
        // 例如：
         present(alertController, animated: true, completion: nil)
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
        scrollView.contentSize = CGSize(
            width: view.bounds.width * CGFloat(viewControllers.count),
            height: view.bounds.height
        )
        
        // Set the initial content offset to show the second view controller
        scrollView.contentOffset = CGPoint(x: view.bounds.width, y: 0)
        scrollView.bringSubviewToFront(viewControllers[1].view)
    }
}

extension BSViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 鎖住垂直滾動，將 y 軸偏移量設為 0
        scrollView.contentOffset.y = 0
    }
}

extension BSViewController: MainViewControllerDelegate {
    func didUpdateGroupID(_ viewController: MainViewController, updatedGroupIDs: [String]) {
        groupIDs = updatedGroupIDs
    }
    func didUpdateGroupTitle(_ viewController: MainViewController, updatedGroupTitles: [String]) {
        groupTitles = updatedGroupTitles
    }
    func didPressSendBtn(_ viewController: MainViewController) {
        memoriesVC.getNewGalleryPics()
    }
}
