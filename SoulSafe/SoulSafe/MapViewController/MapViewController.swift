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
import Kingfisher

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
    // 這邊計算 Post 自己位置的次數，控制打幾次時更新一次其他人的位置，先設定三次
    var numberOfPostCounts = 0
    
    // 將整包資料抓回來
    var groupLocations: [String: [Location]] = [:]
    // 將整包資料抓回來分成單一實體，專門用於 getAnnotationLocations 位置取得後暫存資料以利提供給 AnnotationView Delegate 使用的實體
    var singleGroupLocation: [Location] = []
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
        
        // 先 Default 將選擇的 Group 設定為第一個，並且顯示該群裡的人
        selectedGroupIDInMapView = groupIDs[0]
        selectedGroupTitleInMapView = groupTitles[0]
        
        setupView()
        setupConstraints()
        setupLocationManager()
        setupCollectionView()
        setupLayout()
        registerCell()
        getAnnotationLocations()
    }
    
    private func setupView() {
        view.addSubview(mapView)
        mapView.map.delegate = self
        mapView.map.overrideUserInterfaceStyle = .dark
        mapView.map.register(UserAnnotationView.self, forAnnotationViewWithReuseIdentifier: "UserAnnotationView")
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
    
    func addAndUpdateCustomPin(_ coordinate: CLLocationCoordinate2D) {
        if let existingAnnotation = existingAnnotation {
            // Update the coordinates of the existing annotation
            UIViewPropertyAnimator(duration: 2, curve: .easeInOut) {
                existingAnnotation.coordinate = coordinate
            }.startAnimation()
        } else {
            // Create a new annotation
            let annotation = UserAnnotation()
            annotation.title = "User"
            annotation.coordinate = coordinate
            
            mapView.map.addAnnotation(annotation)
            existingAnnotation = annotation
        }
    }
    
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
    
    private func removeExistingAnnoations() {
        var annotations: [MKAnnotation] = []
        for annotation in mapView.map.annotations where annotation is FriendsAnnotation {
            annotations.append(annotation)
        }
        
        UIView.transition(with: mapView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.mapView.map.removeAnnotations(annotations)
        }, completion: nil)
    }
    
    func getAnnotationLocations() {
        // 把原本的 annotation 移除
        removeExistingAnnoations()
        // 這邊去抓資料
        fetchGroupLocations()
    }
    
    private func fetchGroupLocations() {
        let pathToGroupLocationCollection = db.collection("groups").document(selectedGroupIDInMapView).collection("locations")
        pathToGroupLocationCollection.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                guard let snapshot = snapshot else { return }
                var memberLocationFromSingleGroup: [Location] = []
                for document in snapshot.documents {
                    let locationData = document.data()
                    let oneUserFromSingleGroupLocation = Location(
                        id: locationData["id"] as? String ?? "",
                        groupID: locationData["groupID"] as? String ?? "",
                        userID: locationData["userID"] as? String ?? "",
                        userName: locationData["userName"] as? String ?? "",
                        userLocation: locationData["userLocation"] as? [String] ?? [],
                        // 這邊會拿到 URL
                        userAvatar: locationData["userAvatar"] as? String ?? "",
                        lastUpdate: locationData["lastUpdate"] as? Timestamp ?? Timestamp(date: Date())
                    )
                    memberLocationFromSingleGroup.append(oneUserFromSingleGroupLocation)
                    // 將每個 groupID 裡面的成員位置存入 Dict，可以用 groupID 來取用該群組內成員的位置
                    self.groupLocations["\(self.selectedGroupIDInMapView)"] = memberLocationFromSingleGroup
                    self.addAnnotationForGroupLocations()
                }
            }
        }
    }
    
    private func addAnnotationForGroupLocations() {
        guard let maxIndex = self.groupLocations["\(self.selectedGroupIDInMapView)"]?.count else { return }
        
        for index in 0..<maxIndex {
            guard let singleGroupLocation = self.groupLocations["\(self.selectedGroupIDInMapView)"] else { return }
            self.singleGroupLocation = singleGroupLocation
            let userLocationInString = singleGroupLocation[index].userLocation
            
            guard let latitude = Double(userLocationInString[0]) else { return }
            guard let longitude = Double(userLocationInString[1]) else { return }
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let coordinate = location.coordinate
            
            let annotation = FriendsAnnotation(
                userID: singleGroupLocation[index].userID,
                groupID: singleGroupLocation[index].groupID,
                userName: singleGroupLocation[index].userName,
                userAvatar: singleGroupLocation[index].userAvatar,
                coordinate: coordinate,
                lastUpdate: singleGroupLocation[index].lastUpdate
            )
            self.mapView.map.addAnnotation(annotation)
        }
    }
    
    func resetAnnotationView(_ annotationView: MKAnnotationView) {
        // Remove all subviews from the annotation view
        for subview in annotationView.subviews {
            subview.removeFromSuperview()
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
    
    func configureFriendsAnnotationView(for annotation: FriendsAnnotation, mapView: MKMapView) -> MKAnnotationView {
        let friendAnnotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: "FriendsAnnotationView"
        ) as? FriendsAnnotationView ?? FriendsAnnotationView(
            annotation: annotation,
            reuseIdentifier: "FriendsAnnotationView"
        )
        
        resetAnnotationView(friendAnnotationView)
        
        if annotation.userID == UserSetup.userID {
            friendAnnotationView.isHidden = true
        } else {
            if let originalImage = UIImage(named: annotation.userAvatar) {
                let resizedImage = originalImage.resizedImage(with: CGSize(width: 50, height: 50))
                friendAnnotationView.image = resizedImage
                setupUpdateTime(annotationView: friendAnnotationView, annotation: annotation)
            } else if let imageUrl = URL(string: annotation.userAvatar) {
                KingfisherManager.shared.retrieveImage(with: imageUrl) { result in
                    switch result {
                    case .success(let value):
                        let img = value.image.resizedImage(with: CGSize(width: 50, height: 50))
                        friendAnnotationView.backgroundColor = .clear
                        friendAnnotationView.layer.backgroundColor = UIColor.clear.cgColor
                        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                        imgView.image = img
                        imgView.layer.cornerRadius = 25
                        imgView.clipsToBounds = true
                        imgView.layer.masksToBounds = true
                        imgView.contentMode = .scaleAspectFill
                        friendAnnotationView.addSubview(imgView)
                        self.setupUpdateTime(annotationView: friendAnnotationView, annotation: annotation)
                    case .failure(let error):
                        print("Failed to retrieve image: \(error)")
                    }
                }
            }
        }
        return friendAnnotationView
    }
    
    func configureCustomAnnotationView(for annotation: MKAnnotation, mapView: MKMapView) -> UserAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: "UserAnnotationView"
        ) as? UserAnnotationView
        
        if annotationView == nil {
            annotationView = UserAnnotationView(annotation: annotation, reuseIdentifier: "UserAnnotationView")
        } else {
            annotationView?.annotation = annotation
        }
        
        switch annotation.title {
        case "User":
            let avatarImg = UserDefaults.standard.object(forKey: "userAvatar") as? String ?? "defaultAvatar"
            if avatarImg != "defaultAvatar", let imageUrl = URL(string: avatarImg) {
                KingfisherManager.shared.retrieveImage(with: imageUrl) { result in
                    switch result {
                    case .success(let value):
                        let img = value.image.resizedImage(with: CGSize(width: 50, height: 50))
                        annotationView?.image = img
                        annotationView?.layer.cornerRadius = 25
                        annotationView?.clipsToBounds = true
                        annotationView?.layer.masksToBounds = true
                        annotationView?.contentMode = .scaleAspectFill
                    case .failure(let error):
                        print("Failed to retrieve image: \(error)")
                    }
                }
            } else {
                let originalImage = UIImage(named: "\(UserSetup.userImage)")
                let imgCGSize = CGSize(width: 50, height: 50)
                let image = originalImage?.resizedImage(with: imgCGSize) ?? UIImage(named: "DefaultImage") ?? UIImage()
                annotationView?.image = image
            }
            annotationView?.isHidden = false
        default:
            break
        }
        return annotationView
    }
}
