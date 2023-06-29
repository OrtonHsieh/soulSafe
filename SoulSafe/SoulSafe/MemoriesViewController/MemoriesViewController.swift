//
//  MemoriesViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/15.
//

import UIKit
import Kingfisher
import FirebaseFirestore

class MemoriesViewController: UIViewController {
    let galleryCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let memoriesView = MemoriesView()
    var imageURLs: [String] = []
    var groupIDs: [String] = [] {
        didSet {
            // 這邊要用這些 GroupID 去重新監聽所有的 Group 相片集
            getGroupsPosts()
        }
    }
    var groupTitles: [String] = []
    var groupPostDict: [String: [Any]] = [:]
    var listener: ListenerRegistration?
    var selectedGroup = String()
    // 這邊要在於 ActionSheet 點擊時將該 GroupID 存入用來作為 reloadData 的依據
    var postIDs: [String] = []
    var dates: [String] = []
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
            memoriesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: constant),
            memoriesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            memoriesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            memoriesView.heightAnchor.constraint(equalToConstant: constant),
            
            galleryCollection.topAnchor.constraint(equalTo: memoriesView.bottomAnchor),
            galleryCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            galleryCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            galleryCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func presentPostViewController(_ imageURL: String, postID: String) {
        let postVC = PostViewController()
        postVC.modalPresentationStyle = .formSheet
        let url = URL(string: imageURL)
        postVC.imageView.kf.setImage(with: url)
        postVC.currentPostID = postID
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
        let docRef = db.collection("testingUploadImg").document("\(UserSetup.userID)").collection("posts")
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
                    
                let dateInFormate = CusDateFormatter.shared.formatDate(timeStamp: date)
                
                if index <= self.imageURLs.count - 1 {
                    self.imageURLs[index] = imageURL
                    self.postIDs[index] = postID
                    self.dates[index] = dateInFormate
                } else {
                    self.imageURLs.append(imageURL)
                    self.postIDs.append(postID)
                    self.dates.append(dateInFormate)
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
                
                for document in documents {
                    let data = document.data()
                    guard let postID = data["postID"] as? String else { return }
                    guard let postImgURL = data["postImgURL"] as? String else { return }
                    guard let timeStamp = data["timeStamp"] as? Timestamp else { return }
                    
                    postIDs.append(postID)
                    postImgURLs.append(postImgURL)
                    timeStamps.append(timeStamp)
                }
                
                self.groupPostDict["\(groupID)"] = [postIDs, postImgURLs, timeStamps]
                // 確定拿到資料，要 reloadData
            }
        }
    }
}

extension MemoriesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = 3
        let spacing: CGFloat = 1
        let totalSpacing = (numberOfColumns - 1) * spacing
        let width = (collectionView.bounds.width - totalSpacing) / numberOfColumns
        let height = (width / 325) * 404
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        presentPostViewController(imageURLs[indexPath.row], postID: postIDs[indexPath.row])
    }
}

extension MemoriesViewController: UIAdaptivePresentationControllerDelegate {
    // 可选的委托方法，用于自定义表单的交互和动画等
    // 在这里可以实现 presentationControllerDidDismiss 方法，用于在表单被关闭时执行一些操作
}

extension MemoriesViewController: UISheetPresentationControllerDelegate {
}

extension MemoriesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.4) {
            cell.alpha = 1
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MemoriesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !selectedGroup.isEmpty {
            
            if let groupPost = groupPostDict["\(selectedGroup)"] as? [[Any]] {
                if let postID = groupPost[0] as? [String] {
                    return postID.count
                } else {
                    print("Failed to caculate postID count")
                }
            } else {
                print("Failed to get groupPost's value count")
            }
            
            
        } else {
            return imageURLs.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MemoriesCVI",
            for: indexPath) as? MemoriesCVI else {
            fatalError("Could not create Cell")
        }
        // 設置圖片呈現方式
        cell.memoryImgView.contentMode = .scaleAspectFill
        cell.memoryImgView.clipsToBounds = true
        // 設置圓角
        cell.memoryImgView.layer.cornerRadius = 30
        
        if !selectedGroup.isEmpty {
            if let groupPost = groupPostDict["\(selectedGroup)"] as? [[Any]] {
                if let postIDs = groupPost[0] as? [String],
                   let postURLs = groupPost[1] as? [String],
                   let timeStamps = groupPost[2] as? [Timestamp] {
                        let url = URL(string: postURLs[indexPath.row])
                        cell.memoryImgView.kf.setImage(with: url)
                } else {
                    print("Failed to cast from groupPost property")
                }
            } else {
                print("Failed to extract a group from groupDict")
            }
        } else {
            // 帶入圖片資料GroupSelectionTableViewCell
            let url = URL(string: imageURLs[indexPath.row])
            cell.memoryImgView.kf.setImage(with: url)
        }
        return cell
    }
}

extension MemoriesViewController: MemoriesViewDelegate {
    func didPressGroupSelector(_ view: MemoriesView) {
        print("選擇查看的群組")
        showGroupList(groupTitles)
    }
}
