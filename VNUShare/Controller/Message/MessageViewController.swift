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
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let error = error {
                print(error)
            } else if let document = document {
                let fullname = document.get("fullname") as! String
                print(fullname)
            }
        }
    }
    func search() {
        users.removeAll()
        //        db.collection("users").getDocuments() { (querySnapshot, error) in
        //            if let error = error {
        //                print("Error getting documents: \(error)")
        //            } else {
        //                for document in querySnapshot!.documents {
        //                    let uid = document.documentID
        //                    let email = document.get("email") as! String
        //                    let fullname = document.get("fullname") as! String
        //                    let phonenumber = document.get("phonenumber") as! String
        //                    let role = document.get("role") as! String
        //                    let user = User(uid: uid, email: email, fullname: fullname, phonenumber: phonenumber, role: role)
        //                    self.users.append(user)
        //                    print(user)
        //                }
        //                self.tableView.reloadData()
        //            }
        //        }
        
        //lấy document của user hiện tại
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let document = document {
                    // get contacts về, contacts là một mảng string
                    let contacts = document.get("contacts") as! [String]
                    //với mỗi contacts
                    for contactUid in contacts {
                        //get thông tin của contact trong collection users
                        self.db.collection("users").document(contactUid).getDocument { (document, error) in
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
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = ChatViewController()
        db.collection("messsages").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let user1 = document.get("user1") as! String
                    let user2 = document.get("user2") as! String
                    if user1 == Auth.auth().currentUser!.uid || user2 == Auth.auth().currentUser!.uid {
                        if user1 == self.users[indexPath.row].uid || user2 == self.users[indexPath.row].uid {
                            let content = document.get("content") as! [String]
                            let sender = document.get("sender") as! [String]
                            let id = document.documentID
                            let messages = Messages(id: id, user1: user1, user2: user2, content: content, sender: sender)
                            if user2 == Auth.auth().currentUser!.uid {
                                chatVC.isUser1 = false
                            }
                            chatVC.messages = messages
                            chatVC.navigationItem.title = self.users[indexPath.row].fullname
                            self.navigationController?.pushViewController(chatVC, animated: true)
                        }
                    }
                }
            }
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.textLabel!.text = users[indexPath.row].fullname
        cell.selectionStyle = .none
        return cell
    }
    
}



