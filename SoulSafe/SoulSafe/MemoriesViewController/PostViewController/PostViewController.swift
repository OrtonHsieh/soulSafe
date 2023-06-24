//
//  PostViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/17.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class PostViewController: UIViewController {
    lazy var imageView = UIImageView()
    lazy var textAreaView = TextAreaView()
    lazy var postTableView = UITableView()
    let db = Firestore.firestore()
    var currentPostID = String()
    
    var comments: [String] = []
    var timeStamps: [Timestamp] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupInputView()
        setupTableViewConstraints()
        setupInputViewConstraints()
        getPostComment()
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
    
    func getPostComment() {
        let docRef = db.collection("testingUploadImg").document("\(UserSetup.userID)").collection("posts")
        let commentRef = docRef.document("\(currentPostID)").collection("comments").order(
            by: "timeStamp", descending: true
        )
        commentRef.getDocuments {
            (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var index = 0
                guard let querySnapshot = querySnapshot else { return }
                for document in querySnapshot.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    guard let comment = data["comment"] as? String else { return }
                    guard let timeStamp = data["timeStamp"] as? Timestamp else { return }
                    
                    if index <= self.comments.count - 1 {
                        self.comments[index] = comment
                        self.timeStamps[index] = timeStamp
                    } else {
                        self.comments.append(comment)
                        self.timeStamps.append(timeStamp)
                    }
                    index += 1
                }
            }
            self.postTableView.reloadData()
        }
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
            // 還要將 comments 放入資料 array
            cell.backgroundColor = UIColor(hex: CIC.shared.M1)
            cell.selectionStyle = .none
            cell.commentLabel.text = comments[indexPath.row]
            cell.avatarView.image = UserSetup.userImage
            return cell
        }
    }
}

extension PostViewController: TextAreaViewDelegate {
    func didSendCmt(_ view: TextAreaView, comment: String) {
        Vibration.shared.lightV()
        
        if textAreaView.inputTextView.text.isEmpty == false {
            let postPath = self.db.collection("testingUploadImg").document("\(UserSetup.userID)").collection("posts")
            let postCommentPath = postPath.document("\(currentPostID)").collection("comments").document()
            
            postCommentPath.setData([
                "userID": "\(UserSetup.userID)",
                "commentID": "\(postCommentPath.documentID)",
                "timeStamp": Timestamp(date: Date()),
                "comment": comment
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            
            textAreaView.inputTextView.text = ""
            
            viewDidLoad()
        }
    }
}
