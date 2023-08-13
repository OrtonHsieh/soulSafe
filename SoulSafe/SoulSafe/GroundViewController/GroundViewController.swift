//
//  BasicScrollViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/15.
//

import UIKit
import FirebaseFirestore
import AuthenticationServices

class GroundViewController: UIViewController {
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
            settingVC.groupIDs = groupIDs
        }
    }
    // swiftlint:disable all
    let db = Firestore.firestore()
    // swiftlint:enable all
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupUserInfo()
        setupScrollView()
        setupScrollViewConponents()
        mainVC.delegate = self
        memoriesVC.delegate = self
        settingVC.delegate = self
        observeAppleIDSessionChanges()
        observeIfUserLogout()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func observeAppleIDSessionChanges() {
        NotificationCenter.default.addObserver(
            forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil,
            queue: nil
        ) { _ in
            // Sign user in or out
            print("Sign user in or out...")
        }
    }
    
    private func observeIfUserLogout() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    func setupUserInfo() {
        // 這邊要將資料從 FireBase 拿回來存
        UserSetup.userID = UserDefaults.standard.string(forKey: "userID") ?? "尚未登入"
        UserSetup.userName = "尚未設定名稱"
        // 這邊要打 API 去 fireStore 拿最新的大頭貼存到 UserDefaults
        UserSetup.userImage = UserDefaults.standard.string(forKey: "userAvatar") ?? "defaultAvatar"
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
    
    @objc func userDefaultsDidChange(notification: Notification) {
        if let defaults = notification.object as? UserDefaults {
            if defaults.object(forKey: "userIDForAuth") == nil {
                DispatchQueue.main.async {
                    let signInViewController = SignInViewController()
                    signInViewController.modalPresentationStyle = .fullScreen
                    Vibration.shared.lightV()
                    
                    // Present the GroundViewController from the current view controller
                    self.present(signInViewController, animated: true, completion: nil)
                }
            }
        }
    }
    func switchToMemories() {
        let pageNumber = 0
        let scrollViewWidth = scrollView.bounds.width
        let contentOffset = CGPoint(x: scrollViewWidth * CGFloat(pageNumber), y: 0)
        scrollView.setContentOffset(contentOffset, animated: true)
    }
    
    func switchToMain() {
        let pageNumber = 1
        let scrollViewWidth = scrollView.bounds.width
        let contentOffset = CGPoint(x: scrollViewWidth * CGFloat(pageNumber), y: 0)
        scrollView.setContentOffset(contentOffset, animated: true)
    }
    
    func switchToSetting() {
        let pageNumber = 2
        let scrollViewWidth = scrollView.bounds.width
        let contentOffset = CGPoint(x: scrollViewWidth * CGFloat(pageNumber), y: 0)
        scrollView.setContentOffset(contentOffset, animated: true)
    }
}

extension GroundViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 鎖住垂直滾動，將 y 軸偏移量設為 0
        scrollView.contentOffset.y = 0
    }
}

extension GroundViewController: MainViewControllerDelegate {
    func didPressSettingBtn(_ viewController: MainViewController) {
        switchToSetting()
    }
    
    func didPressMemoriesBtn(_ viewController: MainViewController) {
        switchToMemories()
    }
    
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

extension GroundViewController: MemoriesViewControllerDelegate {
    func didPressBackBtn(_ viewController: MemoriesViewController) {
        switchToMain()
    }
}

extension GroundViewController: SettingViewControllerDelegate {
    func didPressSettingViewBackBtn(_ viewController: SettingViewController) {
        switchToMain()
    }
}
