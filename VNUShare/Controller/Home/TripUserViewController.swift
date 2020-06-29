//
//  TripUserViewController.swift
//  VNUShare
//
//  Created by MM on 6/22/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit

class TripUserViewController: UIViewController {

    var tripId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
}
