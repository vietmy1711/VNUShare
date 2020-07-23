//
//  ChangeInfoViewController.swift
//  VNUShare
//
//  Created by MM on 7/21/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

class ChangeInfoViewController: UIViewController {
    
    let keychain = KeychainSwift()
    
    var user: User? = nil
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var txfName: UITextField!
    @IBOutlet weak var txfPhonenumber: UITextField!
    @IBOutlet weak var txfPassword: UITextField!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    func setupUI() {
        txfName.text = user?.fullname
        txfPhonenumber.text = user?.phonenumber
        if user?.role == "Tài xế" {
            self.roleSegmentedControl.selectedSegmentIndex = 1
        }
        btnChange.layer.cornerRadius = 25
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func btnChangePressed(_ sender: UIButton) {
        if let name = txfName.text, let phonenumber = txfPhonenumber.text, let password = txfPassword.text {
            if fullCheck(name, phonenumber, password) == true {
                var role = "Hành khách"
                if roleSegmentedControl.selectedSegmentIndex == 1 {
                    role = "Tài xế"
                }
                db.collection("users").document(user!.uid).updateData([
                    "phonenumber": phonenumber,
                    "fullname": name,
                    "role": role
                ]) { (error) in
                    if let error = error {
                        let alert = UIAlertController(title: "Đã có lỗi xảy ra", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Thử lại sau", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.user?.fullname = name
                        self.user?.phonenumber = phonenumber
                        self.user?.role = role
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = name
                        changeRequest?.commitChanges { (error) in
                            if let e = error {
                                let alert = UIAlertController(title: "Đã có lỗi xảy ra", message: e.localizedDescription, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Thử lại sau", style: .cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                
                            } else {
                                let alert = UIAlertController(title: "Thành công", message: "Đã đổi thông tin thành công", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Xác nhận", style: .cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            } else {
                if !isValidName(name) {
                    lblError.text = "Tên không hợp lệ"
                } else if !isValidPhoneNumber(phonenumber) {
                    lblError.text = "Số điện thoại không hợp lệ"
                } else if !isValidPassword(password) {
                    lblError.text = "Mật khẩu không hợp lệ"
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func txfNameChange(_ sender: UITextField) {
        if let name = sender.text {
            if !isValidName(name) {
                lblError.text = "Tên không hợp lệ"
            } else {
                lblError.text = ""
            }
        }
    }
    
    @IBAction func txfPhoneChange(_ sender: UITextField) {
        if let phonenumber = sender.text {
            if !isValidPhoneNumber(phonenumber) {
                lblError.text = "Số điện thoại không hợp lệ"
            } else {
                lblError.text = ""
            }
        }
    }
    @IBAction func txfPasswordChange(_ sender: UITextField) {
        if let password = sender.text {
            if !isValidPassword(password) {
                lblError.text = "Mật khẩu không hợp lệ"
            } else {
                lblError.text = ""
            }
        }
    }
    
    //MARK: - INPUT VALIDATION
    func isValidPassword(_ password: String) -> Bool{
        if password != keychain.get("password") {
            return false
        }
        return true
    }
    
    func isValidName(_ name: String) -> Bool {
        if name == "" {
            return false
        }
        return true
    }
    
    func isValidPhoneNumber(_ number: String) -> Bool {
        let RegEx = "^0[3|5|7|8|9]\\d\\d\\d\\d\\d\\d\\d\\d$"
        let Test = NSPredicate(format: "SELF MATCHES %@", RegEx)
        return Test.evaluate(with: number)
    }
    
    func fullCheck(_ name: String, _ number: String, _ password: String) -> Bool {
        if isValidPassword(password) && isValidPhoneNumber(number) {
            return true
        }
        return false
    }
    
}
