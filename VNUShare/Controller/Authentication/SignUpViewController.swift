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
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        if let email = emailTextField.text,
            let password = passwordTextField.text,
            let reenterPassword = reenterPasswordTextField.text,
            let name = nameTextField.text {
            //If password and reentered password match
            if fullCheck(email, password, reenterPassword) {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let e = error {
                        print(e)
                    } else {
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = name
                        changeRequest?.commitChanges { (error) in
                            if let e = error {
                                print(e)
                            }	
                        }
                        //Navigate to HomeViewController
                        self.performSegue(withIdentifier: "signUpSegue", sender: self)
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
    
    func fullCheck(_ email: String, _ password: String, _ reenteredPassword: String) -> Bool {
        if isValidReenteredPassword(password, reenteredPassword) && isValidEmail(email) {
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
