//
//  AlertManager.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

extension UIViewController {
    typealias ImagePickerAndNaviControllerDelegate = UIImagePickerControllerDelegate & UINavigationControllerDelegate
    
    func showOptionsAlert(title: String, message: String?, confirmInfo: String, action: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        
        let myPostAction = UIAlertAction(title: confirmInfo, style: .default) { _ in
            action()
        }
        alertController.addAction(myPostAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showConfirmAlert(title: String, message: String?, confirmInfo: String, action: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let myPostAction = UIAlertAction(title: confirmInfo, style: .default) { _ in
            action?()
        }
        alertController.addAction(myPostAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func chooseImageAlert(viewController: UIViewController) {
        let alert = UIAlertController(title: "選擇照片來源", message: nil, preferredStyle: .actionSheet)
        
        let dismissAlert = UIAlertAction(title: "關閉", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        
        let galleryAction = UIAlertAction(title: "從相簿選擇", style: .default) { _ in
            let picController = UIImagePickerController()
            picController.sourceType = .photoLibrary
            picController.delegate = viewController as? any ImagePickerAndNaviControllerDelegate
            viewController.present(picController, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "開啟相機", style: .default) { _ in
            let picController = UIImagePickerController()
            picController.sourceType = .camera
            picController.delegate = viewController as? any ImagePickerAndNaviControllerDelegate
            viewController.present(picController, animated: true, completion: nil)
        }
        
        alert.addAction(dismissAlert)
        alert.addAction(galleryAction)
        alert.addAction(cameraAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
