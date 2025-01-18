//
//  PostViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/17.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import Kingfisher

class PostViewController: UIViewController {
    lazy var imageView = UIImageView()
    lazy var textAreaView = TextAreaView()
    lazy var postTableView = UITableView()
    let db = Firestore.firestore()
    lazy var currentPostID = String()
    
    // userIDs 與 comments 會有相同排序，可以依據 userIDs 作為篩選順序去找對應留言的頭貼
    lazy var commentsFromGroupsCollectionPath: [String] = []
    lazy var timeStamps: [Timestamp] = []
    lazy var userIDsFromGroupsCollectionPath: [String] = []
//    var userAvatarFromGroupsCollectionPath: [String] = []
    
    lazy var selectedGroup = String()
    lazy var selectedGroupTitle = String()
    
    lazy var selectedGroupInPostVC = String()
    lazy var selectedGroupTitleForPost = String()
    lazy var commentsFromGroupPath: [String] = []
    
    // 以下為用來放置對應 postID 所分享的群組
    lazy var groupIDArray: [String] = []
    lazy var groupTitleArray: [String] = []
    lazy var ifGroupViewTextIsMyPost = true
    
    // 存取目前被選擇群組內成員
    lazy var memberIDsInSelectedGroup: [String] = []
    lazy var memberAvatarsInSelectedGroup: [String] = []
    lazy var memberAvatarsInSelectedGroupInOrder: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memberIDsInSelectedGroup.removeAll()
        memberAvatarsInSelectedGroup.removeAll()
        memberAvatarsInSelectedGroupInOrder.removeAll()
        userIDsFromGroupsCollectionPath.removeAll()
        setupTableView()
        setupInputView()
        setupTableViewConstraints()
        setupInputViewConstraints()
        getGroupMembers()
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
    
    func getGroupMembers() {
        func fetchData(_ path: CollectionReference) {
            // 把之前的清掉防止疊加
//            memberIDsInSelectedGroup.removeAll()
//            memberAvatarsInSelectedGroup.removeAll()
            path.getDocuments { snapshot, err in
                if let err = err {
                    print("Failed to get single group document: \(err)")
                } else {
                    guard let snapshot = snapshot else { return }
                    let documents = snapshot.documents
                    for document in documents {
                        let data = document.data()
                        guard let memberIDInSelectedGroup = data["userID"] as? String else { return }
                        guard let memberAvatarInSelectedGroup = data["userAvatar"] as? String else { return }
                        self.memberIDsInSelectedGroup.append(memberIDInSelectedGroup)
                        self.memberAvatarsInSelectedGroup.append(memberAvatarInSelectedGroup)
                    }
                    self.getPostComment()
                }
            }
        }
        
        if !selectedGroup.isEmpty {
            let groupMemberPath = db.collection("groups").document("\(selectedGroup)").collection("members")
            fetchData(groupMemberPath)
        } else {
            let groupMemberPath = db.collection("groups").document("\(groupIDArray[0])").collection("members")
            fetchData(groupMemberPath)
        }
    }
    
