//
//  MemoriesViewController - Extension.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/2.
//

import UIKit
import FirebaseFirestore

extension MemoriesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = 3
        let spacing: CGFloat = 1
        let totalSpacing = (numberOfColumns - 1) * spacing
        let width = (collectionView.bounds.width - totalSpacing) / numberOfColumns
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        if !selectedGroup.isEmpty {
            // 因為 selectedGroup 有值，代表使用者有點選某個群組
            if let groupPost = groupPostDict["\(selectedGroup)"] as? [[Any]] {
                if let postIDs = groupPost[0] as? [String],
                   let postURLs = groupPost[1] as? [String],
                   let timeStamps = groupPost[2] as? [Timestamp],
                   let groupIDArrays = groupPost[3] as? [[String]],
                   let groupTitleArrays = groupPost[4] as? [[String]] {
                    let url = URL(string: postURLs[indexPath.row])
                    // 這邊 + 1 是因為 0 會是 array 的 title
                    presentPostViewController(
                        postURLs[indexPath.row],
                        postID: postIDs[indexPath.row],
                        groupIDArray: groupIDArrays[indexPath.row + 1],
                        groupTitleArray: groupTitleArrays[indexPath.row + 1])
                } else {
                    print("Failed to cast from groupPost property")
                }
            } else {
                print("Failed to extract a group from groupDict")
            }
        } else {
            // 這邊執行在個人區塊選取照片時跳出畫面所使用的 func, 應該要拿該 PostID 去 Group 撈 Comments
            let postID = postIDs[indexPath.row]
            let imageURL = imageURLs[indexPath.row]
            let groupIDArray = groupIDArrays[indexPath.row]
            let groupTitleArray = groupTitleArrays[indexPath.row]
            presentPostViewController(imageURL, postID: postID, groupIDArray: groupIDArray, groupTitleArray: groupTitleArray)
        }
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
        showGroupList(groupTitles)
    }
    
    func didPressBackBtn(_ view: MemoriesView) {
        delegate?.didPressBackBtn(self)
    }
}
