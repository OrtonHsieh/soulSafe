//
//  SettingViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/15.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import CropViewController
import Kingfisher

protocol SettingViewControllerDelegate: AnyObject {
    func didPressSettingViewBackBtn(_ viewController: SettingViewController)
}

class SettingViewController: UIViewController {
    weak var delegate: SettingViewControllerDelegate?
    let settingView = SettingView()
    let settingTableView = UITableView()
    let settingViewModel = SettingViewModel()
    var groupIDs: [String] = []
    
    var userAvatar = "" {
        didSet {
            if userAvatar == "defaultAvatar" {
                settingView.avatarImgView.image = UIImage(named: "\(userAvatar)")
            } else {
                let url = URL(string: "\(userAvatar)")
                settingView.avatarImgView.kf.setImage(with: url)
            }
        }
    }

    var userName: String = "" {
        didSet {
            settingView.userNameLabel.text = userName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        setupView()
        setupTableView()
        setupConstraints()
        setupTableViewConstaints()
        setupPersonalInfo()
    }
    
    override func viewDidLayoutSubviews() {
        settingView.avatarImgView.applyCircularMask()
    }
    
    func setupPersonalInfo() {
        settingViewModel.setupPersonalInfo { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success(let userInfo):
                guard let userName = userInfo["userName"] as? String else { return }
                guard let userAvatar = userInfo["userAvatar"] as? String else { return }
                self.userName = userName
                self.userAvatar = userAvatar
            case.failure(let err):
                print("Failed to get userInfo from server: \(err)")
            }
        }
    }
    
    func setupView() {
        view.addSubview(settingView)
        settingView.backgroundColor = UIColor(hex: CIC.shared.M1)
        settingView.delegate = self
    }
    
    func setupTableView() {
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.backgroundColor = UIColor(hex: CIC.shared.M1)
        settingTableView.clipsToBounds = false
        settingTableView.isScrollEnabled = false
        settingTableView.register(
            SettingTableViewCell.self,
            forCellReuseIdentifier: "SettingTableViewCell")
        settingView.addSubview(settingTableView)
    }
    
    func setupConstraints() {
        settingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            settingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupTableViewConstaints() {
        settingTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingTableView.topAnchor.constraint(equalTo: settingView.generalLabel.bottomAnchor, constant: 16),
            settingTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            settingTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            settingTableView.heightAnchor.constraint(equalToConstant: 170)
        ])
    }
}

extension SettingViewController: UINavigationControllerDelegate {
    func presentCropViewController(_ img: UIImage) {
        let image = img
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
}

extension SettingViewController: SettingViewDelegate, UISheetPresentationControllerDelegate {
    func presentImagePicker(_ view: SettingView) {
        Vibration.shared.lightV()
        chooseImageAlert(viewController: self)
    }
    
    func didPressSettingViewBackBtn(_ view: SettingView) {
        Vibration.shared.lightV()
        delegate?.didPressSettingViewBackBtn(self)
    }
    
    func didPressSettingViewEditBtn(_ view: SettingView) {
        let editNameViewController = EditNameViewController()
        editNameViewController.delegate = self
        editNameViewController.modalPresentationStyle = .formSheet
        editNameViewController.sheetPresentationController?.detents = [.large()]
        editNameViewController.sheetPresentationController?.delegate = self
        editNameViewController.sheetPresentationController?.preferredCornerRadius = 20
        Vibration.shared.lightV()

        present(editNameViewController, animated: true, completion: nil)
    }
}

extension SettingViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.originalImage] as? UIImage
        guard let image = image else { return }
        picker.dismiss(animated: true)
        // 裁切成圓形
        presentCropViewController(image)
    }
}

extension SettingViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        settingViewModel.uploadPhoto(image: image) { [weak self] result in
            guard let self = self else { return }
            guard let userID = UserDefaults.standard.object(forKey: "userID") else { return }
            switch result {
            case .success(let url):
                // 拿到 url 後上傳到 fireStore 跟存到 UserDefault
                UserDefaults.standard.set("\(url)", forKey: "userAvatar")
                self.settingViewModel.storeAvatarToFireStoreUsersCollection(url: url, userID: userID) { result in
                    switch result {
                    case .success:
                        cropViewController.dismiss(animated: true) {
                            DispatchQueue.main.async {
                                self.settingView.avatarImgView.kf.setImage(with: url)
                            }
                        }
                    case .failure(let err):
                        print("Failed to upload img: \(err)")
                    }
                }
                // 如果 groupIDs 有值，也要分別存到個別的資料夾裡，方便抓取
                if !self.groupIDs.isEmpty {
                    self.settingViewModel.storeAvatarToFireStoreGroupsCollection(
                        groupIDs: self.groupIDs,
                        url: url,
                        userID: userID
                    )
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SettingViewController: EditNameViewControllerDelegate {
    func didPressSaveBtn(_ view: EditNameViewController, name: String) {
        guard let userID = UserDefaults.standard.object(forKey: "userID") as? String else { return }
        UserDefaults.standard.set("\(name)", forKey: "userName")
        settingView.userNameLabel.text = name
        settingViewModel.updateUserName(userName: name, userID: userID) { result in
            switch result {
            case.success(()):
                print("Upload userAvatar to user path successfully.")
            case.failure(let err):
                print("Failed to update userName: \(err)")
            }
        }
        
        if !self.groupIDs.isEmpty {
            settingViewModel.updateUserNameInGroups(userID: userID, userName: name, groupIDs: self.groupIDs) { result in
                switch result {
                case.success(()):
                    print("stored userName in groups")
                case.failure(let err):
                    print("Failed to update userName in existing groups: \(err)")
                }
            }
        } else {
            settingView.userNameLabel.text = name
        }
    }
}
