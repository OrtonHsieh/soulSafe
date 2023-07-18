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
    var groupIDs: [String] = []
    let db = Firestore.firestore()
    
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
        guard let userID = UserDefaults.standard.object(forKey: "userID") else { return }
        let getPersonalInfoPath = db.collection("users").document("\(userID)")
        getPersonalInfoPath.getDocument { snapshot, err in
            if let err = err {
                print(err)
            } else {
                guard let snapshot = snapshot else { return }
                guard  let data = snapshot.data() else { return }
                guard let userAvatar = data["userAvatar"] as? String else { return }
                guard let userName = data["userName"] as? String else { return }
                self.userAvatar = userAvatar
                self.userName = userName
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
    
    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileReference = Storage.storage().reference().child(UUID().uuidString + ".jpg")
        if let data = image.jpegData(compressionQuality: 0.1) {
            fileReference.putData(data, metadata: nil) { result in
                switch result {
                case .success:
                    fileReference.downloadURL(completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func presentCropViewController(_ img: UIImage) {
        let image = img
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)")
        if indexPath.row == 0 {
            DispatchQueue.main.async {
                self.deleteUserAccount()
            }
        } else {
            userLogOut()
        }
    }
}

extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SettingTableViewCell",
            for: indexPath) as? SettingTableViewCell else {
            fatalError("Failed to produce reuseable cell for SettingTableViewCell.")
        }
        let settingTableViewTitleArray = ["刪除帳號", "登出"]
        cell.settingOptionLabel.text = settingTableViewTitleArray[indexPath.row]
        cell.layer.shadowColor = UIColor(red: 24 / 255, green: 183 / 255, blue: 231 / 255, alpha: 0.4).cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 8
        return cell
    }
}

extension SettingViewController: SettingViewDelegate {
    func presentImagePicker(_ view: SettingView) {
        Vibration.shared.lightV()
        chooseImageAlert()
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

extension SettingViewController: UINavigationControllerDelegate {
}

extension SettingViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        uploadPhoto(image: image) { result in
            guard let userID = UserDefaults.standard.object(forKey: "userID") else { return }
            switch result {
            case .success(let url):
                print(url)
                // 拿到 url 後上傳到 fireStore 跟存到 UserDefault
                UserDefaults.standard.set("\(url)", forKey: "userAvatar")
                let storeAvatarPath = self.db.collection("users").document("\(UserSetup.userID)")
                storeAvatarPath.setData([
                    "userAvatar": "\(url)",
                    "userID": "\(userID)"
                ], merge: true) { err in
                    if let err = err {
                        print("Failed to upload img: \(err)")
                    } else {
                        print("Upload userAvatar to user path successfully.")
                        cropViewController.dismiss(animated: true) {
                            DispatchQueue.main.async {
                                self.settingView.avatarImgView.kf.setImage(with: url)
                            }
                        }
                    }
                }
                
                if !self.groupIDs.isEmpty {
                    for groupID in self.groupIDs {
                        let storeAvatarInGroupMemberListPath = self.db.collection("groups").document("\(groupID)").collection("members").document("\(userID)")
                        storeAvatarInGroupMemberListPath.setData([
                            "userAvatar": "\(url)"
                        ],
                        merge: true)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SettingViewController: UISheetPresentationControllerDelegate {
}

extension SettingViewController: EditNameViewControllerDelegate {
    func didPressSaveBtn(_ view: EditNameViewController, name: String) {
        guard let userID = UserDefaults.standard.object(forKey: "userID") else { return }
        UserDefaults.standard.set("\(name)", forKey: "userName")
        settingView.userNameLabel.text = name
        let storeNamePath = self.db.collection("users").document("\(userID)")
        storeNamePath.setData([
            "userName": "\(name)"
        ], merge: true) { err in
            if let err = err {
                print("Failed to upload img: \(err)")
            } else {
                print("Upload userAvatar to user path successfully.")
            }
        }
        
        if !self.groupIDs.isEmpty {
            for groupID in self.groupIDs {
                let storeNameInGroupMemberListPath = self.db.collection("groups").document("\(groupID)").collection("members").document("\(userID)")
                storeNameInGroupMemberListPath.setData([
                    "userName": "\(name)"
                ], merge: true) { err in
                    if let err = err {
                        print(err)
                    } else {
                        print("stored userName in groups")
                    }
                }
            }
        } else {
            settingView.userNameLabel.text = name
        }
    }
}
