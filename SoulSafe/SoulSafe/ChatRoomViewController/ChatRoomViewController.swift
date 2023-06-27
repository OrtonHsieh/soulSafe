//  ChatRoomViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/26.



import UIKit
import FirebaseFirestore
import IQKeyboardManagerSwift

class ChatRoomViewController: UIViewController {
    lazy var closeBtn = UIButton()
    lazy var chatTableView = UITableView()
    lazy var textAreaView = ChatRoomView()
    lazy var headerAreaView = ChatRoomHeaderView()
    
    var chats: [String] = []
    var userIDs: [String] = []
    // 這邊現在是存 local 的圖片字串，等個人頁做好後要改成上傳圖片
    var userAvatars: [String] = []
    
    var groupID = String()
    var listener: ListenerRegistration?
    var groupTitle = String()
    var keyboardHeightCons: NSLayoutConstraint?
    lazy var db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        setupView()
        getChats()
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
            print(self.chats)
            print(self.userIDs)
            print(self.userAvatars)
            self.scrollToNewCell()
        }
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
            cell.avatarView.image = UIImage(named: "\(userAvatars[indexPath.row])")
            cell.backgroundColor = UIColor(hex: CIC.shared.M1)
            cell.selectionStyle = .none
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



////
////  ChatRoomViewController.swift
////  SoulSafe
////
////  Created by 謝承翰 on 2023/6/26.
////
//
//import UIKit
//import FirebaseFirestore
//import IQKeyboardManagerSwift
//
//class ChatRoomViewController: UIViewController {
//    lazy var closeBtn = UIButton()
//    lazy var chatTableView = UITableView()
//    lazy var textAreaView = ChatRoomView()
//    lazy var headerAreaView = ChatRoomHeaderView()
//    lazy var chats: [String] = []
//    var userIDs: [String] = []
//    var groupID = String()
//    var listener: ListenerRegistration?
//    var groupTitle = String()
//    lazy var keyboardHeightCons = CGFloat()
//    lazy var db = Firestore.firestore()
//
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor(hex: CIC.shared.M1)
//        setupView()
//        getChats()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        IQKeyboardManager.shared.enableAutoToolbar = false
//        textAreaView.inputTextView.becomeFirstResponder()
//        // 在跑之前先 reloadData，若等到傳訊息時才 reload 則先前的畫面對話擺放位置會有誤（我傳的訊息跑到另一邊顯示）
//        self.chatTableView.reloadData()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        scrollToNewCell()
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        chats.removeAll()
//        IQKeyboardManager.shared.enableAutoToolbar = true
//        listener?.remove()
//    }
//
//    override func viewDidLayoutSubviews() {
//        chatTableView.layer.cornerRadius = 10
//        textAreaView.inputTextView.layer.cornerRadius = 10
//        headerAreaView.groupTitleLabel.layer.cornerRadius = 10
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    func setupView() {
//        [chatTableView, textAreaView, headerAreaView].forEach { view.addSubview($0) }
//
//        chatTableView.layer.borderColor = UIColor(hex: CIC.shared.F2).cgColor
//        chatTableView.backgroundColor = UIColor(hex: CIC.shared.M1)
//        chatTableView.layer.borderWidth = 1
//        chatTableView.separatorStyle = .none
//        chatTableView.delegate = self
//        chatTableView.dataSource = self
//        chatTableView.register(ChatRoomTableViewCell.self, forCellReuseIdentifier: "ChatRoomTableViewCell")
//        chatTableView.register(ChatRoomTableViewCellMine.self, forCellReuseIdentifier: "ChatRoomTableViewCellMine")
//
//        headerAreaView.delegate = self
//        headerAreaView.groupTitleLabel.text = groupTitle
//
//        textAreaView.delegate = self
//    }
//
//    func setupConstraints() {
//        [chatTableView, textAreaView, headerAreaView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
//
//        NSLayoutConstraint.activate([
//            headerAreaView.topAnchor.constraint(equalTo: view.topAnchor, constant: keyboardHeightCons),
//            headerAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            headerAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            headerAreaView.heightAnchor.constraint(equalToConstant: 76),
//
//            chatTableView.topAnchor.constraint(equalTo: headerAreaView.bottomAnchor),
//            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            chatTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
//
//            textAreaView.topAnchor.constraint(equalTo: chatTableView.bottomAnchor, constant: 24),
//            textAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            textAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//    }
//
//    func getChats() {
//        let chatRoomPath = db.collection("groups").document("\(groupID)").collection("messages").order(by: "timeStamp")
//
//        listener = chatRoomPath.addSnapshotListener { querySnapshot, error in
//            if let error = error {
//                print("Error fetching collection: \(error)")
//                return
//            }
//
//            guard let documents = querySnapshot?.documents else {
//                print("No documents in collection")
//                return
//            }
//
//            var index = 0
//            // 這邊之後要優化成只會拿新增的訊息，不要整包拿。如此就會直接 append 在最後，不用有判斷
//            for document in documents {
//                let data = document.data()
//                guard let message = data["message"] as? String else { return }
//                guard let userID = data["userID"] as? String else { return }
//
//                if index <= self.chats.count - 1 {
//                    self.chats[index] = message
//                    self.userIDs[index] = userID
//                } else {
//                    self.chats.append(message)
//                    self.userIDs.append(userID)
//                }
//                index += 1
//            }
//            self.scrollToNewCell()
//        }
//    }
//
//    func scrollToNewCell() {
//        self.chatTableView.reloadData()
//        // 這邊是為了讓沒有對話紀錄的群組跳過此 func 所設下的判斷
//        if chatTableView.numberOfRows(inSection: 0) != 0 {
//            let lastRow = chatTableView.numberOfRows(inSection: 0) - 1
//            let indexPath = IndexPath(row: lastRow, section: 0)
//            chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//        }
//    }
//
//    @objc func keyboardDidShow(_ notification: Notification) {
//        guard let userInfo = notification.userInfo else { return }
//
//        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//        let keyboardHeight = keyboardFrame?.height ?? 0
//
//        keyboardHeightCons = keyboardHeight
//
//        // Use the keyboardHeight value as needed
//        // For example, update your UI layout or scroll content to accommodate the keyboard
//
//        // After getting the keyboard height, you can remove the observer if it's no longer needed
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
//        setupConstraints()
//    }
//}
//
//extension ChatRoomViewController: UITableViewDelegate {
//}
//
//extension ChatRoomViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        chats.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if userIDs[indexPath.row] == UserSetup.userID {
//            guard let cell = tableView.dequeueReusableCell(
//                withIdentifier: "ChatRoomTableViewCellMine",
//                for: indexPath) as? ChatRoomTableViewCellMine else {
//                fatalError("fatal_error_message")
//            }
//
//            cell.msgLabel.text = chats[indexPath.row]
//            cell.msgView.layer.cornerRadius = 8
//            cell.backgroundColor = UIColor(hex: CIC.shared.M1)
//            cell.selectionStyle = .none
//            return cell
//        } else {
//            guard let cell = tableView.dequeueReusableCell(
//                withIdentifier: "ChatRoomTableViewCell",
//                for: indexPath) as? ChatRoomTableViewCell else {
//                fatalError("fatal_error_message")
//            }
//            cell.msgLabel.text = chats[indexPath.row]
//            cell.msgView.layer.cornerRadius = 8
//            cell.backgroundColor = UIColor(hex: CIC.shared.M1)
//            cell.selectionStyle = .none
//            return cell
//        }
//    }
//}
//
//extension ChatRoomViewController: ChatRoomHeaderViewDelegate {
//    func didPressCloseBtn(_ viewController: ChatRoomHeaderView, button: UIButton) {
//        dismiss(animated: true)
//    }
//}
//
//extension ChatRoomViewController: ChatRoomViewDelegate {
//    func didSendCmt(_ view: ChatRoomView, msg: String) {
//        Vibration.shared.lightV()
//
//        if textAreaView.inputTextView.text.isEmpty == false {
//            let postPath = self.db.collection("groups").document("\(groupID)").collection("messages").document()
//
//            postPath.setData([
//                "userID": "\(UserSetup.userID)",
//                "messageID": "\(postPath.documentID)",
//                "timeStamp": Timestamp(date: Date()),
//                "message": msg
//            ]) { err in
//                if let err = err {
//                    print("Error writing document: \(err)")
//                } else {
//                    print("Document successfully written!")
//                }
//            }
//            textAreaView.inputTextView.text = ""
//        }
//    }
//}
