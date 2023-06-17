//
//  PostViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/17.
//

import UIKit

class PostViewController: UIViewController {
    lazy var imageView = UIImageView()
    lazy var textAreaView = TextAreaView()
    lazy var postTableView = UITableView()
    
//    lazy var groupView: UIView = {
//        let groupView = UIView()
//        groupView.frame = CGRect(x: 16, y: 12, width: 120, height: 36)
//        groupView.layer.borderWidth = 1
//        groupView.layer.borderColor = UIColor(hex: CIC.shared.F2).cgColor
//        groupView.backgroundColor = UIColor(hex: CIC.shared.M3)
//        groupView.layer.cornerRadius = 15
//        let groupLabel = UILabel()
//        groupLabel.text = "選擇留言串"
//        groupLabel.frame = CGRect(x: 11, y: 6, width: groupView.frame.width - 22, height: groupView.frame.height - 12)
//        groupLabel.font = .systemFont(ofSize: 16, weight: .medium)
//        groupView.addSubview(groupLabel)
//        return groupView
//    }()
    
    var comments: [String] = ["今天跟高中同學出去（有你前男友", "他去幹嘛拉去搞笑ㄛ", "笑死超氣耶哈哈哈哈哈哈"]
    var avatars: [UIImage?] = [UIImage(named: "avatar-1"), UIImage(named: "avatar-2"), UIImage(named: "avatar-3")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupInputView()
        setupTableViewConstraints()
        setupInputViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        textAreaView.inputTextView.layer.cornerRadius = 10
    }
    
    func setupTableView() {
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.register(PostTBCellCmt.self, forCellReuseIdentifier: "PostTBCellCmt")
        postTableView.register(PostTBCellImg.self, forCellReuseIdentifier: "PostTBCellImg")
        postTableView.register(PostTBCellList.self, forCellReuseIdentifier: "PostTBCellList")
        postTableView.backgroundColor = UIColor(hex: CIC.shared.M1)
        postTableView.separatorStyle = .none
        postTableView.showsVerticalScrollIndicator = false
        postTableView.layer.borderWidth = 1
        postTableView.layer.borderColor = UIColor(hex: CIC.shared.F2).cgColor
        postTableView.layer.cornerRadius = 20
        view.addSubview(postTableView)
    }
    
    func setupTableViewConstraints() {
        postTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            postTableView.topAnchor.constraint(equalTo: view.topAnchor),
            postTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120)
        ])
    }
    
    func setupInputView() {
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        view.addSubview(textAreaView)
        textAreaView.backgroundColor = UIColor(hex: CIC.shared.M1)
        textAreaView.delegate = self
    }
    
    func setupInputViewConstraints() {
        textAreaView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textAreaView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension PostViewController: UITableViewDelegate {
}

extension PostViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        58
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return (view.frame.width) / 325 * 403
        } else if indexPath.section == 0 && indexPath.row == 1 {
            return 60
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "PostTBCellImg",
                    for: indexPath) as? PostTBCellImg else {
                    fatalError("Could not create cell")
                }
                cell.backgroundColor = UIColor(hex: CIC.shared.M1)
                cell.selectionStyle = .none
                cell.postImgView.image = imageView.image
                cell.postImgView.layer.cornerRadius = 20
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "PostTBCellList",
                    for: indexPath) as? PostTBCellList else {
                    fatalError("Could not create cell")
                }
                cell.backgroundColor = UIColor(hex: CIC.shared.M1)
                cell.selectionStyle = .none
                return cell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "PostTBCellCmt",
                for: indexPath) as? PostTBCellCmt else {
                fatalError("Could not create cell")
            }
            cell.backgroundColor = UIColor(hex: CIC.shared.M1)
            cell.selectionStyle = .none
            cell.commentLabel.text = comments[indexPath.row]
            cell.avatarView.image = avatars[indexPath.row]
            return cell
        }
    }
}

extension PostViewController: TextAreaViewDelegate {
    func didSendCmt(_ view: TextAreaView, comment: String) {
        Vibration.shared.lightV()
        comments.append(comment)
        avatars.append(UIImage(named: "avatar-1"))
        textAreaView.inputTextView.text = ""
        postTableView.reloadData()
    }
}
