//
//  FirstViewController.swift
//  VNUShare
//
//  Created by MM on 4/10/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    let user = Auth.auth().currentUser!
    
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.nameLabel.text = "Hello, \(String(describing: self.user.displayName!))!"
        }
        
    }
    
    
}

