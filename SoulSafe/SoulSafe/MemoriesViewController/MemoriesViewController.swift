//
//  MemoriesViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/15.
//

import UIKit
import Kingfisher
import FirebaseFirestore

protocol MemoriesViewControllerDelegate: AnyObject {
    func didPressBackBtn(_ viewController: MemoriesViewController)
}

class MemoriesViewController: UIViewController {
    weak var delegate: MemoriesViewControllerDelegate?
    let galleryCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let memoriesView = MemoriesView()
    var imageURLs: [String] = []
    // 這個 groupIDs 是指說該使用者目前所加入的群組
    var groupIDs: [String] = [] {
        didSet {
            // 這邊要用這些 GroupID 去重新監聽所有的 Group 相片集
            getGroupsPosts()
        }
    }
    var groupTitles: [String] = []
    var groupPostDict: [String: [Any]] = [:]
    var listener: ListenerRegistration?
    // 這邊要在於 ActionSheet 點擊時將該 GroupID 存入用來作為 reloadData 的依據
    var selectedGroup = String()
    var selectedGroupTitle = String()
    var postIDs: [String] = []
    var dates: [String] = []
    // 這邊 groupArray 記錄該貼文發給了哪些群組
    var groupIDArrays: [[String]] = []
    var groupTitleArrays: [[String]] = []
    var ifGroupViewTextIsMyPost = true
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        setupView()
        setupConstraints()
        getNewGalleryPics()
        getGroupsPosts()
    }
    
    override func viewDidLayoutSubviews() {
        galleryCollection.layer.cornerRadius = 28
    }
    
    deinit {
        listener?.remove()
    }
    
    func setupView() {
        galleryCollection.delegate = self
        galleryCollection.dataSource = self
        galleryCollection.register(MemoriesCVI.self, forCellWithReuseIdentifier: "MemoriesCVI")
        galleryCollection.backgroundColor = UIColor(hex: CIC.shared.M1)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        galleryCollection.bounces = false
        galleryCollection.collectionViewLayout = layout
        galleryCollection.decelerationRate = UIScrollView.DecelerationRate.fast
        galleryCollection.layer.borderWidth = 1
        galleryCollection.layer.borderColor = UIColor(hex: CIC.shared.F2).cgColor
        
        memoriesView.delegate = self
        
        [galleryCollection, memoriesView].forEach { view.addSubview($0) }
    }
    
    func setupConstraints() {
        [galleryCollection, memoriesView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        let constant: CGFloat = 60
        NSLayoutConstraint.activate([
            memoriesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            memoriesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            memoriesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            memoriesView.heightAnchor.constraint(equalToConstant: constant),
            
            galleryCollection.topAnchor.constraint(equalTo: memoriesView.bottomAnchor),
            galleryCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            galleryCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            galleryCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func presentPostViewController(_ imageURL: String, postID: String, groupIDArray: [String], groupTitleArray: [String]) {
        let postVC = PostViewController()
        postVC.modalPresentationStyle = .formSheet
        let url = URL(string: imageURL)
        postVC.imageView.kf.setImage(with: url)
        postVC.currentPostID = postID
        // 這邊目前 Post 點進去時會是上一張照片
        postVC.selectedGroup = selectedGroup
        postVC.selectedGroupTitle = selectedGroupTitle
        postVC.selectedGroupInPostVC = selectedGroup
        postVC.groupIDArray = groupIDArray
        postVC.groupTitleArray = groupTitleArray
        Vibration.shared.lightV()
        present(postVC, animated: true)
        
        if let sheetPC = postVC.sheetPresentationController {
            sheetPC.detents = [.large()]
            sheetPC.prefersGrabberVisible = true
            sheetPC.delegate = self
            sheetPC.preferredCornerRadius = 20
        }
    }
    
    func getNewGalleryPics() {
        let docRef = db.collection("users").document("\(UserSetup.userID)").collection("posts")
        docRef.order(by: "timeStamp", descending: true).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching collection: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents in collection")
                return
            }
            
            var index = 0
            
            for document in documents {
                let data = document.data()
                guard let imageURL = data["postImgURL"] as? String else { return }
                guard let postID = data["postID"] as? String else { return }
                guard let date = data["timeStamp"] as? Timestamp else { return }
                guard let groupIDArray = data["shareGroupList"] as? [String] else { return }
                guard let groupTitleArray = data["groupTitleArray"] as? [String] else { return }
                
                let dateInFormate = CusDateFormatter.shared.formatDate(timeStamp: date)
                
                if index <= self.imageURLs.count - 1 {
                    self.imageURLs[index] = imageURL
                    self.postIDs[index] = postID
                    self.dates[index] = dateInFormate
                    self.groupIDArrays[index] = groupIDArray
                    self.groupTitleArrays[index] = groupTitleArray
                } else {
                    self.imageURLs.append(imageURL)
                    self.postIDs.append(postID)
                    self.dates.append(dateInFormate)
                    self.groupIDArrays.append(groupIDArray)
                    self.groupTitleArrays.append(groupTitleArray)
                }
                index += 1
            }
            self.galleryCollection.reloadData()
        }
    }
    
    func getGroupsPosts() {
        groupPostDict.removeAll()
        
        for groupID in groupIDs {
            let groupPostPath = db.collection("groups").document("\(groupID)").collection("posts").order(by: "timeStamp", descending: true)
            
            listener = groupPostPath.addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching collection: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents in collection")
                    return
                }
                
                var postIDs: [String] = []
                var postImgURLs: [String] = []
                var timeStamps: [Timestamp] = []
                var shareGroupLists: [[String]] = [[]]
                var groupTitleArrays: [[String]] = [[]]
                
                for document in documents {
                    let data = document.data()
                    guard let postID = data["postID"] as? String else { return }
                    guard let postImgURL = data["postImgURL"] as? String else { return }
                    guard let timeStamp = data["timeStamp"] as? Timestamp else { return }
                    guard let shareGroupList = data["shareGroupList"] as? [String] else { return }
                    guard let groupTitleArray = data["groupTitleArray"] as? [String] else { return }
                    
                    postIDs.append(postID)
                    postImgURLs.append(postImgURL)
                    timeStamps.append(timeStamp)
                    shareGroupLists.append(shareGroupList)
                    groupTitleArrays.append(groupTitleArray)
                    
                    
                    self.groupPostDict["\(groupID)"] = [
                        postIDs,
                        postImgURLs,
                        timeStamps,
                        shareGroupLists,
                        groupTitleArrays
                    ]
                    // 確定拿到資料，要 reloadData
                }
            }
        }
    }
}
