//
//  MapViewController + CollectionView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/8.
//

import UIKit

extension MapViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        // 如果是三個 item 則 1/3 如果是兩個則 1/2 如果是一個則 1
        var widthForItem = Double()
        var widthForGroup = Double()
        if groupTitles.isEmpty {
            widthForItem = 0
            widthForGroup = 0
        } else if groupTitles.count == 1 {
            widthForItem = 1
            widthForGroup = 0.6
        } else if groupTitles.count == 2 {
            widthForItem = 1 / 2
            widthForGroup = 1.2
        } else {
            widthForItem = 1 / 3
            widthForGroup = 1.8
        }
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(widthForItem),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10) // Add content insets
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(widthForGroup),
            heightDimension: .absolute(68)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func updateCollectionViewLayout() {
        // Invalidate the layout to trigger a redraw
        mapCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        groupIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MapCollectionViewCell",
            for: indexPath) as? MapCollectionViewCell else {
            fatalError("map cell cannot be created.")
        }
        // Configure the custom cell's properties or UI elements as needed
        if indexPath.row == 0 {
            cell.layer.borderWidth = 1
        }
        cell.layer.borderColor = UIColor(hex: CIC.shared.F2).cgColor
        cell.layer.cornerRadius = 14
        cell.groupTitleLabel.text = groupTitles[indexPath.row]
        return cell
    }
}

extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Deselect all cells to reset their appearance
        for visibleIndexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: visibleIndexPath) {
                cell.layer.borderWidth = 0
            }
        }
        
        // Select the tapped cell and update its appearance
        if let selectedCell = collectionView.cellForItem(at: indexPath) {
            selectedCell.layer.borderWidth = 1
        }
        
        Vibration.shared.hardV()
        selectedGroupIDInMapView = groupIDs[indexPath.row]
        selectedGroupTitleInMapView = groupTitles[indexPath.row]
        getAnnotationLocations()
        // 這邊到時候要重新顯示在該群組的人於地圖上
        print(selectedGroupIDInMapView)
        print(selectedGroupTitleInMapView)
    }
}
