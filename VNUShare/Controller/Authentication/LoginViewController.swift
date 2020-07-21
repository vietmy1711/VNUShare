//
//  LoginViewController.swift
//  VNUShare
//
//  Created by MM on 4/19/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

class LoginViewController: UIViewController {
    let keychain = KeychainSwift()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLastUser()
//        emailTextField.text = "test2@gmail.com"
//        passwordTextField.text = "123456"
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        checkLoggedOn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLastUser()
        passwordTextField.text = ""
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func checkLastUser() {
        if let email = keychain.get("email") {
            emailTextField.text = email
        }
    }
    func checkLoggedOn() {
        if let email = keychain.get("email"), let password = keychain.get("password") {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    let alert = UIAlertController(title: "Có lỗi xảy ra", message: e.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Đăng nhập lại", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            }
        }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    let alert = UIAlertController(title: "Có lỗi xảy ra", message: e.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Đăng nhập lại", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.keychain.set(email, forKey: "email")
                    self.keychain.set(password, forKey: "password")
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            }
        }
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
