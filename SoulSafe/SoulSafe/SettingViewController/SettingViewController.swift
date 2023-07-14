//
//  SettingViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/15.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

protocol SettingViewControllerDelegate: AnyObject {
    func didPressSettingViewBackBtn(_ viewController: SettingViewController)
}

class SettingViewController: UIViewController {
    weak var delegate: SettingViewControllerDelegate?
    let settingView = SettingView()
    let settingTableView = UITableView()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        setupView()
        setupTableView()
        setupConstraints()
        setupTableViewConstaints()
    }
    
    override func viewDidLayoutSubviews() {
        settingView.avatarImgView.applyCircularMask()
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
        if let data = image.jpegData(compressionQuality: 0.2) {
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
        Vibration.shared.lightV()
        commingSoonAlert()
    }
}

extension SettingViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        guard let image = image else { return }
        // 拿 image 上傳到 firebaseStorage
        uploadPhoto(image: image) { result in
            switch result {
            case .success(let url):
                print(url)
                // 拿到 url 後上傳到 fireStore 跟存到 UserDefault
                UserDefaults.standard.set("\(url)", forKey: "userAvatar")
                let storeAvatarPath = self.db.collection("users").document("\(UserSetup.userID)")
                storeAvatarPath.setData(["userAvatar" : "\(url)"]) { err in
                    if let err = err {
                        print("Failed to upload img: \(err)")
                    } else {
                        print("Upload userAvatar to user path successfully.")
                        picker.dismiss(animated: true) {
                            DispatchQueue.main.async {
                                self.settingView.avatarImgView.kf.setImage(with: url)
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SettingViewController: UINavigationControllerDelegate {
}
