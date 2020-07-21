//
//  ChatViewController.swift
//  VNUShare
//
//  Created by nam on 6/21/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    var messagesId: String?
    
    var messages: Messages?
    
    var isUser1: Bool = true
    
    var imgAvatar: UIImage?
    
    let db = Firestore.firestore()
    
    var listener: ListenerRegistration?
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGray6
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let txvInput: UITextView = {
        let txv = UITextView()
        txv.backgroundColor = .systemGray6
        txv.layer.cornerRadius = 25
        txv.font = UIFont(name: "helvetica", size: 17)
        txv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        txv.text = "Nhập tin nhắn"
        txv.textColor = .lightGray
        txv.translatesAutoresizingMaskIntoConstraints = false
        return txv
    }()
    
    let btnSend: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "location.fill"), for: .normal)
        btn.tintColor = .systemPink
        btn.addTarget(self, action: #selector(btnSendTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        txvInput.delegate = self
        tableView.register(UINib(nibName: "SendChatCell", bundle: nil), forCellReuseIdentifier: "SendChatCell")
        tableView.register(UINib(nibName: "ReceiveChatCell", bundle: nil), forCellReuseIdentifier: "ReceiveChatCell")
        setupUI()
        listenForMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.remove()
    }
    
    func setupUI() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        stackView.addArrangedSubview(txvInput)
        txvInput.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        stackView.addArrangedSubview(btnSend)
        btnSend.widthAnchor.constraint(equalToConstant: 50).isActive = true
        btnSend.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    func listenForMessage() {
        listener = db.collection("messages").document(messagesId!)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                let content = document.get("content") as! [String]
                let sender = document.get("sender") as! [String]
                if content.count == sender.count {
                    self.messages?.content = content
                    self.messages?.sender = sender
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
        }
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            if self.messages!.content.count != 0 {
                let indexPath = IndexPath(row: self.messages!.content.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    @objc func btnSendTapped() {
        if txvInput.textColor != UIColor.lightGray {
            txvInput.text = txvInput.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            if txvInput.text != "" {
                let newMessage = txvInput.text
                var user = "user1"
                if isUser1 == false {
                    user = "user2"
                }
                self.messages?.content.append(newMessage!)
                self.messages?.sender.append(user)
                
                db.collection("messages").document(messagesId!).updateData([
                    "content": messages!.content,
                    "sender": messages!.sender,
                    "last": Date().timeIntervalSince1970
                ])
                txvInput.text = ""
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension ChatViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Nhập tin nhắn"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages!.content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isUser1 == true {
            if messages!.sender[indexPath.row] == "user1" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SendChatCell", for: indexPath) as! SendChatCell
                cell.selectionStyle = .none
                cell.backgroundColor = .clear
                cell.configWithContent(messages!.content[indexPath.row])
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiveChatCell", for: indexPath) as! ReceiveChatCell
                cell.selectionStyle = .none
                cell.backgroundColor = .clear
                if indexPath.row < messages!.sender.count - 1 {
                    if messages!.sender[indexPath.row] == messages!.sender[indexPath.row + 1] {
                        cell.configWithContent(messages!.content[indexPath.row], nil)
                    } else {
                        cell.configWithContent(messages!.content[indexPath.row], imgAvatar)
                    }
                } else {
                    cell.configWithContent(messages!.content[indexPath.row], imgAvatar)
                }
                return cell
            }
        }
        if messages!.sender[indexPath.row] == "user1" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiveChatCell", for: indexPath) as! ReceiveChatCell
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            if indexPath.row < messages!.sender.count - 1 {
                if messages!.sender[indexPath.row] == messages!.sender[indexPath.row + 1] {
                    cell.configWithContent(messages!.content[indexPath.row], nil)
                } else {
                    cell.configWithContent(messages!.content[indexPath.row], imgAvatar)
                }
            } else {
                cell.configWithContent(messages!.content[indexPath.row], imgAvatar)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendChatCell", for: indexPath) as! SendChatCell
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.configWithContent(messages!.content[indexPath.row])
        return cell
    }
}
