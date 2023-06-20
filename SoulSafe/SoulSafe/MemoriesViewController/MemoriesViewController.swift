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
    var postIDs: [String] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        setupView()
        setupConstraints()
        getNewGalleryPics()
    }
    
    func setupView() {
        galleryCollection.delegate = self
        galleryCollection.dataSource = self
        galleryCollection.register(MemoriesCVI.self, forCellWithReuseIdentifier: "MemoriesCVI")
        galleryCollection.backgroundColor = UIColor(hex: CIC.shared.M1)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        galleryCollection.collectionViewLayout = layout
        
        [galleryCollection, memoriesView].forEach { view.addSubview($0) }
    }
    
    func setupConstraints() {
        [galleryCollection, memoriesView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        let constant: CGFloat = 60
        NSLayoutConstraint.activate([
            memoriesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: constant),
            memoriesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -constant / 3),
            
            galleryCollection.topAnchor.constraint(equalTo: view.topAnchor, constant: constant * 1.8),
            galleryCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            galleryCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            galleryCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func presentPostViewController(_ imageURL: String) {
        let postVC = PostViewController()
        postVC.modalPresentationStyle = .formSheet
        let url = URL(string: imageURL)
        postVC.imageView.kf.setImage(with: url)
        Vibration.shared.lightV()
        present(postVC, animated: true)
        
        if let sheetPC = postVC.sheetPresentationController {
            sheetPC.detents = [.large()]
            sheetPC.prefersGrabberVisible = true
            sheetPC.delegate = self
            sheetPC.preferredCornerRadius = 20
        }
    }
    
    func getGalleryPics() {
        let docRef = db.collection("testingUploadImg").document("userIDOrton").collection("posts")
        docRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching collection: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents in collection")
                return
            }
            
            for document in documents {
                let data = document.data()
                guard let imageURL = data["postImgURL"] as? String else { return }
                guard let postID = data["postID"] as? String else { return }
                
                self.imageURLs.append(imageURL)
                self.postIDs.append(postID)
            }
            self.galleryCollection.reloadData()
        }
    }
    
    func getNewGalleryPics() {
        let docRef = db.collection("testingUploadImg").document("userIDOrton").collection("posts")
        docRef.addSnapshotListener { querySnapshot, error in
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
                    
                if index <= self.imageURLs.count - 1 {
                    self.imageURLs[index] = imageURL
                    self.postIDs[index] = postID
                } else {
                    self.imageURLs.append(imageURL)
                    self.postIDs.append(postID)
                }
                index += 1
            }
            self.galleryCollection.reloadData()
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
        presentPostViewController(imageURLs[indexPath.row])
    }
}

extension MemoriesViewController: UIAdaptivePresentationControllerDelegate {
    // 可选的委托方法，用于自定义表单的交互和动画等
    // 在这里可以实现 presentationControllerDidDismiss 方法，用于在表单被关闭时执行一些操作
}

extension MemoriesViewController: UISheetPresentationControllerDelegate{
}

extension MemoriesViewController: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDataSource
extension MemoriesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageURLs.count
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
        // 設置光暈
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor(red: 24 / 255, green: 183 / 255, blue: 231 / 255, alpha: 0.4).cgColor
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 80
        cell.layer.shadowOffset = CGSize(width: 0, height: 150)
        // 帶入圖片資料
        let url = URL(string: imageURLs[indexPath.row])
        cell.memoryImgView.kf.setImage(with: url)
        return cell
    }
}
