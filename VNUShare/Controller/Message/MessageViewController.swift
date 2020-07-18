//
//  SecondViewController.swift
//  VNUShare
//
//  Created by MM on 4/10/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import Firebase

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate {
    
    let db = Firestore.firestore()
    
    var users: [User] = []
    
    var messages: [Messages] = []
        
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
        tabBarController?.tabBar.isHidden = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        //            if let error = error {
        //                print(error)
        //            } else if let document = document {
        //                let fullname = document.get("fullname") as! String
        //                print(fullname)
        //            }
        //        }
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
                                    let user = User(uid: uid, email: email, fullname: fullname, phonenumber: phonenumber, role: role, points: points)
                                    self.users.append(user)

                                    self.tableView.reloadData()
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
                                    let user = User(uid: uid, email: email, fullname: fullname, phonenumber: phonenumber, role: role, points: points)
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
    
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = ChatViewController()
        
        chatVC.messages = messages[indexPath.row]
        chatVC.messagesId = messages[indexPath.row].id
        if messages[indexPath.row].user2 == Auth.auth().currentUser!.uid {
            chatVC.isUser1 = false
            self.db.collection("users").document(self.messages[indexPath.row].user1).getDocument { (document, error) in
                if let error = error {
                    print(error)
                } else {
                    if let document = document {
                        let avatarData = document.get("avatar") as! Data
                        chatVC.imgAvatar = UIImage(data: avatarData)
                        for user in self.users {
                            if user.uid == self.messages[indexPath.row].user1 {
                                chatVC.navigationItem.title = user.fullname
                            }
                        }
                        self.navigationController?.pushViewController(chatVC, animated: true)
                    }
                }
            }
        } else {
            self.db.collection("users").document(self.messages[indexPath.row].user2).getDocument { (document, error) in
                if let error = error {
                    print(error)
                } else {
                    if let document = document {
                        let avatarData = document.get("avatar") as! Data
                        chatVC.imgAvatar = UIImage(data: avatarData)
                        for user in self.users {
                            if user.uid == self.messages[indexPath.row].user2 {
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
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        for user in users {
            if messages[indexPath.row].user1 == user.uid || messages[indexPath.row].user2 == user.uid {
                self.db.collection("users").document(user.uid).getDocument { (document, error) in
                    if let error = error {
                        print(error)
                    } else if let document = document {
                        let fullname = document.get("fullname") as! String
                        
                        let avatarData = document.get("avatar")
                        let image = UIImage(data: avatarData as! Data)
                        var senderName = user.fullname
                        var sendUser = "user1"
                        if self.messages[indexPath.row].user2 == user.uid {
                            sendUser = "user2"
                        }
                        if self.messages[indexPath.row].sender.last != sendUser {
                            senderName = "Bạn"
                        }
                        let lastMessage = self.messages[indexPath.row].getLastestMessage(senderName)
                        cell.configCell(avatar: image!, name: fullname, lastMessage: lastMessage)
                    }
                }
            }
        }
        cell.selectionStyle = .none
        return cell
    }
}
