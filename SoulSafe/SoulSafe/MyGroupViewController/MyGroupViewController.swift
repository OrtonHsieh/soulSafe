//
//  MyGroupViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/18.
//

import UIKit

class GroupViewController: UIViewController {
    lazy var groupTableView = UITableView()
    lazy var editGroupBtn: UIButton = {
        let editGroupBtn = UIButton()
        editGroupBtn.setTitle("管理群組", for: .normal)
        editGroupBtn.backgroundColor = UIColor(hex: CIC.shared.M1)
        return editGroupBtn
    }()
    
    let mockData = ["2real", "RealChillSquad"]
    
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
    
    @objc func didPressGroupBtn() {
        Vibration.shared.lightV()
        let groupVC = EditGroupViewController()
        groupVC.modalPresentationStyle = .formSheet
        Vibration.shared.lightV()
        
        present(groupVC, animated: true)
        
        if let sheetPC = groupVC.sheetPresentationController {
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
        
        if mockData.count - 1 >= indexPath.row {
            cell.groupLabel.text = mockData[indexPath.row]
        } else {
            cell.groupView.isHidden = true
        }
        return cell
    }
}

extension GroupViewController: UISheetPresentationControllerDelegate {
}
