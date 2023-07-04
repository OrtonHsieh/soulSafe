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
    lazy var mapCollectionView = UICollectionView()
    lazy var groupTitles: [String] = [] {
        didSet {
            if isInitialized {
                mapCollectionView.reloadData()
            } else {
                return
            }
        }
    }
    lazy var groupIDs: [String] = []
    lazy var isInitialized = false
    lazy var mapView = MapView()
    private lazy var locationManager = CLLocationManager()
    private lazy var regionInMeter: Double = 5000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupLocationManager()
        setupCollectionView()
        setupLayout()
        registerCell()
    }
    
    private func setupView() {
        view.addSubview(mapView)
        mapView.map.delegate = self
        mapView.map.overrideUserInterfaceStyle = .dark
        mapView.map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "custom")
        mapView.delegate = self
    }
    
    private func setupConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
    
    private func checkLocationAuthorization() {
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
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    private func setupCollectionView() {
        let collectionViewFrame = CGRect(
            x: 0,
            y: view.bounds.height - 200,
            width: view.bounds.width,
            height: 200) // Adjust the frame to fit the screen width
        let layout = createLayout()
        layout.configuration.scrollDirection = .horizontal // Set the scroll direction to horizontal
        mapCollectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        mapCollectionView.dataSource = self // Set the data source delegate
        mapCollectionView.backgroundColor = .clear
        mapCollectionView.alwaysBounceVertical = false
        mapCollectionView.showsHorizontalScrollIndicator = false
        view.addSubview(mapCollectionView)
    }
    
    private func setupLayout() {
        mapCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            mapCollectionView.heightAnchor.constraint(equalToConstant: 68)
        ])
    }
    
    private func registerCell() {
        mapCollectionView.register(MapCollectionViewCell.self, forCellWithReuseIdentifier: "MapCollectionViewCell")
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        // 如果是三個 item 則 1/3 如果是兩個則 1/2 如果是一個則 1
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.33),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10) // Add content insets
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.8), heightDimension: .absolute(68))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
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
        let center = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude)
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
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(hex: CIC.shared.F2).cgColor
        cell.layer.cornerRadius = 14
        cell.groupTitleLabel.text = groupTitles[indexPath.row]
        return cell
    }
}

extension MapViewController: UICollectionViewDelegate {
    // Add delegate methods as needed
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
