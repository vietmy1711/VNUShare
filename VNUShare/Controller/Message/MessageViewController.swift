//
//  SecondViewController.swift
//  VNUShare
//
//  Created by MM on 4/10/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import Firebase

class MessageViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var users: [User] = []
    
    var filteredUsers: [User] = []
    
    var messages: [Messages] = []
    
    var filterMessages: [Messages] = []
    
    var firstTime = true
    
    var cellRef: DocumentReference? = nil
    
    @IBOutlet var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        setupUI()
        search()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .systemPink
        tabBarController?.tabBar.isHidden = false
        firstTime = true
        filteredUsers = users
        filterMessages = messages
        tableView.reloadData()
    }
    
    func search() {
        
        db.collection("messages").addSnapshotListener { documentSnapshot, error in
            guard let documents = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            self.users.removeAll()
            self.messages.removeAll()
            for document in documents.documents {
                let user1 = document.get("user1") as! String
                let user2 = document.get("user2") as! String
                if user1 == Auth.auth().currentUser!.uid || user2 == Auth.auth().currentUser!.uid {
                    if user1 == Auth.auth().currentUser!.uid {
                        let content = document.get("content") as! [String]
                        let sender = document.get("sender") as! [String]
                        let lastNS = document.get("last") as! NSNumber
                        let last = lastNS.doubleValue
                        let id = document.documentID
                        let message = Messages(id: id, user1: user1, user2: user2, content: content, sender: sender, last: last)
                        if self.firstTime == true {
                            self.filterMessages.append(message)
                            self.filterMessages = self.filterMessages.sorted(by: {$0.last > $1.last})
                        }
                        self.messages.append(message)
                        self.messages = self.messages.sorted(by: {$0.last > $1.last})
                        
                        for _ in self.messages {
                            self.db.collection("users").document(user2).getDocument { (document, error) in
                                if let error = error {
                                    print(error)
                                } else if let document = document {
                                    let uid = document.documentID
                                    let email = document.get("email") as! String
                                    let fullname = document.get("fullname") as! String
                                    let phonenumber = document.get("phonenumber") as! String
                                    let role = document.get("role") as! String
                                    let pointsNS: NSNumber = document.get("points") as! NSNumber
                                    let points: Int = pointsNS.intValue
                                    let avatarData = document.get("avatar")
                                    let avatar = UIImage(data: avatarData as! Data)
                                    let user = User(uid: uid, email: email, fullname: fullname, phonenumber: phonenumber, role: role, points: points, avatar: avatar!)
                                    var isAlreadyExist = false
                                    for existingUser in self.users {
                                        if user.uid == existingUser.uid {
                                            isAlreadyExist = true
                                        }
                                    }
                                    if isAlreadyExist == false {
                                        if self.firstTime == true {
                                            self.filteredUsers.append(user)
                                        }
                                        self.users.append(user)
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    } else {
                        let content = document.get("content") as! [String]
                        let sender = document.get("sender") as! [String]
                        let lastNS = document.get("last") as! NSNumber
                        let last = lastNS.doubleValue
                        let id = document.documentID
                        let message = Messages(id: id, user1: user1, user2: user2, content: content, sender: sender, last: last)
                        if self.firstTime == true {
                            self.filterMessages.append(message)
                            self.filterMessages = self.filterMessages.sorted(by: {$0.last > $1.last})
                        }
                        self.messages.append(message)
                        self.messages = self.messages.sorted(by: {$0.last > $1.last})
                        
                        for _ in self.messages {
                            self.db.collection("users").document(user1).getDocument { (document, error) in
                                if let error = error {
                                    print(error)
                                } else if let document = document {
                                    let uid = document.documentID
                                    let email = document.get("email") as! String
                                    let fullname = document.get("fullname") as! String
                                    let phonenumber = document.get("phonenumber") as! String
                                    let role = document.get("role") as! String
                                    let pointsNS: NSNumber = document.get("points") as! NSNumber
                                    let points: Int = pointsNS.intValue
                                    let avatarData = document.get("avatar")
                                    let avatar = UIImage(data: avatarData as! Data)
                                    let user = User(uid: uid, email: email, fullname: fullname, phonenumber: phonenumber, role: role, points: points, avatar: avatar!)
                                    var isAlreadyExist = false
                                    for existingUser in self.users {
                                        if user.uid == existingUser.uid {
                                            isAlreadyExist = true
                                        }
                                    }
                                    if isAlreadyExist == false {
                                        if self.firstTime == true {
                                            self.filteredUsers.append(user)
                                        }
                                        self.users.append(user)
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
    }
    
}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = ChatViewController()
        
        chatVC.messages = filterMessages[indexPath.row]
        chatVC.messagesId = filterMessages[indexPath.row].id
        if messages[indexPath.row].user2 == Auth.auth().currentUser!.uid {
            chatVC.isUser1 = false
            self.db.collection("users").document(self.filterMessages[indexPath.row].user1).getDocument { (document, error) in
                if let error = error {
                    print(error)
                } else {
                    if let document = document {
                        let avatarData = document.get("avatar") as! Data
                        chatVC.imgAvatar = UIImage(data: avatarData)
                        for user in self.filteredUsers {
                            if user.uid == self.filterMessages[indexPath.row].user1 {
                                chatVC.navigationItem.title = user.fullname
                            }
                        }
                        self.navigationController?.pushViewController(chatVC, animated: true)
                    }
                }
            }
        } else {
            self.db.collection("users").document(self.filterMessages[indexPath.row].user2).getDocument { (document, error) in
                if let error = error {
                    print(error)
                } else {
                    if let document = document {
                        let avatarData = document.get("avatar") as! Data
                        chatVC.imgAvatar = UIImage(data: avatarData)
                        for user in self.filteredUsers {
                            if user.uid == self.filterMessages[indexPath.row].user2 {
                                chatVC.navigationItem.title = user.fullname
                            }
                        }
                        self.navigationController?.pushViewController(chatVC, animated: true)
                    }
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        if filterMessages.count != 0 {
            for user in filteredUsers {
                if filterMessages[indexPath.row].user1 == user.uid || filterMessages[indexPath.row].user2 == user.uid {
                    //                    cellRef = self.db.collection("users").document(user.uid)
                    //                    cellRef!.getDocument { (document, error) in
                    //                        if let error = error {
                    //                            print(error)
                    //                        } else if let document = document {
                    //                            let fullname = document.get("fullname") as! String
                    //
                    //                            let avatarData = document.get("avatar")
                    //                            let image = UIImage(data: avatarData as! Data)
                    //                            var senderName = user.fullname
                    //                            var sendUser = "user1"
                    //                            if self.filterMessages[indexPath.row].user2 == user.uid {
                    //                                sendUser = "user2"
                    //                            }
                    //                            if self.filterMessages[indexPath.row].sender.last != sendUser {
                    //                                senderName = "Bạn"
                    //                            }
                    //                            let lastMessage = self.filterMessages[indexPath.row].getLastestMessage(senderName)
                    //                            cell.configCell(avatar: image!, name: fullname, lastMessage: lastMessage)
                    //                        }
                    //                    }
                    var senderName = user.fullname
                    var sendUser = "user1"
                    if self.filterMessages[indexPath.row].user2 == user.uid {
                        sendUser = "user2"
                    }
                    if self.filterMessages[indexPath.row].sender.last != sendUser {
                        senderName = "Bạn"
                    }
                    let lastMessage = self.filterMessages[indexPath.row].getLastestMessage(senderName)
                    cell.configCell(avatar: user.avatar, name: user.fullname, lastMessage: lastMessage)
                }
            }
        }
        cell.selectionStyle = .none
        return cell
    }
}

extension MessageViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        cellRef = nil
        firstTime = false
        filteredUsers = users
        filterMessages = messages
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            filteredUsers = users
            filterMessages = messages
        } else {
            filteredUsers = users.filter {
                $0.fullname.range(of: searchText, options: .caseInsensitive) != nil
            }
            var diff: [User] = users
            for removeUser in filteredUsers {
                if let ix = find(diff, removeUser) {
                    diff.remove(at: ix)
                }
            }
            for message in filterMessages {
                for user in diff {
                    if message.user1 == user.uid || message.user2 == user.uid {
                        if let ix = find(filterMessages, message) {
                            filterMessages.remove(at: ix)
                        }
                    }
                }
            }
            print(filterMessages)
        }
        tableView.reloadData()
    }
    
    func find(_ array: [User],_ user: User) -> Int? {
        for n in 0..<array.count {
            if array[n].uid == user.uid {
                return n
            }
        }
        return nil
    }
    
    func find(_ array: [Messages],_ message: Messages) -> Int? {
        for n in 0..<array.count {
            if array[n].id == message.id {
                return n
            }
        }
        return nil
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        //        if firstTime == true {
        //
        //        }
        return true
    }
}

