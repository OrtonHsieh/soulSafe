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
    lazy var locationManager = CLLocationManager()
    lazy var regionInMeter: Double = 5000
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
    
    // 這邊每當 didUpdateLocations 觸發五次時就 post 一次位置至 FireStore
    lazy var updateCount = 0
    lazy var viewModel = MapViewModel()
    
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
    
    private func registerCell() {
        mapCollectionView.register(MapCollectionViewCell.self, forCellWithReuseIdentifier: "MapCollectionViewCell")
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
        viewModel.fetchGroupLocations(
            selectedGroupIDInMapView: selectedGroupIDInMapView
        ) { [weak self] result in
            guard let self = self else { return }
            self.groupLocations = result
            self.addAnnotationForGroupLocations()
        }
    }
    
    private func addAnnotationForGroupLocations() {
        guard let maxIndex = self.groupLocations["\(self.selectedGroupIDInMapView)"]?.count else { return }
        viewModel.addAnnotationForGroupLocations(
            maxIndex: maxIndex,
            groupLocations: groupLocations,
            selectedGroupIDInMapView: selectedGroupIDInMapView
        ) { [weak self] annotations in
            guard let self = self else { return }
            for annotation in annotations {
                self.mapView.map.addAnnotation(annotation)
            }
        }
    }
    
    func resetAnnotationView(_ annotationView: MKAnnotationView) {
        // Remove all subviews from the annotation view
        for subview in annotationView.subviews {
            subview.removeFromSuperview()
        }
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
