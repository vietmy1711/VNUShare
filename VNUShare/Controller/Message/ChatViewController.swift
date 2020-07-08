//
//  ChatViewController.swift
//  VNUShare
//
//  Created by nam on 6/21/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import MessageKit

class ChatViewController: UIViewController {
    
    var messages: Messages?
    var isUser1: Bool = true
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let txvInput: UITextView = {
        let txvInput = UITextView()
        txvInput.backgroundColor = .systemGray6
        txvInput.layer.cornerRadius = 25
        txvInput.font = UIFont(name: "helvetica", size: 17)
        txvInput.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        txvInput.text = "Eneter message"
        txvInput.textColor = .lightGray
        txvInput.translatesAutoresizingMaskIntoConstraints = false
        return txvInput
    }()
    
    let btnSend: UIButton = {
        let btnSend = UIButton()
        btnSend.setImage(UIImage(systemName: "location.fill"), for: .normal)
        btnSend.tintColor = .systemPink
        btnSend.translatesAutoresizingMaskIntoConstraints = false
        return btnSend
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
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupUI(){
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 0).isActive = true
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
            textView.text = "Enter message"
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
                cell.configWithContent(messages!.content[indexPath.row])
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiveChatCell", for: indexPath) as! ReceiveChatCell
                cell.selectionStyle = .none
                cell.configWithContent(messages!.content[indexPath.row])
                return cell
            }
        }
        if messages!.sender[indexPath.row] == "user1" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiveChatCell", for: indexPath) as! ReceiveChatCell
            cell.selectionStyle = .none
            cell.configWithContent(messages!.content[indexPath.row])
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendChatCell", for: indexPath) as! SendChatCell
        cell.selectionStyle = .none
        cell.configWithContent(messages!.content[indexPath.row])
        return cell
    }
}
