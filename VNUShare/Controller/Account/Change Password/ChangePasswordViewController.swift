//
//  ChangePasswordViewController.swift
//  VNUShare
//
//  Created by MM on 7/21/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import KeychainSwift
import Firebase

class ChangePasswordViewController: UIViewController {
    
    let keychain = KeychainSwift()

    @IBOutlet weak var btnChangePassword: UIButton!
    @IBOutlet weak var txfLastPassword: UITextField!
    @IBOutlet weak var txfNewPassword: UITextField!
    @IBOutlet weak var txfReenterPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnChangePassword.layer.cornerRadius = 25
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func btnChangePasswordPressed(_ sender: UIButton) {
        if let lastPassword = txfLastPassword.text, let newPassword = txfNewPassword.text, let reenterPassword = txfReenterPassword.text {
            if lastPassword != keychain.get("password") {
                let alert = UIAlertController(title: "Sai mật khẩu cũ", message: "Mật khẩu cũ không trùng khớp, vui lòng kiếm tra lại", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Nhập lại", style: .default, handler: nil))
                self.present(alert, animated: true) {
                    return
                }
            }
            if reenterPassword != newPassword {
                let alert = UIAlertController(title: "Nhập lại không trùng khớp", message: "Mật khẩu nhập lại không trùng khớp, vui lòng kiểm tra lại", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Nhập lại", style: .default, handler: nil))
                self.present(alert, animated: true) {
                    return
                }
            }
            Auth.auth().currentUser?.updatePassword(to: newPassword) { (error) in
                if let e = error {
                    let alert = UIAlertController(title: "Đã có lỗi xảy ra", message: e.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Thử lại sau", style: .default, handler: nil))
                    self.present(alert, animated: true) {
                        return
                    }
                } else {
                    let alert = UIAlertController(title: "Thành công", message: "Đã đổi mật khẩu thành công", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Xác nhận", style: .default, handler: { (_) in
                        self.keychain.set(newPassword, forKey: "password")
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
