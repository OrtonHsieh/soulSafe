//
//  MapViewController - Extensions.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/21.
//

import UIKit
import MapKit
import CoreLocation

extension MapViewController {
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
        case .denied:
            // Show alert instruction them how to turn on permissions
            // if user turn off location device wide, it call back denied
            locationManager.requestAlwaysAuthorization()
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            // Do stuff here
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    private func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(
                center: location,
                latitudinalMeters: regionInMeter,
                longitudinalMeters: regionInMeter)
            mapView.map.setRegion(region, animated: true)
        }
    }
    
    func setupUpdateTime(annotationView: FriendsAnnotationView, annotation: FriendsAnnotation) {
        let lastUpdateInString = CusDateFormatter.shared.calculateHoursPassed(from: annotation.lastUpdate)
        let subviewTitle = UILabel()
        subviewTitle.text = "\(lastUpdateInString)"
        subviewTitle.font = UIFont.systemFont(ofSize: 14)
        subviewTitle.textAlignment = .center
        annotationView.addSubview(subviewTitle)
        if lastUpdateInString.contains("0 分鐘前更新") && lastUpdateInString.first == "0" {
            subviewTitle.frame = CGRect(x: -26, y: -30, width: 100, height: 20)
        } else {
            subviewTitle.frame = CGRect(x: -56, y: -30, width: 160, height: 20)
        }
        subviewTitle.layer.cornerRadius = 4
        subviewTitle.clipsToBounds = true
        subviewTitle.layer.masksToBounds = true
        subviewTitle.textColor = UIColor(hex: CIC.shared.F1)
        subviewTitle.backgroundColor = UIColor(hex: CIC.shared.M2)
    }
}

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
            self.viewModel.uploadUserLocation(groupIDs: groupIDs, location: location) { [weak self] result in
                guard let self = self else { return }
                if result == true {
                    self.getAnnotationLocations()
                    self.numberOfPostCounts = 0
                } else {
                    print("Failed to upload user location.")
                }
            }
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
