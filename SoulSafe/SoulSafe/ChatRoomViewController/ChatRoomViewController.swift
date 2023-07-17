//  ChatRoomViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/26.



import UIKit
import FirebaseFirestore
import IQKeyboardManagerSwift
import Kingfisher

class ChatRoomViewController: UIViewController {
    lazy var closeBtn = UIButton()
    lazy var chatTableView = UITableView()
    lazy var textAreaView = ChatRoomView()
    lazy var headerAreaView = ChatRoomHeaderView()
    
    lazy var chats: [String] = []
    lazy var userIDs: [String] = []
    // 這邊現在是存 local 的圖片字串，等個人頁做好後要改成上傳圖片
    lazy var userAvatars: [String] = []
    
    lazy var groupID = String()
    lazy var groupMemberIDsInTargetGroup: [String] = []
    lazy var groupMemberAvatarsInTargetGroup: [String] = []
    lazy var groupMemberAvatarsInOrderInTargetGroup: [String] = []
    var listener: ListenerRegistration?
    lazy var groupTitle = String()
    var keyboardHeightCons: NSLayoutConstraint?
    lazy var db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        setupView()
        getGroupMember()
        setupConstraints()
        registerForKeyboardNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.chatTableView.reloadData()
        IQKeyboardManager.shared.enableAutoToolbar = false
        textAreaView.inputTextView.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chats.removeAll()
        IQKeyboardManager.shared.enableAutoToolbar = true
        listener?.remove()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        chatTableView.layer.cornerRadius = 10
        textAreaView.inputTextView.layer.cornerRadius = 10
        headerAreaView.groupTitleLabel.layer.cornerRadius = 10
    }

    deinit {
        unregisterForKeyboardNotifications()
    }

    func setupView() {
        [chatTableView, textAreaView, headerAreaView].forEach { view.addSubview($0) }

        chatTableView.layer.borderColor = UIColor(hex: CIC.shared.F2).cgColor
        chatTableView.backgroundColor = UIColor(hex: CIC.shared.M1)
        chatTableView.layer.borderWidth = 1
        chatTableView.separatorStyle = .none
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.register(ChatRoomTableViewCell.self, forCellReuseIdentifier: "ChatRoomTableViewCell")
        chatTableView.register(ChatRoomTableViewCellMine.self, forCellReuseIdentifier: "ChatRoomTableViewCellMine")

        headerAreaView.delegate = self
        headerAreaView.groupTitleLabel.text = groupTitle

        textAreaView.delegate = self
    }

    func setupConstraints() {
        [chatTableView, textAreaView, headerAreaView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            headerAreaView.topAnchor.constraint(equalTo: view.topAnchor, constant: 336),
            headerAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerAreaView.heightAnchor.constraint(equalToConstant: 76),

            chatTableView.topAnchor.constraint(equalTo: headerAreaView.bottomAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),

            textAreaView.topAnchor.constraint(equalTo: chatTableView.bottomAnchor, constant: 24),
            textAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func getGroupMember() {
        groupMemberIDsInTargetGroup.removeAll()
        groupMemberAvatarsInTargetGroup.removeAll()
        let groupMemberInChatRoomPath = db.collection("groups").document("\(groupID)").collection("members")
        groupMemberInChatRoomPath.getDocuments { snapshot, err in
            if let err = err {
                print("Failed to get group member of target chat room: \(err).")
            } else {
                guard let snapshot = snapshot else { return }
                let documents = snapshot.documents
                for document in documents {
                    let data = document.data()
                    guard let userID = data["userID"] as? String else { return }
                    guard let userAvatar = data["userAvatar"] as? String else { return }
                    self.groupMemberIDsInTargetGroup.append(userID)
                    self.groupMemberAvatarsInTargetGroup.append(userAvatar)
                }
                self.getChats()
            }
        }
    }

    func getChats() {
        let chatRoomPath = db.collection("groups").document("\(groupID)").collection("messages").order(by: "timeStamp")

        listener = chatRoomPath.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching collection: \(error)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("No documents in collection")
                return
            }
            
            self.chats.removeAll()
            self.userIDs.removeAll()
            self.userAvatars.removeAll()
            
            for document in documents {
                let data = document.data()
                guard let message = data["message"] as? String else { return }
                guard let userID = data["userID"] as? String else { return }
                guard let userAvatar = data["userAvatar"] as? String else { return }
                
                self.chats.append(message)
                self.userIDs.append(userID)
                self.userAvatars.append(userAvatar)
            }
            self.groupMemberAvatarsInOrderInTargetGroup = self.getMemberAvatarsInSelectedGroup(
                from: self.groupMemberIDsInTargetGroup,
                memberAvatarsInSelectedGroup: self.groupMemberAvatarsInTargetGroup,
                userIDsFromGroupsCollectionPath: self.userIDs
            )
            self.scrollToNewCell()
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

    func scrollToNewCell() {
        self.chatTableView.reloadData()
        if chatTableView.numberOfRows(inSection: 0) != 0 {
            let lastRow = chatTableView.numberOfRows(inSection: 0) - 1
            let indexPath = IndexPath(row: lastRow, section: 0)
            chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }

    func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    @objc func keyboardDidShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }

        let keyboardHeight = keyboardFrame.height
        keyboardHeightCons?.constant = keyboardHeight
        view.layoutIfNeeded()
    }
}

extension ChatRoomViewController: UITableViewDelegate {
}

extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if userIDs[indexPath.row] == UserSetup.userID {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChatRoomTableViewCellMine",
                for: indexPath) as? ChatRoomTableViewCellMine else {
                fatalError("fatal_error_message")
            }

            cell.msgLabel.text = chats[indexPath.row]
            cell.msgView.layer.cornerRadius = 8
            cell.backgroundColor = UIColor(hex: CIC.shared.M1)
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChatRoomTableViewCell",
                for: indexPath) as? ChatRoomTableViewCell else {
                fatalError("fatal_error_message")
            }
            cell.msgLabel.text = chats[indexPath.row]
            cell.msgView.layer.cornerRadius = 8
            let avatar = groupMemberAvatarsInOrderInTargetGroup[indexPath.row]
            if avatar == "defaultAvatar" {
                cell.avatarView.image = UIImage(named: "\(avatar)")
            } else {
                let url = URL(string: "\(avatar)")
                cell.avatarView.kf.setImage(with: url)
            }
            cell.backgroundColor = UIColor(hex: CIC.shared.M1)
            cell.selectionStyle = .none
            cell.avatarView.clipsToBounds = true
            cell.avatarView.layer.masksToBounds = true
            cell.avatarView.layer.cornerRadius = 10
            return cell
        }
    }
}

extension ChatRoomViewController: ChatRoomHeaderViewDelegate {
    func didPressCloseBtn(_ viewController: ChatRoomHeaderView, button: UIButton) {
        dismiss(animated: true)
    }
}

extension ChatRoomViewController: ChatRoomViewDelegate {
    func didSendCmt(_ view: ChatRoomView, msg: String) {
        Vibration.shared.lightV()

        if textAreaView.inputTextView.text.isEmpty == false {
            let postPath = self.db.collection("groups").document("\(groupID)").collection("messages").document()

            postPath.setData([
                "userID": "\(UserSetup.userID)",
                "messageID": "\(postPath.documentID)",
                "userAvatar": "\(UserSetup.userImage)",
                "timeStamp": Timestamp(date: Date()),
                "message": msg
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            textAreaView.inputTextView.text = ""
        }
    }
}
