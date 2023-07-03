//
//  MapViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/3.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    lazy var mapView = MapView()
    lazy var locationManager = CLLocationManager()
    lazy var regionInMeter: Double = 5000
    var userAnnotationView: MKAnnotationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupLocationManager()
    }
    
    func setupView() {
        view.addSubview(mapView)
        mapView.map.delegate = self
        mapView.map.overrideUserInterfaceStyle = .dark
        mapView.map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "custom")
        mapView.delegate = self
    }
    
    func setupConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
            mapView.map.setRegion(region, animated: true)
        }
    }
    
    private func addAndUpdateCustomPin(_ coordinate: CLLocationCoordinate2D) {
        if let existingAnnotation = mapView.map.annotations.first(where: { $0.title == "Pokemon Here" }) {
            // Update the existing annotation
            mapView.map.removeAnnotation(existingAnnotation)
        }
        
        let annotation = MKPointAnnotation()
        annotation.title = "Pokemon Here"
        annotation.subtitle = "Go and catch them all"
        annotation.coordinate = coordinate
        
        mapView.map.addAnnotation(annotation)
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
        case .denied:
            // Show alert instruction them how to turn on permissions
            // if user turn off location device wide, it call back denied
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            // Do stuff here
//            locationManager.startUpdatingLocation()
            break
        @unknown default:
            break
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            // Create View
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
        } else {
            // Assign annotation
            annotationView?.annotation = annotation
        }
        
        // Set image
        switch annotation.title {
        case "Pokemon Here":
            let image: UIImage = {
                if let originalImage = UIImage(named: "\(UserSetup.userImage)") {
                    let scaledImage = originalImage.resizedImage(with: CGSize(width: 50, height: 50))
                    return scaledImage
                } else {
                    // Provide a default image here
                    return UIImage(named: "DefaultImage") ?? UIImage()
                }
            }()
            annotationView?.image = image
        default:
            break
        }
        
        return annotationView
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
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        addAndUpdateCustomPin(center)
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

extension UIImage {
    func resizedImage(with size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return resizedImage
    }
}
