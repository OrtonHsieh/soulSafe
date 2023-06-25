//
//  EditGroupViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/18.
//

import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

class EditGroupViewController: UIViewController {
    lazy var editGroupTBView = UITableView()
    lazy var editGroupView = EditGroupView()
    // swiftlint:disable all
    let db = Firestore.firestore()
    // swiftlint:enable all
//    var dataClosure: ((String) -> Void)? {
//        didSet {
//            // 由 Sence Delegate 將 groupID 傳到這邊
//            // 將 groupID 放入 currentGroupID
//            // 
//        }
//    }
    lazy var currentGroupID = String()
    lazy var groupTitles: [String] = []
    lazy var groupIDs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
        setupTableViewConstraints()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        editGroupView.leftActionView.layer.cornerRadius = 12
        editGroupView.rightActionView.layer.cornerRadius = 12
    }
    
    func setupTableView() {
        editGroupTBView.delegate = self
        editGroupTBView.dataSource = self
        editGroupTBView.register(EditGroupTBCell.self, forCellReuseIdentifier: "EditGroupTBCell")
        editGroupTBView.backgroundColor = UIColor(hex: CIC.shared.M1)
        editGroupTBView.separatorStyle = .none
        editGroupTBView.layer.masksToBounds = false
        editGroupTBView.isScrollEnabled = false
        view.addSubview(editGroupTBView)
    }
    
    func setupView() {
        view.addSubview(editGroupView)
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        editGroupView.delegate = self
    }
    
    func setupTableViewConstraints() {
        editGroupTBView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            editGroupTBView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            editGroupTBView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editGroupTBView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editGroupTBView.heightAnchor.constraint(equalToConstant: 288)
        ])
    }
    
    
    func setupConstraints() {
        editGroupView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            editGroupView.topAnchor.constraint(equalTo: editGroupTBView.bottomAnchor, constant: 40),
            editGroupView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editGroupView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editGroupView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension EditGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let title = UILabel()
        title.text = "管理我的群組"
        title.font = .systemFont(ofSize: 20, weight: .medium)
        title.textColor = UIColor(hex: CIC.shared.F1)
        title.alpha = 0.8
        title.textAlignment = .center
        headerView.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            title.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentGroupID = groupIDs[indexPath.row]
    }
}

extension EditGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditGroupTBCell", for: indexPath) as? EditGroupTBCell else { fatalError() }
        
        if indexPath.row == 0 {
            cell.groupView.backgroundColor = UIColor(hex: CIC.shared.F1)
        }
        
        cell.delegate = self
        cell.backgroundColor = UIColor(hex: CIC.shared.M1)
        if groupTitles.count - 1 >= indexPath.row {
            cell.groupView.isHidden = false
            cell.groupLabel.text = groupTitles[indexPath.row]
            editGroupView.createGroupLabel.text = "分享我的群組"
            editGroupView.leftHintLabel.text = editGroupView.titleForLeave
            editGroupView.rightHintLabel.text = editGroupView.titleForCopylink
            editGroupView.leaveBtn.isHidden = false
            editGroupView.shareLinkBtn.isHidden = false
            editGroupView.QRCodeBtn.isHidden = true
            editGroupView.copyLinkBtn.isHidden = true
        } else {
            cell.groupView.isHidden = true
        }
        
        cell.baseGroupView.layer.cornerRadius = 12
        cell.groupView.layer.cornerRadius = 8
        cell.selectionStyle = .none
        
        return cell
    }
}

extension EditGroupViewController: EditGroupTBCellDelegate {
    func didPressBaseGroupView(_ cell: EditGroupTBCell, view: UIView) {
        print("didPressBaseGroupView")
        editGroupView.createGroupLabel.text = "建立新的群組"
        editGroupView.leftHintLabel.text = editGroupView.titleForQRCode
        editGroupView.rightHintLabel.text = editGroupView.titleForCreateLink
        editGroupView.leaveBtn.isHidden = true
        editGroupView.shareLinkBtn.isHidden = true
        editGroupView.QRCodeBtn.isHidden = false
        editGroupView.copyLinkBtn.isHidden = false
        
        // 將其他 View 變成 M3
        for visibleCell in editGroupTBView.visibleCells {
            if let cell = visibleCell as? EditGroupTBCell {
                cell.groupView.backgroundColor = UIColor(hex: CIC.shared.M3)
            }
        }
    }
    
    func didPressGroupView(_ cell: EditGroupTBCell, view: UIView) {
        editGroupView.createGroupLabel.text = "分享我的群組"
        editGroupView.leftHintLabel.text = editGroupView.titleForLeave
        editGroupView.rightHintLabel.text = editGroupView.titleForCopylink
        editGroupView.leaveBtn.isHidden = false
        editGroupView.shareLinkBtn.isHidden = false
        editGroupView.QRCodeBtn.isHidden = true
        editGroupView.copyLinkBtn.isHidden = true
        
        guard let indexPath = editGroupTBView.indexPath(for: cell) else { return }
        currentGroupID = groupIDs[indexPath.row]
        
        // 將其他 View 變成 M3
        for visibleCell in editGroupTBView.visibleCells {
            if let cell = visibleCell as? EditGroupTBCell {
                cell.groupView.backgroundColor = UIColor(hex: CIC.shared.M3)
            }
        }
        // 點擊的 View 變成 F1
        cell.groupView.backgroundColor = UIColor(hex: CIC.shared.F1)
    }
}

extension EditGroupViewController: EditGroupViewDelegate {
    func didPressQRCodeBtn(_ view: EditGroupView, button: UIButton) {
        print("didPressQRCodeBtn")
    }
    
    func didPressGetLinkBtn(_ view: EditGroupView, button: UIButton) {
        inputAlertForCreateGroup(from: self)
    }
    
    func didPressLeaveBtn(_ view: EditGroupView, button: UIButton) {
        print("didPressLeaveBtn")
        leaveAlert(from: self)
    }
    
    func didPressCopyLinkBtn(_ view: EditGroupView, button: UIButton) {
        print("didPressCopyLinkBtn")
    }
}
