//
//  MapViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/3.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore

class MapViewController: UIViewController {
    lazy var mapCollectionView = UICollectionView()
    lazy var groupTitles: [String] = [] {
        didSet {
            // 這邊是要因應使用者可能會隨時新增或退出群組
            // 目前問題是如果使用者觸發更新群組數量，不會重算 Group 的寬度
            if isInitialized {
                updateCollectionViewLayout()
                mapCollectionView.reloadData()
            } else {
                return
            }
        }
    }
    // groupIDs 與 groupTitles 的數量要始終一起變動
    lazy var groupIDs: [String] = []
    lazy var isInitialized = false
    lazy var mapView = MapView()
    private lazy var locationManager = CLLocationManager()
    private lazy var regionInMeter: Double = 5000
    private var existingAnnotation: UserAnnotation?
    
    // 將整包資料抓回來
    var groupLocations: [String: Location] = [:]
    // 將整包資料抓回來分成單一實體
    var singleGroupLocation: Location?
    // 將位置資料抓回來所存放的地方
    var userLocationInCLLocation: [CLLocation] = []
    
    // 此二 property 是用來存取目前使用者在 map 所選擇的 groupID 以及 groupTitle 以利點擊頭像開啟群組對話時有依據
    // 此二一開始會被放入 groupIDs 與 groupTitles arrays 第一個值
    lazy var selectedGroupIDInMapView = String()
    lazy var selectedGroupTitleInMapView = String()
    
    lazy var db = Firestore.firestore()
    // 這邊每當 didUpdateLocations 觸發五次時就 post 一次位置至 FireStore
    lazy var updateCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupLocationManager()
        setupCollectionView()
        setupLayout()
        registerCell()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(annotationCoordinateUpdated(_:)),
            name: NSNotification.Name("AnnotationCoordinateUpdated"),
            object: nil
        )
    }
    
    private func setupView() {
        view.addSubview(mapView)
        mapView.map.delegate = self
        mapView.map.overrideUserInterfaceStyle = .dark
        mapView.map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "custom")
        mapView.map.register(FriendsAnnotationView.self, forAnnotationViewWithReuseIdentifier: "FriendsAnnotationView")
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
        if let existingAnnotation = existingAnnotation {
            // Update the coordinates of the existing annotation
            existingAnnotation.coordinate = coordinate
        } else {
            // Create a new annotation
            let annotation = UserAnnotation()
            annotation.title = "Pokemon Here"
            annotation.subtitle = "Go and catch them all"
            annotation.coordinate = coordinate
            
            mapView.map.addAnnotation(annotation)
            existingAnnotation = annotation
        }
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
            height: 200
        ) // Adjust the frame to fit the screen width
        let layout = createLayout()
        layout.configuration.scrollDirection = .horizontal // Set the scroll direction to horizontal
        mapCollectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        mapCollectionView.dataSource = self // Set the data source delegate
        mapCollectionView.delegate = self
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
    
    private func updateCollectionViewLayout() {
        // Invalidate the layout to trigger a redraw
        mapCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func registerCell() {
        mapCollectionView.register(MapCollectionViewCell.self, forCellWithReuseIdentifier: "MapCollectionViewCell")
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
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
    
    @objc private func annotationCoordinateUpdated(_ notification: Notification) {
        if let annotation = notification.object as? UserAnnotation {
            // Update the title and subtitle of the existing annotation
            annotation.title = "Pokemon Here"
            annotation.subtitle = "Go and catch them all"
        }
    }
    
    func getAnnotationLocations() {
        // 這邊去抓資料
        for groupID in groupIDs {
            let pathToGroupLocationCollection = db.collection("groups").document(groupID).collection("locations")
            pathToGroupLocationCollection.getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    guard let snapshot = snapshot else { return }
                    
                    for document in snapshot.documents {
                        let locationData = document.data()

                        self.singleGroupLocation = Location(
                            id: locationData["id"] as? String ?? "",
                            userID: locationData["userID"] as? String ?? "",
                            userName: locationData["userName"] as? String ?? "",
                            userLocation: locationData["userLocation"] as? [String] ?? [],
                            userAvatar: locationData["userAvatar"] as? String ?? "")
                    }
                    self.groupLocations["\(groupID)"] = self.singleGroupLocation
                    
                    print(self.singleGroupLocation!)
                    guard let userLocationInString = self.singleGroupLocation?.userLocation else { return }
                    
                    for locationString in userLocationInString {
                        if let latitude = Double(locationString.components(separatedBy: ",")[0]),
                           let longitude = Double(locationString.components(separatedBy: ",")[1]) {
                            let location = CLLocation(latitude: latitude, longitude: longitude)
                            self.userLocationInCLLocation.append(location)
                        }
                    }
                }
            }
        }
    }
    
    func updateAnnotationLocations() {
        // 這邊將抓回來的資料更新在畫面上
        for annotation in mapView.map.annotations {
            if let friendsAnnotation = annotation as? FriendsAnnotation {
                // 這邊要放抓回來資料的 locations
                if let index = userLocationInCLLocation.firstIndex(where: {
                    $0.coordinate.latitude == friendsAnnotation.coordinate.latitude && $0.coordinate.longitude == friendsAnnotation.coordinate.longitude
                }) {
                    let location = userLocationInCLLocation[index]
                    friendsAnnotation.coordinate = location.coordinate
                }
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is FriendsAnnotation {
            // 這邊實作其他人的 annotationView
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "FriendsAnnotationView")
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "FriendsAnnotationView")
                guard let singleGroupLocation = singleGroupLocation else { fatalError("error") }
                annotationView?.image = UIImage(named: "\(singleGroupLocation.userAvatar)")
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        } else {
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
                annotationView?.canShowCallout = true
            default:
                break
            }
            
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Check if the annotation is of the desired type, if necessary
        if let annotation = view.annotation {
            if selectedGroupIDInMapView.isEmpty {
                selectedGroupIDInMapView = groupIDs[0]
                selectedGroupTitleInMapView = groupTitles[0]
            }
            // Instantiate the view controller you want to display
            let chatRoom = ChatRoomViewController()
            chatRoom.modalPresentationStyle = .fullScreen
            chatRoom.groupID = selectedGroupIDInMapView
            chatRoom.groupTitle = selectedGroupTitleInMapView
            Vibration.shared.lightV()
            
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
        // 將使用者名稱、ID、位置、頭貼上傳
        for groupID in self.groupIDs {
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let userLocation: [String] = [latitude, longitude]
            let pathToGroupMemberLocation = self.db.collection("groups").document(groupID).collection("locations").document(UserSetup.userID)
            let location = Location(
                id: pathToGroupMemberLocation.documentID,
                userID: UserSetup.userID,
                userName: UserSetup.userName,
                userLocation: userLocation,
                userAvatar: UserSetup.userImage).toDict
            pathToGroupMemberLocation.setData(location, merge: true) { error in
                if let error = error {
                    print(error)
                } else {
                    print("successfully overwriten location")
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Vibration.shared.hardV()
        selectedGroupIDInMapView = groupIDs[indexPath.row]
        selectedGroupTitleInMapView = groupTitles[indexPath.row]
        // 這邊到時候要重新顯示在該群組的人於地圖上
        print(selectedGroupIDInMapView)
        print(selectedGroupTitleInMapView)
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