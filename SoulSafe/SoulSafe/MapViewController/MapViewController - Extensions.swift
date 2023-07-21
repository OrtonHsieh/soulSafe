//
//  MapViewController - Extensions.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/21.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import Kingfisher

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let friendsAnnotation = annotation as? FriendsAnnotation {
            return configureFriendsAnnotationView(for: friendsAnnotation, mapView: mapView)
        } else {
            return configureCustomAnnotationView(for: annotation, mapView: mapView)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        Vibration.shared.lightV()
        // Check if the annotation is of the desired type, if necessary
        if let annotation = view.annotation {
            if selectedGroupIDInMapView.isEmpty {
                selectedGroupIDInMapView = groupIDs[0]
                selectedGroupTitleInMapView = groupTitles[0]
                // 這邊 filter 出特定的 Group
            }
            // Instantiate the view controller you want to display
            let chatRoom = ChatRoomViewController()
            chatRoom.modalPresentationStyle = .fullScreen
            chatRoom.groupID = selectedGroupIDInMapView
            chatRoom.groupTitle = selectedGroupTitleInMapView
            
            // Set any necessary properties or data on the chatRoom view controller
            // Present the view controller from the current view controller
            present(chatRoom, animated: true, completion: nil)
            
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
}

extension MapViewController: MapViewDelegate {
    func didPressCloseBtnOfMapView(_ view: MapView) {
        Vibration.shared.lightV()
        dismiss(animated: true)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 這邊是當取用的位置偵測到使用者更新位置時會執行的 code
        // 也就是說自己會看到最精準的自己，但別人會因為上傳至 FireStore 的時間不同而有所差異
        // 這邊如果執行的話會一直跑回預設的位置有點 bothering
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude)
        addAndUpdateCustomPin(center)

        numberOfPostCounts += 1
        if numberOfPostCounts == 10 {
            // 將使用者名稱、ID、位置、頭貼上傳
            guard let userAvatar = UserDefaults.standard.object(forKey: "userAvatar") else { return }
            for groupID in self.groupIDs {
                let latitude = String(location.coordinate.latitude)
                let longitude = String(location.coordinate.longitude)
                let userLocation: [String] = [latitude, longitude]
                let pathToGroupMemberLocation = self.db.collection("groups").document(groupID).collection("locations").document(UserSetup.userID)
                let location = Location(
                    id: pathToGroupMemberLocation.documentID,
                    groupID: groupID,
                    userID: UserSetup.userID,
                    userName: UserSetup.userName,
                    userLocation: userLocation,
                    userAvatar: "\(userAvatar)",
                    lastUpdate: Timestamp(date: Date())).toDict
                pathToGroupMemberLocation.setData(location, merge: true) { error in
                    if let error = error {
                        print(error)
                    } else {
                        print("successfully overwriten location")
                    }
                }
            }
            getAnnotationLocations()
            print("Friends' location updated")
            numberOfPostCounts = 0
            print("numberOfPostCounts has been reset.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // come back later
        // Could be precise or not after iOS 14+
        checkLocationAuthorization()
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
