//
//  MainViewController + UISheet.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/8.
//

import UIKit

extension MainViewController: UISheetPresentationControllerDelegate {
    func didPressGroupBtn(_ view: CameraView) {
        groupVC.modalPresentationStyle = .formSheet
        groupVC.groupTitles = groupTitles
        groupVC.groupIDs = groupIDs
        Vibration.shared.lightV()
        
        let navigationController = UINavigationController(rootViewController: groupVC)
        navigationController.modalPresentationStyle = .formSheet

        if let sheetPC = navigationController.presentationController as? UISheetPresentationController {
            sheetPC.detents = [.medium()]
            sheetPC.prefersGrabberVisible = true
            sheetPC.delegate = self
            sheetPC.preferredCornerRadius = 20
        }

        present(navigationController, animated: true, completion: nil)
    }
}
