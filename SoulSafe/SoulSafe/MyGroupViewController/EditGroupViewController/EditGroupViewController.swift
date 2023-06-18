//
//  EditGroupViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/18.
//

import UIKit

class EditGroupViewController: UIViewController {
    lazy var editGroupView = EditGroupView()
    lazy var editGroupTBView = UITableView()
    var totalCellHeight: CGFloat = 0
    var mockData = ["我的群組 1", "我的群組 2", "我的群組 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupConstraints()
        setupTableViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        editGroupView.getGroupLinkView.layer.cornerRadius = 12
        editGroupTBView.layer.cornerRadius = 12
    }
    
    func setupView() {
        view.addSubview(editGroupView)
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
    }
    
    func setupTableView() {
        editGroupTBView = Blur.shared.setTableViewShadow(editGroupTBView)
        editGroupTBView.delegate = self
        editGroupTBView.dataSource = self
        editGroupTBView.register(EditGroupTBCell.self, forCellReuseIdentifier: "EditGroupTBCell")
        editGroupTBView.backgroundColor = UIColor(hex: CIC.shared.M1)
        editGroupTBView.separatorStyle = .none
        editGroupTBView.isScrollEnabled = false
        
        totalCellHeight = CGFloat(mockData.count) * 54
        view.addSubview(editGroupTBView)
    }
    
    func setupConstraints() {
        editGroupView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            editGroupView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            editGroupView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editGroupView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editGroupView.heightAnchor.constraint(equalToConstant: 244)
        ])
    }
    
    func setupTableViewConstraints() {
        editGroupTBView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            editGroupTBView.topAnchor.constraint(equalTo: editGroupView.bottomAnchor, constant: 13),
            editGroupTBView.widthAnchor.constraint(equalToConstant: 300),
            editGroupTBView.heightAnchor.constraint(equalToConstant: totalCellHeight),
            editGroupTBView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])
    }
}

extension EditGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Vibration.shared.mediumV()
        let alert = UIAlertController(title: "是否退出群組", message: .none, preferredStyle: .alert)
        let dismissAlert = UIAlertAction(title: "關閉", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        
        let confirmAction = UIAlertAction(title: "退出", style: .default) { _ in
            self.mockData.remove(at: indexPath.row)
            tableView.reloadData()
        }
        
        alert.addAction(dismissAlert)
        alert.addAction(confirmAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension EditGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mockData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "EditGroupTBCell",
            for: indexPath) as? EditGroupTBCell else {
            fatalError("Cannot create editGroupCell")
        }
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(hex: CIC.shared.M1)
        cell.layer.cornerRadius = 12
        cell.groupTitleLabel.text = mockData[indexPath.row]
        if indexPath.row == mockData.endIndex - 1 {
            cell.separatorView.backgroundColor = .clear
        }
        return cell
    }
}
