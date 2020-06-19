//
//  SignUpViewController.swift
//  VNUShare
//
//  Created by MM on 4/19/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reenterPasswordTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var roleSegmentControl: UISegmentedControl!
    @IBOutlet weak var errorLabel: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        if let email = emailTextField.text,
            let password = passwordTextField.text,
            let reenterPassword = reenterPasswordTextField.text,
            let name = nameTextField.text,
            let number = phoneNumberTextField.text {
            //If password and reentered password match
            if fullCheck(email, password, reenterPassword, number) {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    
                    if let e = error {
                        let alert = UIAlertController(title: "Có lỗi đã xảy ra", message: e.localizedDescription, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Xác nhận", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    } else {
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = name
                        changeRequest?.commitChanges { (error) in
                            if let e = error {
                                print(e)
                            }	
                        }
                        var role = "Hành khách"
                        if self.roleSegmentControl.selectedSegmentIndex == 1 {
                            role = "Tài xế"
                        }
                        self.db.collection("users").addDocument(data: [
                            "email": email,
                            "fullname": name,
                            "phonenumber": number,
                            "role": role
                        ])
                        let alert = UIAlertController(title: "Đăng ký thành công", message: "Bạn có thể đăng nhập ngay bây giờ", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Xác nhận", style: .default, handler: { (_) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true)
                    }
                }
            } else {
                if !isValidEmail(email) {
                    DispatchQueue.main.async {
                        self.errorLabel.text = "Email không hợp lệ!"
                    }
                }
                if !isValidReenteredPassword(password, reenterPassword) {
                    DispatchQueue.main.async {
                        self.errorLabel.text = "Mật khẩu phải trùng nhau!"
                    }
                }
                if !isValidPhoneNumber(number) {
                    DispatchQueue.main.async {
                        self.errorLabel.text = "Số điện thoại không hợp lệ!"
                    }
                }
            }
        }
    }
    //MARK: - UPDATE ERROR MESSAGE
    @IBAction func reenteringPasswordError(_ sender: UITextField) {
        if let password = passwordTextField.text, let reenterPassword = reenterPasswordTextField.text {
            if !isValidReenteredPassword(password, reenterPassword) {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Mật khẩu phải trùng nhau!"
                }
            }
            else {
                DispatchQueue.main.async {
                    self.errorLabel.text = ""
                }
                
            }
        }
    }
    @IBAction func phoneNumberError(_ sender: UITextField) {
        if let number = phoneNumberTextField.text {
            if !isValidPhoneNumber(number) {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Số điện thoại không hợp lệ!"
                }
            }
            else {
                DispatchQueue.main.async {
                    self.errorLabel.text = ""
                }
                
            }
        }
    }
    
    @IBAction func emailError(_ sender: UITextField) {
        if let email = emailTextField.text {
            if !isValidEmail(email) {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Email không hợp lệ!"
                }
            }
            else {
                DispatchQueue.main.async {
                    self.errorLabel.text = ""
                }
            }
        }
    }
    //MARK: - INPUT VALIDATION
    func isValidReenteredPassword(_ string1: String, _ string2: String) -> Bool{
        if string1 != string2 {
            return false
        }
        return true
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidName(_ name: String) -> Bool {
        let RegEx = "\\w{7,18}"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: name)
    }
    
    func isValidPhoneNumber(_ number: String) -> Bool {
        let RegEx = "^0[3|5|7|8|9]\\d\\d\\d\\d\\d\\d\\d\\d$"
        let Test = NSPredicate(format: "SELF MATCHES %@", RegEx)
        return Test.evaluate(with: number)
    }
    
    func fullCheck(_ email: String, _ password: String, _ reenteredPassword: String, _ number: String) -> Bool {
        if isValidReenteredPassword(password, reenteredPassword) && isValidEmail(email) && isValidPhoneNumber(number) {
            return true
        }
        return false
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
