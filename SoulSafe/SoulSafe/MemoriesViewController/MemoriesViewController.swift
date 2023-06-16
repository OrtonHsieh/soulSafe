//
//  MemoriesViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/15.
//

import UIKit

class MemoriesViewController: UIViewController {
    let galleryCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let memoriesView = MemoriesView()
//    let imgViewItem = MemoriesCVI()
    var images: [UIImage] = [UIImage(named: "fakePost")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        setupView()
        setupConstraints()
    }
    
//    override func viewDidLayoutSubviews() {
//        imgViewItem.memoryImgView.layer.masksToBounds = false
//        imgViewItem.memoryImgView.layer.shadowColor = UIColor(
//            red: 24 / 255, green: 183 / 255, blue: 231 / 255, alpha: 0.4
//        ).cgColor
//        imgViewItem.memoryImgView.layer.shadowOpacity = 1.0
//        imgViewItem.memoryImgView.layer.shadowRadius = 43
//        imgViewItem.memoryImgView.layer.shadowOffset = CGSize(width: 0, height: 0)
//    }
    
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
        let constant: CGFloat = 48
        NSLayoutConstraint.activate([
            memoriesView.topAnchor.constraint(equalTo: view.topAnchor, constant: constant),
            memoriesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -constant / 2),
            
            galleryCollection.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            galleryCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            galleryCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            galleryCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
}

extension MemoriesViewController: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDataSource
extension MemoriesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
      return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoriesCVI", for: indexPath) as? MemoriesCVI else {
            fatalError("Could not create Cell")
        }
        cell.memoryImgView.contentMode = .scaleAspectFill
        cell.memoryImgView.clipsToBounds = true
        cell.memoryImgView.layer.cornerRadius = 30
        cell.memoryImgView.image = images[indexPath.row]
        return cell
    }
}