    func getPostComment() {
        var postPathInGroups: CollectionReference?
        
        if !selectedGroup.isEmpty {
            postPathInGroups = db.collection("groups").document("\(selectedGroup)").collection("posts")
        } else if !selectedGroupInPostVC.isEmpty {
            postPathInGroups = db.collection("groups").document("\(selectedGroupInPostVC)").collection("posts")
        } else {
            postPathInGroups = db.collection("groups").document("\(groupIDArray[0])").collection("posts")
        }
        
        guard let postPathInGroups = postPathInGroups else { return }
        let commentRef = postPathInGroups.document("\(currentPostID)").collection("comments").order(
            by: "timeStamp"
        )
        commentRef.getDocuments {
            (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.commentsFromGroupsCollectionPath.removeAll() // 確認中
                self.timeStamps.removeAll()
                var index = 0
                guard let querySnapshot = querySnapshot else { return }
                for document in querySnapshot.documents {
                    let data = document.data()
                    guard let comment = data["comment"] as? String else { return }
                    guard let timeStamp = data["timeStamp"] as? Timestamp else { return }
                    guard let userAvatar = data["userAvatar"] as? String else { return }
                    guard let userID = data["userID"] as? String else { return }
                    
                    if index <= self.commentsFromGroupsCollectionPath.count - 1 {
                        self.commentsFromGroupsCollectionPath[index] = comment
                        self.userIDsFromGroupsCollectionPath[index] = userID
                        self.timeStamps[index] = timeStamp
                    } else {
                        self.commentsFromGroupsCollectionPath.append(comment)
                        self.userIDsFromGroupsCollectionPath.append(userID)
                        self.timeStamps.append(timeStamp)
                    }
                    index += 1
                }
                self.postTableView.reloadData()
            }
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
            return view.frame.width
        } else if indexPath.section == 0 && indexPath.row == 1 {
            return 60
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if !selectedGroup.isEmpty {
                return 1
            } else {
                return 2
            }
        } else if section == 1 {
            return commentsFromGroupsCollectionPath.count
        }
        return 0
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
                cell.delegate = self
                // selectedGroupForPost 是放置留言串的 groupID
                
                if selectedGroup.isEmpty {
                    if selectedGroupTitleForPost.isEmpty {
                        cell.groupLabel.text = groupTitleArray[0]
                        selectedGroupInPostVC = groupIDArray[0]
                    } else {
                        cell.groupLabel.text = selectedGroupTitleForPost
                    }
                } else {
                    cell.groupLabel.text = selectedGroupTitle
                }
                
                cell.backgroundColor = UIColor(hex: CIC.shared.M1)
                cell.selectionStyle = .none
                
                // 如果 selectedGroup 是「我的貼文」
                // 則 cell 的抬頭要等於 groupIDArray[0]
                // 如果 selectedGroup 是 A
                // 則 cell 的抬頭要等於 A
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
            
            cell.commentLabel.text = commentsFromGroupsCollectionPath[indexPath.row]
            
//            let userAvatar = userAvatarFromGroupsCollectionPath[indexPath.row]
            
            cell.avatarView.contentMode = .scaleAspectFill
            cell.avatarView.clipsToBounds = true
            cell.avatarView.layer.masksToBounds = true
            cell.avatarView.layer.cornerRadius = 10
            
            if !userIDsFromGroupsCollectionPath.isEmpty {
                // 現在拿到了群組成員的頭貼連結，要有「」才能比對是否吻合，若吻合就將該大頭貼塞給這個留言
//                memberAvatarsInSelectedGroupInOrder.removeAll()
                // 如果留言的 id 數量大於群組成員的數量
                memberAvatarsInSelectedGroupInOrder = getMemberAvatarsInSelectedGroup(
                    from: self.memberIDsInSelectedGroup,
                    memberAvatarsInSelectedGroup: self.memberAvatarsInSelectedGroup,
                    userIDsFromGroupsCollectionPath: self.userIDsFromGroupsCollectionPath
                )
                let userAvatar = memberAvatarsInSelectedGroupInOrder[indexPath.row]
                if userAvatar != "defaultAvatar" && userAvatar != "false" {
                    let url = URL(string: "\(userAvatar)")
                    cell.avatarView.kf.setImage(with: url)
                } else {
                    cell.avatarView.image = UIImage(named: "\(userAvatar)")
                }
            } else {
                cell.avatarView.image = UIImage(named: "defaultAvatar")
            }
            
            return cell
        }
    }
    
    func getMemberAvatarsInSelectedGroup(from memberIDsInSelectedGroup: [String], memberAvatarsInSelectedGroup: [String], userIDsFromGroupsCollectionPath: [String]) -> [String] {
        var memberAvatarsInSelectedGroupInOrder: [String] = []

        for element in userIDsFromGroupsCollectionPath {
            if let matchingIndex = memberIDsInSelectedGroup.firstIndex(of: element) {
                memberAvatarsInSelectedGroupInOrder.append(memberAvatarsInSelectedGroup[matchingIndex])
            }
        }

        return memberAvatarsInSelectedGroupInOrder
    }
}

extension PostViewController: TextAreaViewDelegate {
    func didSendCmt(_ view: TextAreaView, comment: String) {
        Vibration.shared.lightV()
        
        if textAreaView.inputTextView.text.isEmpty == false {
            
            let postPath = self.db.collection("users").document("\(UserSetup.userID)").collection("posts")
            let postCommentPath = postPath.document("\(currentPostID)").collection("comments").document()
            let postPathForGroup = self.db.collection("groups").document("\(selectedGroupInPostVC)").collection("posts")
            let postCommentPathForGroup = postPathForGroup.document("\(currentPostID)").collection("comments").document("\(postCommentPath.documentID)")
            let avatar = UserDefaults.standard.object(forKey: "userAvatar") ?? "defaultAvatar"
            
            // 將留言上傳到 user 分類
            postCommentPath.setData([
                "userID": "\(UserSetup.userID)",
                "commentID": "\(postCommentPath.documentID)",
                "timeStamp": Timestamp(date: Date()),
                "comment": comment,
                "userAvatar": "\(avatar)"
            ])
            
            // 將留言上傳到 Groups 分類
            postCommentPathForGroup.setData([
                "userID": "\(UserSetup.userID)",
                "commentID": "\(postCommentPath.documentID)",
                "timeStamp": Timestamp(date: Date()),
                "comment": comment,
                "userAvatar": "\(avatar)"
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    self.textAreaView.inputTextView.text = ""
                    self.viewDidLoad()
//                    self.getGroupMembers()
                }
            }
        }
    }
}

extension PostViewController: PostTBCellListDelegate {
    func didPressGroupSelector(_ tableViewCell: PostTBCellList) {
        showGroupList(groupTitleArray)
    }
}
