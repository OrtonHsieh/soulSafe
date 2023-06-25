//
//  MyGroupViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/18.
//

import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

protocol GroupViewControllerDelegate: AnyObject {
    // swiftlint:disable all
    func didReceiveNewGroup(_ VC: GroupViewController, newGroupIDs: [String], newGroupsTitle: [String])
    func didRemoveGroup(_ VC: GroupViewController, newGroupIDs: [String], newGroupsTitle: [String])
    // swiftlint:disable all
}

class GroupViewController: UIViewController {
    lazy var groupTableView = UITableView()
    lazy var editGroupBtn: UIButton = {
        let editGroupBtn = UIButton()
        editGroupBtn.setTitle("管理群組", for: .normal)
        editGroupBtn.backgroundColor = UIColor(hex: CIC.shared.M1)
        return editGroupBtn
    }()

    var groupTitles: [String] = []
    var groupIDs: [String] = []
    weak var delegate: GroupViewControllerDelegate?
    let db = Firestore.firestore()
    let editGroupVC = EditGroupViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
        setupTableViewConstraints()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        editGroupBtn.layer.cornerRadius = 12
    }
    
    func setupTableView() {
        groupTableView.delegate = self
        groupTableView.dataSource = self
        groupTableView.register(GroupTBCell.self, forCellReuseIdentifier: "GroupTBCell")
        groupTableView.backgroundColor = UIColor(hex: CIC.shared.M1)
        groupTableView.separatorStyle = .none
        view.addSubview(groupTableView)
    }
    
    func setupView() {
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        editGroupBtn = Blur.shared.setButtonShadow(editGroupBtn)
        view.addSubview(editGroupBtn)
        view.bringSubviewToFront(editGroupBtn)
        editGroupBtn.setTitle("管理我的群組", for: .normal)
        editGroupBtn.addTarget(self, action: #selector(didPressGroupBtn), for: .touchUpInside)
    }
    
    func setupTableViewConstraints() {
        groupTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            groupTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            groupTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            groupTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            groupTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupConstraints() {
        editGroupBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editGroupBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            editGroupBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            editGroupBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            editGroupBtn.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
    
    func updateEditGroupVC() {
        editGroupVC.groupIDs = self.groupIDs
        editGroupVC.groupTitles = self.groupTitles
        editGroupVC.editGroupTBView.reloadData()
    }
    
    @objc func didPressGroupBtn() {
        Vibration.shared.lightV()
        editGroupVC.modalPresentationStyle = .formSheet
        editGroupVC.groupTitles = groupTitles
        
        if groupIDs.count >= 1 {
            editGroupVC.currentGroupID = groupIDs[0]
        }
        
        editGroupVC.groupIDs = groupIDs
        Vibration.shared.lightV()
        
        present(editGroupVC, animated: true)
        
        if let sheetPC = editGroupVC.sheetPresentationController {
            sheetPC.detents = [.large()]
            sheetPC.prefersGrabberVisible = true
            sheetPC.delegate = self
            sheetPC.preferredCornerRadius = 20
        }
    }
}

extension GroupViewController: UITableViewDelegate {
}

extension GroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "GroupTBCell",
            for: indexPath) as? GroupTBCell else {
            fatalError("Cannot create GroupTBCell")
        }
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(hex: CIC.shared.M1)
        
        if groupTitles.count - 1 >= indexPath.row {
            cell.groupView.isHidden = false
            cell.groupLabel.isHidden = false
            cell.groupLabel.text = groupTitles[indexPath.row]
        } else {
            cell.groupView.isHidden = true
            cell.groupLabel.isHidden = true
        }
        return cell
    }
}

extension GroupViewController: UISheetPresentationControllerDelegate {
}
