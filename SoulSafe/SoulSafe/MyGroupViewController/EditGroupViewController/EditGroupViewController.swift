//
//  EditGroupViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/18.
//

import UIKit

class EditGroupViewController: UIViewController {
    lazy var editGroupTBView = UITableView()
    lazy var editGroupView = EditGroupView()
    var mockData = ["2Real", "RealChillSquad", "系籃一家親"]
    
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
}

extension EditGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditGroupTBCell", for: indexPath) as? EditGroupTBCell else { fatalError() }
        
        cell.backgroundColor = UIColor(hex: CIC.shared.M1)
        cell.groupLabel.text = mockData[indexPath.row]
        cell.baseGroupView.layer.cornerRadius = 12
        cell.groupView.layer.cornerRadius = 8
        cell.selectionStyle = .none
        
        return cell
    }
}
